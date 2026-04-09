#ifndef COLORS_H_
#define COLORS_H_

#define FGBLACK "30"
#define FGRED "31"
#define FGGREEN "32"
#define FGYELLOW "33"
#define FGBLUE "34"
#define FGMAGENTA "35"
#define FGCYAN "36"
#define FGWHITE "37"

#define BGBLACK "40"
#define BGRED "41"
#define BGGREEN "42"
#define BGYELLOW "43"
#define BGBLUE "44"
#define BGMAGENTA "45"
#define BGCYAN "46"
#define BGWHITE "47"

#define BOLD "1"

#define RESET "0"

#define COLOR(s, ...) "\033[" __VA_OPT__(SCCONCAT00(__VA_ARGS__)) s "m"
#define FIRST(x, ...) x
#define SCCONCAT00(x, ...) x __VA_OPT__(SCCONCAT01(__VA_ARGS__)) ";"
#define SCCONCAT01(x, ...) x __VA_OPT__(SCCONCAT02(__VA_ARGS__)) ";"
#define SCCONCAT02(x, ...) x __VA_OPT__(SCCONCAT03(__VA_ARGS__)) ";"
#define SCCONCAT03(x, ...) x __VA_OPT__(SCCONCAT04(__VA_ARGS__)) ";"
#define SCCONCAT04(x, ...) x __VA_OPT__(SCCONCAT05(__VA_ARGS__)) ";"
#define SCCONCAT05(x, ...) x __VA_OPT__(FIRST(__VA_ARGS__)) ";"


#endif // !COLORS_H_
