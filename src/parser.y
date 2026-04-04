%{
#include <stdio.h>
#include <stdlib.h>

#include "ts.h"
#include "lit.h"

extern int verbose;
extern int colorize;
extern int echo;
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
%token <val> LIST
%token <val> PATH        
%token <tptr> VAR

%token ERROR        

%token ASSERT        
%token AS        
%token <type> TYPE        

%token CONST        
%token WORKSPACE        
%token CLEAR        
%token QUIT        
%token LOAD        
%token VERBOSE        
%token T_ECHO        
%token TRUE        
%token FALSE        

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
        if (echo) printf("=");
        if (echo) lit_print($1); 
        if (echo) printf("\n"); 
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
    | VERBOSE TRUE '\n' { verbose = 1; }
    | VERBOSE FALSE '\n' { verbose = 0; }
    | T_ECHO TRUE '\n' { echo = 1; }
    | T_ECHO FALSE '\n' { echo = 0; }

    | LOAD '\n' { yyerror("load expects a path: `./path`, `<path>` or a variable"); YYERROR; }
    | VERBOSE '\n' { yyerror("verbose expects one of `on`, `off`, `true` or `false`"); YYERROR; }
    | T_ECHO '\n' { yyerror("echo expects one of `on`, `off`, `true` or `false`"); YYERROR; }
    ;

expr: 
    NUM { $$ = $1; }
    | STR { $$ = $1; }
    | PATH { $$ = $1; }
    | '{' list '}' { $$ = $2; }
    | VAR { 
        if (!$1->assigned) { 
            yyerror("Variable not defined"); 
            if (verbose) yyerror("Maybe you want to type `%s = 1`", $1->value.as.str);
            YYERROR; 
        }
        $$ = $1->value; 
    }

    | expr ASSERT expr { 
        if (lit_neq($1, $3)) { yyerror("Assertion error: Values doesn't match"); exit(1); } 
        $$ = $1; 
    }

    | expr AS TYPE { 
        $$ = lit_cast($1, $3); 
    }

    | VAR '=' expr { 
        if ($1->constant) { yyerror("Assigning to a constant var"); YYERROR; }
        if (!$1->assigned) { $1->assigned = true; }
        lit_free($1->value);
        $$ = $1->value = $3;
    }
    | VAR '=' '\n' { 
        yyerror("Assign operation needs a value");
        if (verbose) yyerror("Don't forget to write the value after the `=` as "
                             "in `%s = 1`", $1->value.as.str);
        YYERROR;
    }

    | CONST VAR '=' expr { 
        if ($2->constant) { yyerror("Assigning to a constant var"); YYERROR; }
        if ($2->assigned) { yyerror("Changing var signature"); YYERROR; }
        $2->assigned = true;
        $2->constant = true;
        $$ = $2->value = $4;
    }
    | CONST VAR '=' '\n' { 
        yyerror("Assign operation needs a value");
        if (verbose) yyerror("Don't forget to write the value after the `=` as "
                             "in `%s = 1`", $2->value.as.str);
        YYERROR;
    }

    | VAR '(' list ')' { 
        if (!$1->assigned){
            $$ = lit_call($1->value, $3); 
            if ($$.type == ERROR){
                yyerror("Could not find any function with this signature"); 
                YYERROR; 
            }
        }
        else if (!$1->callable && $1->assigned) { 
            yyerror("Calling a non-callable var"); 
            YYERROR; 
        } 
        else {
            $$ = lit_call($1->value, $3); 
        }
    }
    | VAR '(' list '\n' { 
        yyerror("Unclosed parenthesis");
        if (verbose) yyerror("Don't forget to close it as in `%s(...)`", 
                             $1->value.as.str);
        YYERROR;
    }

    | expr '+' expr { $$ = lit_add($1, $3); }
    | expr '-' expr { $$ = lit_sub($1, $3); }
    | expr '*' expr { $$ = lit_mul($1, $3); }
    | expr '/' expr { $$ = lit_div($1, $3); }
    | '-' expr %prec NEG { $$ = lit_neg($2); }
    | expr '^' expr { $$ = lit_pow($1, $3); }
    | '(' expr ')' { $$ = $2; }


list: { $$ = lit_list(); }
    | nzlist { $$ = $1; }

nzlist:
    expr { $$ = lit_list_add(lit_list(), $1); }
    | nzlist ',' expr { lit_list_add($1, $3); }
    | nzlist ',' { 
        yyerror("Unterminated list");
        if (verbose) yyerror("Remember that `,` have to be written between two "
                             "values, never at the end of the list");
        YYERROR;
    }
    | ',' {
        yyerror("Malformed list");
        if (verbose) yyerror("Remember that `,` have to be written between two "
                             "values, never at the start of the list");
        YYERROR;
    }
    ;

%%

#include <stdarg.h>
#include <stdio.h>

int yyerror(const char*fmt, ...)
{
    va_list ap;
    int n = 0;
    va_start(ap, fmt);
    if (colorize) n += fprintf(stderr, "\033[31m");
    n += fprintf(stderr, "ERROR: ");
    n += vfprintf(stderr, fmt, ap);
    if (colorize) n += fprintf(stderr, "\033[0m");
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
