#!/bin/bash

getNth() {
    if [[ $1 == 0 ]]; then
        echo 0
    elif [[ $1 == 1 ]]; then
        echo 1
    elif [[ $1 -gt 1 ]]; then
        a=$(getNth $(( $1 - 1 )))
        b=$(getNth $(( $1 - 2 )))
        result=$(( a + b ))
        echo $result
    else
	return 255
    fi
}

read -r -p "Give the number: " n

if [[ $n -lt 0 ]]; then
    echo "Please enter a positive number!"
    exit 1
fi

answer=$(getNth "$n")
echo "Answer: $answer"

