import sys
import re

LINE_STEP = 5
LINE_START = 100

r_exp = re.compile('^\\s*(\\w+)\\s*= [$]([a-f0-9]{1,4})(\\s.*)?$', re.M)

def parse_label_file(label_file):
    res = {}
    lines_in = []
    with open(label_file, "r") as l_file:
        lines_in = l_file.readlines()

    for i in lines_in:
        m = r_exp.match(i)
        if m != None:
            res[m.group(1)] = m.group(2)
        
    return res

def renumber(file_in, file_out, header_lines):
    lines_in = []
    with open(file_in, "r") as f_in:
        lines_in = f_in.readlines()
    
    lines_in = header_lines + lines_in

    num_len = len(str(len(lines_in) * LINE_STEP))

    txt_with_numbers = []

    line_number = LINE_START
    for i in lines_in:
        txt_with_numbers += f"{str(line_number).ljust(num_len)} {i}" 
        line_number += LINE_STEP

    with open(file_out, "w") as f_out:
        f_out.writelines(txt_with_numbers)
        

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: renumber <in_file> <outfile> <label_file>")
        sys.exit()

    label_dict = parse_label_file(sys.argv[3])
    header_lines = ['rem "**** variable references ****"\n',
                    f"maxiter = ${label_dict['MAX_ITER']}\n", 
                    f"stepx = ${label_dict['STEP_X']}\n",
                    f"stepy = ${label_dict['STEP_Y']}\n",
                    f"initreal = ${label_dict['INIT_REAL']}\n",
                    f"initimag = ${label_dict['INIT_IMAG']}\n",
                    'rem "**** Program text ****"\n',
                    'rem\n']
    renumber(sys.argv[1], sys.argv[2], header_lines)