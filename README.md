# zlib-bindings

[**zlib**](https://github.com/madler/zlib) bindings for [**mcc**](https://github.com/fecabrera/mcc)

## Requirements

- `mcc`
- `cc` (`gcc` or `clang`)
- `zlib`

## Quickstart

clone the repo:

```bash
git clone https://github.com/fecabrera/zlib-bindings
cd zlib-bindings
```

also, if you want to, you can build a static library and the `.mci` interfaces

```bash
./build.sh
```

create you `main.mc`:

```c
import "std";
import "zlib";

fn main() -> int32 {
  println("ZLIB_VERSION:  %s", ZLIB_VERSION);
  println("zlibVersion(): %s", zlibVersion());

  return 0;
}
```

then compile and link against zlib

```bash
mcc -c main.mc -I src/
cc -lz main.o
```

or using the static library and interfaces created before:

```bash
mcc -c main.mc -I lib/libz
cc -lz main.o lib/libz.a  # note that you still need to use -lz
```

and run your binary

```bash
./a.out
```
