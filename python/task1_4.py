import sys 

if len(sys.argv) != 2:
    print("Usage: python3 {sys.argv[0]} <string>")
    exit(0)

string = sys.argv[1]
dict = {}
for char in string:
    if char in dict:
        dict[char] += 1
    else:
        dict[char] = 1

print(string)
for char, count in dict.items():
    print(f'{char}: {count}')


