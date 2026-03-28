#include <stdio.h>
#include <unistd.h>

#ifndef TEST

#include "flag.h"

int
parse(char *filename)
{
        extern int yylex();
        extern int open_file(char *);
        extern void close_file();

        printf("filename: %s\n", filename);
        if (open_file(filename)) {
                perror(filename);
                return 1;
        }
        yylex();
        close_file();
        return 0;
}

int
main(int argc, char **argv)
{
        const char *var;

        flag_program(.help = "Yet Another Calculator Interpreter -- By Hugo Coto");
        flag_add(&var, "--var", .help = "var var");

        if (flag_parse(&argc, &argv)) {
                flag_show_help(STDOUT_FILENO);
                exit(1);
        }
        flag_free();

        for (int i = 1; i < argc; i++) {
                parse(argv[i]);
        }

        return 0;
}

#else // TEST

int
main()
{
        return 0;
}

#endif
