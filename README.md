# F256 Mandelbrot
A program for the Foenix 256 Jr. Rev B and F256 K that visualizes the [Mandelbrot set](https://en.wikipedia.org/wiki/Mandelbrot_set) 
and makes use of the F256 integer coprocessor. Download the two files `mandelbrot.bas` and `mandel.prg` from the release 
section of this repo, copy them to a F256 compatible SD card and plug that into either the SD card slot of the F256 or an SD2IEC 
like device. In BASIC change to the relevant device (`drive 0` for the built in SD card slot or `drive 1` for an SD2IEC device 
with device number 8) and type `load "mandelbrot.bas"` followed by `run`. This will first load the machine language part `mandel.prg`
(which does all the mathematical heavy lifitng using fixed point arithmetic) and then start the program.

# How to build the software yourself
If you want to build the software yourself you will need the `64tass` macro assembler and a python interpreter in your `PATH`. 
I use Ubuntu 22.04 on my development machine and I have not tested this software on any other operating system. The `64tass` 
version available in the Ubuntu repos works for this project. Clone the repo, issue the command `make publish`, then copy the 
contents of the `dist` directory to a compatible SD card.

**Note:** The math coprocessor addresses differ between the F256 Jr. FPGA loads. You have to change the value of 

- `COPROC_RES` in `fixed_point.asm`
- `MUL_RES_CO_PROC` in `hires_base.asm`
- `MUL_RES` in `txtdraw.asm`

from `$DE10` to `$DE04` when building for a F256 Jr. with an FPGA version below RC10. When building for a F256 Jr. with older 
firware you may also have to use the version of `api.asm` which was current when that firmware was released. See 
[here](https://wiki.f256foenix.com/index.php?title=FPGA_Releases) for information on how to update the FPGA load. The changes 
in the integer coprocessor happened in the bitstream RC10 for the F256 Jr. FPGA.

# Some screenshots

![](/mandelbrot.png?raw=true "Example picture at iteration depth 80")

Some info about the screenshot depicted above. The values used were Real part: `-02.000000`, Imaginary part `01.250000`, 
zoom level 0 and iteration depth 80. These are the standard values which define the well known picture of the Mandelbrot set. The 
pink square in the upper left corner is the cursor, which is not part of the picture. Here another screenshot. 

![](/thunderstorm.png?raw=true "Example picture at iteration depth 128")

The parameters used were: Real part `00.605b58`, Imaginary part `00.aad9fc`, zoom level 11, iteration depth 128.

# Usage

The BASIC program allows to either generate (press `G` or `g`) a picture, load a picture (press `L` or `l`) or quitting the program. When 
generating a new picture the section to be visualized can be manually selected. You have to enter the real and imaginary part of the upper 
left corner of the desired section in the complex plane. The format used for the numbers is the same as for the 
[C64](https://github.com/rmsk2/c64_mandelbrot) and [X16](https://github.com/rmsk2/X16_mandelbrot) versions of this program. You also have 
to enter the zoom level, which in essence determines the size of the visualized section in the plane of complex numbers. Additionally you have 
to choose an iteration depth. I use typically a depth of 24. Larger values give a more precise result but lead to longer calculation times. 
On the other hand when zooming into the intereseting parts of the set the iteration depth also has to increase, because otherwise the 
potentially colourful parts simply remain black. Try for instance real part `00.4e6604` and imaginary part `00.641bc1` at a zoom level of 4 
and an interation depth of 64 and calculate the picture with a lower iteration depth to see the difference. A calculation can be interrupted
at any time by pressing a key. It is resumed if you press any key but `n` otherwise it is cancelled. After the calculation is finished 
the program waits for a key press and after that asks if the resulting picture should be saved or not. 
 
Following that the program asks if you want to zoom into the set. If that question is answered with `y`es a rectangle is shown which can be moved
with the cursor keys. Use `i` (zoom `i`n) to shrink the size of this rectangle or `o` (zoom `o`ut) to enlarge it again. When you press `Return` 
the computational parameters are adapted to visualize the selected section and the calculation starts anew using these parameters. When you 
press `q` the values are not changed and the program returns to the main menu.

After loading a picture has been completed the program also waits for a key press. When a key is pressed you are asked if you want 
to zoom into the set. If that question is answered with `y` then you can select a section to visualize as described above. Before loading
or saving a picture the drive (0, 1 or 2) to use for this operation can be changed. If one presses just return instead of selecting a 
number the current drive is not changed.

# A note about performance

The F256 version of this program needs about five minutes for the calculation of the default section at an iteration depth of 24. 
This is only about 60% of the runtime of the Commander X16 version (measured in the latest version of the emulator). As the F256 runs 
at 6.29 MHz and the X16 at 8 MHz this speedup can be clearly attributed to the F256 math coprocessor.

# Coming up ...

- We'll see
