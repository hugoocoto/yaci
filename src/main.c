#include <signal.h>
#include <stdio.h>
#include <unistd.h>

int should_quit = 0;
int has_error = 0;

#ifndef TEST

#include "flag.h"
#include <readline/history.h>
#include <readline/readline.h>

extern int yyparse();
extern int yylex_destroy();
extern int open_file(char *);
extern void close_file();
extern char **input_stream;
const char *pretty = (const char *) 1;


#define PROMPT ">> "

void
repl()
{
        using_history();
        rl_variable_bind("editing-mode", "vi");
        rl_bind_key('\t', rl_complete);
        open_file(NULL);
        char *input;
        while (!should_quit) {
                input = readline(PROMPT);
                if (!input) break;
                add_history(input);
                input_stream = &input;
                yyparse();
                free(input);
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

        return has_error;
}

#else // TEST

const char *pretty = 0;

int
main()
{
        return 0;
}

#endif
