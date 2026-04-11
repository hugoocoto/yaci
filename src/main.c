#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#include "flag.h"

typedef void *YY_BUFFER_STATE;

extern int yyparse();
extern int yylex_destroy();
extern int open_file(char *);
extern YY_BUFFER_STATE yy_scan_string(char *);
extern void yy_delete_buffer(YY_BUFFER_STATE);

int should_quit = 0;
int has_error = 0;
int verbose;
int echo;
int colorize;

const char *PROMPT;

#ifndef NO_READLINE
/* ------ readline custom completion functions ------ */

#include <readline/history.h>
#include <readline/readline.h>

const char *compl_dict[] = {
        "exit", "quit", "load", "clear", "verbose", "echo", NULL
};

char *
compl_cmds(const char *text, int state)
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
        if (start == 0) return rl_completion_matches(text, compl_cmds);
        // else: complete with var names
        return NULL; // start is the cursor position I guess
}

void
repl()
{
        using_history();
        rl_variable_bind("editing-mode", "vi");
        rl_bind_key('\t', rl_complete);
        rl_attempted_completion_function = compl_custom;

        char *input;
        while (!should_quit) {
                input = readline(PROMPT);
                if (input && *input) {
                        char *input_nl = calloc(1, strlen(input) + 2);
                        strcat(input_nl, input);
                        strcat(input_nl, "\n");
                        add_history(input_nl);
                        YY_BUFFER_STATE bp = yy_scan_string(input_nl);
                        yyparse();
                        yy_delete_buffer(bp);
                        free(input_nl);
                }
                if (!input) break;
                free(input);
        }
        clear_history();
}

#else // NO_READLINE

void
repl()
{
        printf("%s", PROMPT);
        while (!should_quit) {
                yyparse();
                // todo : fix prompting in no-readline mode
        }
}

#endif // !NO_READLINE

int
parse(char *filename)
{
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
#ifndef NO_READLINE
        putchar('\n'); /* Unsecure but it works */
        rl_on_new_line();
        rl_replace_line("", 0);
        rl_redisplay();
#endif
}

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
        flag_add(&PROMPT, "--prompt", .help = "REPL prompt", .nargs = 1, .defaults = ">> ");

        if (flag_parse(&argc, &argv)) {
                flag_show_help(STDOUT_FILENO);
                exit(1);
        }

        echo = !noecho_v;
        colorize = isatty(STDOUT_FILENO) ? !nocolor_v : 0;
        verbose = !!verbose_v;

        extern void yy_init_owner_queue();
        extern void yy_free_owner_queue();

        yy_init_owner_queue();
        for (int i = 1; i < argc; i++) {
                if (verbose) printf("[YACI] Filename: %s\n", argv[i]);
                parse(argv[i]);
        }
        if (!norepl_v) repl();
        yy_free_owner_queue();

        yylex_destroy();
        flag_free();
        return has_error;
}
