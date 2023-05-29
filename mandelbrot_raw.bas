bitmapaddr = $10000
dim hexfloat(5)
resbyte = 0
resnibble = 0
hexchars$ = "0123456789abcdef"
dim zoomx(5)
dim zoomy(5)
calcstart$ = ""
calcend$ = ""
tsstart = 0
tsend = 0
tsres = 0
pad$ = ""
prsig$ = "MGSJ"

zoomx(0) = 80-2
zoomx(1) = 40-2
zoomx(2) = 20-2
zoomx(3) = 10-2
zoomx(4) = 5-2

zoomy(0) = 60-2
zoomy(1) = 30-2
zoomy(2) = 15-2
zoomy(3) = 8-2
zoomy(4) = 4-2

loadmlprog() : print
poke colshift, 109

cls

repeat
    stopprog = 0
    print
    print "***************************************************************************"
    print "*                                                                         *"
    print "*                 Mandelbrot set viewer by Martin Grap                    *" 
    print "*                                                                         *"
    print "*                           Written in 2023                               *"
    print "*                                                                         *"
    print "***************************************************************************"
    print
    print "(G)enerate picture"
    print
    print "(L)oad picture"
    print
    print "(Q)uit"
    print
    input "Your selection: "; inp$
    print

    if (inp$ = "G") | (inp$ = "g")
        docalc()
    endif

    if (inp$ = "L") | (inp$ = "l")
        loadpicture()
    endif

    if inp$ = "W"
        poke progsig, 0
        inp$ = "q"
    endif
until (inp$ = "Q") | (inp$ = "q")

cursor on
print
print "Good bye ..."
end

proc docalc()
    local i
    print "Enter real and imaginary part of upper left corner"
    input "Real part (return for default)     : "; hfloat$
    if hfloat$ <> ""
        converthexfloat(hfloat$)
    else
        for i = 0 to 4
            hexfloat(i) = peek(defreal+i)
        next
        print "Using                              : "; : printhexfloat(defreal)
    endif

    for i = 0 to 4
        poke initreal+i, hexfloat(i)
    next    
    
    input "Imaginary part (return for default): "; hfloat$
    if hfloat$ <> ""
        converthexfloat(hfloat$)
    else
        for i = 0 to 4
            hexfloat(i) = peek(defimag+i)
        next
        print "Using                              : "; : printhexfloat(defimag)
    endif

    for i = 0 to 4
        poke initimag+i, hexfloat(i)
    next

    repeat
        input "Zoom level (min 0, max 16)         : "; zl
    until (zl >= 0) & (zl <= 16)    
    poke zoomlevel, zl

    repeat
        generatepicture()
        printcalctime()
        askforsave()
        askforzoom()
    until stopprog

    print "Done": print
    printparams("Parameters used:", -1)    
endproc

proc savepicture()
    local filename$
    input "Filename: "; filename$
    memcopy paramaddr, paramlen to bitmapaddr+320*240
    bsave filename$, bitmapaddr, 320*240 + paramlen
endproc

proc generatepicture()
    repeat
        input "Iteration depth (min 1, max 254)   : "; iter
    until (iter > 0) & (iter <= 254)
    print "OK": 
    poke maxiter, iter
    cls
    calcstart$ = gettime$(0)
    call progstart
    calcend$ = gettime$(0)
    if peek(calcintrpt) = 0
        sound 1, 500, 10
        waitforkeypress()
    endif
    clearscreen()
endproc

proc zerostr(l)
    local i
    pad$ = ""
    i = 0
    while i < l
        pad$ = pad$ + "0"
        i = i + 1
    wend
endproc

