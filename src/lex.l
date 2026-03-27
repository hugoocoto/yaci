%option noyywrap
%option noinput
%option nounput

/* numbers */
DECIMAL [[:digit:]]+
FLOAT (({DECIMAL}"."{DECIMAL}?|"."{DECIMAL}){EXP}?)|({DECIMAL}{EXP})
EXP [eE][-+]*{DECIMAL}

/* id */
ID [[:alpha:]_][[:alphanum:]-_]* 

/* whitespace */
WS [[:space:]]+

%%

{DECIMAL}   { printf("+ Decimal: %s\n", yytext); }
{FLOAT}     { printf("+ Float: %s\n", yytext); }
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
