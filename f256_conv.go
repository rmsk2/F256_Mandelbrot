package main

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"os"
)

func readClut(fileName string) ([]color.RGBA, error) {
	colData, err := os.ReadFile(fileName)
	if err != nil {
		return nil, fmt.Errorf("unable to read colour definitions: %v", err)
	}

	var colors [256]color.RGBA
	colPtr := 0

	for i := 0; i < 256; i++ {
		colors[i] = color.RGBA{colData[colPtr+2], colData[colPtr+1], colData[colPtr], 255}
		colPtr += 4
	}

	return colors[:], nil
}

func setChunkyPixel(image *image.RGBA, x, y int, c color.Color, zoomLevel int) {
	if zoomLevel == 1 {
		image.Set(x, y, c)
		return
	}

	xStart := x * zoomLevel
	yStart := y * zoomLevel

	for yD := yStart; yD < yStart+zoomLevel; yD++ {
		for xD := xStart; xD < xStart+zoomLevel; xD++ {
			image.Set(xD, yD, c)
		}
	}
}

func makeImage(inFile string, colors []color.RGBA, zoomLevel int) error {
	data, err := os.ReadFile(inFile)
	if err != nil {
		return fmt.Errorf("unable to read input file: %v", err)
	}

	xSize := 320 * zoomLevel
	ySize := 240 * zoomLevel

	upLeft := image.Point{0, 0}
	lowRight := image.Point{int(xSize), int(ySize)}
	image := image.NewRGBA(image.Rectangle{upLeft, lowRight})

	ctr := 0

	for y := 0; y < 240; y++ {
		for x := 0; x < 320; x++ {
			setChunkyPixel(image, x, y, colors[data[ctr]], zoomLevel)
			ctr++
		}
	}

	f, err := os.Create(inFile + ".png")
	if err != nil {
		return fmt.Errorf("unable to open file for pic writer: %v", err)
	}
	defer func() { f.Close() }()

	err = png.Encode(f, image)
	if err != nil {
		return fmt.Errorf("unable to encode picture: %v", err)
	}

	return nil
}

func main() {
	picName := flag.String("i", "", "File name of pic to convert")
	colorDefName := flag.String("c", "clut_0.dat", "File name of saved F256 CLUT")
	zoom := flag.Int("z", 1, "Zoom level")

	flag.Parse()

	if *picName == "" {
		fmt.Println("No input file specified")
		return
	}

	if (*zoom < 1) || (*zoom > 3) {
		fmt.Println("Invalid zoom value")
		return
	}

	colors, err := readClut(*colorDefName)
	if err != nil {
		fmt.Println(err)
		return
	}

	err = makeImage(*picName, colors, *zoom)
	if err != nil {
		fmt.Println(err)
		return
	}
}
