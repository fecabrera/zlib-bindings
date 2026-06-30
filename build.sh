#!/bin/bash
MCC=${MCC:-"mcc"}
CC=${CC:-"cc"}
AR=${AR:-"ar"}

run_echo() {
  echo "$@"
  $@ || exit 1
}

compile_example() {
  run_echo $MCC -I lib/libz -c $1 -o "${1%.mc}.o"
  run_echo $CC -lz lib/libz.a "${1%.mc}.o" -o ${1%.mc}
}

compile_lib() {
  run_echo $MCC -c $1 -o "${1%.mc}.o"
  run_echo $MCC --emit-interface $1 -o "lib/libz/$(basename ${1%.mc}).mci"
  run_echo $AR -rc "lib/$2.a" "${1%.mc}.o"
}

mkdir -p lib
mkdir -p lib/libz

compile_lib src/zlib.mc libz

for f in examples/*.mc; do compile_example $f; done
