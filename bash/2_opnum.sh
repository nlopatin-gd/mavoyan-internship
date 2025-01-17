#!/bin/bash

nums=()
operation=""
dflag=0

while getopts "o:n:d" opt; do
  case $opt in
    o)
	operation="$OPTARG"
      ;;
    n)
	 shift $((OPTIND - 2))
	 while [[ $# -gt 0 && "$1" != -* ]]; do
        	if [[ "$1" =~ ^-?[0-9]+$ ]]; then
          		nums+=("$1")
        	else
          		echo "Invalid number: $1" >&2
			echo "If you are using *, use with parenthesis"
          		exit 1
       		fi
        	shift
      	done
	OPTIND=1
	;;
    d)
	dflag=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$operation" || ${#nums[@]} -eq 0 ]]; then
  echo "Usage: $0 -o [operation] -n [numbers...] [-d]" >&2
  exit 1
fi
result=${nums[0]}

for number in "${nums[@]:1}"; do
    case $operation in
         +)
            result=$((result + number))
            ;;
         -)
            result=$((result - number))
            ;;
        "*")
            result=$((result * number))
            ;;
        %)
            result=$((result % number))
            ;;
        *)
            echo "Invalid operation: $operation" >&2
            exit 1
            ;;
    esac
done
echo "Result: $result"

if [[ $dflag -eq 1 ]]; then
  echo "Debug Information:"
  echo "User: $USER"
  echo "Script: $0"
  echo "Operation: $operation"
  echo "Numbers: ${nums[@]}"
fi
