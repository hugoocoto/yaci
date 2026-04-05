%option noinput nounput noyywrap

%{
#include "lit.h"
#include "parser.tab.h"
#include "ts.h"

extern TS_Entry *register_id();
extern int verbose;
extern int yyerror(const char*, ...);
char **input_stream = NULL;
extern char *trim_right(char *c);

#define YY_INPUT(buf, result, max_size)                              \
{                                                                    \
        if (fileno(stdin) != fileno(yyin)) {                         \
                buf[0] = getc(yyin);                                 \
                if (buf[0] == EOF) {                                 \
                        goto stream_case;                            \
                }                                                    \
                if (verbose) putchar(buf[0]);                        \
                result = 1;                                          \
        } else {                                                     \
        stream_case:;                                                \
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

ERR_EXP ([eE][-+][-+]+{DECIMAL})|([eE][+-]?[^[:digit:]])
ERR_NUMBER {ERR_FLOAT}
ERR_FLOAT ("."{DECIMAL}{ERR_EXP}?)|({DECIMAL}{ERR_EXP})

/* chars (numbers) */
CHAR "'"[^']"'"
/* if it's not closed it raises unclosed string error */

/* strings */
STR {DQSTR}|{SQSTR}
SQSTR "'"{SQSTRCHR}*"'"
DQSTR "\""{DQSTRCHR}*"\""
SQSTRCHR {ESCSEQ}|[^\\'\n]
DQSTRCHR {ESCSEQ}|[^\\"\n]
ESCSEQ "\\"['"?\\0abfnrtv]

ERR_DQSTR "\""{DQSTRCHR}*\n
ERR_SQSTR "'"{SQSTRCHR}*\n

/* path -> start with ./ or between <> */
PATH ({PATH_START}{PATH_DIR}*{PATH_TEXT})|("<"{PATH_DIR}*{PATH_TEXT}">")
PATH_START ("."|"..")"/"
PATH_DIR ({PATH_TEXT}|"."|"..")"/"
PATH_TEXT [[:alnum:]_!@#$<>:|?*. -]+

/* booleans for commands */
TRUE ([Tt][Rr][Uu][Ee])|([Oo][Nn])|([Yy][Ee][Ss])
FALSE ([Ff][Aa][Ll][Ss][Ee])|([Oo][Ff][Ff])|([Nn][Oo])

/* id */
ID [[:alpha:]_][[:alnum:]_]* 

/* whitespace */
WS [ \f\r\t\v]+

/* Single Char Token */
SCT [+/*^(){}\[\];.,=`-]

/* alpha operators */
ASSERT "eq!"
AS "as"
CONST "const"
SILENT ("shh!")|(", but don't show any output")|(", but be quiet")
MINUS "minus"
PLUS "plus"
LET "let"
BE "be"

/* types */
TYPE_STR "str"
TYPE_NUM "num"
TYPE_LIST "list"

/* commands */
CLEAR [Cc][Ll][Ee][Aa][Rr]{PAR_OR_NOT}
QUIT (([Qq][Uu][Ii][Tt])|([Ee][Xx][Ii][Tt])){PAR_OR_NOT}
WORKSPACE [Ww]([Oo][Rr][Kk])?[Ss]([Pp][Aa][Cc][Ee])?{PAR_OR_NOT}
LOAD [Ll][Oo][Aa][Dd]
OPEN ([Oo][Pp][Ee][Nn])|([Ll][Ii][Nn][Kk])
VERBOSE [Vv][Ee][Rr][Bb][Oo][Ss][Ee]
ECHO [Ee][Cc][Hh][Oo]
HELP [Hh][Ee][Ll][Pp]{PAR_OR_NOT}

PAR_OR_NOT ("("{WS}?")")?

%%

{TYPE_NUM}  { yylval.type = NUM; return TYPE; }
{TYPE_STR}  { yylval.type = STR; return TYPE; }
{TYPE_LIST}  { yylval.type = LIST; return TYPE; }

{AS}        { return AS; }
{CLEAR}     { return CLEAR; }
{QUIT}      { return QUIT; }
{CONST}     { return CONST; }
{WORKSPACE} { return WORKSPACE; }
{LOAD}      { return LOAD; }
{ASSERT}    { return ASSERT; }
{VERBOSE}   { return VERBOSE; }
{ECHO}      { return T_ECHO; }
{OPEN}      { return OPEN; }
{HELP}      { return HELP; }

{TRUE}      { return TRUE; }
{FALSE}     { return FALSE; }

{LET}       { }
{BE}        { return '='; }
{SILENT}    { return ';'; }
{MINUS}     { return '-'; }
{PLUS}      { return '+'; }

{NUMBER}    { yylval.val = double_to_lit(strtod(yytext, NULL)); return NUM; }
{CHAR}      { yylval.val = double_to_lit(*yytext); return NUM; }
{STR}       { yylval.val = str_to_lit(strdup(yytext)); return STR; }
{PATH}      { yylval.val = str_to_lit(strdup(yytext)); return PATH; }
{ID}        { yylval.tptr = register_id(); return VAR; }
{SCT}       { return *yytext; }

"\n"        { return '\n'; }
{WS}        { }

.           { yyerror("Unknown token `%s`\n", yytext); }
{ERR_SQSTR} { yyerror("Unclosed string `%s`\n", trim_right(yytext)); }
{ERR_DQSTR} { yyerror("Unclosed string `%s`\n", trim_right(yytext)); }
{ERR_FLOAT} { yyerror("Malformed number `%s`\n", trim_right(yytext)); }

%%

#include <string.h>
#include <ctype.h>

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

char *trim_right(char *c){
    char* r = c + strlen(c) - 1;
    while(isspace(*r) && r >= c){
        *r = 0;
        --r;
    }
    return c;
}

/* get the entry in the symbol table. 
 * Add it if it's not there (key = yytext) */
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
