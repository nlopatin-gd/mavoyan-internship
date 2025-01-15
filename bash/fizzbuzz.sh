#!/bin/bash

number=1

while [[ $number -le 100 ]]; do
    if [[ $(( number % 3 )) == 0 ]]; then
        if [[ $(( number % 5 )) == 0 ]]; then
            echo "FizzBuzz"
        else
            echo "Fizz"
        fi
    elif [[ $(( number % 5 )) == 0 ]]; then
        echo "Buzz"
    else
        echo $number
    fi
    number=$(( number + 1 ))
done

