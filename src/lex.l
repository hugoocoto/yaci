%option noinput nounput noyywrap

%{
#include "lit.h"
#include "parser.tab.h"
#include "ts.h"

extern TS_Entry *register_id();
extern int verbose;
char **input_stream = NULL;

#define YY_INPUT(buf, result, max_size)                              \
{                                                                    \
        if (fileno(stdin) != fileno(yyin)) {                         \
                buf[0] = getc(yyin); /* Todo: improve this */        \
                if (buf[0] == EOF) {                                 \
                        goto stream_case;                            \
                };                                                   \
                if (verbose) putchar(buf[0]);                        \
                result = 1;                                          \
        } else {                                                     \
        stream_case:                                                 \
                char *segment = input_stream ? *input_stream : NULL; \
                if (segment == NULL)                                 \
                        result = 0;                                  \
                else if (*segment == 0) {                            \
                        buf[0] = '\n';                               \
                        result = 1;                                  \
                        *input_stream = NULL;                        \
                } else {                                             \
                        size_t avail = strnlen(segment, max_size);   \
                        memcpy(buf, segment, avail);                 \
                        *input_stream += avail;                      \
                        result = avail;                              \
                }                                                    \
        }                                                            \
}

%}

/* numbers */
NUMBER {DECIMAL}|{FLOAT}|"NAN"|"INF"
DECIMAL [[:digit:]]+
FLOAT (({DECIMAL}"."{DECIMAL}?|"."{DECIMAL}){EXP}?)|({DECIMAL}{EXP})
EXP [eE][-+]?{DECIMAL}

/* chars (numbers) */
CHAR "'"[^']"'"

/* strings */
STR {DQSTR}|{SQSTR}
SQSTR "'"{STRCHR}*"'"
DQSTR "\""{STRCHR}*"\""
STRCHR {ESCSEQ}|[^\\"\n]
ESCSEQ "\\"['"?\\0abfnrtv]

/* path -> start with ./ or between <> */
PATH ({PATH_START}{PATH_DIR}*{PATH_TEXT})|("<"{PATH_DIR}*{PATH_TEXT}">")
PATH_START ("."|"..")"/"
PATH_DIR ({PATH_TEXT}|"."|"..")"/"
PATH_TEXT [^/[:space:]]+

/* id */
ID [[:alpha:]_][[:alnum:]_]* 

/* whitespace */
WS [ \f\r\t\v]+

/* Single Char Token */
SCT [+/*^(){}\[\];.,=-]

/* alpha operators */
ASSERT "eq!"
AS "as"
CONST "const"

/* types */
TYPE_STR "str"
TYPE_NUM "num"

/* commands */
CLEAR [Cc][Ll][Ee][Aa][Rr]{PAR_OR_NOT}
QUIT (([Qq][Uu][Ii][Tt])|([Ee][Xx][Ii][Tt])){PAR_OR_NOT}
WORKSPACE [Ww]([Oo][Rr][Kk])?[Ss]([Pp][Aa][Cc][Ee])?{PAR_OR_NOT}
LOAD [Ll][Oo][Aa][Dd]

PAR_OR_NOT ("("[[:space:]]*")")?

%%

{TYPE_NUM}  { yylval.type = NUM; return TYPE; }
{TYPE_STR}  { yylval.type = STR; return TYPE; }
{AS}        { return AS; }
{CLEAR}     { return CLEAR; }
{QUIT}      { return QUIT; }
{CONST}     { return CONST; }
{WORKSPACE} { return WORKSPACE; }
{LOAD}      { return LOAD; }
{ASSERT}    { return ASSERT; }
{NUMBER}    { yylval.val = double_to_lit(strtod(yytext, NULL)); return NUM; }
{CHAR}      { yylval.val = double_to_lit(*yytext); return NUM; }
{STR}       { yylval.val = str_to_lit(strdup(yytext)); return STR; }
{PATH}      { printf("PATH=%s\n", yytext); yylval.val = str_to_lit(strdup(yytext)); return PATH; }
{ID}        { yylval.tptr = register_id(); return VAR; }
{SCT}       { return *yytext; }
"\n"        { return '\n'; }
{WS}        { }
.           { printf("! Error: unknown token: `%s`\n", yytext); }

%%

#include <string.h>

int open_file(char *filename) 
{
    if (filename == NULL) {
        yyin = stdin;
        return 0;
    }
    FILE* f = fopen(filename, "r");
    if (f == NULL) return 1;
    yyin = f;
    return 0;
}

void close_file() 
{
    if (fileno(yyin) != fileno(stdin)) {
        fclose(yyin);
    }
    yyin = stdin;
}

TS_Entry *register_id()
{
        TS_Entry *entry = ts_get(yytext);
        if (!entry) {
                ts_add(yytext, (TS_Entry) { 
                    .type = VAR, 
                    .value = str_to_lit(strdup(yytext)),
                });
                entry = ts_get(yytext);
        }
        return entry;
}
