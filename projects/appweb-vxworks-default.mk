#
#   appweb-vxworks-default.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 5.6.2
PROFILE               ?= default
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*$(ME_ROOT_PREFIX)/')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ldundefined
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_CGI            ?= 0
ME_COM_COMPILER       ?= 1
ME_COM_DIR            ?= 0
ME_COM_EJS            ?= 0
ME_COM_ESP            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_LIB            ?= 1
ME_COM_LINK           ?= 1
ME_COM_MATRIXSSL      ?= 0
ME_COM_MBEDTLS        ?= 1
ME_COM_MDB            ?= 1
ME_COM_MPR            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 0
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_PHP            ?= 0
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 0
ME_COM_VXWORKS        ?= 0
ME_COM_WATCHDOG       ?= 1
ME_COM_ZLIB           ?= 0

ME_COM_OPENSSL_PATH   ?= "/usr/lib"

ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_LINK),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_MBEDTLS),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_ESP),1)
    ME_COM_MDB := 1
endif

export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)
CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h" $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_LINK=$(ME_COM_LINK) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MBEDTLS=$(ME_COM_MBEDTLS) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WATCHDOG=$(ME_COM_WATCHDOG) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -L$(BUILD)/bin
LIBS                  += -lgcc

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= deploy
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)
ME_DATA_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_STATE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_BIN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_INC_PREFIX         ?= $(ME_VAPP_PREFIX)/inc
ME_LIB_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_MAN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SBIN_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_ETC_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_WEB_PREFIX         ?= $(ME_VAPP_PREFIX)/web
ME_LOG_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SPOOL_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_CACHE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/src/$(NAME)-$(VERSION)

WEB_USER              ?= $(shell egrep 'www-data|_www|nobody' /etc/passwd | sed 's^:.*^^' |  tail -1)
WEB_GROUP             ?= $(shell egrep 'www-data|_www|nobody|nogroup' /etc/group | sed 's^:.*^^' |  tail -1)

TARGETS               += $(BUILD)/bin/appweb.out
TARGETS               += $(BUILD)/bin/authpass.out
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/appweb-esp.out
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/.extras-modified
endif
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += $(BUILD)/bin/http.out
endif
TARGETS               += $(BUILD)/.install-certs-modified
TARGETS               += $(BUILD)/bin/makerom.out
TARGETS               += src/server/cache
TARGETS               += $(BUILD)/bin/appman.out

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/appweb-vxworks-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/appweb-vxworks-default-me.h >/dev/null ; then\
		cp projects/appweb-vxworks-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build" ; \
			echo "   [Warning] Previous build command: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/appweb.o"
	rm -f "$(BUILD)/obj/authpass.o"
	rm -f "$(BUILD)/obj/cgiHandler.o"
	rm -f "$(BUILD)/obj/cgiProgram.o"
	rm -f "$(BUILD)/obj/config.o"
	rm -f "$(BUILD)/obj/convenience.o"
	rm -f "$(BUILD)/obj/esp.o"
	rm -f "$(BUILD)/obj/espHandler.o"
	rm -f "$(BUILD)/obj/espLib.o"
	rm -f "$(BUILD)/obj/http.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/makerom.o"
	rm -f "$(BUILD)/obj/mbedtls.o"
	rm -f "$(BUILD)/obj/mpr-mbedtls.o"
	rm -f "$(BUILD)/obj/mpr-openssl.o"
	rm -f "$(BUILD)/obj/mpr-version.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/openssl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/rom.o"
	rm -f "$(BUILD)/obj/watchdog.o"
	rm -f "$(BUILD)/bin/appweb.out"
	rm -f "$(BUILD)/bin/authpass.out"
	rm -f "$(BUILD)/bin/appweb-esp.out"
	rm -f "$(BUILD)/.extras-modified"
	rm -f "$(BUILD)/bin/http.out"
	rm -f "$(BUILD)/.install-certs-modified"
	rm -f "$(BUILD)/bin/libappweb.out"
	rm -f "$(BUILD)/bin/libesp.out"
	rm -f "$(BUILD)/bin/libhttp.out"
	rm -f "$(BUILD)/bin/libmbedtls.a"
	rm -f "$(BUILD)/bin/libmpr.out"
	rm -f "$(BUILD)/bin/libmpr-mbedtls.a"
	rm -f "$(BUILD)/bin/libmpr-version.a"
	rm -f "$(BUILD)/bin/libpcre.out"
	rm -f "$(BUILD)/bin/makerom.out"
	rm -f "$(BUILD)/bin/appman.out"

