#!/bin/bash

input_file=
output_file=
declare -a s_args

usage() {
    echo "Usage: $0 -i <input_file> -o <output_file> [options]"
    echo
    echo "Options:"
    echo "  -i <input_file>       Specify the input file (required)"
    echo "  -o <output_file>      Specify the output file (required)"
    echo "  -v                    Convert text to its opposite case and append to output"
    echo "  -s <old> <new>        Replace occurrences of <old> with <new> in the input and append to output"
    echo "  -r                    Reverse the lines of the input and append to output"
    echo "  -l                    Convert text to lowercase and append to output"
    echo "  -u                    Convert text to uppercase and append to output"
    echo
    echo "Examples:"
    echo "  $0 -i input.txt -o output.txt -v"
    echo "  $0 -i input.txt -o output.txt -s old new"
    echo "  $0 -i input.txt -o output.txt -r"
    echo
    exit 1
}

while getopts "i:o:vs:rlu" opt; do
    case ${opt} in
	i)
		input_file=$OPTARG
		;;
	o)
		output_file=$OPTARG
		;;
        v)
		cat "$input_file" | tr 'a-zA-Z' 'A-Za-z' >> "$output_file"
            ;;
        s)
		s_args+=("$OPTARG")
		while [[ $OPTIND -le $# && ! ${!OPTIND} =~ ^- ]]; do
        		s_args+=("${!OPTIND}")
        		OPTIND=$((OPTIND + 1))
      		done
		cat "$input_file" | sed "s/${s_args[0]}/${s_args[1]}/g" >> "$output_file"
      		;;	
        r)
		cat "$input_file" | rev >> "$output_file"
            ;;
        l)
		cat "$input_file" | tr '[:upper:]' '[:lower:]' >> "$output_file"
            ;;
        u)
		cat "$input_file" | tr '[:lower:]' '[:upper:]' >> "$output_file"
            ;;
	*)
	   usage
	   ;;
    esac
done

if [[ -z "$input_file" || -z "$output_file" ]]; then
	usage
fi

echo "Input file: $input_file"
echo "Output file: $output_file"

