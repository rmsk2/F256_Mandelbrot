MANDEL=mandelbrot.asm
BINARY=mandel.prg
BASIC=mandelbrot.bas

all: $(BINARY)

mandel.prg: fixed_point.asm $(MANDEL) api.asm khelp.asm hires_base.asm
	64tass -o $(BINARY) -b $(MANDEL)

test:
	6502profiler verifyall -c config.json

upload: $(BINARY)
	sudo python3 fnxmgr.zip --port /dev/ttyUSB0 --binary $(BINARY) --address 2500

publish: $(BINARY)
	cp $(BINARY) dist/
	cp $(BASIC) dist/

clean:
	rm $(BINARY)
	rm dist/$(BINARY)
	rm dist/$(BASIC)
	rm tests/bin/*