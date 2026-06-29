#!/bin/bash
MCC=${MCC:-"mcc"}
CC=${CC:-"cc"}

run_echo() {
  echo "$@"
  $@ || exit 1
}

compile() {
  run_echo $MCC -I src -c $1 -o "${1%.mc}.o"
  run_echo CC -lz "${1%.mc}.o" -o ${1%.mc}
}

for f in examples/*.mc; do compile $f; done
