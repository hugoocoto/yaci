%{
#include <stdio.h>
#include <stdlib.h>

#include "ts.h"
#include "lit.h"

extern void yyerror (char *);
extern int yylex();
%}

%union {
    struct TS_Entry *tptr;
    struct Lit val;
    int type;
}

%token <val> NUM        
%token <val> STR        
%token <tptr> VAR
%token <val> LIST
%token ASSERT        
%token ERROR        
%token AS        
%token <type> TYPE        
%token CLEAR        
%token QUIT        

%type <val> expr
%type <val> list
%type <val> nzlist

%right ASSERT
%right '='
%left '-' '+'
%left '*' '/'
%left NEG
%right '^'
%right AS

%start program

%%

program: 
    | program line 
    ;

line: 
    expr '\n' { 
        printf("=");
        lit_print($1); 
        printf("\n"); 
    }
    | expr ';' '\n' { }
    | error { }
    | ';' '\n'
    | '\n'
    | CLEAR '\n' {
        printf("\033[H\033[2J");
        fflush(stdout);
    }
    | QUIT '\n' {
        fflush(stdout);
        printf("See you soon!\n");
        YYABORT;
    }
    ;

expr: 
    NUM { $$ = $1; }
    | STR { $$ = $1; }
 
    | VAR { 
        if (!$1->assigned) { yyerror("Can not read value from non-initialized var"); YYERROR; }
        $$ = $1->value; 
    }

    | expr ASSERT expr { 
        if (lit_neq($1, $3)) { yyerror("Values doesn't match\n"); exit(1); } 
        $$ = $1; 
    }

    | expr AS TYPE { 
        $$ = lit_cast($1, $3); 
    }

    | VAR '=' expr { 
        if ($1->constant) { yyerror("Assigning to a constant var"); YYERROR; }
        if (!$1->assigned) { $1->assigned = true; }
        $$ = $1->value = $3;
          
    }

    | VAR '(' list ')' { 
        if (!$1->callable && !$1->assigned){
            $$ = lit_call($1->value, $3); 
        }
        else if (!$1->callable && $1->assigned) { 
            yyerror("Calling a non-callable var"); 
            YYERROR; 
        } 
        else {
            $$ = lit_call($1->value, $3); 
        }
    }

    | expr '+' expr { $$ = lit_add($1, $3); }
    | expr '-' expr { $$ = lit_sub($1, $3); }
    | expr '*' expr { $$ = lit_mul($1, $3); }
    | expr '/' expr { $$ = lit_div($1, $3); }
    | '-' expr %prec NEG { $$ = lit_neg($2); }
    | expr '^' expr { $$ = lit_pow($1, $3); }
    | '(' expr ')' { $$ = $2; }
    ;

list: { $$ = lit_list(); }
    | nzlist { $$ = $1; }

nzlist:
    expr { $$ = lit_list_add(lit_list(), $1); }
    | nzlist ',' expr { lit_list_add($1, $3); }

%%

#include <stdio.h>

void
yyerror (char *s)
{
    fprintf (stderr, "ERROR: %s\n", s);
}

