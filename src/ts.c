#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define memdup(x) memcpy(malloc(sizeof(x)), &(x), sizeof(x))

#include "bt.h"
#include "parser.tab.h"
#include "ts.h"

static BT ts = { 0 };

int
builtin_clear()
{
        printf("\033[H\033[2J");
        fflush(stdout);
        return 0;
}

__attribute__((constructor)) static void
insert_keywords()
{
#define ts_add_num_const(strlit, val) \
        ts_add((strlit), (TS_Entry) { .as.value = (val), .assigned = 1, .constant = 1, .type = NUM })

        /* Constants from math.h */
        ts_add_num_const("e", M_E);           /* e */
        ts_add_num_const("log2e", M_LOG2E);   /* log_2 e */
        ts_add_num_const("log10e", M_LOG10E); /* log_10 e */
        ts_add_num_const("ln2", M_LN2);       /* log_e 2 */
        ts_add_num_const("ln10", M_LN10);     /* log_e 10 */
        ts_add_num_const("pi", M_PI);         /* pi */
        ts_add_num_const("pi_2", M_PI_2);     /* pi/2 */
        ts_add_num_const("pi_4", M_PI_4);     /* pi/4 */
        ts_add_num_const("sqrt2", M_SQRT2);   /* sqrt(2) */

        /* This is the funniest thing I did in the last 10 hours */
        ts_add_num_const("zero", 0);
        ts_add_num_const("one", 1);
        ts_add_num_const("two", 2);
        ts_add_num_const("three", 3);
        ts_add_num_const("four", 4);
        ts_add_num_const("five", 5);
        ts_add_num_const("six", 6);
        ts_add_num_const("seven", 7);
        ts_add_num_const("eight", 8);
        ts_add_num_const("nine", 9);
        ts_add_num_const("ten", 10);

        ts_add("clear", (TS_Entry) { .as.ptr = builtin_clear, .assigned = 1, .constant = 1, .type = CMD });
}

__attribute__((destructor)) static void
delete_table()
{
        bt_destroy(&ts);
}

void
ts_print()
{
        extern char *pretty;
        printf("----| Tabla de simbolos |----\n");
        pretty ? bt_write_pretty(stdout, &ts) : bt_write(stdout, &ts);
        printf("-----------------------------\n");
}

void
ts_add(const char *key, TS_Entry entry)
{
        bt_add(&ts, key, memdup(entry));
}

TS_Entry *
ts_get(const char *key)
{
        return bt_get(&ts, key);
}

char *
ts_get_key_addr(const char *key)
{
        return bt_get_key_addr(&ts, key);
}

/* BT stuff under here */

#define BT_VALUE_DELETE value_delete_callback
void
value_delete_callback(void *value)
{
        free(value);
}

#define BT_IMPLEMENTATION
#include "bt.h"
