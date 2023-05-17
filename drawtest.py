def get_headers(label_dict):
    header_lines = ['rem "**** variable references ****"\n',
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
    
    return header_lines