#ifndef DEFS_H_
#define DEFS_H_

#define LIST_OF_TOKENS(TOK)                                                    \
  TOK(ID, 0, "id")                                                             \
  TOK(DECIMAL, 0, "decimal number")                                            \
  TOK(FLOAT, 0, "float number")                                                \
  TOK(PLUS, '+', "+")                                                          \
  TOK(LESS, '-', "-")                                                          \
  TOK(ASTERISK, '*', "*")                                                      \
  TOK(SLASH, '/', "/")                                                         \
  TOK(CARET, '^', "^")                                                         \
  TOK(PARL, '(', "(")                                                          \
  TOK(PARR, ')', ")")                                                          \
  TOK(CURLYL, '{', "{")                                                        \
  TOK(CURLYR, '}', "}")                                                        \
  TOK(BRACEL, '[', "[")                                                        \
  TOK(BRACER, ']', "]")                                                        \
  TOK(SEMICOLON, ';', ";")                                                     \
  TOK(DOT, '.', ".")                                                           \
  TOK(COMMA, ',', ",")                                                         \
  TOK(EQUAL, '=', "=")

#define TOKPRE(x) TOK_##x

#define COUNT_START 300

enum toktype {
#define T(x, y, z) TOKPRE(x) = y ? y : COUNT_START + __COUNTER__,
  LIST_OF_TOKENS(T)
#undef T
};

const int tok_count =
#define T(x, y, z) +1
    LIST_OF_TOKENS(T)
#undef T
    ;

#ifndef __cplusplus
const char *const toktype_repr[] = {
#define T(x, y, z) [TOKPRE(x)] = z,
    LIST_OF_TOKENS(T)
#undef T
};
#else
const char *const toktype_repr[tok_count] = {0};
#endif

#endif // !DEFS_H_
