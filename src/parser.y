%{
#include <stdio.h>
#include <stdlib.h>

#include "ts.h"
#include "lit.h"

extern int has_error;
extern int yylex();
extern int should_quit;
extern int load(char *);
extern int open_file(char*);
extern void close_file();
extern int yyerror(const char*, ...);
%}

%union {
    struct TS_Entry *tptr;
    struct Lit val;
    int type;
}

%token <val> NUM        
%token <val> STR        
%token <val> PATH        
%token <tptr> VAR
%token <val> LIST

%token ERROR        

%token ASSERT        
%token AS        
%token <type> TYPE        

%token CONST        
%token WORKSPACE        
%token CLEAR        
%token QUIT        
%token LOAD        

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

    | CLEAR '\n' { printf("\033[H\033[2J"); }
    | WORKSPACE '\n' { ts_print(); }

    | QUIT '\n' {
        fflush(stdout);
        printf("See you soon!\n");
        should_quit = 1;
        YYABORT;
    }

    | LOAD VAR '\n' { if (load($2->value.as.str)) YYERROR; }
    | LOAD PATH '\n' { if (load($2.as.str)) YYERROR; }
    ;

expr: 
    NUM { $$ = $1; }
    | STR { $$ = $1; }
    | PATH { $$ = $1; }
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

    | CONST VAR '=' expr { 
        if ($2->constant) { yyerror("Assigning to a constant var"); YYERROR; }
        if ($2->assigned) { yyerror("Changing var signature"); YYERROR; }
        $2->assigned = true;
        $2->constant = true;
        $$ = $2->value = $4;
          
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

#include <stdarg.h>
#include <stdio.h>

int yyerror(const char*fmt, ...)
{
    va_list ap;
    int n = 0;
    va_start(ap, fmt);
    n += fprintf(stderr, "ERROR: ");
    n += vfprintf(stderr, fmt, ap);
    if(fmt[strlen(fmt)-1] != '\n') n+=fprintf(stderr, "\n");
    va_end(ap);
    has_error = 1;
    return n;
}

int load(char* s){
    if(open_file(s)){
        yyerror("file `%s` not found", s);
        return 1;
    }
    return 0;
}
