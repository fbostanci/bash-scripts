#!/bin/bash

 [[ -z $(echo $1 | tr -d 0-9) ]] && k=$1 || k=1
 [[ -z $1 || $1 -lt 1 || $1 -gt 100 ]] && k=1

    for ((n=1; n<=$k; n++))
    do
        shuf -i 1-34 -n 5 | sort -n | xargs echo -n;echo -n " + " ;shuf -i 1-14 -n 1
    done  
