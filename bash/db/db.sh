#!/bin/bash


count_chars (){
	local length=0
	for element in "$@"; do
		((length += ${#element}))
	done
	echo $length
}

create_db (){
	if [[ -z $1 ]]; then
		echo "Database name is required!"
		exit 1
	fi
	#if there is no file with this name
	touch "$1.txt"
	echo "Database $1 successfully created."
}

create_table () {
	if [ -z "$1" ] || [ -z "$2" ]; then
        	echo "Database name and table name are required!"
        	exit 1
    	fi
	db="$1.txt"
	if [ ! -f "$db" ]; then
       	 	echo "Error: Database '$1' does not exist."
        	exit 1
    	fi
	table_name="$2"
	shift 2
	params=("$@")
	chars_count_res=$(count_chars "${params[@]}")
	if [[ $chars_count_res -gt 34 ]]; then
		echo "Max length of line is 34!"
		exit 1
	fi
	echo >> "$db"
	for ((i=1; i<=39; i++)); do echo -n '*'; done >> "$db"
	echo >> "$db"	
	echo -n "** $table_name" >> "$db"
	count_of_spaces=$((34 - ${#table_name}))
       	for ((i=1; i<=$count_of_spaces; i++)); do echo -n ' '; done >> "$db"
	echo -n '**' >>	"$db"
	echo >> "$db"
	printf "** %-7s|%-8s|%-8s|%-8s**\n" "${params[0]}" "${params[1]}" "${params[2]}" "${params[3]}" >> "$db"
	for ((i=1; i<=39; i++)); do echo -n '*'; done >> "$db"
}

select_data() {
	found_persons=false

	while IFS= read -r line; do
   		 if [[ "$line" == *"$2"* ]]; then
        		found_persons=true
        		echo "$line"
        		continue
    		 fi

    		if $found_persons; then
       			if [[ "$line" == *"***************************************"* ]]; then
            			break
        		fi
        		echo "$line"
    		fi
	done < "$1.txt"
}

delete_data() {
    local db_file="$1.txt"
    local table_name="$2"
    local condition="$3"

    column=$(echo "$condition" | cut -d'=' -f1)
    value=$(echo "$condition" | cut -d'=' -f2)

    table_start=$(grep -n "^\*\* ${table_name}[[:space:]]*\*\*$" "$db_file" | cut -d: -f1)
    if [ -z "$table_start" ]; then
        echo "Error: Table '$table_name' does not exist in the database."
        return 1
    fi
    table_end=$(tail -n +$((table_start + 1)) "$db_file" | grep -nm 1 "^\*\*\*\*" | cut -d: -f1)
    table_end=$((table_start + table_end - 1))

    sed -n "${table_start},${table_end}p" "$db_file" > temp_table.txt

    header=$(head -n 1 temp_table.txt) 
    body=$(tail -n +2 temp_table.txt | grep -v "^\*\*[[:space:]]*${value}[[:space:]]*|")

    {
        echo "$header"
        echo "$body"
    } > temp_table.txt

    sed "${table_start},${table_end}d" "$db_file" > temp_db.txt
    awk -v line="$table_start" 'NR==line { while (getline < "temp_table.txt") print; next } { print }' temp_db.txt > final_db.txt
    mv final_db.txt "$db_file"

    rm temp_table.txt temp_db.txt

    echo "Row(s) matching condition '$condition' deleted from table '$table_name' and table reinserted in its original position."
}

insert_data() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Database name and table name are required!"
        exit 1
    fi

    db="$1.txt"
    if [ ! -f "$db" ]; then
        echo "Error: Database '$1' does not exist."
        exit 1
    fi

    table_name="$2"
    shift 2
    data=("$@")

    table_start_line=$(grep -n "^\*\* ${table_name}[[:space:]]*\*\*$" "$db" | cut -d: -f1)
    if [ -z "$table_start_line" ]; then
        echo "Error: Table '$table_name' does not exist in the database."
        exit 1
    fi

    insert_line=$((table_start_line + 2))

    formatted_data="**$(printf ' %-7s|%-8s|%-8s|%-8s' "${data[0]}" "${data[1]}" "${data[2]}" "${data[3]}")**"

    sed -i "${insert_line}i\\$formatted_data" "$db"

    echo "Data inserted into table '$table_name' at line $insert_line."
}


case "$1" in
    create_db)
        create_db "$2"
        ;;
    create_table)
        create_table "$2" "$3" "${@:4}"
        ;;
    insert_data)
        insert_data "$2" "$3" "${@:4}"
        ;;
    select_data)
        select_data "$2" "$3"
        ;;
    delete_data)
        delete_data "$2" "$3" "$4"
        ;;
    *)
        echo "Usage: $0 {create_db|create_table|insert_data|select_data|delete_data}"
        ;;
esac

