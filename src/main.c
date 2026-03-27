#include <unistd.h>

#ifndef TEST

#include "flag.h"

int
main(int argc, char **argv)
{
        char *var;

        flag_program(.help = "Yet Another Calculator Interpreter -- By Hugo Coto");

        flag_add(&var, "--var", .help = "var var");

        if (flag_parse(&argc, &argv)) {
                flag_show_help(STDOUT_FILENO);
        }

        flag_free();

        return 0;
}

#else // TEST

int
main()
{
        return 0;
}

#endif
