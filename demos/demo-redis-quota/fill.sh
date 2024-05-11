#!/bin/bash
PREFIX=${1?:prefix}
N=${2?:count}
X=$(printf "x%.0s" {1..1024})
for i in $(seq 1 $N)
do K=$RANDOM
   echo $i $K
   redis-cli set $PREFIX:$K "$X"
done
