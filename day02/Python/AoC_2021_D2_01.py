import re

def chapter_three():
    f = open("../Input/AoC_2021_D2.txt", "r")
    horizontal = 0
    depth = 0
    for line in f:
        a = re.search("([a-z]+) (\d+)", line).groups()
        if a[0] == 'forward':
            horizontal += int(a[1])
        elif a[0] == 'down':
            depth += int(a[1])
        elif a[0] == 'up':
            depth -= int(a[1])

    print("Horizontal:")
    print(horizontal)
    print("Depth:")
    print(depth)
    print("Result:")
    print(horizontal * depth)

if __name__ == '__main__':
    chapter_three()
