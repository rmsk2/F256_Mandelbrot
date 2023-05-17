overwrite = 1
callrect(10, 10, 10, 10, $54, overwrite)
waitforkeypress()
callclear(10, 10, 10, 10, $92, overwrite)

callrect(35, 45, 0, 0, $54, overwrite)
waitforkeypress()
callclear(35, 45, 0, 0, $92, overwrite)

callrect(70, 50, 20, 20, $54, overwrite)
waitforkeypress()
callclear(70, 50, 20, 20, $92, overwrite)

end
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

proc waitforkeypress()
    repeat
       key$ = inkey$() 
    until key$ <> ""
endproc