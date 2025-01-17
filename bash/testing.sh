#!/bin/bash

test_getNth() {
    local input=$1
    local expected=$2

    local result=$(echo "$input" | ./fibonacci.sh | grep "Answer:" | awk '{print $2}')

    if [[ "$result" == "$expected" ]]; then
        echo "Test passed for input: $input"
    else
        echo "Test failed for input: $input. Expected: $expected, Got: $result"
        exit 1
    fi
}

test_cesar() {
  shift=$1
  input=$2
  expected_output=$3
  input_file=$(mktemp)
      output_file=$(mktemp)

  echo -n "$input" > "$input_file"
  ./cesar.sh -s "$shift" -i "$input_file" -o "$output_file" > /dev/null 2>&1
  
  actual_output=$(cat "$output_file")

  if [[ "$actual_output" == "$expected_output" ]]; then
          echo "Test passed for shift: $shift, input: \"$input\""
      else
          echo "Test failed for shift: $shift, input: \"$input\""
          echo "Expected: \"$expected_output\", Got: \"$actual_output\""
          exit 1
      fi

  rm "$input_file" "$output_file"

}

test_fizzbuzz() {
  expected_output=$(cat expected_fizzbuzz.txt)
  actual_output=$(bash fizzbuzz.sh /dev/null 2>&1)

  if [[ "$actual_output" == "$expected_output" ]]; then
                echo "Test passed"
        else
                echo "Test failed"
                echo "Expected: \"$expected_output\", Got: \"$actual_output\""
                exit 1
        fi
  
}

test_getopts() {
  input=$1
  option=$2
  expected_output=$3

  input_file=$(mktemp)
  output_file=$(mktemp)

  echo -n "$input" > "$input_file"

  bash getopts.sh -i $input_file -o $output_file $option > /dev/null 2>&1

  actual_output=$(cat $output_file)
  if [[ "$actual_output" == "$expected_output" ]]; then
                echo "Test passed for input: $input, option: \"$option\""
        else
                echo "Test failed for input: $input, option: \"$option\""
                echo "Expected: \"$expected_output\", Got: \"$actual_output\""
                exit 1
        fi

}

test_opnum() {
    description=$1
    operation=$2
    numbers=$3
    debug=$4
    expected_output=$5
    expected_debug=$6

    command="bash opnum.sh -o \"$operation\" -n $numbers"
    if [[ "$debug" == "1" ]]; then
        command="$command -d"
    fi

    actual_output=$(eval "$command")

    if [[ "$actual_output" == *"$expected_output"* ]]; then
        echo "Test passed: $description"
    else
        echo "Test failed: $description"
        echo "Expected output: \"$expected_output\""
        echo "Actual output: \"$actual_output\""
        exit 1
    fi

    if [[ "$debug" == "1" ]]; then
        if [[ "$actual_output" == *"$expected_debug"* ]]; then
            echo "Debug information correct for: $description"
        else
            echo "Debug information incorrect for: $description"
            echo "Expected debug: \"$expected_debug\""
            echo "Actual output: \"$actual_output\""
            exit 1
        fi
    fi
}

echo "Running tests for Fibonacci script..."

test_getNth 0 0
test_getNth 1 1
test_getNth 2 1
test_getNth 3 2
test_getNth 4 3
test_getNth 5 5
test_getNth 6 8
test_getNth 7 13
test_getNth 10 55

echo "All tests passed successfully!"
echo "---------------------------------------"
echo "Running tests for Cesar script..."

test_cesar 0 "PlainText" "PlainText"
test_cesar 1 "abc" "bcd"
test_cesar 3 "Hello world" "Khoor zruog"

echo "All tests passed successfully!"
echo "---------------------------------------"
echo "Running tests for Fizzbuzz script..."

test_fizzbuzz 

echo "---------------------------------------"
echo "Running tests for getopts script..."

test_getopts "Hello World" "-v" "hELLO wORLD"

test_getopts "Hello World" "-s Hello Hi" "Hi World"

test_getopts "Hello World" "-r" "dlroW olleH"

test_getopts "Hello World" "-l" "hello world"

test_getopts "Hello World" "-u" "HELLO WORLD"
echo "---------------------------------------"
echo "Running tests for opnums script..."

test_opnum "Addition" "+" "1 2 3" 0 "Result: 6" ""
test_opnum "Subtraction" "-" "10 4 2" 0 "Result: 4" ""
test_opnum "Multiplication" "*" "2 3 4" 0 "Result: 24" ""
test_opnum "Modulus" "%" "10 3" 0 "Result: 1" ""

test_opnum "Subtraction with debug" "-" "10 4 2" 1 "Result: 4" "Result: 4
Debug Information:
User: mane
Script: opnum.sh
Operation: -
Numbers: 10 4 2"

echo "All tests passed successfully!"
echo "---------------------------------------"
