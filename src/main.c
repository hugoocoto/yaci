#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int should_quit = 0;

#ifndef TEST

#include "flag.h"
#include <readline/readline.h>

extern int yyparse();
extern int yylex_destroy();
extern int open_file(char *);
extern void close_file();
extern char **input_stream;

#define PROMPT ">> "

void
repl()
{
        open_file(NULL);
        while (!should_quit) {
                // char *this = strdup(readline(PROMPT));
                // input_stream = &this;
                yyparse();
        }
        close_file();
        yylex_destroy();
}

int
parse(char *filename)
{
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
