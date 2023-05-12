bitmapaddr = $10000
dim hexfloat(5)
resbyte = 0
resnibble = 0
hexchars$ = "0123456789abcdef"

print "Loading machine language program ..."
try bload "mandel.prg", progstart to rc
if rc <> 0
    print "Load error"
    end
endif
print "done"

input "(G)enerate or (L)oad a picture?: "; inp$

if inp$ = "G"
    print "Enter real and imaginary part of upper left corner"
    input "Real part (return for default)     : "; hfloat$
    if hfloat$ <> ""
        converthexfloat(hfloat$)
    else
        hexfloat(0) = peek(defreal)
        hexfloat(1) = peek(defreal+1)
        hexfloat(2) = peek(defreal+2)
        hexfloat(3) = peek(defreal+3)
        hexfloat(4) = peek(defreal+4)
        print "Using                              : "; : printhexfloat(defreal)
    endif
    
    poke initreal, hexfloat(0)
    poke initreal+1, hexfloat(1)
    poke initreal+2, hexfloat(2)
    poke initreal+3, hexfloat(3)
    poke initreal+4, hexfloat(4)

    input "Imaginary part (return for default): "; hfloat$
    if hfloat$ <> ""
        converthexfloat(hfloat$)
    else
        hexfloat(0) = peek(defimag)
        hexfloat(1) = peek(defimag+1)
        hexfloat(2) = peek(defimag+2)
        hexfloat(3) = peek(defimag+3)
        hexfloat(4) = peek(defimag+4)
        print "Using                              : "; : printhexfloat(defimag)
    endif
    
    poke initimag, hexfloat(0)
    poke initimag+1, hexfloat(1)
    poke initimag+2, hexfloat(2)
    poke initimag+3, hexfloat(3)
    poke initimag+4, hexfloat(4)

    repeat
        input "Zoom level (min 0, max 16)         : "; zl
    until (zl >= 0) & (zl <= 16)    
    poke zoomlevel, zl

    generatepicture()
    input "Save picture (y/n)? "; inp$
    if inp$ <> "n" 
        savepicture()
    endif
    print "Done"
    printparams("Parameters used:")    
else
    loadpicture()
endif
cursor on
end

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
    call progstart
endproc

proc loadpicture()
    local filename$
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
        printparams("Parameters used:")
        print
        input "Zoom into picture (y/n)? "; inp$
        if inp$ <> "n"
            zoomin()
        endif
    else 
        clearscreen()               
        print "Load error"
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

proc printparams(s$)
    print s$
    print "==============="
    print "Real part      : ";: printhexfloat(initreal)
    print "Imaginary part : ";: printhexfloat(initimag)
    print "Zoom level     :  ";: print peek(zoomlevel)
endproc

proc zoomin()
    rem "make zoom stuff"
    printparams("New parameters")

    input "Calculate picture with new values (y/n)? "; inp$
    if inp$ <> "n"
        generatepicture()
        input "Save picture (y/n)? "; inp$
        if inp$ <> "n" 
            savepicture()
        endif
    endif
endproc