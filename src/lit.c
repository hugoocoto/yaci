#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lit.h"
#include "parser.tab.h"
#include "ts.h"

#define LIT_ERROR              \
        (Lit)                  \
        {                      \
                .type = ERROR, \
        }

#define AUTO_BRANCH(NUM_NUM, STR_STR) \
        do {                          \
        } while (0)

Lit
lit_cast(Lit a, int type)
{
        switch (a.type) {
        case NUM:
                if (type == NUM) return a;
                if (type == STR) {
                        char *buf = NULL;
                        assert(asprintf(&buf, "\"%g\"", a.as.num) > 0);
                        return str_to_lit(buf);
                }
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);

        case STR:
                if (type == NUM) return double_to_lit(strtod(a.as.str + 1, 0));
                if (type == STR) return a;
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);

        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

Lit
double_to_lit(double d)
{
        return (Lit) { .type = NUM, .as.num = d };
}

Lit
str_to_lit(char *s)
{
        return (Lit) { .type = STR, .as.str = s };
}

int
lit_print(Lit a)
{
        switch (a.type) {
        case NUM: return printf("%g", a.as.num);
        case STR: return printf("%s", a.as.str);
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

bool
lit_neq(Lit a, Lit b)
{
        if (a.type != b.type) return false;
        switch (a.type) {
        case NUM: return a.as.num != b.as.num;
        case STR: return strcmp(a.as.str, b.as.str);
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

/* a + b */
Lit
lit_add(Lit a, Lit b)
{
        if (a.type != b.type) return LIT_ERROR;
        switch (a.type) {
        case NUM: return double_to_lit(a.as.num + b.as.num);
        case STR: return LIT_ERROR;
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

/* a - b */
Lit
lit_sub(Lit a, Lit b)
{
        if (a.type != b.type) return LIT_ERROR;
        switch (a.type) {
        case NUM: return double_to_lit(a.as.num - b.as.num);
        case STR: return LIT_ERROR;
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

/* a * b */
Lit
lit_mul(Lit a, Lit b)
{
        if (a.type != b.type) return LIT_ERROR;
        switch (a.type) {
        case NUM: return double_to_lit(a.as.num * b.as.num);
        case STR: return LIT_ERROR;
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

/* a / b */
Lit
lit_div(Lit a, Lit b)
{
        if (a.type != b.type) return LIT_ERROR;
        switch (a.type) {
        case NUM: return double_to_lit(a.as.num / b.as.num);
        case STR: return LIT_ERROR;
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

/* a ^ b */
Lit
lit_pow(Lit a, Lit b)
{
        if (a.type != b.type) return LIT_ERROR;
        switch (a.type) {
        case NUM: return double_to_lit(pow(a.as.num, b.as.num));
        case STR: return LIT_ERROR;
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

/* - a */
Lit
lit_neg(Lit a)
{
        switch (a.type) {
        case NUM: return double_to_lit(-a.as.num);
        case STR: return LIT_ERROR;
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}
