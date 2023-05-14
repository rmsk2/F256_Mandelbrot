# F256 Mandelbrot
A program for the Foenix 256 Rev B that visualizes the mandelbrot set and makes use of the F256 integer coprocessor. 
Use `make publish` to build the software and copy all the files needed to the `dist` directory. Copy the contents of 
the `dist` directory to a compatible SD card and plug it into either the SD card slot of the F256 or an SD2IEC like 
device. 

In Basic change to the relevant device (`drive 0` for the built in SD card slot or `drive 1` for an SD2IEC device with 
device number 8) and type `load "MANDELBROT.BAS"` followed by `run`.

The makefile target `make upload` can be used to upload the machine language part (which does the computational heavy lifting)
of the software to the memory of the F256 via a USB connection to the F256 debug port. The target address is $3500 and after the upload 
it can be started by `call $3500`. You may have to adapt the serial device. On my machine the F256 debug port appears as `/dev/ttyUSB0`. 
The makefile target `make test` runs some simple tests using my [6502profiler](https://github.com/rmsk2/6502profiler) project. As usual 
use  `make clean` to delete all intermediate files from the project directory. 

You will need the `64tass` macro assembler in your path in order to build the software. I use Ubuntu 22.04 on my development
machine and I have not tested this software on any other operating system. The `64tass` version available in the Ubuntu repos
works for this project.

![](/mandelbrot.png?raw=true "Example picture at iteration depth 80")

Some additional info about the screenshot. The values used were Real part: `-02.000000`, Imaginary part `01.250000`, zoom level 0 and
iteratioon depth 80. These are the standard values which define the well known picture of the Mandelbrot set. The pink square in the
upper left corner is the cursor, which is not part of the picture. Unfortunately the program does not run in the emulator. In order to
create the screenshot I loaded the precalculated image data in the emulator's RAM beginning at address $10000 and issued the command `
bitmap on`. After that I took a screenshot of the emulator's window. Here another screenshot. 

![](/thunderstorm.png?raw=true "Example picture at iteration depth 128")

The parameters used were: Real part `00.605b58`, Imaginary part `00.aad9fc`, zoom level 11, iteration depth 128.

# Usage

The BASIC program allows to either generate (press `G` or `g`) a picture or to load a picture (press any other key). When generating a 
new picture the section to be visualized can be manually selected. You have to enter the real and imaginary part of the upper left corner of the 
desired section in the complex plane. The format used for the numbers is the same as for my [C64](https://github.com/rmsk2/c64_mandelbrot)
and  [X16](https://github.com/rmsk2/X16_mandelbrot) versions of this program. You also have to enter the zoom level, which in essence
determines the size of the visualized section as well as the iteration depth to use. I use typically a depth of 24. Larger values give 
a more precise result but lead to longer calculation times. On the other hand when zooming into the intereseting parts of the set the 
iteration depth also has to increase, because otherwise the potentially colourful parts simply remain black. Try for instance real part 
`00.4e6604` and imaginary part `00.641bc1` at a zoom level of 4 and an interation depth of 64. After the calculation is finished the program 
waits for a key press and after that asks if the resulting picture should be saved or not. A calculation can be interrupted at any time
by pressing a key. It is resumed if you press any key but `n`.
 
Following that the program asks if you want to zoom into the set. If that question is answered with `y`es a rectangle is shown which can be moved
with the cursor keys. Use `i` (zoom `i`n) to halve the size of this rectangle or `o` (zoom `o`ut) to double its size. When you press `Return` 
the computational parameters are adapted to visualize the selected section and the calculation starts anew using these parameters. When you 
press `q` the values are not changed and the program ends.

After loading a picture has been completed the program also waits for a key press. When a key is pressed you are asked if you want 
to zoom into the set. If that question is answered with `y` then you can select a section to visualize as described above.

# A note about performance

The F256 version of this program needs about five minutes for the calculation of the default section at an iteration depth of 24. 
This is only about 60% of the runtime of the Commander X16 version (measured in the latest version of the emulator). As the F256 runs 
at 6.29 MHz and the X16 at 8 MHz this speedup can be clearly attributed to the F256 math coprocessor.

# Coming up ...

Use RTC to measure duration of calculation.
