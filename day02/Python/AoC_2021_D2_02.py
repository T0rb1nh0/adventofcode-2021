import re

def chapter_four():
    f = open("../Input/AoC_2021_D2.txt", "r")
    horizontal = 0
    depth = 0
    aim = 0
    for line in f:
        a = re.search("([a-z]+) (\d+)", line).groups()
        if a[0] == 'forward':
            horizontal += int(a[1])
            depth += aim * int(a[1])
        elif a[0] == 'down':
            aim += int(a[1])
        elif a[0] == 'up':
            aim -= int(a[1])

    print("Horizontal:")
    print(horizontal)
    print("Depth:")
    print(depth)
    print("Aim:")
    print(aim)
    print("Result:")
    print(horizontal * depth)

if __name__ == '__main__':
    chapter_four()