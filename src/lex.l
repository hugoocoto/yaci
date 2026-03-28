%option noyywrap
%option noinput
%option nounput

%{
#include "./parser.tab.h"
%}

/* numbers */
DECIMAL [[:digit:]]+
FLOAT (({DECIMAL}"."{DECIMAL}?|"."{DECIMAL}){EXP}?)|({DECIMAL}{EXP})
EXP [eE][-+]?{DECIMAL}

/* id */
ID [[:alpha:]_][[:alnum:]_]* 

/* whitespace */
WS [[:space:]]+

/* Single Char Token */
SCT [-+/*^(){}\[\];.,=]

%%

{DECIMAL}   { yylval.val = (double)atoi(yytext); return NUM; }
{FLOAT}     { yylval.val = (double)atof(yytext); return NUM; }
{ID}        { return VAR; }
{SCT}       { return *yytext; }
{WS}        { }
.           { printf("! Error: unknown token: %s\n", yytext); }

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
