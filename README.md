# YACI

**Yet Another Calculator Interpreter**

YACI is an interactive interpreter for evaluating mathematical and text
expressions. It reads expressions, evaluates them, and prints the result. It
can also execute script files and call functions from compiled C libraries
(FFI).

## Documentation

A full user manual (in Spanish) is available at [`docs/yaci-es.pdf`](docs/yaci-es.pdf).

## Features

- **Numbers** (double-precision float): `42`, `3.14`, `.5`, `2.9e-1`, `1e6`, `INF`, `NAN`
- **Characters** (integer literals): `'A'` → `65`
- **Strings**: `"hello"`, `'world'` — with escape sequences (`\n`, `\t`, …)
- **Lists**: `{1, 2, 3}`, `{}`, `{"a", "b"}`
- **Boolean literals**: `true`/`false`, `on`/`off`, `yes`/`no` (stored as `1`/`0`)
- **Built-in constants**: `pi`, `e`, `sqrt2`, `ln2`, `ln10`, `log2e`, `log10e`, `pi_2`, `pi_4`; integer shorthands `zero`…`ten`
- **Variables**: `a = 10`
- **User-defined constants**: `const G = 9.8` (read-only after definition)
- **Arithmetic operators**: `+`, `-`, `*`, `/`, `^` (right-associative), unary `-`
- **Operator aliases**: `plus`, `minus`; assignment form `let x be 5`
- **Type casting** (`as`): `"12.5" as num`, `3.14 as str`, `1 as int`, `42 as list`
- **Assertion** (`eq!`): `1 + 1 eq! 2` — exits with error if values don't match
- **Suppress output** with `;` or `shh!` or `, but be quiet`
- **Comments**: `# line comment` or `// line comment`
- **FFI** — call any C shared-library function:
  - `open ./libm.so` / `open <math.h>` (GNU/Linux alias for libm)
  - `sqrt(2)`, `log(e)` — returns `num` by default
  - `strcspn("abc", "b") -> int` — specify return type with `->`
  - `InitWindow(800 as int, 450 as int, "title")` — pass integers with `as int`
- **REPL commands**: `clear`, `exit`/`quit`, `workspace`/`ws`, `del`/`delete`, `verbose`, `echo`, `load`
- **Script files** (`.yc`): run with `./yaci script.yc --norepl`
- **Load files at runtime**: `load ./constants.yc`
- **Circular-load detection** (prevents infinite recursion)
- **REPL** with readline: vi-mode editing, history, Tab completion, configurable prompt
- **CLI flags**: `--norepl`, `--verbose`/`-v`, `--noecho`/`-E`, `--nocolor`/`-C`, `--prompt`
- **Automated test suite**: `make test` (GNU/Linux)

### Tech

- flex + bison
- GNU readline
- libffi
- Hugo's flag.h

## Build

### Dependencies

- **readline**:
  - Ubuntu/Debian: `apt install libreadline-dev`
  - macOS: `brew install readline`

- **libffi**:
  - Ubuntu/Debian: `apt install libffi-dev`
  - macOS: `brew install libffi`

Compile the interpreter with:

```sh
make
```

### Running tests

```sh
make test
```

For memory-leak checking:

```sh
valgrind --leak-check=full --show-leak-kinds=all --log-file=valgrind.log ./yaci
```

### macOS linkage errors

If the compiler cannot find the libraries, set the following environment
variables before running `make`:

```sh
export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig:/opt/homebrew/opt/readline/lib/pkgconfig"
export LDFLAGS="-L/opt/homebrew/opt/libffi/lib -L/opt/homebrew/opt/readline/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libffi/include -I/opt/homebrew/opt/readline/include"
make
```

## Usage

```sh
./yaci                        # interactive REPL
./yaci script.yc              # run script, then enter REPL
./yaci script.yc --norepl     # run script only, no REPL
./yaci --verbose              # enable hints on errors
./yaci --help                 # show all options
```

### Quick examples

```
>> 2 + 3
=5
>> radio = 5
=5
>> pi * radio ^ 2
=78.5398
>> "hello" as list
={"hello"}
>> const G = 9.8;
>> open <math.h>
>> sqrt(2)
=1.41421
>> strcspn("abc", "b") -> int
=1
```

### CLI options

| Option | Short | Description |
|--------|-------|-------------|
| `--norepl` | | Do not enter REPL mode after processing files |
| `--verbose` | `-v` | Show hints alongside error messages |
| `--noecho` | `-E` | Do not print expression results |
| `--nocolor` | `-C` | Disable colored output |
| `--prompt X` | | Use `X` as the REPL prompt (default: `>> `) |
| `--help` | `-h` | Show help and exit |


### Things that are not done

- Some things are not properly free on errors
- Path is relative to the interpreter, not to the file
- There are more than one errors, but I don't find them yet.
