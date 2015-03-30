/*
    sslModule.c - Module for SSL support
    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************* Includes ***********************************/

#include    "appweb.h"

#if ME_COM_SSL
/*********************************** Code *************************************/

static void checkSsl(MaState *state)
{
    HttpRoute   *route, *parent;
    
    route = state->route;
    parent = route->parent;

    if (route->ssl == 0) {
        if (parent && parent->ssl) {
            route->ssl = mprCloneSsl(parent->ssl);
        } else {
            route->ssl = mprCreateSsl(1);
        }
    } else {
        if (parent && route->ssl == parent->ssl) {
            route->ssl = mprCloneSsl(parent->ssl);
        }
    }
}


static int sslCaCertificatePathDirective(MaState *state, cchar *key, cchar *value)
{
    char *path;
    
    if (!maTokenize(state, value, "%P", &path)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    checkSsl(state);
    if (!mprPathExists(path, R_OK)) {
        mprLog("error ssl", 0, "Cannot locate %s", path);
        return MPR_ERR_CANT_FIND;
    }
    mprSetSslCaPath(state->route->ssl, path);
    return 0;
}


static int sslCaCertificateFileDirective(MaState *state, cchar *key, cchar *value)
{
    char *path;
    
    if (!maTokenize(state, value, "%P", &path)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    checkSsl(state);
    if (!mprPathExists(path, R_OK)) {
        mprLog("error ssl", 0, "Cannot locate %s", path);
        return MPR_ERR_CANT_FIND;
    }
    mprSetSslCaFile(state->route->ssl, path);
    return 0;
}


static int sslCertificateFileDirective(MaState *state, cchar *key, cchar *value)
{
    char *path;
    
    if (!maTokenize(state, value, "%P", &path)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    checkSsl(state);
    if (!mprPathExists(path, R_OK)) {
        mprLog("error ssl", 0, "Cannot locate %s", path);
        return MPR_ERR_CANT_FIND;
    }
    mprSetSslCertFile(state->route->ssl, path);
    return 0;
}


static int sslCertificateKeyFileDirective(MaState *state, cchar *key, cchar *value)
{
    char *path;
    
    if (!maTokenize(state, value, "%P", &path)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    checkSsl(state);
    if (!mprPathExists(path, R_OK)) {
        mprLog("error ssl", 0, "Cannot locate %s", path);
        return MPR_ERR_CANT_FIND;
    }
    mprSetSslKeyFile(state->route->ssl, path);
    return 0;
}


static int sslCipherSuiteDirective(MaState *state, cchar *key, cchar *value)
{
    checkSsl(state);
    mprAddSslCiphers(state->route->ssl, value);
    return 0;
}


/*
    SSLProvider [provider]
 */
static int sslProviderDirective(MaState *state, cchar *key, cchar *value)
{
    char    *provider;

    if (!maTokenize(state, value, "?S", &provider)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    checkSsl(state);
    mprSetSslProvider(state->route->ssl, provider);
    return 0;
}


/*
    SSLEngine on [provider]
 */
static int sslEngineDirective(MaState *state, cchar *key, cchar *value)
{
    char    *provider;
    bool    on;

    if (!maTokenize(state, value, "%B ?S", &on, &provider)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    if (on) {
        checkSsl(state);
        mprSetSslProvider(state->route->ssl, provider);
        if (!state->host->secureEndpoint) {
            if (httpSecureEndpointByName(state->host->name, state->route->ssl) < 0) {
                mprLog("error ssl", 0, "No HttpEndpoint at %s to secure. Must use inside a VirtualHost block", state->host->name);
                return MPR_ERR_BAD_STATE;
            }
        }
    }
    return 0;
}


/*
    SSLVerifyClient [on|off]
    DEPRECATED: SSLVerifyClient [none|require]
 */
static int sslVerifyClientDirective(MaState *state, cchar *key, cchar *value)
{
    bool    on;

    on = 0;
    checkSsl(state);
    if (scaselesscmp(value, "require") == 0) {
        on = 1;

    } else if (scaselesscmp(value, "none") == 0) {
        on = 0;

    } else {
        if (!maTokenize(state, value, "%B", &on)) {
            return MPR_ERR_BAD_SYNTAX;
        }
    }
    mprVerifySslPeer(state->route->ssl, on);
    return 0;
}


/*
    SSLVerifyDepth N
 */
static int sslVerifyDepthDirective(MaState *state, cchar *key, cchar *value)
{
    checkSsl(state);
    mprVerifySslDepth(state->route->ssl, (int) stoi(value));
    return 0;
}


/*
    SSLVerifyIssuer [on|off]
 */
static int sslVerifyIssuerDirective(MaState *state, cchar *key, cchar *value)
{
    bool    on;

    checkSsl(state);
    if (!maTokenize(state, value, "%B", &on)) {
        return MPR_ERR_BAD_SYNTAX;
    }
    mprVerifySslIssuer(state->route->ssl, on);
    return 0;
}


/*
    SSLProtocol [+|-] protocol
 */
static int sslProtocolDirective(MaState *state, cchar *key, cchar *value)
{
    char    *word, *tok;
    int     mask, protoMask;

    checkSsl(state);
    protoMask = 0;
    word = stok(sclone(value), " \t", &tok);
    while (word) {
        mask = -1;
        if (*word == '-') {
            word++;
            mask = 0;
        } else if (*word == '+') {
            word++;
        }
        if (scaselesscmp(word, "SSLv2") == 0) {
            protoMask &= ~(MPR_PROTO_SSLV2 & ~mask);
            protoMask |= (MPR_PROTO_SSLV2 & mask);

        } else if (scaselesscmp(word, "SSLv3") == 0) {
            protoMask &= ~(MPR_PROTO_SSLV3 & ~mask);
            protoMask |= (MPR_PROTO_SSLV3 & mask);

        } else if (scaselesscmp(word, "TLSv1") == 0) {
            /* Enable or disable all of TLS 1.X */
            protoMask &= ~(MPR_PROTO_TLSV1 & ~mask);
            protoMask |= (MPR_PROTO_TLSV1 & mask);

        } else if (scaselesscmp(word, "TLSv1.1") == 0) {
            protoMask &= ~(MPR_PROTO_TLSV1_1 & ~mask);
            protoMask |= (MPR_PROTO_TLSV1_1 & mask);

        } else if (scaselesscmp(word, "TLSv1.2") == 0) {
            protoMask &= ~(MPR_PROTO_TLSV1_2 & ~mask);
            protoMask |= (MPR_PROTO_TLSV1_2 & mask);

        } else if (scaselesscmp(word, "ALL") == 0) {
            protoMask &= ~(MPR_PROTO_ALL & ~mask);
            protoMask |= (MPR_PROTO_ALL & mask);
        }
        word = stok(0, " \t", &tok);
    }
    mprSetSslProtocols(state->route->ssl, protoMask);
    return 0;
}


/*
    Loadable module initialization. 
 */
PUBLIC int httpSslInit(Http *http, MprModule *module)
{
    HttpStage   *stage;

    if ((stage = httpCreateStage("sslModule", HTTP_STAGE_MODULE, module)) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    maAddDirective("SSLEngine", sslEngineDirective);
    maAddDirective("SSLCACertificateFile", sslCaCertificateFileDirective);
    maAddDirective("SSLCACertificatePath", sslCaCertificatePathDirective);
    maAddDirective("SSLCertificateFile", sslCertificateFileDirective);
    maAddDirective("SSLCertificateKeyFile", sslCertificateKeyFileDirective);
    maAddDirective("SSLCipherSuite", sslCipherSuiteDirective);
    maAddDirective("SSLProtocol", sslProtocolDirective);
    maAddDirective("SSLProvider", sslProviderDirective);
    maAddDirective("SSLVerifyClient", sslVerifyClientDirective);
    maAddDirective("SSLVerifyIssuer", sslVerifyIssuerDirective);
    maAddDirective("SSLVerifyDepth", sslVerifyDepthDirective);
#if ME_STATIC
    /*
        Pull in the libmprssl code at link time.
     */
    extern MprModuleEntry mprSslInit;
    mprNop(mprSslInit);
#endif
    return 0;
}
#endif /* ME_COM_SSL */

/*
    @copy   default

    Copyright (c) Embedthis Software. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
