# Yaci

Yet Another Calculator Interpreter

> [!NOTE]
> WTF clang breaks flag.h. Now it's only compatible with gcc until I fix it.

## Features

- Supports numbers and strings
- Numbers (floating point): `2.9e-1`
- Strings: `"hello"`
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

### Tech

- flex + bison
- gnu readline
- Hugo's flag.h
- libffi


## Build

### Dependencies

- readline: you can install it using the system package manager.
  - ubuntu: `apt install libreadline-dev`

You can compile it from source 

```sh
make
```

### Test

```sh
make test
```

