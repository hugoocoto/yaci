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
        rl_variable_bind("editing-mode", "vi");
        open_file(NULL);
        while (!should_quit) {
                char *this = readline(PROMPT);
                input_stream = &this;
                yyparse();
                free(this);
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

const char *pretty = (const char *) 1;

void
exit_handler(int sig)
{
        (void) sig;
        putchar('\n'); /* Insecure but it works */
        rl_on_new_line();
        rl_replace_line("", 0);
        rl_redisplay();
}

int
main(int argc, char **argv)
{
        const char *norepl;

        signal(SIGINT, exit_handler);

        flag_program(.help = "Yet Another Calculator Interpreter -- By Hugo Coto");
        flag_add(&norepl, "--norepl", .help = "Do not enter repl mode");

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
