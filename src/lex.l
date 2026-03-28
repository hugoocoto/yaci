%option noyywrap
%option noinput
%option nounput

%{
#include "defs.h"
%}

/* numbers */
DECIMAL [[:digit:]]+
FLOAT (({DECIMAL}"."{DECIMAL}?|"."{DECIMAL}){EXP}?)|({DECIMAL}{EXP})
EXP [eE][-+]*{DECIMAL}

/* id */
ID [[:alpha:]_][[:alnum:]_]* 

/* whitespace */
WS [[:space:]]+

/* Single Char Token */
SCT [-+/*^(){}\[\];.,=]

%%

{DECIMAL}   { printf("+ Decimal: %s -- %d\n", yytext, TOK_DECIMAL); }
{FLOAT}     { printf("+ Float: %s -- %d\n", yytext, TOK_FLOAT); }
{ID}        { printf("+ Id: %s -- %d\n", yytext, TOK_ID); }
{SCT}       { printf("+ `%c`: %s -- %d\n", *yytext, yytext, *yytext); }
{WS}        { }
.           { printf("! Error: unknown token: %s\n", yytext); exit(1); }

%%


int open_file(char *filename) {
    FILE* f = fopen(filename, "r");
    if (f == NULL) return 1;
    yyin = f;
    return 0;
}

void close_file() {
    if (yyin && yyin != stdin) {
        fclose(yyin);
        yyin = stdin;
    }
}
