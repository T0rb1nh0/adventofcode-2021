def chapter_two():
    f = open("../Input/AoC_2021_D1.txt", "r")
    signals = f.read().split()
    # convert string array to int array
    signals = [int(numeric) for numeric in signals]

    count = 0
    for run, signal in enumerate(signals):
        if len(signals) > run+3:
            current_value = signals[run] + signals[run+1] + signals[run+2]
            next_value = signals[run+1] + signals[run+2] + signals[run+3]

            if next_value > current_value:
                count += 1

    print("Result:")
    print(count)

if __name__ == '__main__':
    chapter_two()