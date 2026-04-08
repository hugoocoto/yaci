#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#include "flag.h"
#include "ts.h"
#include <readline/history.h>
#include <readline/readline.h>

typedef void *YY_BUFFER_STATE;

extern int yyparse();
extern int yylex_destroy();
extern int open_file(char *);
extern char **input_stream;
extern YY_BUFFER_STATE yy_scan_string(char *);
extern void yy_delete_buffer(YY_BUFFER_STATE);
extern void yypush_buffer_state(YY_BUFFER_STATE);
extern void yy_switch_to_buffer(YY_BUFFER_STATE);

int should_quit = 0;
int has_error = 0;
int verbose;
int echo;
int colorize;

#define PROMPT ">> "

/* ------ readline custom completion functions ------ */

const char *compl_dict[] = {
        "exit", "quit", "load", "clear", "verbose", "echo", NULL
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

// char *
// compl_from_ts(const char *text, int state)
// {
//         static int i, l;
//         const char *n;
//
//         if (state == 0) {
//                 i = 0;
//                 l = strlen(text);
//         }
//
//         while ((n = ts_get_next())) {
//                 if (strncmp(n, text, l) == 0) return strdup(n);
//         }
//         return NULL;
// }

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

void
repl()
{
        using_history();
        rl_variable_bind("editing-mode", "vi");
        rl_bind_key('\t', rl_complete);
        rl_attempted_completion_function = compl_custom;

        extern int yy_flex_debug;
        yy_flex_debug = 1;
        extern void yy_init_queue();
        yy_init_queue();

        char *input;
        while (!should_quit) {
                input = readline(PROMPT);
                if (!input) break;
                if (*input) {
                        char *input_nl = calloc(1, strlen(input) + 2);
                        strcat(input_nl, input);
                        strcat(input_nl, "\n");
                        add_history(input_nl);
                        YY_BUFFER_STATE bp = yy_scan_string(input_nl);
                        yyparse();
                        yy_delete_buffer(bp);
                        // free(input_nl);
                }
                // free(input);
        }
}

int
parse(char *filename)
{
        set_owner(strdup(filename)); // how i'm going to free this?
        if (open_file(filename)) {
                perror(filename);
                return 1;
        }

        yyparse();
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
        const char *norepl_v;
        const char *noecho_v;
        const char *nocolor_v;
        const char *verbose_v;

        signal(SIGINT, exit_handler);

        flag_program(.help = "Yet Another Calculator Interpreter -- By Hugo Coto");
        flag_add(&norepl_v, "--norepl", .help = "Do not enter repl mode");
        flag_add(&verbose_v, "--verbose", "-v", .help = "Give hints and show a little more info");
        flag_add(&noecho_v, "--noecho", "-E", .help = "Do not echo result");
        flag_add(&nocolor_v, "--nocolor", "-C", .help = "Do not use colors");

        if (flag_parse(&argc, &argv)) {
                flag_show_help(STDOUT_FILENO);
                exit(1);
        }

        echo = !noecho_v;
        colorize = isatty(STDOUT_FILENO) ? !nocolor_v : 0;
        verbose = !!verbose_v;

        for (int i = 1; i < argc; i++) {
                if (verbose) printf("[YACI] Filename: %s\n", argv[i]);
                parse(argv[i]);
        }

        if (!norepl_v) repl();

        yylex_destroy();
        flag_free();
        return has_error;
}
