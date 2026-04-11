%token-table

%{
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <assert.h>

#include "ts.h"
#include "lit.h"
#include "da.h"
#include "qq.h"

extern void state_reset();
extern int verbose;
extern int colorize;
extern int echo;
extern int has_error;
extern int yylex();
extern int should_quit;
extern int load(char *);
extern int link_lib(char *);
extern int open_file(char*);
extern void close_file();
extern int yyerror(const char*, ...);
extern int yyhint(const char*, ...);
extern Lit func_call(TS_Entry*, Lit, int);
extern int INIT_ASSIGN;

QQ(Lit) scope_constants = {0};

%}

%union {
    struct TS_Entry *tptr;
    struct Lit val;
    int type;
}

%token <val> NUM        
%token <val> DEC        
%token <val> STR        
%token <val> FUN        
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
%token HELP        
%token OPEN        
%token POLL        
%token ARROW
%token DEL
%token ALL

%type <val> expr
%type <val> strange_quote_error
%type <val> silentexpr
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
    | program line { 
        state_reset();
    }
    ;

line: 
    expr '\n' { 
        if (echo) printf("=");
        if (echo) lit_print($1); 
        if (echo) printf("\n"); 
    }
    | expr ';' '\n' { }

    | ';' '\n' { }
    | '\n' { }
    | error { 
        if (verbose) yyhint("Type `help` for aditional help"); 
        state_reset();
    }

    | CLEAR '\n' { printf("\033[H\033[2J"); }
    | WORKSPACE '\n' { ts_print(); }
    | WORKSPACE VAR '\n' { ts_print_entry($2); }
    | WORKSPACE TYPE '\n' { ts_print_by_type($2); }
    | WORKSPACE PATH '\n' { ts_print_by_owner($2.as.str); qqpush(&scope_constants, $2); }
    | WORKSPACE STR '\n' { ts_print_by_owner($2.as.str); qqpush(&scope_constants, $2); }

    | DEL '\n' { 
        yyerror("del expects an action");
        if (verbose) yyhint("Write one of `all`, 'owner' or a variable"); 
        if (verbose) yyhint("Write ./ and <tab><tab> to get suggestions"); 
        YYERROR; 
    }
    | DEL ALL '\n' { ts_del_all(); }
    | DEL VAR '\n' { ts_del_entry($2); }
    | DEL PATH '\n' { ts_del_by_owner($2.as.str); qqpush(&scope_constants, $2); }
    | DEL STR '\n' { ts_del_by_owner($2.as.str); qqpush(&scope_constants, $2); }

    | QUIT '\n' {
        fflush(stdout);
        printf("See you soon!\n");
        should_quit = 1;
        YYABORT;
    }

    | LOAD VAR '\n' { if (load($2->value.as.str)) YYERROR; }
    | LOAD PATH '\n' { qqpush(&scope_constants, $2); if (load($2.as.str)) YYERROR; }
    | OPEN VAR '\n' { if (link_lib($2->value.as.str)) YYERROR; }
    | OPEN PATH '\n' { qqpush(&scope_constants, $2); if (link_lib($2.as.str)) YYERROR; }
    | VERBOSE TRUE '\n' { verbose = 1; }
    | VERBOSE FALSE '\n' { verbose = 0; }
    | T_ECHO TRUE '\n' { echo = 1; }
    | T_ECHO FALSE '\n' { echo = 0; }

    | LOAD '\n' { 
        yyerror("load expects a path");
        if (verbose) yyhint("Write one of `./path`, `<path>` or a variable"); 
        if (verbose) yyhint("Write ./ and <tab><tab> to get suggestions"); 
        YYERROR; 
    }
    | VERBOSE '\n' { yyerror("verbose expects one of `on`, `off`, `true` or `false`"); YYERROR; }
    | T_ECHO '\n' { yyerror("echo expects one of `on`, `off`, `true` or `false`"); YYERROR; }
    | HELP '\n' { yyerror("Sorry, you're on your own"); YYERROR; }

  // Error reported in strange_quote_error
    | LOAD strange_quote_error '\n' { }
    | OPEN strange_quote_error '\n' { }
    | VERBOSE strange_quote_error '\n' { }
    | T_ECHO strange_quote_error '\n' { }
    | strange_quote_error '\n' { }

