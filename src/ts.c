#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define memdup(x) memcpy(malloc(sizeof (x)), &(x), sizeof(x))

#include "ts.h"
#include "bt.h"

/* Tabla de simbolos */
static BT table = { 0 };

/* Añade los kwords a la tabla de simbolos. Reduce los kwords al tamaño maximo
 * de lexema, de tal manera que se puedan identificar aun siendo mas grandes de
 * lo posible. */
__attribute__((constructor)) static void
insert_keywords()
{
}

/* Borra la tabla de simbolos */
__attribute__((destructor)) static void
delete_table()
{
        bt_destroy(&table);
}

/* Pinta la tabla de simbolos */
void
ts_print()
{
        extern char *pretty;
        printf("----| Tabla de simbolos |----\n");
        pretty ? bt_write_pretty(stdout, &table) : bt_write(stdout, &table);
        printf("-----------------------------\n");
}

/* Añade un par key-entry a la tabla de simbolos. key es la llave que se indexa
 * en el arbol, y se copia en el heap. La entrada tambien se duplica en el heap.
 * Si ya hay una entrada con la misma key, se reemplaza el valor con entry. */
void
ts_add(const char *key, TS_Entry entry)
{
        bt_add(&table, key, memdup(entry));
}

/* Obtiene el valor dado una key, o NULL si no existe */
TS_Entry *
ts_get(const char *key)
{
        return bt_get(&table, key);
}

/* Obtiene la direccion de memoria donde reside la llave de la tabla de simbolos
 * dada una string cuyo contenido es igual al de la llave de la tabla de
 * simbolos */
char *
ts_get_key_addr(const char *key)
{
        return bt_get_key_addr(&table, key);
}

/* BT stuff under here */

/* Se añade un callback para destruir la entrada de la tabla de simbolos */
#define BT_VALUE_DELETE value_delete_callback
void
value_delete_callback(void *value)
{
        free(value);
}

#define BT_IMPLEMENTATION
#include "bt.h"
