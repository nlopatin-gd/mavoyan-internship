# Usage of DB

## Description

![Screenshot](../../screenshots/bash-task/db1.png)
![Screenshot](../../screenshots/bash-task/db2.png)

To create database

```
./db.sh create_db example_db
```
To create table 
```
./db.sh create_table example_db persons id name age height
```
To insert data
```
./db.sh insert_data example_db persons 0 Igor 36 180

```
To select data
```
./db.sh select_data example_db persons
```
To delete data 
```
bash db.sh delete_data example_db persons "id=0"
```

# Screenshots

![screenshot](../../screenshots/bash-task/9.png)
![screenshot](../../screenshots/bash-task/10.png)

