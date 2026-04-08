#ifndef TS_H_
#define TS_H_

#include "lit.h"

#include <stdbool.h>

typedef struct TS_Entry {
        const char *key;
        const char *owner;
        Lit value;
        bool assigned; // false by default
        bool constant; // false by default
        bool callable; // false by default
        int type;
} TS_Entry;

extern const char *const OWNER_REPL;
extern const char *const OWNER_CNST;

extern void set_owner(const char *);
extern const char *get_owner();

extern void ts_add(const char *key, TS_Entry entry);
extern TS_Entry *ts_get(const char *key);
extern void ts_print();
extern int ts_print_entry(TS_Entry *e);
extern void ts_print_by_type(int type);
extern char *ts_get_key_addr(const char *key);

#endif // !TS_H_
