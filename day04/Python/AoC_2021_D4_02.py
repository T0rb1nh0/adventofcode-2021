import copy

def chapter_eight():
    f = open("../Input/AoC_2021_D4.txt", "r")
    file_data = f.read().splitlines()

    result = build_boards(file_data)
    finish = play_game(result[0], result[1])

    field_counter = 0
    for row in finish[1]:
        for field in row:
            if not field[1]:
                field_counter += int(field[0])

    print("result")
    print((field_counter/2) * int(finish[0])) #devide result by two cause of double entries for boards

def play_game(numbers, boards):
    for number in numbers:
        finished_boards = []
        for count_board, board in enumerate(boards):
            for count_line, line in enumerate(board):
                for count_field, field in enumerate(line):
                    if number == field[0]:
                        boards[count_board][count_line][count_field] = (number, 1)

            final_board = check_board(board)
            if final_board and len(boards) == 1:
                return number, final_board
            elif final_board:
                finished_boards.append(final_board)

        for finished_board in finished_boards:
            boards.remove(finished_board)

    return 0

def check_board(board):
    for row in board:
        field_counter = 0
        for field in row:
            if field[1] == 1:
                field_counter += 1

        if field_counter == len(row):
            return board

    return 0


def build_boards(file_data):
    draws = []
    boards = []

    for row, line in enumerate(file_data):
        if row == 0:
            draws = line.split(",")
            continue

        if line == '':
            boards.append([])
        else:
            number_arr = []
            for number in line.split(" "):
                if number == '':
                    continue
                number_arr.append((number, 0))
            boards[-1].append(number_arr)

    boards_copy = copy.deepcopy(boards)
    for number, board in enumerate(boards_copy):
        reverse_boards = [[] for i in range(len(board[0]))]
        for row in board:
            for count, field in enumerate(row):
                reverse_boards[count].append(field)

        for reverse_board in reverse_boards:
            boards[number].append(reverse_board)

    return draws, boards

if __name__ == '__main__':
    chapter_eight()