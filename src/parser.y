%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "ts.h"

#define YYERROR_VERBOSE

extern void yyerror (char *);
extern int yylex();
%}

%union {
    double val;
    struct TS_Entry *tptr;
}

%token <val> NUM        
%token <tptr> VAR FNCT 
%token ASSERT        

%type <val> expr

%right ASSERT
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
    expr '\n' { printf("%g\n", $1); }
    | expr ';' '\n' { }
    | error { }
    | ';' '\n'
    | '\n'
    ;

expr: 
    NUM { $$ = $1; }

    | VAR { 
        if (!$1->assigned) { yyerror("can not read value from non-initialized var"); YYERROR; }
        if ($1->type == CMD) {
            $$ = (double)((builtin_cmd) $1->as.ptr)();
        } else {
            $$ = $1->as.value; 
        }
    }

    | expr ASSERT expr { 
        if ($1 != $3) { 
            // YYERROR;
            printf("%g eq! %g\n: ", $1, $3);
            yyerror("Values doesn't match\n"); 
            exit(1); 
        } 
        $$ = $1; 
    }


    | VAR '=' expr { 
        if ($1->constant) { yyerror("can not assign to constant var"); YYERROR; }
        if (!$1->assigned) { $1->assigned = true; }
        $$ = $1->as.value = $3;
          
    }

    | expr '+' expr { $$ = $1 + $3; }
    | expr '-' expr { $$ = $1 - $3; }
    | expr '*' expr { $$ = $1 * $3; }
    | expr '/' expr { $$ = $1 / $3; }
    | '-' expr %prec NEG { $$ = -$2; }
    | expr '^' expr { $$ = pow($1, $3); }
    | '(' expr ')' { $$ = $2; }
    ;

%%

#include <stdio.h>

void
yyerror (char *s)
{
    fprintf (stderr, "ERROR: %s\n", s);
}