clobber: clean
	rm -fr ./$(BUILD)

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_1)

#
#   osdep.h
#
DEPS_2 += src/osdep/osdep.h
DEPS_2 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_3 += src/mpr/mpr.h
DEPS_3 += $(BUILD)/inc/me.h
DEPS_3 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_4 += src/http/http.h
DEPS_4 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/http/http.h $(BUILD)/inc/http.h

#
#   appweb.h
#
DEPS_5 += src/appweb.h
DEPS_5 += $(BUILD)/inc/osdep.h
DEPS_5 += $(BUILD)/inc/mpr.h
DEPS_5 += $(BUILD)/inc/http.h

$(BUILD)/inc/appweb.h: $(DEPS_5)
	@echo '      [Copy] $(BUILD)/inc/appweb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/appweb.h $(BUILD)/inc/appweb.h

#
#   customize.h
#
DEPS_6 += src/customize.h

$(BUILD)/inc/customize.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/customize.h'
	mkdir -p "$(BUILD)/inc"
	cp src/customize.h $(BUILD)/inc/customize.h

#
#   embedtls.h
#
DEPS_7 += src/mbedtls/embedtls.h

$(BUILD)/inc/embedtls.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/embedtls.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mbedtls/embedtls.h $(BUILD)/inc/embedtls.h

#
#   esp.h
#
DEPS_8 += src/esp/esp.h
DEPS_8 += $(BUILD)/inc/me.h
DEPS_8 += $(BUILD)/inc/osdep.h
DEPS_8 += $(BUILD)/inc/http.h

$(BUILD)/inc/esp.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/esp/esp.h $(BUILD)/inc/esp.h

#
#   mbedtls-config.h
#
DEPS_9 += src/mbedtls/mbedtls-config.h

$(BUILD)/inc/mbedtls-config.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/mbedtls-config.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mbedtls/mbedtls-config.h $(BUILD)/inc/mbedtls-config.h

#
#   mbedtls.h
#
DEPS_10 += src/mbedtls/mbedtls.h

$(BUILD)/inc/mbedtls.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/mbedtls.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mbedtls/mbedtls.h $(BUILD)/inc/mbedtls.h

#
#   mpr-version.h
#
DEPS_11 += src/mpr-version/mpr-version.h
DEPS_11 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/mpr-version.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/mpr-version.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mpr-version/mpr-version.h $(BUILD)/inc/mpr-version.h

#
#   pcre.h
#
DEPS_12 += src/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_12)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   server.c
#

src/server/cache/server.c: $(DEPS_13)

#
#   appweb.o
#
DEPS_14 += $(BUILD)/inc/appweb.h
DEPS_14 += src/server/cache/server.c

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_14)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c -o $(BUILD)/obj/appweb.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/server/appweb.c

#
#   authpass.o
#
DEPS_15 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c -o $(BUILD)/obj/authpass.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/utils/authpass.c

#
#   appweb.h
#

src/appweb.h: $(DEPS_16)

#
#   cgiHandler.o
#
DEPS_17 += src/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c -o $(BUILD)/obj/cgiHandler.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    test/cgiProgram.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c -o $(BUILD)/obj/cgiProgram.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" $(IFLAGS) test/cgiProgram.c

#
#   config.o
#
DEPS_19 += src/appweb.h
DEPS_19 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c -o $(BUILD)/obj/config.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_20 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c -o $(BUILD)/obj/convenience.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/convenience.c

#
#   esp.h
#

src/esp/esp.h: $(DEPS_21)

#
#   esp.o
#
DEPS_22 += src/esp/esp.h
DEPS_22 += $(BUILD)/inc/mpr-version.h

$(BUILD)/obj/esp.o: \
    src/esp/esp.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c -o $(BUILD)/obj/esp.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/esp/esp.c

#
#   espHandler.o
#
DEPS_23 += src/appweb.h
DEPS_23 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/modules/espHandler.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c -o $(BUILD)/obj/espHandler.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/modules/espHandler.c

#
#   espLib.o
#
DEPS_24 += src/esp/esp.h
DEPS_24 += $(BUILD)/inc/pcre.h
DEPS_24 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/esp/espLib.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c -o $(BUILD)/obj/espLib.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/esp/espLib.c

