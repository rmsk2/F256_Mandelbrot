def get_headers(label_dict):
    header_lines = ['rem "**** variable references ****"\n',
                f"progstart = ${label_dict['PROG_START']}\n", 
                f"maxiter = ${label_dict['MAX_ITER']}\n",
                f"numiter = ${label_dict['NUM_ITER']}\n", 
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
                f"calcintrpt = ${label_dict['CALC_INTERRUPTED']}\n",
                f"progsig = ${label_dict['PROG_SIG']}\n",
                f"plotstate = ${label_dict['PLOT_STATE']}\n",
                f"defaultcol1 = ${label_dict['chooseColourDefault']}\n",
                f"altcol1 = ${label_dict['chooseColourAlt1']}\n",
                f"colshift = ${label_dict['PLOT_STATE']}+3\n",
                'rem "**** Program text ****"\n',
                'rem\n']
    
    return header_lines