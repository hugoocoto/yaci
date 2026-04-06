#include <assert.h>
#include <ffi.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "call.h"
#include "da.h"
#include "lit.h"
#include "parser.tab.h"
#include "ts.h"

#define LIT_ERROR             \
        (Lit)                 \
        {                     \
                .type = ERROR \
        }

void
lit_free(Lit a)
{
        switch (a.type) {
        case LIST:
                for_da_each(e, *a.as.list)
                {
                        lit_free(*e);
                }
                free(a.as.list);
                break;
        }
}

Lit
lit_call(Lit func, Lit args)
{
        Call c = {
                .return_type = &ffi_type_double,
                .result = malloc(sizeof(double)),
                .func_name = strdup(func.as.str),
        };
        switch (args.type) {
        case NUM: call_add_arg(&c, &args.as.num, &ffi_type_double); break;
        case STR: call_add_arg(&c, &args.as.str, &ffi_type_pointer); break;
        case LIST:
                for_da_each(e, *args.as.list)
                {
                        switch (e->type) {
                        case NUM: call_add_arg(&c, &e->as.num, &ffi_type_double); break;
                        case STR: call_add_arg(&c, &e->as.str, &ffi_type_pointer); break;
                        default: assert(0 && "Unhandled type in argument list");
                        }
                }
                break;
        default: assert(0 && "Unhandled type in argument list");
        }

        if (call(c)) return LIT_ERROR;

        Lit l = double_to_lit(*(double *) c.result);
        call_free(c);
        return l;
}

Lit
lit_cast(Lit a, int type)
{
        switch (a.type) {
        case NUM:
                if (type == NUM) return a;
                if (type == STR) {
                        char *buf = NULL;
                        assert(asprintf(&buf, "%g", a.as.num) > 0);
                        return str_to_lit(buf);
                }
                if (type == LIST) {
                        Lit l = lit_list();
                        lit_list_add(l, a);
                        return l;
                }
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);

        case STR:
                if (type == NUM) return double_to_lit(strtod(a.as.str, 0));
                if (type == STR) return a;
                if (type == LIST) {
                        Lit l = lit_list();
                        lit_list_add(l, a);
                        return l;
                }
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);

        case LIST:
                if (a.as.list->count != 1) return LIT_ERROR;
                if (a.as.list->data->type != type) return LIT_ERROR;
                return a.as.list->data[0];

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
        int n = 0;
        switch (a.type) {
        case NUM: return printf("%g", a.as.num);
        case STR: return printf("%s", a.as.str);
        case LIST:
                n += printf("{");
                for_da_each(e, *a.as.list)
                {
                        if (a.as.list->data != e) printf(", ");
                        lit_print(*e);
                }
                n += printf("}");
                return n;

        case ERROR: return printf("Error");
        default:
                printf("Compiler Panic! %s case %d not handled (at %s:%d)\n",
                       __FUNCTION__, a.type, __FILE__, __LINE__);
                exit(127);
        }
}

bool
lit_neq(Lit a, Lit b)
{
        // true if a!=b, false if a==b
        if (a.type != b.type) return true;
        switch (a.type) {
        case NUM: return a.as.num != b.as.num;
        case STR: return strcmp(a.as.str, b.as.str);
        case LIST: {
                if (a.as.list->count != b.as.list->count) return true;
                for (int i = 0; i < a.as.list->count; i++) {
                        if (lit_neq(a.as.list->data[i], b.as.list->data[i])) {
                                return true;
                        }
                }
                return false;
        }

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
        case NUM:
                if (b.as.num == 0) return LIT_ERROR;
                return double_to_lit(a.as.num / b.as.num);
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

Lit
lit_list()
{
        // this is UB
        return (Lit) {
                .type = LIST,
                .as.list = calloc(1, sizeof(Lit_List)),
        };
        printf("creating empty lits\n");
}

Lit
lit_list_add(Lit list, Lit value)
{
        assert(list.type == LIST);
        da_append(list.as.list, value);
        return list;
}
