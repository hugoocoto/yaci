%option noyywrap
%option noinput
%option nounput

%{
#include "lit.h"
#include "ts.h"
#include "parser.tab.h"

extern TS_Entry* register_id();
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

/* id */
ID [[:alpha:]_][[:alnum:]_]* 

/* whitespace */
WS [ \t\f\r\v]+

/* Single Char Token */
SCT [+/*^(){}\[\];.,=-]

ASSERT "eq!"
AS "as"

TYPE_STR "str"
TYPE_NUM "num"

%%

{TYPE_NUM}  { yylval.type = NUM; return TYPE; }
{TYPE_STR}  { yylval.type = STR; return TYPE; }
{AS}        { return AS; }
{NUMBER}    { yylval.val = double_to_lit(strtod(yytext, NULL)); return NUM; }
{CHAR}      { yylval.val = double_to_lit(*yytext); return NUM; }
{STR}       { yylval.val = str_to_lit(strdup(yytext)); return NUM; }
{ID}        { yylval.tptr = register_id(); return VAR; }
{SCT}       { return *yytext; }
{ASSERT}    { return ASSERT; }
"\n"        { return '\n'; }
{WS}        { }
.           { printf("! Error: unknown token: %s\n", yytext); }

%%

#include <string.h>

int open_file(char *filename) 
{
    FILE* f = fopen(filename, "r");
    if (f == NULL) return 1;
    yyin = f;
    return 0;
}

void close_file() 
{
    if (yyin && fileno(yyin) != fileno(stdin)) {
        fclose(yyin);
        yyin = stdin;
    }
}

TS_Entry *register_id()
{
        TS_Entry *entry = ts_get(yytext);

        if (!entry) {
                ts_add(yytext, (TS_Entry) { .type = VAR, });
                entry = ts_get(yytext);
        }

        return entry;

}
