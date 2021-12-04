import copy

def chapter_six():
    f = open("../Input/AoC_2021_D3.txt", "r")
    oxygen_array = f.read().splitlines()
    co2_array = copy.deepcopy(oxygen_array)
    line_length = len(oxygen_array[0])

    for run in range(line_length):
        ox_amount = get_bit_count(oxygen_array, run)
        oxygen_array_temp = copy.deepcopy(oxygen_array)
        for ox_line in oxygen_array:
            if ox_amount[1] >= ox_amount[0] and ox_line[run] == '0' and ox_line in oxygen_array_temp and len(oxygen_array_temp) > 1:
                oxygen_array_temp.remove(ox_line)
            elif ox_amount[0] > ox_amount[1] and ox_line[run] == '1' and ox_line in oxygen_array_temp and len(oxygen_array_temp) > 1:
                oxygen_array_temp.remove(ox_line)

        oxygen_array = copy.deepcopy(oxygen_array_temp)

        co_amount = get_bit_count(co2_array, run)
        co2_array_temp = copy.deepcopy(co2_array)
        for co_line in co2_array:
            if co_amount[0] <= co_amount[1] and co_line[run] == '1' and co_line in co2_array_temp and len(co2_array_temp) > 1:
                co2_array_temp.remove(co_line)
            elif co_amount[1] < co_amount[0] and co_line[run] == '0' and co_line in co2_array_temp and len(co2_array_temp) > 1:
                co2_array_temp.remove(co_line)

        co2_array = copy.deepcopy(co2_array_temp)

    print("oxygen:")
    print(oxygen_array[0])
    print("c02:")
    print(co2_array[0])
    print("Result:")
    print(int(oxygen_array[0], 2) * int(co2_array[0], 2))


def get_bit_count(lines, column):
    zeros = 0
    ones = 0
    for line in lines:
        for run, char in enumerate(line):
            if char == '1' and column == run:
                ones += 1
            elif char == '0' and column == run:
                zeros += 1

    return zeros, ones




if __name__ == '__main__':
    chapter_six()