#!/bin/bash
SCRIPT=$(redis-cli SCRIPT LOAD "$(cat size_by_prefix.lua)")
for i in "$@"
do redis-cli EVALSHA $SCRIPT 0 "$i:"
done