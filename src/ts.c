#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define memdup(x) memcpy(malloc(sizeof(x)), &(x), sizeof(x))

#include "bt.h"

#include "lit.h"
#include "ts.h"

#include "parser.tab.h"

static BT ts = { 0 };

const char *const OWNER_REPL =  "__REPL__";
const char *const OWNER_CNST = "__CNST__";

const char *current_owner = OWNER_CNST;

void
set_owner(const char *owner)
{
        current_owner = owner;
}

const char *
get_owner()
{
        return current_owner;
}

static char *
token_name(int tok)
{
        static char *lut[] = {
                [NUM] = "num",
                [DEC] = "dec",
                [STR] = "str",
        };
        switch (tok) {
        case NUM:
        case DEC:
        case STR:
                return lut[tok];
        }
        return "unknown";
}

__attribute__((constructor)) static void
insert_keywords()
{
#define ts_add_num_const(strlit, val)                                                  \
        ts_add((strlit), (TS_Entry) { .value = (Lit) { .type = NUM, .as.num = (val) }, \
                                      .assigned = 1,                                   \
                                      .constant = 1,                                   \
                                      .type = NUM,                                     \
                                      .owner = current_owner })

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
}

__attribute__((destructor)) static void
delete_table()
{
        bt_destroy(&ts);
}

int
ts_print_entry(TS_Entry *e)
{
        if (!e) return 1;
        printf("%s: ", e->key);
        lit_print(e->value);

        printf(" (%s)", token_name(e->type));

        if (e->assigned) printf(", assigned");
        if (e->constant) printf(", constant");
        if (e->callable) printf(", callable");
        printf(", owner='%s'", e->owner);
        printf("\n");
        return 0;
}

void
ts_print_by_type(int type)
{
        BT *it;
        for_bt_each(it, &ts)
        {
                TS_Entry *e = it->value;
                if (e->type == type) ts_print_entry(e);
        }
}


void
ts_print()
{
        BT *it;
        for_bt_each(it, &ts)
        {
                ts_print_entry(it->value);
        }
}

void
ts_add(const char *key, TS_Entry entry)
{
        entry.owner = current_owner;
        bt_add(&ts, key, memdup(entry));
        ts_get(key)->key = ts_get_key_addr(key);
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
