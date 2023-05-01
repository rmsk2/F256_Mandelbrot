repeat
    input "Iteration depth (min 1, max 254): "; iter
until (iter > 0) & (iter <= 254)
print "OK": print : print "Loading machine language program ..."
bload "mandel.prg", $2500
print "done"
poke maxiter, iter
call $2500