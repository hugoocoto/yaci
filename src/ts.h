#ifndef TS_H_
#define TS_H_

#include "lit.h"

#include <stdbool.h>

enum ASSIGN_TO {
        A_NONE = false,
        A_INIT = true,
        A_VALUE,
};

typedef struct TS_Entry {
        const char *key;
        const char *owner;
        Lit value;
        enum ASSIGN_TO assigned; // A_NONE by default
        bool constant;           // false by default
        bool callable;           // false by default
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
extern void ts_print_by_owner(char *owner);
extern char *ts_get_key_addr(const char *key);

extern void ts_del_all();
extern void ts_del_entry(TS_Entry *e);
extern void ts_del_by_owner(char *owner);

#endif // !TS_H_
