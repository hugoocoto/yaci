#include <dlfcn.h>
#include <ffi.h>
#include <stdio.h>
#include <stdlib.h>
#include "call.h"

int
call(Call call)
{
        // Prepare the ffi_cif structure.
        if (ffi_prep_cif(&call.cif,
                         FFI_DEFAULT_ABI,
                         call.arg_value_size,
                         call.return_type,
                         call.arg_types) != FFI_OK) {
                perror("ffi_prep_cif");
                return 1;
        }

        // Invoke the function.
        void *func = dlsym(RTLD_DEFAULT, call.func_name);
        if (!func) {
                return 1;
        }

        ffi_call(&call.cif, func, call.result, call.arg_values);
        return 0;
}

void
call_free(Call call)
{
        // if (call.arg_types) free(call.arg_types);
        call.arg_value_size = 0;
        // if (call.arg_values) free(call.arg_values);
        call.arg_value_size = 0;
        if (call.func_name) free(call.func_name);
}

void
call_add_arg_type(Call *call, ffi_type *type)
{
        call->arg_types[call->arg_type_size] = type;
        ++call->arg_type_size;
}

void
call_add_arg_value(Call *call, void *value)
{
        call->arg_values[call->arg_value_size] = value;
        ++call->arg_value_size;
}

void
call_add_arg(Call *call, void *value, ffi_type *type)
{
        call_add_arg_value(call, value);
        call_add_arg_type(call, type);
}
