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

def renumber(file_in, file_out, header_lines, for_upload):
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
    
    if for_upload:
        with open(file_out, "ab") as f_out:
            f_out.write(bytes([10, 145]))
        

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: renumber <in_file> <outfile> <label_file>")
        sys.exit()

    label_dict = parse_label_file(sys.argv[3])
    header_lines = ['rem "**** variable references ****"\n',
                    f"progstart = ${label_dict['PROG_START']}\n", 
                    f"maxiter = ${label_dict['MAX_ITER']}\n", 
                    f"initreal = ${label_dict['INIT_REAL']}\n",
                    f"initimag = ${label_dict['INIT_IMAG']}\n",
                    f"zoomlevel = ${label_dict['ZOOM_LEVEL']}\n",
                    f"defreal = ${label_dict['DEFAULT_INIT_REAL']}\n",
                    f"defimag = ${label_dict['DEFAULT_INIT_IMAG']}\n",
                    f"setzoom = ${label_dict['setZoomLevel']}\n",
                    f"derive = ${label_dict['deriveFromBasicValues']}\n",
                    f"xpos = ${label_dict['COUNT_X']}\n",
                    f"ypos = ${label_dict['COUNT_Y']}\n",
                    f"paramlen = ${label_dict['PIC_PARAMS_LEN']}\n",
                    f"paramaddr = ${label_dict['PIC_PARAMS']}\n",
                    f"txtrec = ${label_dict['drawRect']}\n",
                    f"clrtxtrec = ${label_dict['clearRect']}\n",
                    f"txtx = ${label_dict['RECT_PARAMS']}\n",
                    f"txty = ${label_dict['RECT_PARAMS']}+1\n",
                    f"lenx = ${label_dict['RECT_PARAMS']}+2\n",
                    f"leny = ${label_dict['RECT_PARAMS']}+3\n",
                    f"txtcol = ${label_dict['RECT_PARAMS']}+4\n",
                    f"txtovwr = ${label_dict['RECT_PARAMS']}+5\n",
                    'rem "**** Program text ****"\n',
                    'rem\n']
    renumber(sys.argv[1], sys.argv[2], header_lines, True)