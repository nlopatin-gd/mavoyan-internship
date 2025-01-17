#!/bin/bash

bash db.sh create_db "test_db"
if [ -f "test_db.txt" ]; then
    echo "  Pass: Database created."
else
    echo "  Fail: Database not created."
    exit 1
fi

bash db.sh create_table "test_db" "test_table" "col1" "col2" "col3" "col4"
if grep -q "test_table" "test_db.txt"; then
    echo "  Pass: Table created."
else
    echo "  Fail: Table not created."
    exit 1
fi

bash db.sh insert_data "test_db" "test_table" "data1" "data2" "data3" "data4"
if grep -q "data1" "test_db.txt"; then
    echo "  Pass: Data inserted."
else
    echo "  Fail: Data not inserted."
    exit 1
fi

output=$(bash db.sh select_data "test_db" "test_table")

expected_output="** test_table                        **
** col1   |col2    |col3    |col4    **
** data1  |data2   |data3   |data4   **"

if [[ "$output" == "$expected_output" ]]; then
    echo "  Pass: Data selected."
else
    echo "  Fail: Data not selected."
    exit 1
fi

bash db.sh delete_data "test_db" "test_table" "col1=data1"
if ! grep -q "data1" "test_db.txt"; then
    echo "  Pass: Data deleted."
else
    echo "  Fail: Data not deleted."
    exit 1
fi

echo "All basic tests completed!"
