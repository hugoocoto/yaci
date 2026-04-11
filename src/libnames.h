#ifdef __GLIBC__
#include <gnu/lib-names.h>
#endif

#ifndef LD_LINUX_X86_64_SO
#define LD_LINUX_X86_64_SO yytext
#endif

#ifndef LD_SO
#define LD_SO yytext
#endif

#ifndef LIBANL_SO
#define LIBANL_SO yytext
#endif

#ifndef LIBBROKENLOCALE_SO
#define LIBBROKENLOCALE_SO yytext
#endif

#ifndef LIBC_MALLOC_DEBUG_SO
#define LIBC_MALLOC_DEBUG_SO yytext
#endif

#ifndef LIBC_SO
#define LIBC_SO yytext
#endif

#ifndef LIBDL_SO
#define LIBDL_SO yytext
#endif

#ifndef LIBGCC_S_SO
#define LIBGCC_S_SO yytext
#endif

#ifndef LIBMVEC_SO
#define LIBMVEC_SO yytext
#endif

#ifndef LIBM_SO
#define LIBM_SO yytext
#endif

#ifndef LIBNSL_SO
#define LIBNSL_SO yytext
#endif

#ifndef LIBNSS_COMPAT_SO
#define LIBNSS_COMPAT_SO yytext
#endif

#ifndef LIBNSS_DB_SO
#define LIBNSS_DB_SO yytext
#endif

#ifndef LIBNSS_DNS_SO
#define LIBNSS_DNS_SO yytext
#endif

#ifndef LIBNSS_FILES_SO
#define LIBNSS_FILES_SO yytext
#endif

#ifndef LIBNSS_HESIOD_SO
#define LIBNSS_HESIOD_SO yytext
#endif

#ifndef LIBNSS_LDAP_SO
#define LIBNSS_LDAP_SO yytext
#endif

#ifndef LIBPTHREAD_SO
#define LIBPTHREAD_SO yytext
#endif

#ifndef LIBRESOLV_SO
#define LIBRESOLV_SO yytext
#endif

#ifndef LIBRT_SO
#define LIBRT_SO yytext
#endif

#ifndef LIBTHREAD_DB_SO
#define LIBTHREAD_DB_SO yytext
#endif

#ifndef LIBUTIL_SO
#define LIBUTIL_SO yytext
#endif


#define X(name, lib)                                                     \
        if (!strcmp(name, yytext)) {                                     \
                yylval.val = str_to_lit(strdup(lib));                    \
                if (verbose) yyhint("Using `" name "` is not portable"); \
                return PATH;                                             \
        }

#define LIST_OF_UNSECURE_SYSTEM_LIBS()              \
        X("math.h", LIBM_SO)                        \
        X("ld.h", LD_SO)                            \
        X("anl.h", LIBANL_SO)                       \
        X("brokenlocale.h", LIBBROKENLOCALE_SO)     \
        X("c_malloc_debug.h", LIBC_MALLOC_DEBUG_SO) \
        X("c.h", LIBC_SO)                           \
        X("dl.h", LIBDL_SO)                         \
        X("gcc_s.h", LIBGCC_S_SO)                   \
        X("mvec.h", LIBMVEC_SO)                     \
        X("nsl.h", LIBNSL_SO)                       \
        X("nss_compat.h", LIBNSS_COMPAT_SO)         \
        X("nss_db.h", LIBNSS_DB_SO)                 \
        X("nss_dns.h", LIBNSS_DNS_SO)               \
        X("nss_files.h", LIBNSS_FILES_SO)           \
        X("nss_hesiod.h", LIBNSS_HESIOD_SO)         \
        X("nss_ldap.h", LIBNSS_LDAP_SO)             \
        X("pthread.h", LIBPTHREAD_SO)               \
        X("resolv.h", LIBRESOLV_SO)                 \
        X("rt.h", LIBRT_SO)                         \
        X("thread_db.h", LIBTHREAD_DB_SO)           \
        X("util.h", LIBUTIL_SO)
