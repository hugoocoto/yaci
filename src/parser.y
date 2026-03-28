%{
#include <math.h>
#include <stdio.h>
#include "ts.h"

extern void yyerror (char *);
extern int yylex();
%}

%union {
double val;
struct TS_Entry *tptr;
}

%token <val> NUM        
%token <tptr> VAR FNCT 

%type <val> exp

%right '='
%left '-' '+'
%left '*' '/'
%left NEG
%right '^'

%%

input: line 
    | input line 
    ;

line: exp echo { printf("%g\n", $1); }
    | error { }
    ;

echo: ';' 
    ;

exp: 
    NUM { $$ = $1; }
    | VAR { $$ = $1->as.value; }
    | VAR '=' exp { $$ = $3; $1->as.value = $3; }
    | FNCT '(' exp ')' { $$ = (*($1->as.ptr))($3); }
    | exp '+' exp { $$ = $1 + $3; }
    | exp '-' exp { $$ = $1 - $3; }
    | exp '*' exp { $$ = $1 * $3; }
    | exp '/' exp { $$ = $1 / $3; }
    | '-' exp %prec NEG { $$ = -$2; }
    | exp '^' exp { $$ = pow ($1, $3); }
    | '(' exp ')' { $$ = $2; }
    ;


%%

#include <stdio.h>

void
yyerror (char *s)
{
    fprintf (stderr, "ERROR: %s\n", s);
}

