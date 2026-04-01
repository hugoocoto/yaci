#include "ffi.h"

/* TYPES */
// ffi_type_void;
// ffi_type_uint8;
// ffi_type_sint8;
// ffi_type_uint16;
// ffi_type_sint16;
// ffi_type_uint32;
// ffi_type_sint32;
// ffi_type_uint64;
// ffi_type_sint64;
// ffi_type_float;
// ffi_type_double;
// ffi_type_pointer;
// ffi_type_longdouble;

#define MAX_ARGS 16

typedef struct {
        char *func_name;
        ffi_cif cif;
        ffi_type *arg_types[MAX_ARGS];
        void *arg_values[MAX_ARGS];
        size_t arg_value_size;
        size_t arg_type_size;
        ffi_status status;
        ffi_type *return_type;
        void* result;
} Call;

void call_add_arg(Call *call, void *value, ffi_type *type);
void call_free(Call call);
int call(Call call);
