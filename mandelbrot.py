def get_headers(label_dict):
    prog_start = int(label_dict['PROG_START'], 16)
    prog_end = int(label_dict['PROG_END'], 16)

    def relative_address(label):
        offset = int(label_dict[label], 16) - prog_start
        return f"progstart + ${offset:x}"

    # ALLOC(0) probes without consuming memory. Legacy SuperBASIC allocates
    # below $2000; newer versions share $4000-$7fff with this fixed image.
    # Reject other layouts instead of loading over an occupied array area.
    header_lines = ['rem "**** variable references ****"\n',
                f"progorg = ${prog_start:x}\n",
                f"progsize = ${prog_end - prog_start:x}\n",
                "progstart = progorg\n",
                "allocstart = alloc(0)\n",
                "if allocstart = progorg\n",
                "    progstart = alloc(progsize)\n",
                "else\n",
                "    if allocstart >= $2000\n",
                '        print "Machine-language memory is not available at $4000"\n',
                "        end\n",
                "    endif\n",
                "endif\n",
                f"maxiter = {relative_address('MAX_ITER')}\n",
                f"numiter = {relative_address('NUM_ITER')}\n",
                f"initreal = {relative_address('INIT_REAL')}\n",
                f"initimag = {relative_address('INIT_IMAG')}\n",
                f"zoomlevel = {relative_address('ZOOM_LEVEL')}\n",
                f"defreal = {relative_address('DEFAULT_INIT_REAL')}\n",
                f"defimag = {relative_address('DEFAULT_INIT_IMAG')}\n",
                f"setzoom = {relative_address('setZoomLevel')}\n",
                f"derive = {relative_address('deriveFromBasicValues')}\n",
                f"xpos = {relative_address('COUNT_X')}\n",
                f"ypos = {relative_address('COUNT_Y')}\n",
                f"paramlen = ${label_dict['PIC_PARAMS_LEN']}\n",
                f"paramaddr = {relative_address('PIC_PARAMS')}\n",
                f"txtrec = {relative_address('drawRect')}\n",
                f"clrtxtrec = {relative_address('clearRect')}\n",
                f"txtx = {relative_address('RECT_PARAMS')}\n",
                f"txty = {relative_address('RECT_PARAMS')} + 1\n",
                f"lenx = {relative_address('RECT_PARAMS')} + 2\n",
                f"leny = {relative_address('RECT_PARAMS')} + 3\n",
                f"txtcol = {relative_address('RECT_PARAMS')} + 4\n",
                f"txtovwr = {relative_address('RECT_PARAMS')} + 5\n",
                f"calcintrpt = {relative_address('CALC_INTERRUPTED')}\n",
                f"progsig = {relative_address('PROG_SIG')}\n",
                f"plotstate = {relative_address('PLOT_STATE')}\n",
                f"defaultcol1 = {relative_address('chooseColourDefault')}\n",
                f"altcol1 = {relative_address('chooseColourAlt1')}\n",
                f"colshift = {relative_address('PLOT_STATE')} + 3\n",
                'rem "**** Program text ****"\n',
                'rem\n']
    
    return header_lines
