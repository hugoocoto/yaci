%option noinput nounput noyywrap

%{
#include "lit.h"
#include "parser.tab.h"
#include "ts.h"

#include "libnames.h"

int include_depth = 0;
#define MAX_INCLUDE_DEPH 600

extern int verbose;
extern TS_Entry *register_id();
extern int yyerror(const char*, ...);
extern int yyhint(const char*, ...);
extern char *trim_right(char *c);
extern char *trim_chars(char *s, char *cs);

DA(const char*) queue = {0};
void q_push(const char *c) { da_append(&queue, (c)); }
void q_pop() { da_remove(&queue, queue.count - 1); }
const char* q_top() { return queue.data[queue.count - 1]; }

void yy_init_queue(){
    q_push(OWNER_REPL); set_owner(q_top());
}

__attribute__((destructor)) void free_queue(){
    da_destroy(&queue);
}

%}

COMMENT {SL_COMMENT}
SL_COMMENT ("#"|"//")[^\n]*[\n]

/* numbers */
DECIMAL [[:digit:]]+
FLOAT (({DECIMAL}"."{DECIMAL}?|"."{DECIMAL}){EXP}?)|({DECIMAL}{EXP})|"NAN"|"INF"
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

/* path -> start with ./ or between <> or xxx.xx */
PATH {REL_PATH}|{C_PATH}|{DOT_PATH}

REL_PATH {PATH_START}{PATH_DIR}*{PATH_TEXT}
C_PATH "<"{PATH_DIR}*{PATH_TEXT}">"
DOT_PATH {PATH_DIR}*{PATH_TEXT}"."[[:alnum:]]+

PATH_START ("."|"..")"/"
PATH_DIR ({PATH_TEXT}|"."|"..")"/"
PATH_TEXT [[:alnum:]_!@#$<>:|?*.-]+

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
TYPE_NUM "num"|"float"
TYPE_DEC "dec"|"int"
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
{COMMENT}   { return '\n'; }

{TYPE_NUM}  { yylval.type = NUM; return TYPE; }
{TYPE_DEC}  { yylval.type = DEC; return TYPE; }
{TYPE_STR}  { yylval.type = STR; return TYPE; }
{TYPE_LIST} { yylval.type = LIST; return TYPE; }

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

{FLOAT}     { yylval.val = double_to_lit(strtod(yytext, NULL)); return NUM; }
    /* decimals are floats by default. Because math functions expects doubles */
{DECIMAL}   { yylval.val = double_to_lit(strtod(yytext, NULL)); return NUM; }
{CHAR}      { yylval.val = int_to_lit(*yytext); return DEC; }

{STR}       { yylval.val = str_to_lit(strdup(trim_chars(yytext, "\""))); return STR; }
{PATH}      { LIST_OF_UNSECURE_SYSTEM_LIBS();
              yylval.val = str_to_lit(strdup(trim_chars(yytext, "\"<>"))); 
              return PATH; 
            }
{ID}        { yylval.tptr = register_id(); return VAR; }
{SCT}       { return *yytext; }

"\n"        { return '\n'; }
{WS}        { }

.           { yyerror("Unknown token `%s`\n", yytext); }
{ERR_SQSTR} { yyerror("Unclosed string `%s`\n", trim_right(yytext)); }
{ERR_DQSTR} { yyerror("Unclosed string `%s`\n", trim_right(yytext)); }
{ERR_FLOAT} { yyerror("Malformed number `%s`\n", trim_right(yytext)); }

<<EOF>> {
    if (include_depth > 0) {
        q_pop(); set_owner(q_top());
        include_depth--;
        yypop_buffer_state();
        if (!YY_CURRENT_BUFFER) {
            q_push(OWNER_REPL);
            yyterminate();
        }
    } else {
        q_push(OWNER_REPL);
        yyterminate();
    }
}
%%

#include <string.h>
#include <ctype.h>

int open_file(char *filename) 
{
    if (filename == NULL) return 0;

    FILE* f = fopen(filename, "r");
    if (f == NULL) return 1;

    q_push(strdup(filename)); set_owner(q_top());

    YY_BUFFER_STATE file_buffer = yy_create_buffer(f, YY_BUF_SIZE);
    yypush_buffer_state(file_buffer);

    include_depth++; 
    if (include_depth >= MAX_INCLUDE_DEPH){
        yyerror("Recursion detected on load");
        if (verbose) yyhint("Check that there isn't a load-loop");
        exit(1);
    }

    return 0;
}

char *trim_chars(char *s, char *cs){
    for (int i = 0; cs[i]; i++){
        char* r = s + strlen(s) - 1;
        while(r != s-1 && *r == cs[i]){
            *r = 0;
            --r;
        }
        while (*s == cs[i]) {
            ++s;
        }
    }
    return s;
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
