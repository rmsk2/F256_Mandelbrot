import sys

LINE_STEP = 5


def renumber(file_in, file_out):
    lines_in = []
    with open(file_in, "r") as f_in:
        lines_in = f_in.readlines()
    
    num_len = len(str(len(lines_in) * LINE_STEP))

    txt_with_numbers = []

    line_number = LINE_STEP
    for i in lines_in:
        txt_with_numbers += f"{str(line_number).ljust(num_len)} {i}" 
        line_number += LINE_STEP

    with open(file_out, "w") as f_out:
        f_out.writelines(txt_with_numbers)
        

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: renumber <in_file> <outfile>")
        sys.exit()

    renumber(sys.argv[1], sys.argv[2])