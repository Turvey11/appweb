/*
    edi.h -- Embedded Database Interface (EDI).

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

#ifndef _h_EDI
#define _h_EDI 1

/********************************* Includes ***********************************/

#include    "appweb.h"

#if BLD_FEATURE_EDI || 1

#ifdef __cplusplus
extern "C" {
#endif

/****************************** Forward Declarations **************************/

#if !DOXYGEN
#endif

/********************************** Tunables **********************************/
/*
   Field data types
 */
#define EDI_TYPE_BLOB       1
#define EDI_TYPE_BOOL       2
#define EDI_TYPE_DATE       3
#define EDI_TYPE_FLOAT      4
#define EDI_TYPE_INT        5
#define EDI_TYPE_STRING     6       /* String is UTF-8 */
#define EDI_TYPE_TEXT       7

/*
    Column options
 */
#define EDI_NOT_NULL        0x1     /**< Value cannot be null */
#define EDI_AUTO_INC        0x2     /**< Field auto increments on new row */
#define EDI_KEY             0x4     /**< Column is the key */
#define EDI_INDEX           0x8     /**< Column is indexed */
 
struct Edi;
struct EdiGrid;
struct EdiProvider;
struct EdiRec;

typedef bool (*EdiValidate)(struct EdiRec *rec);

typedef union EdiValue {
    cchar       *blob;
    cchar       *str;
    int64       inum;
    double      num;
    MprTime     date;
    bool        boolean;
} EdiValue;

typedef struct EdiField {
    EdiValue        value;
    cchar           *name;
    int             type:  8;
    int             valid: 8;
    int             flags: 8;
} EdiField;

typedef struct EdiRec {
    struct Edi      *edi;
    MprList         *errors;
    cchar           *tableName;
    cchar           *id;                    /**<  Record ID */
    int             nfields;
    EdiField        fields[MPR_FLEX];
} EdiRec;

typedef struct EdiGrid {
    struct Edi      *edi;
    cchar           *tableName;
    int             nrecords;
    EdiRec          *records[MPR_FLEX];
} EdiGrid;

/*
    Database flags
 */
#define EDI_CREATE         0x1          /**< Create database if not present */
#define EDI_AUTO_SAVE      0x2          /**< Auto-save database if modified in memory */
#define EDI_SUPPRESS_SAVE  0x4          /**< Temporarily suppress auto-save */

/*
    Set flags
 */
#define EDI_NOSAVE      0x1

typedef struct Edi {
    struct EdiProvider *provider;
    int             flags;          /**< Database flags */
} Edi;

typedef struct EdiProvider {
    cchar     *name;
    int       (*addColumn)(Edi *edi, cchar *tableName, cchar *columnName, int type, int flags);
    int       (*addIndex)(Edi *edi, cchar *tableName, cchar *columnName, cchar *indexName);
    int       (*addTable)(Edi *edi, cchar *tableName);
    int       (*changeColumn)(Edi *edi, cchar *tableName, cchar *columnName, int type, int flags);
    void      (*close)(Edi *edi);
    int       (*delete)(Edi *edi, cchar *path);
    int       (*deleteRow)(Edi *edi, cchar *tableName, cchar *key);
    EdiGrid   *(*getAll)(Edi *edi, cchar *tableName);
    MprList   *(*getColumns)(Edi *edi, cchar *tableName);
    EdiField  (*getField)(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName);
    EdiRec    *(*getRec)(Edi *edi, cchar *tableName, cchar *key);
    int       (*getSchema)(Edi *edi, cchar *tableName, cchar *columnName, int *type, int *flags);
    MprList   *(*getTables)(Edi *edi);
    int       (*load)(Edi *edi, cchar *path);
    int       (*lookupField)(Edi *edi, cchar *tableName, cchar *fieldName);
    Edi       *(*open)(cchar *path, int flags);
    EdiGrid   *(*query)(Edi *edi, cchar *cmd);
    int       (*removeColumn)(Edi *edi, cchar *tableName, cchar *columnName);
    int       (*removeIndex)(Edi *edi, cchar *tableName, cchar *indexName);
    int       (*removeTable)(Edi *edi, cchar *tableName);
    int       (*renameTable)(Edi *edi, cchar *tableName, cchar *newTableName);
    int       (*renameColumn)(Edi *edi, cchar *tableName, cchar *columnName, cchar *newColumnName);
    int       (*setField)(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName, cchar *value, int flags);
    int       (*setRec)(Edi *edi, cchar *tableName, cchar *key, MprHash *params);
    int       (*save)(Edi *edi);
} EdiProvider;

typedef struct EdiService {
    MprHash    *providers;
    MprHash    *validations;
} EdiService;

extern EdiService *ediCreateService();
extern void ediAddProvider(EdiProvider *provider);
extern void ediAddValidation(cchar *name, void *validation);


/*
    Provider wrapped calls
 */
extern int ediAddColumn(Edi *edi, cchar *tableName, cchar *columnName, int type, int flags);
extern int ediAddIndex(Edi *edi, cchar *tableName, cchar *columnName, cchar *indexName);
extern int ediAddTable(Edi *edi, cchar *tableName);
extern int ediChangeColumn(Edi *edi, cchar *tableName, cchar *columnName, int type, int flags);
extern void ediClose(Edi *edi);
extern int ediDelete(Edi *edi, cchar *path);
extern int ediDeleteRow(Edi *edi, cchar *tableName, cchar *key);
extern MprList *ediGetColumns(Edi *edi, cchar *tableName);

extern EdiRec *ediGetRec(Edi *edi, cchar *tableName, cchar *key);
extern EdiGrid *ediGetAll(Edi *edi, cchar *tableName);
//  MOB - should key be after fieldName?
extern EdiField ediGetField(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName);

extern int ediGetSchema(Edi *edi, cchar *tableName, cchar *columName, int *type, int *flags);
extern MprList *ediGetTables(Edi *edi);
extern int ediLoad(Edi *edi, cchar *path);
extern int ediLookupField(Edi *edi, cchar *tableName, cchar *fieldName);
extern Edi *ediOpen(cchar *provider, cchar *path, int flags);
extern EdiGrid *ediQuery(Edi *edi, cchar *cmd);
extern int edRemoveColumn(Edi *edi, cchar *tableName, cchar *columnName);
extern int ediRemoveIndex(Edi *edi, cchar *tableName, cchar *indexName);
extern int ediRemoveTable(Edi *edi, cchar *tableName);
extern int ediRenameTable(Edi *edi, cchar *tableName, cchar *newTableName);
extern int ediRenameColumn(Edi *edi, cchar *tableName, cchar *columnName, cchar *newColumnName);
extern int ediSetField(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName, cchar *value, int flags);
extern int ediSetRec(Edi *edi, cchar *tableName, cchar *key, MprHash *params);
extern int ediSave(Edi *edi);


/*
    Convenience Routines
 */
extern int ediGetDbFlags(Edi *edi);
extern EdiGrid *ediGetWhere(Edi *edi, cchar *tableName, cchar *expression);
extern EdiRec  *ediGetOneWhere(Edi *edi, cchar *tableName, cchar *expression);

//  MOB - rethink API
extern cchar *ediGetFieldAsString(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName, cchar *fmt, cchar *defaultValue);

extern EdiGrid *ediMakeGrid(cchar *str);
extern MprList *ediGetErrors(EdiRec *rec);
extern void ediSetDbFlags(Edi *edi, int flags);
extern cchar *ediToString(cchar *fmt, EdiField value);
extern bool edValidateRecord(EdiRec *rec);

//  MOB - position of fmt
extern cchar *ediGetRecFieldAsString(EdiRec *rec, cchar *fieldName, cchar *fmt);
extern EdiField ediGetRecField(EdiRec *rec, cchar *fieldName);

extern int ediGetRecFieldType(EdiRec *rec, cchar *fieldName);
extern MprList *ediGetGridColumns(EdiGrid *grid);


/*
    Support routines for providers
 */
extern EdiGrid *ediCreateGrid(Edi *edi, cchar *tableName, int nrows);
extern EdiRec *ediCreateRec(Edi *edi, cchar *tableName, cchar *id, int nfields, EdiField *fields);
extern char *ediGetTypeString(int type);
extern void ediManageEdiRec(EdiRec *rec, int flags);
extern int ediParseTypeString(cchar *type);
extern EdiValue ediParseValue(cchar *value, int type);

//  MOB
#if BLD_FEATURE_MDB || 1
extern void mdbInit();
#endif

#if BLD_FEATURE_SDB && 0
extern void sdbInit();
#endif

#ifdef __cplusplus
} /* extern C */
#endif

#endif /* BLD_FEATURE_EDI */
#endif /* _h_EDI */

/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2011. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the GPL open source license described below or you may acquire
    a commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.TXT distributed with
    this software for full details.

    This software is open source; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version. See the GNU General Public License for more
    details at: http: *www.embedthis.com/downloads/gplLicense.html

    This program is distributed WITHOUT ANY WARRANTY; without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    This GPL license does NOT permit incorporating this software into
    proprietary programs. If you are unable to comply with the GPL, you must
    acquire a commercial license to use this software. Commercial licenses
    for this software and support services are available from Embedthis
    Software at http: *www.embedthis.com

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */

