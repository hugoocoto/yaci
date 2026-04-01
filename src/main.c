#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#ifndef TEST

#include "flag.h"

extern int yyparse();
extern int yylex_destroy();

void
repl()
{
        printf("REPL:\n");
        yyparse();
        yylex_destroy();
}

int
parse(char *filename)
{
        extern int open_file(char *);
        extern void close_file();

        if (open_file(filename)) {
                perror(filename);
                return 1;
        }

        yyparse();
        close_file();
        yylex_destroy();
        return 0;
}

const char *pretty;

void
exit_handler(int sig)
{
        (void) sig;
        extern const char *quit_seq;
        printf("\nMaybe you want to type one of:\n%s\n", quit_seq);
}

int
main(int argc, char **argv)
{
        const char *norepl;
        const char *nopretty;

        signal(SIGINT, exit_handler);

        flag_program(.help = "Yet Another Calculator Interpreter -- By Hugo Coto");
        flag_add(&norepl, "--norepl", .help = "Do not enter repl mode");
        flag_add(&nopretty, "--plain", .help = "Do not use pretty mode");

        pretty = (const char *) (nopretty ? 0L : 1L);

        if (flag_parse(&argc, &argv)) {
                flag_show_help(STDOUT_FILENO);
                exit(1);
        }
        flag_free();

        for (int i = 1; i < argc; i++) {
                parse(argv[i]);
        }

        if (!norepl) repl();

        return 0;
}

#else // TEST

const char *pretty = 0;

int
main()
{
        return 0;
}

#endif


const char *quit_seq = "quit, quiT, quIt, quIT, qUit, qUiT, qUIt, qUIT, Quit, QuiT, QuIt, QuIT, QUit, QUiT, QUIt, QUIT, exit, exiT, exIt, exIT, eXit, eXiT, eXIt, eXIT, Exit, ExiT, ExIt, ExIT, EXit, EXiT, EXIt, EXIT, q, Q, q!, Q!, wq, wQ, Wq, WQ, wq!, wQ!, Wq!, WQ!, :q, :Q, :q!, :Q!, :wq, :wQ, :Wq, :WQ, :wq!, :wQ!, :Wq!, :WQ!, quit(), quiT(), quIt(), quIT(), qUit(), qUiT(), qUIt(), qUIT(), Quit(), QuiT(), QuIt(), QuIT(), QUit(), QUiT(), QUIt(), QUIT(), exit(), exiT(), exIt(), exIT(), eXit(), eXiT(), eXIt(), eXIT(), Exit(), ExiT(), ExIt(), ExIT(), EXit(), EXiT(), EXIt(), EXIT(), q(), Q(), q!(), Q!(), wq(), wQ(), Wq(), WQ(), wq!(), wQ!(), Wq!(), WQ!(), :q(), :Q(), :q!(), :Q!(), :wq(), :wQ(), :Wq(), :WQ(), :wq!(), :wQ!(), :Wq!(), :WQ!(), quit( ), quiT( ), quIt( ), quIT( ), qUit( ), qUiT( ), qUIt( ), qUIT( ), Quit( ), QuiT( ), QuIt( ), QuIT( ), QUit( ), QUiT( ), QUIt( ), QUIT( ), exit( ), exiT( ), exIt( ), exIT( ), eXit( ), eXiT( ), eXIt( ), eXIT( ), Exit( ), ExiT( ), ExIt( ), ExIT( ), EXit( ), EXiT( ), EXIt( ), EXIT( ), q( ), Q( ), q!( ), Q!( ), wq( ), wQ( ), Wq( ), WQ( ), wq!( ), wQ!( ), Wq!( ), WQ!( ), :q( ), :Q( ), :q!( ), :Q!( ), :wq( ), :wQ( ), :Wq( ), :WQ( ), :wq!( ), :wQ!( ), :Wq!( ), :WQ!( ), quit(  ), quiT(  ), quIt(  ), quIT(  ), qUit(  ), qUiT(  ), qUIt(  ), qUIT(  ), Quit(  ), QuiT(  ), QuIt(  ), QuIT(  ), QUit(  ), QUiT(  ), QUIt(  ), QUIT(  ), exit(  ), exiT(  ), exIt(  ), exIT(  ), eXit(  ), eXiT(  ), eXIt(  ), eXIT(  ), Exit(  ), ExiT(  ), ExIt(  ), ExIT(  ), EXit(  ), EXiT(  ), EXIt(  ), EXIT(  ), q(  ), Q(  ), q!(  ), Q!(  ), wq(  ), wQ(  ), Wq(  ), WQ(  ), wq!(  ), wQ!(  ), Wq!(  ), WQ!(  ), :q(  ), :Q(  ), :q!(  ), :Q!(  ), :wq(  ), :wQ(  ), :Wq(  ), :WQ(  ), :wq!(  ), :wQ!(  ), :Wq!(  ), :WQ!(  ), quit(   ), quiT(   ), quIt(   ), quIT(   ), qUit(   ), qUiT(   ), qUIt(   ), qUIT(   ), Quit(   ), QuiT(   ), QuIt(   ), QuIT(   ), QUit(   ), QUiT(   ), QUIt(   ), QUIT(   ), exit(   ), exiT(   ), exIt(   ), exIT(   ), eXit(   ), eXiT(   ), eXIt(   ), eXIT(   ), Exit(   ), ExiT(   ), ExIt(   ), ExIT(   ), EXit(   ), EXiT(   ), EXIt(   ), EXIT(   ), q(   ), Q(   ), q!(   ), Q!(   ), wq(   ), wQ(   ), Wq(   ), WQ(   ), wq!(   ), wQ!(   ), Wq!(   ), WQ!(   ), :q(   ), :Q(   ), :q!(   ), :Q!(   ), :wq(   ), :wQ(   ), :Wq(   ), :WQ(   ), :wq!(   ), :wQ!(   ), :Wq!(   ), :WQ!(   )";
