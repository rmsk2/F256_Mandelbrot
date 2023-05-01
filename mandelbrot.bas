10  repeat
20 input "Iteration depth (min 1, max 254): "; iter
30 until (iter > 0) & (iter <= 254)
90 print "OK": print : print "Loading machine language program ..."
100 bload "mandel.prg", $2500
110 print "done"
120 poke $290d, iter
130 call $2500