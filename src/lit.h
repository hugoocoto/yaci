#ifndef LIT_H_
#define LIT_H_

typedef struct Lit {
        int type;
        union {
                char *str;
                double num;
        } as;
} Lit;

#endif

Lit lit_add(Lit a, Lit b); /* a + b */
Lit lit_sub(Lit a, Lit b); /* a - b */
Lit lit_mul(Lit a, Lit b); /* a * b */
Lit lit_div(Lit a, Lit b); /* a / b */
Lit lit_pow(Lit a, Lit b); /* a ^ b */
Lit lit_neg(Lit a);        /* -a    */

bool lit_neq(Lit a, Lit b); /* a != b */


Lit double_to_lit(double d);
Lit str_to_lit(char *s);

Lit lit_cast(Lit a, int type);
int lit_print(Lit a);