proc printcalctime()
    local duration, d$, t$, h, d, s
    parsetimestamp(calcstart$)
    tsstart = tsres
    parsetimestamp(calcend$)
    tsend = tsres

    if tsend < tsstart
        duration = (86400 - tsstart) + tsend
    else
        duration = tsend - tsstart    
    endif

    h = duration \ 3600
    s = duration % 3600
    m = s \ 60
    s = s % 60

    t$ = str$(h) 
    zerostr(2 - len(t$))
    d$ = pad$ + t$
    t$ = str$(m)
    zerostr(2 - len(t$))
    d$ = d$ + ":" + pad$  + t$
    t$ = str$(s)
    zerostr(2 - len(t$))
    d$ = d$ + ":"  + pad$ + t$

    print
    print "Calculation started at : "; calcstart$
    print "Calculation ended at   : "; calcend$
    print "Duration of calculation: "; d$
    print
endproc

proc parsetimestamp(timestamp$)
    local h, m, s

    h = val(mid$(timestamp$, 1, 2))
    m = val(mid$(timestamp$, 4, 2))
    s = val(mid$(timestamp$, 7, 2))

    tsres = h * 3600 + m * 60 + s
endproc

proc loadpicture()
    local filename$
    changedrive()
    input "Filename: "; filename$
    cls
    cursor off
    bitmap at bitmapaddr
    bitmap on
    bitmap clear 2
    try bload filename$, bitmapaddr to rc
    if rc = 0
        memcopy bitmapaddr+320*240, paramlen to paramaddr
        waitforkeypress()        
        clearscreen()
        printparams("Parameters used:", 0): print
        askforzoom()

        while not(stopprog)
            generatepicture()
            printcalctime()
            askforsave()
            askforzoom()
        wend
        
        print
        printparams("Parameters used:", -1): print
    else 
        clearscreen()               
        print "Load error. Press any key."
        waitforkeypress()
    endif
endproc
 
proc waitforkeypress()
    repeat
       key$ = inkey$() 
    until key$ <> ""
endproc

proc strtonibble(n$)
    local code
    code = asc(left$(n$,1))
    if (code >= asc("0")) & (code <= asc("9"))
        resnibble = code-asc("0")
    else
        if (code >= asc("a")) & (code <= asc("f"))
            resnibble = code-asc("a") + 10
        else
            print "Not valid hex value"
            end
        endif
    endif
endproc
 
proc strtobyte(s$)
    local b
    strtonibble(left$(s$, 1))    
    b = 16 * resnibble
    strtonibble(right$(s$, 1))
    resbyte = b + resnibble
endproc

proc converthexfloat(v$)
    local val$
    val$ = v$
    if (len(val$) < 9) | (len(val$) > 10)
        print "Hexfloat not wellformed!"
        end
    endif

    sign = 0
    if len(val$) = 10 
        if left$(val$, 1) = "-"
            sign = 1
            val$ = right$(val$, len(val$)-1)
        endif
    endif
    hexfloat(0) = sign
    strtobyte(left$(val$, 2))
    hexfloat(4) = resbyte
    strtobyte(mid$(val$, 4, 2))
    hexfloat(3) = resbyte
    strtobyte(mid$(val$, 6, 2))
    hexfloat(2) = resbyte
    strtobyte(mid$(val$, 8, 2))
    hexfloat(1) = resbyte
endproc

proc clearscreen()
    cursor on
    bitmap off
    poke $d000,1    
    print chr$(128+9)
    print chr$(144+2)
    print chr$(12)
endproc

proc printhexbyte(b)
    local nibble
    nibble = peek(b) \ 16
    print mid$(hexchars$, nibble+1, 1);
    nibble = peek(b) % 16
    print mid$(hexchars$, nibble+1, 1);
endproc

proc printhexfloat(addr)
    local sign$, i
    sign$ = " "
    if peek(addr) <> 0
        sign$ = "-"
    endif
    print sign$; 
    printhexbyte(addr+4)
    print ".";
    for i = 3 downto 1
        printhexbyte(addr+i)
    next
    print 
endproc

proc printparams(s$, printiter)
    print s$
    print "==============="
    print "Real part      : ";: printhexfloat(initreal)
    print "Imaginary part : ";: printhexfloat(initimag)
    print "Zoom level     :  ";: print peek(zoomlevel)
    if printiter <> 0
        print "Iteration depth:  ";: print peek(maxiter)
    endif
