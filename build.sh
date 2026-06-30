#!/bin/bash
MCC=${MCC:-"mcc"}
CC=${CC:-"cc"}
AR=${AR:-"ar"}

run_echo() {
  echo "$@"
  $@ || exit 1
}

compile_example() {
  run_echo $MCC -I src -c $1 -o "${1%.mc}.o"
  run_echo $CC -lz "${1%.mc}.o" -o "build/${1%.mc}"
}

compile_lib() {
  run_echo $MCC -c $1 -o "${1%.mc}.o"
  run_echo $AR -rc "build/$2.a" "${1%.mc}.o"
}

mkdir -p build
mkdir -p build/examples

compile_lib src/zlib.mc libz

for f in examples/*.mc; do compile_example $f; done
