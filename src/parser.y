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

program: 
    | program line 
    ;

line: 
    exp '\n' { printf("%g\n", $1); }
    | exp ';' '\n' { }
    | error { }
    | ';' '\n'
    | '\n'
    ;

exp: 
    NUM { $$ = $1; }

    | VAR { 
        if (!$1->assigned) { yyerror("can not read value from non-initialized var"); YYERROR; }
        if ($1->type == CMD) {
            $$ = (double)((builtin_cmd) $1->as.ptr)();
        } else {
            $$ = $1->as.value; 
        }
    }

    | VAR '=' exp { 
        if ($1->constant) { yyerror("can not assign to constant var"); YYERROR; }
        if (!$1->assigned) { $1->assigned = true; }
        $$ = $1->as.value = $3;
          
    }

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

