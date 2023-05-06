bitmapaddr = $40000
dim hexfloat(5)
resbyte = 0
resnibble = 0
input "(G)enerate or (L)oad a picture?: "; inp$

if inp$ = "G"
    print "Loading machine language program ..."
    bload "mandel.prg", progstart
    print "done"

    input "Enter real part of left upper corner (return for default): "; hfloat$
    if hfloat$ <> ""
        converthexfloat(hfloat$)
    else
        hexfloat(0) = peek(defreal)
        hexfloat(1) = peek(defreal+1)
        hexfloat(2) = peek(defreal+2)
        hexfloat(3) = peek(defreal+3)
        hexfloat(4) = peek(defreal+4)
    endif
    
    poke initreal, hexfloat(0)
    poke initreal+1, hexfloat(1)
    poke initreal+2, hexfloat(2)
    poke initreal+3, hexfloat(3)
    poke initreal+4, hexfloat(4)

    input "Enter imaginary part of left upper corner (return for default): "; hfloat$
    if hfloat$ <> ""
        converthexfloat(hfloat$)
    else
        hexfloat(0) = peek(defimag)
        hexfloat(1) = peek(defimag+1)
        hexfloat(2) = peek(defimag+2)
        hexfloat(3) = peek(defimag+3)
        hexfloat(4) = peek(defimag+4)
    endif
    
    poke initimag, hexfloat(0)
    poke initimag+1, hexfloat(1)
    poke initimag+2, hexfloat(2)
    poke initimag+3, hexfloat(3)
    poke initimag+4, hexfloat(4)

    repeat
        input "Zoom level (min 0, max 16): "; zl
    until (zl >= 0) & (zl <= 16)    
    poke zoomlevel, zl

    generatepicture()
    input "Save picture (y/n)? "; inp$
    if inp$ = "y" 
        savepicture()
    endif
    print "done"
else
    loadpicture()
endif
cursor on
end
rem
rem "Save picture"
rem 
proc savepicture()
    local filename$
    input "Filename: "; filename$
    bsave filename$, bitmapaddr, 320*240
    print "Done!"
endproc
rem
rem "Calculate picture"
rem 
proc generatepicture()
    repeat
        input "Iteration depth (min 1, max 254): "; iter
    until (iter > 0) & (iter <= 254)
    print "OK": 
    poke maxiter, iter
    call progstart
endproc
rem
rem "Load picture"
rem 
proc loadpicture()
    local filename$
    cursor off
    input "Filename: "; filename$
    bitmap on: cls: bitmap clear 2
    bload filename$, $10000
    waitforkeypress()
    bitmap off
    cursor on
endproc
rem
rem "Wait for key press"
rem 
proc waitforkeypress()
    repeat
       key$ = inkey$() 
    until key$ <> ""
endproc

rem
rem "Convert string to nibble"
rem 
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
rem
rem "Convert hex string to byte"
rem 
proc strtobyte(s$)
    local b
    strtonibble(left$(s$, 1))    
    b = 16 * resnibble
    strtonibble(right$(s$, 1))
    resbyte = b + resnibble
endproc
rem
rem "Convert hexfloat"
rem 
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