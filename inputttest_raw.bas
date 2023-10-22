dim keycodes(8)
dim keyascii$(8)
keypressed$ = ""

keycodes(0) = 184 
keycodes(1) = 185
keycodes(2) = 182
keycodes(3) = 183
keycodes(4) = 105
keycodes(5) = 111
keycodes(6) = 148
keycodes(7) = 113

keyascii$(0) = chr$(2)
keyascii$(1) = chr$(6)
keyascii$(2) = chr$(16)
keyascii$(3) = chr$(14)
keyascii$(4) = "i"
keyascii$(5) = "o"
keyascii$(6) = chr$(13)
keyascii$(7) = "q"


repeat
    checkkey()
    print asc(keypressed$)
    for delay = 0 to 1000
    next

until false

end

proc checkkey()
    local done, i, delay
    done = 0

    repeat
        for i = 0 to 7
            if keydown(keycodes(i)) 
                while inkey$() <> ""
                wend

                keypressed$ = keyascii$(i)
                done = 1
            endif
        next
    until done <> 0
endproc