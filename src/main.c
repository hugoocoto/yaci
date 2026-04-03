#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#include "flag.h"
#include <readline/history.h>
#include <readline/readline.h>

extern int yyparse();
extern int yylex_destroy();
extern int open_file(char *);
extern void close_file();
extern char **input_stream;
char *pretty = (char *) 1;
int should_quit = 0;
int has_error = 0;
int verbose;

#define PROMPT ">> "

/* ------ readline custom completion functions ------ */

const char *compl_dict[] = {
        "exit", "quit", "load", NULL
};

char *
compl_gen(const char *text, int state)
{
        static int i, l;
        const char *n;

        if (state == 0) {
                i = 0;
                l = strlen(text);
        }

        while ((n = compl_dict[i++])) {
                if (strncmp(n, text, l) == 0) return strdup(n);
        }
        return NULL;
}

char **
compl_custom(const char *text, int start, int end)
{
        (void) end; // suppress unused warning

        if (strncmp(text, "./", 2) == 0 ||
            strncmp(text, "../", 3) == 0) {
                rl_attempted_completion_over = 0;
                return NULL;
        }

        rl_attempted_completion_over = 1;
        if (start != 0) return NULL; // start is the cursor position i guess
        return rl_completion_matches(text, compl_gen);
}

/* ----- help functions ----- */

void
repl()
{
        using_history();
        rl_variable_bind("editing-mode", "vi");
        rl_bind_key('\t', rl_complete);
        rl_attempted_completion_function = compl_custom;

        open_file(NULL);
        char *input;
        while (!should_quit) {
                input = readline(PROMPT);
                if (!input) break;
                if (*input) add_history(input);
                input_stream = &input;
                yyparse();
                free(input);
                fflush(stdout);
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

/* ----- flags and execution loop ----- */

int
main(int argc, char **argv)
{
        const char *norepl;

        signal(SIGINT, exit_handler);

        flag_program(.help = "Yet Another Calculator Interpreter -- By Hugo Coto");
        flag_add(&norepl, "--norepl", .help = "Do not enter repl mode");
        flag_add((const char **) &verbose, "--verbose", "-v", .help = "Write more text than usual");

        if (flag_parse(&argc, &argv)) {
                flag_show_help(STDOUT_FILENO);
                exit(1);
        }

        for (int i = 1; i < argc; i++) {
                parse(argv[i]);
        }

        if (!norepl) repl();

        flag_free();
        return has_error;
}
