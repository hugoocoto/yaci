#ifndef QQ_H_

// Queue wrapper around DA

// API
// extern const char *qqtop();
// extern void qqpush(elem);
// extern void qqpop();

#define QQ_H_
#include "da.h"

#define QQ DA
#define for_qq_each for_da_each

#define qqtop(q_ptr) (q_ptr)->data[(q_ptr)->count - 1]

#define qqpush(q_ptr, ...)                       \
        do {                                     \
                da_append((q_ptr), __VA_ARGS__); \
        } while (0)

#define qqpop(q_ptr)                         \
        do {                                 \
                if ((q_ptr)->count <= 0) {   \
                        assert(0 && "qpop"); \
                }                            \
                (q_ptr)->count -= 1;         \
        } while (0)

#endif // !QQ_H_
