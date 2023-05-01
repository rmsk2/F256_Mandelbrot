repeat
    input "Iteration depth (min 1, max 254): "; iter
until (iter > 0) & (iter <= 254)
print "OK": print : print "Loading machine language program ..."
bload "mandel.prg", progstart
print "done"
poke maxiter, iter
call progstart