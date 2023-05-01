MANDEL=mandelbrot.asm
BINARY=mandel.prg
BASIC=mandelbrot.bas
BASIC_RAW=mandelbrot_raw.bas

all: $(BINARY)

mandel.prg: fixed_point.asm $(MANDEL) api.asm khelp.asm hires_base.asm
	64tass -o $(BINARY) -l labels.txt -b $(MANDEL)

test:
	6502profiler verifyall -c config.json

upload: $(BINARY)
	sudo python3 fnxmgr.zip --port /dev/ttyUSB0 --binary $(BINARY) --address 2500

publish: $(BINARY) $(BASIC_RAW)
	cp $(BINARY) dist/
	python3 renumber.py $(BASIC_RAW) dist/$(BASIC)

clean:
	rm $(BINARY)
	rm labels.txt
	rm dist/$(BINARY)
	rm dist/$(BASIC)
	rm tests/bin/*.bin