#
#   http.h
#

src/http/http.h: $(DEPS_25)

#
#   http.o
#
DEPS_26 += src/http/http.h

$(BUILD)/obj/http.o: \
    src/http/http.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/http/http.c

#
#   httpLib.o
#
DEPS_27 += src/http/http.h
DEPS_27 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/http/httpLib.c

#
#   makerom.o
#
DEPS_28 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/makerom.o: \
    src/makerom/makerom.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c -o $(BUILD)/obj/makerom.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/makerom/makerom.c

#
#   mbedtls.h
#

src/mbedtls/mbedtls.h: $(DEPS_29)

#
#   mbedtls.o
#
DEPS_30 += src/mbedtls/mbedtls.h

$(BUILD)/obj/mbedtls.o: \
    src/mbedtls/mbedtls.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/mbedtls.o'
	$(CC) -c -o $(BUILD)/obj/mbedtls.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/mbedtls/mbedtls.c

#
#   mpr-mbedtls.o
#
DEPS_31 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/mpr-mbedtls.o: \
    src/mpr-mbedtls/mpr-mbedtls.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/mpr-mbedtls.o'
	$(CC) -c -o $(BUILD)/obj/mpr-mbedtls.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/mpr-mbedtls/mpr-mbedtls.c

#
#   mpr-openssl.o
#
DEPS_32 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/mpr-openssl.o: \
    src/mpr-openssl/mpr-openssl.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/mpr-openssl.o'
	$(CC) -c -o $(BUILD)/obj/mpr-openssl.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" $(IFLAGS) src/mpr-openssl/mpr-openssl.c

#
#   mpr-version.h
#

src/mpr-version/mpr-version.h: $(DEPS_33)

#
#   mpr-version.o
#
DEPS_34 += src/mpr-version/mpr-version.h
DEPS_34 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/mpr-version.o: \
    src/mpr-version/mpr-version.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/mpr-version.o'
	$(CC) -c -o $(BUILD)/obj/mpr-version.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" $(IFLAGS) src/mpr-version/mpr-version.c

#
#   mpr.h
#

src/mpr/mpr.h: $(DEPS_35)

#
#   mprLib.o
#
DEPS_36 += src/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/mpr/mprLib.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/mpr/mprLib.c

#
#   openssl.o
#
DEPS_37 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/openssl.o: \
    src/mpr-openssl/openssl.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/openssl.o'
	$(CC) -c -o $(BUILD)/obj/openssl.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" $(IFLAGS) src/mpr-openssl/openssl.c

#
#   pcre.h
#

src/pcre/pcre.h: $(DEPS_38)

#
#   pcre.o
#
DEPS_39 += $(BUILD)/inc/me.h
DEPS_39 += src/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/pcre/pcre.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" $(IFLAGS) src/pcre/pcre.c

#
#   rom.o
#
DEPS_40 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/rom.o: \
    src/rom.c $(DEPS_40)
	@echo '   [Compile] $(BUILD)/obj/rom.o'
	$(CC) -c -o $(BUILD)/obj/rom.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/rom.c

#
#   watchdog.o
#
DEPS_41 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/watchdog.o: \
    src/watchdog/watchdog.c $(DEPS_41)
	@echo '   [Compile] $(BUILD)/obj/watchdog.o'
	$(CC) -c -o $(BUILD)/obj/watchdog.o $(CFLAGS) -DME_DEBUG=1 -DVXWORKS -DRW_MULTI_THREAD -DCPU=PENTIUM -DTOOL_FAMILY=gnu -DTOOL=gnu -D_GNU_TOOL -D_WRS_KERNEL_ -D_VSB_CONFIG_FILE=\"/WindRiver/vxworks-7/samples/prebuilt_projects/vsb_vxsim_linux/h/config/vsbConfig.h\" -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/watchdog/watchdog.c

ifeq ($(ME_COM_MBEDTLS),1)
#
#   libmbedtls
#
DEPS_42 += $(BUILD)/inc/osdep.h
DEPS_42 += $(BUILD)/inc/embedtls.h
DEPS_42 += $(BUILD)/inc/mbedtls-config.h
DEPS_42 += $(BUILD)/inc/mbedtls.h
DEPS_42 += $(BUILD)/obj/mbedtls.o