endproc

proc loadmlprog()
    local i, s$

    s$ = ""
    for i = 0 to 3
        s$ = s$ + chr$(peek(progsig + i))
    next
    print "Loading machine language program ...";
    if s$ <> prsig$
        try bload "mandel.prg", progstart to rc
        if rc <> 0
            print "Load error"
            end
        endif
    endif
    print " done"
endproc

proc callrect(x, y, w, h, c, o)
      poke txtx, x
      poke txty, y
      poke lenx, w
      poke leny, h
      poke txtcol, c
      poke txtovwr, o
      call txtrec
endproc

proc callclear(x, y, w, h, c, o)
      poke txtx, x
      poke txty, y
      poke lenx, w
      poke leny, h
      poke txtcol, c
      poke txtovwr, o
      call clrtxtrec
endproc

proc changezoomlevel(currentzoom)
    local posy, posy, zoomdelta, width, height, key$, done, col

    cls
    cursor off

    posx = 0
    posy = 0
    zoomdelta = 1
    width = zoomx(zoomdelta)
    height = zoomy(zoomdelta)
    done = 0
    col = $F2

    callrect(posx, posy, width, height, col, 0)
    
    repeat
        bitmap on
        repeat
            key$ = inkey$()
        until key$ <> ""

        if (key$ = chr$(16)) & (posy > 0)
            callclear(posx, posy, width, height, col, 0)
            posy = posy -1
            callrect(posx, posy, width, height, col, 0)
        endif

        if (key$ = chr$(14)) & (posy < 59)
            callclear(posx, posy, width, height, col, 0)
            posy = posy + 1
            callrect(posx, posy, width, height, col, 0)
        endif

        if (key$ = chr$(2)) & (posx > 0)
            callclear(posx, posy, width, height, col, 0)
            posx = posx - 1
            callrect(posx, posy, width, height, col, 0)

        endif

        if (key$ = chr$(6)) & (posx < 79)
            callclear(posx, posy, width, height, col, 0)
            posx = posx + 1
            callrect(posx, posy, width, height,col, 0)
        endif

        if (key$ = chr$(13))
            callclear(posx, posy, width, height, col, 0)
            done = -1
        endif

        if (key$ = "q")
            callclear(posx, posy, width, height, col, 0)
            done = -1
        endif

        if (key$ = "i" ) & ((currentzoom + zoomdelta) < 16) & (zoomdelta < 4)
            callclear(posx, posy, width, height, col, 0)
            zoomdelta = zoomdelta + 1
            width = zoomx(zoomdelta)
            height = zoomy(zoomdelta)
            callrect(posx, posy, width, height, col, 0)                
        endif

        if (key$ = "o") & (zoomdelta > 0)
            callclear(posx, posy, width, height, col, 0)
            zoomdelta = zoomdelta - 1
            width = zoomx(zoomdelta)
            height = zoomy(zoomdelta)
            callrect(posx, posy, width, height, col, 0)                
        endif
    until done

    bitmap off
    poke $d000,1

    if key$ <> "q"
        poke zoomlevel, currentzoom + zoomdelta
        poke xpos, posx
        poke ypos, posy
        call derive
    else
        stopprog = -1
    endif

    cursor on
endproc

proc askforzoom()
    if peek(zoomlevel) < 16
        input "Zoom into picture (y/n)? "; inp$
        if inp$ <> "n"
            changezoomlevel(peek(zoomlevel))
            printparams("New parameters", 0)
        else
            stopprog = -1
        endif
    else
        stopprog = -1
        print "Maximum zoomlevel is reached"
    endif
endproc

proc askforsave()    
    input "Save picture (y/n)? "; inp$
    if inp$ <> "n" 
        changedrive()
        savepicture()
    endif
endproc

proc changedrive()
    local dr$
    repeat
        input "Drive 0,1 or 2? "; dr$
    until (dr$ = "") | (dr$ = "0") | (dr$ = "1") | (dr$ = "2")
    if dr$ <> ""
        drive val(dr$)
    endif
endproc