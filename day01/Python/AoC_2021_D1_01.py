def chapter_one():
    f = open("../Input/AoC_2021_D1.txt", "r")
    count = 0
    prev = None
    for signal in f:
        signal = int(signal)
        if prev and signal > prev:
            count = count + 1
        prev = signal

    print("Result:")
    print(count)

if __name__ == '__main__':
    chapter_one()
