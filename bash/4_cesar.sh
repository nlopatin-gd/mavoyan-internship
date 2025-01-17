#!/bin/bash


key=
input_file=
output_file=

usage() {
 echo "Needed options:"
 echo " -s,    shift"
 echo " -i,    input file"
 echo " -o,    output file"
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( -n "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

while getopts "s:i:o:" opt; do
	case $opt in
		s)
			key=$OPTARG
			;;
		i)
			input_file=$OPTARG
			;;
		o)
			output_file=$OPTARG
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done
echo "$input_file"
echo "$output_file"
echo "$key"

if [[ -z "$key" || -z "$input_file" ]]; then
    echo "Error: Key (-s) and input file (-i) are required." >&2
    usage
    exit 1
fi

while IFS= read -r -n1 char; do
    if [[ $char =~ [a-z] ]]; then
        result+=$(printf \\$(printf '%03o' $(( ( $(printf '%d' "'$char") + key - 97 ) % 26 + 97 ))))
    elif [[ $char =~ [A-Z] ]]; then
        result+=$(printf \\$(printf '%03o' $(( ( $(printf '%d' "'$char") + key - 65 ) % 26 + 65 ))))
    else
        result+="$char"
    fi
done < "$input_file"
echo "$result" > "$output_file"
