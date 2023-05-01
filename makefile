MANDEL=mandelbrot.asm
BINARY=mandel.prg
BASIC=mandelbrot.bas
BASIC_RAW=mandelbrot_raw.bas
LABELS=labels.txt

all: $(BINARY)

$(BINARY): fixed_point.asm $(MANDEL) api.asm khelp.asm hires_base.asm
	64tass -o $(BINARY) -l $(LABELS) -b $(MANDEL)

$(LABELS): $(BINARY)

test:
	6502profiler verifyall -c config.json

upload: $(BINARY)
	sudo python3 fnxmgr.zip --port /dev/ttyUSB0 --binary $(BINARY) --address 2500

publish: $(BINARY) $(BASIC_RAW) $(LABELS)
	cp $(BINARY) dist/
	python3 renumber.py $(BASIC_RAW) dist/$(BASIC) $(LABELS)

clean:
	rm $(BINARY)
	rm $(LABELS)
	rm dist/$(BINARY)
	rm dist/$(BASIC)
	rm tests/bin/*.bin