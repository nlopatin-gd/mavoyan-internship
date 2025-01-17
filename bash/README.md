# Usage

To make all files executable
```
find . -type f -name "*.sh" -exec chmod +x {} \;
```
## 1. Fibonacci
![Screenshot](../screenshots/bash-task/task1.png)
Link to script -> [Fibonacci Script](https://github.com/nlopatin-gd/mavoyan-internship/blob/bash/bash/1_fibonacci.sh)
```
./1_fibonacci.sh
```
After executing script you should provide number then get answer.

<<<<<<< HEAD
Result:

![Screenshot](../screenshots/bash-task/1.png)

=======
>>>>>>> 3023404 (Fixed README)
## 2. Opnum
![Screenshot](../screenshots/bash-task/task2.png)
Link to script -> [ Script](https://github.com/nlopatin-gd/mavoyan-internship/blob/bash/bash/2_opnum.sh)
```
./2_opnum.sh -o "+" -n 1 2 3 4 5 
```
Change numbers and operation as you want.
<br/>
For debug mode
```
./2_opnum.sh -o "+" -n 1 2 3 4 5 -d
```

Result:

![Screenshot](../screenshots/bash-task/5.png)

## 3. Fizzbuzz
![Screenshot](../screenshots/bash-task/task3.png)
Link to script -> [ Script](https://github.com/nlopatin-gd/mavoyan-internship/blob/bash/bash/3_fizzbuzz.sh)
```
./3_fizzbuzz.sh
```
Result:

![Screenshot](../screenshots/bash-task/2.png)
![Screenshot](../screenshots/bash-task/3.png)


## 4. Cesar
![Screenshot](../screenshots/bash-task/task4.png)
Link to script -> [ Script](https://github.com/nlopatin-gd/mavoyan-internship/blob/bash/bash/4_cesar.sh)
```
./4_cesar.sh -s "shift" -i "input_file" -o "output_file"
./4_cesar.sh -s "shift" -i a.txt -o b.txt
```
Result:

![Screenshot](../screenshots/bash-task/4.png)

## 5. Getopts
![Screenshot](../screenshots/bash-task/task5.png)
Link to script -> [ Script](https://github.com/nlopatin-gd/mavoyan-internship/blob/bash/bash/5_getopts.sh)
```
./5_getopts.sh -i "input_file" -o "output_file" -v
./5_getopts.sh -i a.txt -o b.txt -v
```
```
./5_getopts.sh -i "input_file" -o "output_file" -s "word1" "word2"
./5_getopts.sh -i a.txt -o b.txt -s "word1" "word2"
```
```
./5_getopts.sh -i "input_file" -o "output_file" -l
./5_getopts.sh -i a.txx -o b.txt -l
```
```
./5_getopts.sh -i a.txt -o b.txt -r
```
```
./5_getopts.sh -i a.txt -o b.txt -u
```
Result:

![Screenshot](../screenshots/bash-task/6.png)
![Screenshot](../screenshots/bash-task/7.png)



## 6. Report
![Screenshot](../screenshots/bash-task/task6.png)
Link to script -> [ Script](https://github.com/nlopatin-gd/mavoyan-internship/blob/bash/bash/6_report.sh)
```
./6_report.sh
```
Result:

![Screenshot](../screenshots/bash-task/8.png)


# Testing

```
./testing.sh
```

![screenshot](../screenshots/bash-task/11.png)
![screenshot](../screenshots/bash-task/12.png)
