#ifndef LIT_H_
#define LIT_H_

#include "da.h"
#include <stdbool.h>

typedef struct Lit Lit;
typedef struct Lit_List Lit_List;

struct Lit_List {
        int capacity;
        int count;
        Lit *data;
};

struct Lit {
        int type;
        union {
                char *str;
                double num;
                int dec;
                Lit_List *list;
        } as;
};

#endif

void lit_free(Lit a);
Lit lit_dup(Lit a);

Lit lit_add(Lit a, Lit b); /* a + b */
Lit lit_sub(Lit a, Lit b); /* a - b */
Lit lit_mul(Lit a, Lit b); /* a * b */
Lit lit_div(Lit a, Lit b); /* a / b */
Lit lit_pow(Lit a, Lit b); /* a ^ b */
Lit lit_neg(Lit a);        /* -a    */

bool lit_neq(Lit a, Lit b); /* a != b */

Lit lit_cast(Lit a, int type); /* change type (type is bison token name) */
Lit double_to_lit(double d);
Lit int_to_lit(int i);
Lit str_to_lit(char *s);
Lit lit_list();                        /* create empty list */
Lit lit_list_add(Lit list, Lit value); /* add a value to the list */

int lit_print(Lit a);
int lit_print_more(Lit a);
Lit lit_call(Lit func, Lit args, int ret_type);
