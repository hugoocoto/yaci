#ifndef TS_H_
#define TS_H_

#include "lit.h"

#include <stdbool.h>

typedef struct TS_Entry {
        Lit value;
        bool assigned; // false by default
        bool constant; // false by default
        bool callable; // false by default
        int type;
} TS_Entry;

extern void ts_add(const char *key, TS_Entry entry); // añade entry a la tabla de simbolos, indexada por key
extern TS_Entry *ts_get(const char *key);            // obtiene una entrada dada una key, o NULL si no existe
extern void ts_print();                              // pinta el arbol
extern char *ts_get_key_addr(const char *key);       // obtiene la direccion de memoria de una key

#endif // !TS_H_
