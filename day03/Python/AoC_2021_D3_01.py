def chapter_five():
    f = open("../Input/AoC_2021_D3.txt", "r")
    values = {}
    for line in f:
        for run, char in enumerate(line):
            if char == '\n':
                continue

            if run not in values.keys():
                values[run] = {
                    1: 0,
                    0: 0
                }

            if char == '1':
                values[run][1] += 1
            else:
                values[run][0] += 1

    gamma_rate = ''
    epsilon_rate = ''
    for x in values:
        if values[x][1] > values[x][0]:
            gamma_rate += '1'
            epsilon_rate += '0'
        else:
            gamma_rate += '0'
            epsilon_rate += '1'

    print("Epsilon Rate:")
    print(epsilon_rate)
    print("Gamma Rate:")
    print(gamma_rate)
    print("Result:")
    print(int(epsilon_rate, 2) * int(gamma_rate, 2))

if __name__ == '__main__':
    chapter_five()