$(BUILD)/bin/libmbedtls.a: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libmbedtls.a'
	arundefined -cr $(BUILD)/bin/libmbedtls.a "$(BUILD)/obj/mbedtls.o"
endif

ifeq ($(ME_COM_MBEDTLS),1)
#
#   libmpr-mbedtls
#
DEPS_43 += $(BUILD)/bin/libmbedtls.a
DEPS_43 += $(BUILD)/obj/mpr-mbedtls.o

$(BUILD)/bin/libmpr-mbedtls.a: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libmpr-mbedtls.a'
	arundefined -cr $(BUILD)/bin/libmpr-mbedtls.a "$(BUILD)/obj/mpr-mbedtls.o"
endif

ifeq ($(ME_COM_OPENSSL),1)
#
#   libmpr-openssl
#
DEPS_44 += $(BUILD)/obj/mpr-openssl.o
DEPS_44 += $(BUILD)/obj/openssl.o

$(BUILD)/bin/libmpr-openssl.a: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/libmpr-openssl.a'
	arundefined -cr $(BUILD)/bin/libmpr-openssl.a "$(BUILD)/obj/mpr-openssl.o" "$(BUILD)/obj/openssl.o"
endif

ifeq ($(ME_COM_SSL),1)
ifeq ($(ME_COM_OPENSSL),1)
#
#   openssl
#
ifeq ($(ME_COM_OPENSSL),1)
    DEPS_45 += $(BUILD)/bin/libmpr-openssl.a
endif
DEPS_45 += $(BUILD)/obj/mpr-openssl.o
DEPS_45 += $(BUILD)/obj/openssl.o

$(BUILD)/bin/libmpr-openssl.a: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/libmpr-openssl.a'
	arundefined -cr $(BUILD)/bin/libmpr-openssl.a "$(BUILD)/obj/mpr-openssl.o" "$(BUILD)/obj/openssl.o"
endif
endif

#
#   libmpr
#
DEPS_46 += $(BUILD)/inc/osdep.h
ifeq ($(ME_COM_MBEDTLS),1)
    DEPS_46 += $(BUILD)/bin/libmpr-mbedtls.a
endif
ifeq ($(ME_COM_MBEDTLS),1)
    DEPS_46 += $(BUILD)/bin/libmbedtls.a
endif
ifeq ($(ME_COM_SSL),1)
ifeq ($(ME_COM_OPENSSL),1)
    DEPS_46 += $(BUILD)/bin/libmpr-openssl.a
endif
endif
DEPS_46 += $(BUILD)/inc/mpr.h
DEPS_46 += $(BUILD)/obj/mprLib.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_46 += -lssl
    LIBPATHS_46 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_46 += -lcrypto
    LIBPATHS_46 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libmpr.out: $(DEPS_46)
	@echo '      [Link] $(BUILD)/bin/libmpr.out'
	$(CC) -r -o $(BUILD)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/mprLib.o" -lmpr-mbedtls -lmbedtls $(LIBPATHS_46) $(LIBS_46) $(LIBS_46) $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_47 += $(BUILD)/inc/pcre.h
DEPS_47 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.out: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/libpcre.out'
	$(CC) -r -o $(BUILD)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_48 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_PCRE),1)
    DEPS_48 += $(BUILD)/bin/libpcre.out
endif
DEPS_48 += $(BUILD)/inc/http.h
DEPS_48 += $(BUILD)/obj/httpLib.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_48 += -lssl
    LIBPATHS_48 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_48 += -lcrypto
    LIBPATHS_48 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libhttp.out: $(DEPS_48)
	@echo '      [Link] $(BUILD)/bin/libhttp.out'
	$(CC) -r -o $(BUILD)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/httpLib.o" $(LIBPATHS_48) $(LIBS_48) $(LIBS_48) $(LIBS) -lmpr-mbedtls -lmbedtls 
endif

#
#   libmpr-version
#
DEPS_49 += $(BUILD)/inc/mpr-version.h
DEPS_49 += $(BUILD)/obj/mpr-version.o

$(BUILD)/bin/libmpr-version.a: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/libmpr-version.a'
	arundefined -cr $(BUILD)/bin/libmpr-version.a "$(BUILD)/obj/mpr-version.o"

