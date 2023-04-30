# F256 Mandelbrot
A program for the Foenix 256 Rev B that visualizes the mandelbrot set. Use `make publish` to build the software and copy
all the files needed to the `dist` directory. Copy the contents of the `dist` directory to a compatible SD card and plug
it into either the SD card slot of the F256 or an SD2IEC like device. 

In Basic change to the relevant device (`drive 0` for the built in SD card slot or `drive 1` for an SD2IEC device with 
device number 8) and type `load "MANDELBROT.BAS"` followed by `run`. The program then asks for the iteration depth to use.
I use typically 24 but larger values give a more precise result but are slower. At iteration depth 24 the calculation is
finished after about 5 minutes. The program then waits for a key press and exits if a key was pressed.

The makefile target `make upload` can be used to upload the machine language part to the memory of the F256 via a USB
connection to the F256 debug port. You may have to adapt the serial device. On my machine the F256 debug port appears
as `/dev/ttyUSB0`. The makefile target `make test` runs some basic tests using my 
[6502profiler](https://github.com/rmsk2/6502profiler) project. As usual use `make clean` to delete all intermediate 
files from the project directory. 

You will need the `64tass` macro assembler in your path in order to build the software. I use Ubuntu 22.04 on my development
machine and I have not tested this software on any other operating system. The `64tass` version available in the Ubuntu repos
works for this project.

At the moment you can not change the section of the Mandelbrot set that is visualized. This may be added in the future.