expr: 
    NUM { $$ = $1; }
    | DEC { $$ = $1; }
    | STR { $$ = $1; qqpush(&scope_constants, $$); }
    | FUN { $$ = $1; qqpush(&scope_constants, $$); }
    | PATH { $$ = $1; qqpush(&scope_constants, $$); }
    | '{' list '}' { $$ = $2; }
    | VAR { 
        if ($1->assigned == A_INIT) { 
            yyerror("Variable `%s` not defined", $1->key); 
            if (verbose) yyhint("Maybe you want to type `%s = 1`", $1->key);
            YYERROR; 
        }
        else if ($1->assigned == A_NONE){
            assert(0 && "var assigned type is A_NONE");
        }
        $$ = $1->value; 
    }
    | TRUE { $$ = double_to_lit(1); }
    | FALSE { $$ = double_to_lit(0); }

    | expr ASSERT expr { 
        if (lit_neq($1, $3)) { 
            yyerror("Assertion error: ");
            printf("  lvalue: ");
            lit_print($1);
            printf("\n  rvalue: ");
            lit_print($3);
            printf("\n");
            yyerror("Values doesn't match"); 
            exit(1); 
        } 
        $$ = $1; 
    }

    | expr AS TYPE { 
        $$ = lit_cast($1, $3); 
        qqpush(&scope_constants, $$);
    }

    // assignment
    | VAR '=' expr { 
        if ($1->constant) { yyerror("Assigning to a constant var"); YYERROR; }
        if ($1->assigned != A_NONE) { lit_free($1->value); } 
        $1->assigned = A_VALUE;
        $$ = $1->value = lit_dup($3);
    }
    | VAR '=' '\n' { 
        yyerror("Assign operation needs a value");
        if (verbose) yyhint("Don't forget to write the value after the `=` as "
                             "in `%s = 1`", $1->value.as.str);
        YYERROR;
    }

    | CONST VAR '=' expr { 
        if ($2->constant) { yyerror("Assigning to a constant var"); YYERROR; }
        if ($2->assigned == A_VALUE) { yyerror("Can't change var signature"); YYERROR; }
        if ($2->assigned != A_NONE) { lit_free($2->value); } 
        $2->constant = true;
        $2->assigned = A_VALUE;
        $$ = $2->value = $4;
    }
    | CONST VAR '=' '\n' { 
        yyerror("Assign operation needs a value");
        if (verbose) yyhint("Don't forget to write the value after the `=` as "
                             "in `%s = 1`", $2->value.as.str);
        YYERROR;
    }

    // calls
    | VAR '(' list ')' ARROW TYPE { $$ = func_call($1, $3, $6); if($$.type == ERROR) YYERROR; }
    | VAR '(' list ')' { $$ = func_call($1, $3, NUM); if($$.type == ERROR) YYERROR; }
    | VAR '(' list '\n' { 
        yyerror("Unclosed parenthesis");
        if (verbose) yyhint("Don't forget to close it as in `%s(...)`", 
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

silentexpr:  { }
    | NUM  { }
    | DEC  { }
    | STR  { }
    | FUN  { }
    | PATH  { }
    | '{' list '}'  { }
    | VAR  { }
    | TRUE  { }
    | FALSE  { }
    | expr ASSERT expr  { }
    | expr AS TYPE  { }
    | VAR '=' expr  { }
    | VAR '=' '\n'  { }
    | CONST VAR '=' expr  { }
    | CONST VAR '=' '\n'  { }
    | VAR '(' list ')'  { }
    | VAR '(' list '\n'  { }
    | expr '+' expr  { }
    | expr '-' expr  { }
    | expr '*' expr  { }
    | expr '/' expr  { }
    | '-' expr %prec NEG  { }
    | expr '^' expr  { }
    | '(' expr ')'  { }

list: { $$ = lit_list(); qqpush(&scope_constants, $$); }
    | nzlist { $$ = $1; qqpush(&scope_constants, $$); }

nzlist:
    expr { $$ = lit_list_add(lit_list(), $1); }
    | nzlist ',' expr { lit_list_add($1, $3); }
    | nzlist ',' { 
        yyerror("Malformed list");
        if (verbose) yyhint("Remember that `,` have to be written between two "
                             "values, never at the end of the list");
        YYERROR;
    }
    | ',' {
        yyerror("Malformed list");
        if (verbose) yyhint("Remember that `,` have to be written between two "
                             "values, never at the start of the list");
        YYERROR;
    }

strange_quote_error: 
    '`' silentexpr '`' { 
        yyerror("Invalid separator ``");
        if (verbose) yyhint("Separator `` is used in examples to say that the "
                             "text between them is literally what you have to "
                             "type. Remove them");
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
    n += fprintf(stderr, "Error: ");
    n += vfprintf(stderr, fmt, ap);
    if (colorize) n += fprintf(stderr, "\033[0m");
    if(fmt[strlen(fmt)-1] != '\n') n+=fprintf(stderr, "\n");
    va_end(ap);
    has_error = 1;
    return n;
}

int yyhint(const char*fmt, ...)
{
    va_list ap;
    int n = 0;
    va_start(ap, fmt);
    if (colorize) n += fprintf(stderr, "\033[32m");
    n += fprintf(stderr, "Hint: ");
    n += vfprintf(stderr, fmt, ap);
    if (colorize) n += fprintf(stderr, "\033[0m");
    if(fmt[strlen(fmt)-1] != '\n') n+=fprintf(stderr, "\n");
    va_end(ap);
    has_error = 1;
    return n;
}

int load(char* s){
    if (open_file(s)) {
        yyerror("file `%s` not found", s);
        yyhint("Write load ./<tab><tab> to get suggestions");
        return 1;
    }
    return 0;
}

int link_lib(char* s){
    if (!dlopen(s, RTLD_NOW | RTLD_GLOBAL)) {
        yyerror("%s\n", s, dlerror());
        yyhint("Use the `./` prefix for local libraries");
        yyhint("Use no prefix for system ones");
        return 1;
    }
    return 0;
}

Lit func_call(TS_Entry* var, Lit arg_list, int ret_type)
{
    Lit ret;
    if (var->assigned != A_VALUE){
        ret = lit_call(var->value, arg_list, ret_type); 
        if (ret.type == ERROR){
            yyerror("Couldn't find any function with this signature"); 
            if (verbose) yyhint("Make sure %s exists and it's linked", var->value.as.str); 
            return (Lit){ .type = ERROR };
        }
        var->callable = true;
        var->assigned = A_VALUE ;
        var->constant = true;
        var->type = FUN;
        var->value.type = FUN;
        return ret;
    }

    else if (!var->callable && var->assigned == A_VALUE) { 
        yyerror("Calling a non-callable var"); 
            if (verbose) yyhint("You can only call functions from linked libraries"); 
        return (Lit){ .type = ERROR };
    } 

    return lit_call(var->value, arg_list, ret_type); 
}

void state_reset() {
    for_qq_each(e, scope_constants){ lit_free(*e); }
    scope_constants.count = 0;
    {
    #ifdef NO_READLINE
        extern const char* PROMPT;
        printf("%s", PROMPT);
    #endif
    }
}