ifeq ($(ME_COM_ESP),1)
#
#   libesp
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_50 += $(BUILD)/bin/libhttp.out
endif
DEPS_50 += $(BUILD)/bin/libmpr-version.a
DEPS_50 += $(BUILD)/inc/esp.h
DEPS_50 += $(BUILD)/obj/espLib.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_50 += -lssl
    LIBPATHS_50 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_50 += -lcrypto
    LIBPATHS_50 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libesp.out: $(DEPS_50)
	@echo '      [Link] $(BUILD)/bin/libesp.out'
	$(CC) -r -o $(BUILD)/bin/libesp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/espLib.o" -lmpr-version $(LIBPATHS_50) $(LIBS_50) $(LIBS_50) $(LIBS) -lmpr-mbedtls -lmbedtls 
endif

#
#   libappweb
#
ifeq ($(ME_COM_ESP),1)
    DEPS_51 += $(BUILD)/bin/libesp.out
endif
ifeq ($(ME_COM_HTTP),1)
    DEPS_51 += $(BUILD)/bin/libhttp.out
endif
DEPS_51 += $(BUILD)/bin/libmpr.out
DEPS_51 += $(BUILD)/inc/appweb.h
DEPS_51 += $(BUILD)/inc/customize.h
DEPS_51 += $(BUILD)/obj/config.o
DEPS_51 += $(BUILD)/obj/convenience.o
DEPS_51 += $(BUILD)/obj/rom.o
DEPS_51 += $(BUILD)/obj/cgiHandler.o
DEPS_51 += $(BUILD)/obj/espHandler.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_51 += -lssl
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_51 += -lcrypto
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libappweb.out: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/libappweb.out'
	$(CC) -r -o $(BUILD)/bin/libappweb.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o" "$(BUILD)/obj/rom.o" "$(BUILD)/obj/cgiHandler.o" "$(BUILD)/obj/espHandler.o" $(LIBPATHS_51) $(LIBS_51) $(LIBS_51) $(LIBS) -lmpr-version -lmpr-mbedtls -lmbedtls 

#
#   appweb
#
DEPS_52 += $(BUILD)/bin/libappweb.out
DEPS_52 += $(BUILD)/obj/appweb.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_52 += -lssl
    LIBPATHS_52 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_52 += -lcrypto
    LIBPATHS_52 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/appweb.out: $(DEPS_52)
	@echo '      [Link] $(BUILD)/bin/appweb.out'
	$(CC) -o $(BUILD)/bin/appweb.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/appweb.o" $(LIBPATHS_52) $(LIBS_52) $(LIBS_52) $(LIBS) -lmpr-version -lmpr-mbedtls -lmbedtls -Wl,-r 

#
#   authpass
#
DEPS_53 += $(BUILD)/bin/libappweb.out
DEPS_53 += $(BUILD)/obj/authpass.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_53 += -lssl
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_53 += -lcrypto
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/authpass.out: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/authpass.out'
	$(CC) -o $(BUILD)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) -lmpr-version -lmpr-mbedtls -lmbedtls -Wl,-r 

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_54 += $(BUILD)/bin/libesp.out
DEPS_54 += $(BUILD)/obj/esp.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_54 += -lssl
    LIBPATHS_54 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_54 += -lcrypto
    LIBPATHS_54 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/appweb-esp.out: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/appweb-esp.out'
	$(CC) -o $(BUILD)/bin/appweb-esp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_54) $(LIBS_54) $(LIBS_54) $(LIBS) -lmpr-version -lmpr-mbedtls -lmbedtls -Wl,-r 
endif

ifeq ($(ME_COM_ESP),1)
#
#   extras
#
DEPS_55 += src/esp/esp-compile.json
DEPS_55 += src/esp/vcvars.bat

$(BUILD)/.extras-modified: $(DEPS_55)
	@echo '      [Copy] $(BUILD)/bin'
	mkdir -p "$(BUILD)/bin"
	cp src/esp/esp-compile.json $(BUILD)/bin/esp-compile.json
	cp src/esp/vcvars.bat $(BUILD)/bin/vcvars.bat
	touch "$(BUILD)/.extras-modified"
