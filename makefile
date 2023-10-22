MANDEL=mandelbrot.asm
BINARY=mandel.prg
BASIC=mandelbrot.bas
BASIC_RAW=mandelbrot_raw.bas
LABELS=labels.txt

all: $(BINARY)

$(BINARY): fixed_point.asm $(MANDEL) api.asm khelp.asm hires_base.asm txtdraw.asm zeropage.asm
	64tass -o $(BINARY) -l $(LABELS) -b $(MANDEL)

$(LABELS): $(BINARY)

test:
	6502profiler verifyall -c config.json

drawtest.bas: drawtest_raw.bas $(LABELS)
	python3 renumber.py drawtest_raw.bas drawtest.bas $(LABELS) drawtest

inputttest.bas: inputttest_raw.bas $(LABELS)
	python3 renumber.py inputttest_raw.bas inputttest.bas $(LABELS) inputtest


publish: $(BINARY) $(BASIC_RAW) $(LABELS)
	cp $(BINARY) dist/
	python3 renumber.py $(BASIC_RAW) dist/$(BASIC) $(LABELS) mandelbrot

tstprgclean:
	rm inputttest.bas
	rm drawtest.bas

clean:
	rm $(BINARY)
	rm $(LABELS)
	rm dist/$(BINARY)
	rm dist/$(BASIC)
	rm tests/bin/*.bin