%option noyywrap
%option noinput
%option nounput

%{
#include "parser.tab.h"
#include "ts.h"

extern TS_Entry* register_id();
%}

/* numbers */
NUMBER {DECIMAL}|{FLOAT}|"NAN"|"INF"
DECIMAL [[:digit:]]+
FLOAT (({DECIMAL}"."{DECIMAL}?|"."{DECIMAL}){EXP}?)|({DECIMAL}{EXP})
EXP [eE][-+]?{DECIMAL}

/* id */
ID [[:alpha:]_][[:alnum:]_]* 

/* whitespace */
WS [ \t\f\r\v]+

/* Single Char Token */
SCT [+/*^(){}\[\];.,=-]

%%

{NUMBER}    { yylval.val = strtod(yytext, NULL); return NUM; }
{ID}        { yylval.tptr = register_id(); return VAR; }
{SCT}       { return *yytext; }
{WS}        { }
"\n"        { return '\n'; }
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
    if (yyin && yyin != stdin) {
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
