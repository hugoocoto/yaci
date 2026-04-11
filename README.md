# Yaci

Yet Another Calculator Interpreter

## Documentation

See `./docs`

## Features

- Supports numbers and strings
- Numbers (floating point): `2.9e-1`
- Strings: `"hello"`
- Ints: `12 as int`, to pass int arguments to functions
- Chars (they're numbers btw): `'c'`
- Cast: `"12" as num`, `pi as str`
- Constants: `pi`, `e`
- Variables: `a = 10;`
- User defined constants: `const a = 10;`
- Arithmetic operations: `+`, `(...)`, `^`
- Suppress output with `;`.
- FFI to `double(*)((double|str)?(, double|str)*)` functions: `log(12.5)`
- Commands: `clear`, `exit/quit`, `workspace` (not finished)
- Edit input line
- Clear input on ^C
- History
- Suggest commands
- Automate Test Workflow. Only gnu/linux is supported
- Rich flag support: `./yaci --help`
- Repl by default, supports `--norepl` option
- Interprete commands from file passing them as arguments
- Load files on runtime
- Hints on errors
- You can call raylib from yaci
- Etc..

### Tech

- flex + bison
- gnu readline
- Hugo's flag.h
- libffi


## Build

### Dependencies

- readline: you can install it using the system package manager.
  - ubuntu: `apt install libreadline-dev`
  - macos: `brew install readline`

- libffi: you can install it using the system package manager.
  - ubuntu: `apt install libreadline-dev`
  - macos: `brew install libffi`

You can compile it from source 

You can compile the interpreter using make. 

```sh
make
```

### Test the compiler

```sh
make test
```

```sh
valgrind --leak-check=full --show-leak-kinds=all --log-file=valgrind.log ./yaci
```

### Mac linkage errors

If your compiler fail to find the libraries, I fix it by manually setting the
following env vars.

```
export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig:/opt/homebrew/opt/readline/lib/pkgconfig"
export LDFLAGS="-L/opt/homebrew/opt/libffi/lib -L/opt/homebrew/opt/readline/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libffi/include -I/opt/homebrew/opt/readline/include"
make test
```