endif

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_56 += $(BUILD)/bin/libhttp.out
DEPS_56 += $(BUILD)/obj/http.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_56 += -lssl
    LIBPATHS_56 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_56 += -lcrypto
    LIBPATHS_56 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/http.out: $(DEPS_56)
	@echo '      [Link] $(BUILD)/bin/http.out'
	$(CC) -o $(BUILD)/bin/http.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/http.o" $(LIBPATHS_56) $(LIBS_56) $(LIBS_56) $(LIBS) -lmpr-mbedtls -lmbedtls -Wl,-r 
endif

#
#   installPrep
#

installPrep: $(DEPS_57)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with sudo." ; \
	exit 255 ; \
	fi

#
#   install-certs
#
DEPS_58 += src/certs/samples/ca.crt
DEPS_58 += src/certs/samples/ca.key
DEPS_58 += src/certs/samples/ec.crt
DEPS_58 += src/certs/samples/ec.key
DEPS_58 += src/certs/samples/roots.crt
DEPS_58 += src/certs/samples/self.crt
DEPS_58 += src/certs/samples/self.key
DEPS_58 += src/certs/samples/test.crt
DEPS_58 += src/certs/samples/test.key

$(BUILD)/.install-certs-modified: $(DEPS_58)
	@echo '      [Copy] $(BUILD)/bin'
	mkdir -p "$(BUILD)/bin"
	cp src/certs/samples/ca.crt $(BUILD)/bin/ca.crt
	cp src/certs/samples/ca.key $(BUILD)/bin/ca.key
	cp src/certs/samples/ec.crt $(BUILD)/bin/ec.crt
	cp src/certs/samples/ec.key $(BUILD)/bin/ec.key
	cp src/certs/samples/roots.crt $(BUILD)/bin/roots.crt
	cp src/certs/samples/self.crt $(BUILD)/bin/self.crt
	cp src/certs/samples/self.key $(BUILD)/bin/self.key
	cp src/certs/samples/test.crt $(BUILD)/bin/test.crt
	cp src/certs/samples/test.key $(BUILD)/bin/test.key
	touch "$(BUILD)/.install-certs-modified"

#
#   makerom
#
DEPS_59 += $(BUILD)/bin/libmpr.out
DEPS_59 += $(BUILD)/obj/makerom.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_59 += -lssl
    LIBPATHS_59 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_59 += -lcrypto
    LIBPATHS_59 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/makerom.out: $(DEPS_59)
	@echo '      [Link] $(BUILD)/bin/makerom.out'
	$(CC) -o $(BUILD)/bin/makerom.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/makerom.o" $(LIBPATHS_59) $(LIBS_59) $(LIBS_59) $(LIBS) -lmpr-mbedtls -lmbedtls -Wl,-r 

#
#   server-cache
#

src/server/cache: $(DEPS_60)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)

ifeq ($(ME_COM_WATCHDOG),1)
#
#   watchdog
#
DEPS_61 += $(BUILD)/bin/libmpr.out
DEPS_61 += $(BUILD)/obj/watchdog.o

ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_61 += -lssl
    LIBPATHS_61 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_61 += -lcrypto
    LIBPATHS_61 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/appman.out: $(DEPS_61)
	@echo '      [Link] $(BUILD)/bin/appman.out'
	$(CC) -o $(BUILD)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/watchdog.o" -lmpr-mbedtls -lmbedtls $(LIBPATHS_61) $(LIBS_61) $(LIBS_61) $(LIBS) -Wl,-r 
endif

#
#   installBinary
#

installBinary: $(DEPS_62)

#
#   install
#
DEPS_63 += installPrep
DEPS_63 += compile
DEPS_63 += stop
DEPS_63 += installBinary
DEPS_63 += start

install: $(DEPS_63)

#
#   run
#
DEPS_64 += compile

run: $(DEPS_64)
	( \
	cd src/server; \
	../../$(BUILD)/bin/appweb --log stdout:2 ; \
	)

#
#   uninstall
#
DEPS_65 += stop

uninstall: $(DEPS_65)
	( \
	cd installs; \
	rm -f "$(ME_VAPP_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_VAPP_PREFIX)/esp.conf" ; \
	rm -f "$(ME_VAPP_PREFIX)/mine.types" ; \
	rm -f "$(ME_VAPP_PREFIX)/install.conf" ; \
	rm -fr "$(ME_VAPP_PREFIX)/inc/appweb" ; \
	)

#
#   uninstallBinary
#

uninstallBinary: $(DEPS_66)

#
#   version
#

version: $(DEPS_67)
	echo $(VERSION)

