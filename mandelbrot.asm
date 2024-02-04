.cpu "w65c02"

*=$3b00

RES_X = 320
RES_Y = 240

PROG_START
jmp mandelLoop

.include "api.asm"
.include "zeropage.asm"
.include "fixed_point.asm"
.include "hires_base.asm"
.include "txtdraw.asm"
.include "rtc.asm"

; --------------------------------------------------
; values settable/usable by callers
; --------------------------------------------------

; maxmimum number of iterations
MAX_ITER
.byte 24

; The number of iterations used for the current point
NUM_ITER
.byte 0


; **************************************************
; The following 5 values have to be contiguously laid out
; in memory. The load and save routines expect this.
PIC_PARAMS
PIC_PARAMS_LEN = $15
; x offset to move in complex plane for next point
STEP_X
.byte 0, $66, $66, $02, $00

; Y offset to move in complex plane for next line of picture
STEP_Y
.byte 1, $11, $71, $02, $00

; real part of upper left point of picture
INIT_REAL
.byte 1, 0, 0, 0, 2

; imaginary part of upper left point of picture
INIT_IMAG
.byte 0, 0, 0, $25, 1

ZOOM_LEVEL
.byte 0

; **************************************************

; Number of points (resolution) in x direction
MAX_X
.byte <RES_X, >RES_X 

; Number of points (resolution) in y direction
MAX_Y 
.byte RES_Y

; current X position
COUNT_X
.byte 0, 0

; current y position
COUNT_Y
.byte 0


; --------------------------------------------------
; variables used for calculation
; --------------------------------------------------


REAL
.byte 0,2,0,0,0

IMAG
.byte 0,3,0,0,0

XN
.byte 0,0,0,0,0

YN
.byte 0,0,0,0,0

XN_OLD
.byte 0,0,0,0,0

TEMP_MAX
.byte 0,0,0,0,0

YN_SQUARE
.byte 0,0,0,0,0

XN_SQUARE
.byte 0,0,0,0,0

; --------------------------------------------------
; constants
; --------------------------------------------------

; The fixed value 4. When a sequence's value is greater or equal to this number
; the sequence defined by the current point diverges
VAL_MAX
.byte 0,0,0,0,4

; x offset to move in complex plane default picture (full resolution)
DEFAULT_STEP_X
.byte 0, $66, $66, $02, $00

; Y offset to move in complex plane for next line of default picture
DEFAULT_STEP_Y
.byte 1, $11, $71, $02, $00

; real part of upper left point of default picture
DEFAULT_INIT_REAL
.byte 1, 0, 0, 0, 2

; imaginary part of upper left point of picture default picture
DEFAULT_INIT_IMAG
.byte 0, 0, 0, $25, 1
; **************************************************



; --------------------------------------------------
; This routine test if calcualtion of the Mandelbrot sequence should be stopped.
; It is stopped, when the iteration count reached MAX_ITER of the absolute value
; of the current sequence value is larger than 4
;
; This routine returns a nonzero value if computation has to be stopped. The zero
; flag is cleared in this case.
; --------------------------------------------------
testMandelbrotDone
    lda NUM_ITER
    cmp MAX_ITER
    bne _testLimit
    jmp _stopCalc

_testLimit
    ; *****************************
    ; abs_val = xn*xn + yn*yn
    ; *****************************

    ; XN_SQUARE <= XN
    #move32BitInline XN, XN_SQUARE
    ; XN_SQUARE <= XN_SQUARE * XN_SQUARE
    #callFuncMono square32BitNormalized, XN_SQUARE
    ; YN_SQUARE <= YN
    #move32BitInline YN, YN_SQUARE
    ; YN_SQUARE <= YN_SQUARE * YN_SQUARE
    #callFuncMono square32BitNormalized, YN_SQUARE
    ; TEMP_MAX <= XN_SQUARE
    #move32BitInline XN_SQUARE, TEMP_MAX
    ; TEMP_MAX <= YN_SQUARE + TEMP_MAX
    #callFunc add32Bit, YN_SQUARE, TEMP_MAX

    ; Stop if TEMP_MAX > 4
    ; continue if TEMP_MAX <= 4

    ; Carry is set if TEMP_MAX >= 4
    ; Zero flag is set if TEMP_MAX == 4
    #callFunc cmp32BitUnsigned, TEMP_MAX, VAL_MAX 
    bcs _greaterPerhapsEqual
_continueCalc                ; TEMP_MAX < 4
    lda #0
    rts
_greaterPerhapsEqual         ; TEMP_MAX >= 4
    beq _continueCalc        ; TEMP_MAX == 4? => If yes continue
_stopCalc
    lda #1                   ; TEMP_MAX > 4 => Stop
    rts

; --------------------------------------------------
; This routine calculates the Mandelbrot sequence for the complex value given through
; REAL und IMAG.
;
; The number of iterations performed is returned in NUM_ITER 
; --------------------------------------------------
calcOneMandelbrotSequence
    lda #1
    sta NUM_ITER

    ; REAL <= XN
    #callFunc move32Bit, REAL, XN
    ; YN <= IMAG
    #callFunc move32Bit, IMAG, YN

_loopMandelbrot
    ; check for key press
    jsr checkKey

    jsr testMandelbrotDone
    beq _continueMandelbrot
    jmp _endMandelbrot

_continueMandelbrot
    ; XN_OLD <= XN
    #move32BitInline XN, XN_OLD
    
    ; *****************************
    ; xn+1 = xn*xn - yn*yn + real
    ; *****************************

    ; XN <= XN_SQUARE
    #move32BitInline XN_SQUARE, XN
    ; YN_SQUARE <= -YN_SQUARE
    #neg32Inline YN_SQUARE
    ; XN <= YN_SQUARE + XN
    #callFunc add32Bit, YN_SQUARE, XN
    ; XN <= REAL + XN
    #callFunc add32Bit, REAL, XN

    ; *****************************
    ; yn+1 = 2*xn*yn + imag
    ; *****************************

    ; YN <= XN_OLD * YN 
    #callFunc mul32BitNormalized, XN_OLD, YN
    ; YN <= 2*YN
    #callFuncMono double32Bit, YN
    ; YN <= IMAG + YN
    #callFunc add32Bit, IMAG, YN 

    inc NUM_ITER
    jmp _loopMandelbrot

_endMandelbrot
    rts

TEMP_ZOOM
.byte 0

; --------------------------------------------------
; This routine initialises the data needed for computation
;
; initMandel has no return value. 
; --------------------------------------------------
initMandel
    #load16BitImmediate 0, COUNT_X
    lda #0
    sta COUNT_Y

    ; reset complex numbers    
    #callFunc move32Bit, INIT_REAL, REAL
    #callFunc move32Bit, INIT_IMAG, IMAG

    jsr setZoomLevel

    rts


; --------------------------------------------------
; This routine performs all necessary calculations for one point in the
; complex plane. Calling this routine repeatedly calculates and draws the
; selected rectangular part of the Mandelbrot set. If COUNT_Y reaches 200
; all pixels have been drawn.
;
; nextMandel has no return value. 
; --------------------------------------------------
nextMandel
    #move16Bit COUNT_X, PLOT_STATE.pos_x
    lda COUNT_Y
    sta PLOT_STATE.pos_y
    jsr calcOneMandelbrotSequence
    jsr plotPoint
    ; REAL <= STEP_X + REAL
    #callFunc add32Bit, STEP_X, REAL
    #inc16Bit COUNT_X
    #cmp16Bit COUNT_X, MAX_X
    bne _done
    #load16BitImmediate 0, COUNT_X
    ; REAL <= INIT_REAL
    #callFunc move32Bit, INIT_REAL, REAL
    ; IMAG <= STEP_Y + IMAG
    #callFunc add32Bit, STEP_Y, IMAG
    inc COUNT_Y
_done
    rts


START_TIME .dstruct TimeStamp_t, 0, 0, 0

; --------------------------------------------------
; This routine visualizes the Mandelbrot set 
; --------------------------------------------------
mandelLoop
    jsr initEvents
    jsr initMandel

    #getTimestamp START_TIME

    lda #3
    sta hires.backgroundColor
    jsr hires.on
    jsr hires.clearBitmap

    stz CALC_INTERRUPTED

_loopUntilFinished
    jsr nextMandel
    ; check for interruption of calculation    
    lda CALC_INTERRUPTED
    beq _continueCalc
    jsr askContinue
    bcs _continueCalc
    bra _done
_continueCalc
    stz CALC_INTERRUPTED
    lda COUNT_Y
    cmp MAX_Y
    bne _loopUntilFinished
_done
    jsr restoreEvents

    rts

.include "khelp.asm"

textContinue .text "Continue calculation (y/n)?"
colorContinue .text x"92" x len(textContinue)
textIter .text "Iteration depth:    "
textZoom .text "Zoom level     :    "
colorTextIter .text x"92" x len(textIter)

CURRENT_TIME .dstruct TimeStamp_t

TEXT_ELAPSED_TIME .text "Elapsed time: "
TIME_STR .fill 8
colorTime .text x"92" x (len(TEXT_ELAPSED_TIME)+8)

calcTime
    #getTimestamp CURRENT_TIME
    #diffTime START_TIME, CURRENT_TIME
    #getTimeStr TIME_STR, CURRENT_TIME
    rts


askContinue
    jsr hires.Off
    lda #32
    sta textIter+17
    sta textIter+18
    sta textIter+19
    #itoa textIter+17, MAX_ITER
    #kprint 0, 27, textIter, len(textIter), colorTextIter

    lda #32
    sta textZoom+17
    sta textZoom+18
    sta textZoom+19
    #itoa textZoom+17, ZOOM_LEVEL
    #kprint 0, 28, textZoom, len(textZoom), colorTextIter

    jsr calcTime
    #kprint 0, 29, TEXT_ELAPSED_TIME, len(TEXT_ELAPSED_TIME) + 8, colorTime

    #kprint 0, 31, textContinue, len(textContinue), colorContinue
    ldx #len(textContinue)
    lda #30
    jsr setCursor
    jsr waitForKey
    cmp #$4E                                  ; $4e = ASCII code for N
    beq _stopCalc
    cmp #$6E                                  ; $6E = ASCII code for n
    beq _stopCalc
    jsr hires.on
    sec
    rts
_stopCalc
    clc
    rts

NO_KEY_PRESSED = $0
KEY_PRESSED = $1

CALC_INTERRUPTED .byte 0

checkKey
    lda CALC_INTERRUPTED
    bne _done
    lda kernel.args.events.pending ; Negated count
    bpl _done
    jsr kernel.NextEvent
    bcs _done
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    bne _done
    lda #KEY_PRESSED
    sta CALC_INTERRUPTED
_done
    rts
    

; --------------------------------------------------
; This routine waits for a key press event from the kernel and returns
; the ASCII code of the pressed key in the accu.
; --------------------------------------------------
waitForKey
    ; Peek at the queue to see if anything is pending
    lda kernel.args.events.pending ; Negated count
    bpl waitForKey
    ; Get the next event.
    jsr kernel.NextEvent
    bcs waitForKey
    ; Handle the event
    lda myEvent.type    
    cmp #kernel.event.key.PRESSED
    beq _done
    bra waitForKey
_done
    lda myEvent.key.flags 
    and #myEvent.key.META
    bne waitForKey
    lda myEvent.key.ascii
    rts 

plotState_t .struct
    pos_x    .word 0
    pos_y    .byte 0
    param1   .byte 109
    param2   .byte 32
    param3   .byte 0
    param4   .byte 0
    col_vec  .word chooseColourDefault
.endstruct

PLOT_STATE .dstruct plotState_t


; --------------------------------------------------
; This routine looks at NUM_ITER and MAX_ITER and decides what color a point
; is given
; --------------------------------------------------
chooseColourDefault
    lda NUM_ITER
    cmp MAX_ITER
    beq _drawBlack

    clc    
    adc PLOT_STATE.param1               ; shift color
    bne _done                           ; value is not zero => we are done
    ; value was zero but color zero is black which is reserved for points in the set.
    ; Use color 1 instead
    lda #1                              
    bra _done
_drawBlack
    ; use a black pixel if the maximum number of iterations
    ; was reached
    lda #0
_done        
    rts


chooseColourAlt1
    lda NUM_ITER
    cmp MAX_ITER
    beq _drawBlack

    and #$1F
    clc
    adc PLOT_STATE.param2
    bra _done
_drawBlack
    ; use a black pixel if the maximum number of iterations
    ; was reached
    lda #0
_done        
    rts


; --------------------------------------------------
; This routine sets a point on the bitmap
; --------------------------------------------------
plotPoint
    #move16Bit PLOT_STATE.pos_x, hires.setPixelArgs.x
    lda PLOT_STATE.pos_y
    sta hires.setPixelArgs.y
    
    jsr chooseColVec

    sta hires.setPixelArgs.col
    jsr hires.setPixel
    rts

; Call routine whose address is stored in PLOT_STATE.col_vec
chooseColVec
    jmp (PLOT_STATE.col_vec)


; --------------------------------------------------
; This routine resets the top left corner to use in the complex
; plane for the iconic mandelset picture in hires mode
;
; resetParameters has no return value. 
; --------------------------------------------------
resetParameters
    #callFunc move32Bit, DEFAULT_INIT_REAL, INIT_REAL
    #callFunc move32Bit, DEFAULT_INIT_IMAG, INIT_IMAG       
    rts


resetStepping
    #callFunc move32Bit, DEFAULT_STEP_X, STEP_X
    #callFunc move32Bit, DEFAULT_STEP_Y, STEP_Y 
    rts


resetAll
    jsr resetParameters
    jsr resetStepping
    rts


zoomIn .namespace
ZOOM_TEMP .byte 0
.endnamespace
; --------------------------------------------------
; This routine sets STEP_X and STEP_Y according to the zoom level
; stored in ZOOM_LEVEL.
;
; setZoomLevel has no return value. As a side effect it changes
; STEP_x and STEP_Y. 
; --------------------------------------------------
setZoomLevel
    stz zoomIn.ZOOM_TEMP
    jsr resetStepping    
_loopZoom
    lda ZOOM_LEVEL
    cmp zoomIn.ZOOM_TEMP
    beq _zoomDone
    #callFuncMono halve32bit, STEP_X
    #callFuncMono halve32bit, STEP_Y
    inc zoomIn.ZOOM_TEMP
    bra _loopZoom
_zoomDone    
    rts


derive .namespace
TEMP_X .byte 0, 0
TEMP_Y .byte 0
.endnamespace
; --------------------------------------------------
; This routine determines the point in the complex plane for which the pixel
; at COUNT_X and COUNT_Y stands
;
; deriveParametersFromPixel has no return value. As a side effect it changes
; INIT_REAL and INIT_IMAG 
; --------------------------------------------------
deriveParametersFromPixel
    #callFunc move32Bit, INIT_IMAG, IMAG
    #callFunc move32Bit, INIT_REAL, REAL

    #load16BitImmediate 0, derive.TEMP_X
_loopDeriveX
    #cmp16Bit COUNT_X, derive.TEMP_X
    beq _procYCoord
    #callFunc add32Bit, STEP_X, REAL
    #inc16Bit derive.TEMP_X
    bra _loopDeriveX

_procYCoord
    lda #0
    sta derive.TEMP_Y
_loopDeriveY
    lda derive.TEMP_Y
    cmp COUNT_Y
    beq _deriveDone
    #callFunc add32Bit, STEP_Y, IMAG
    inc derive.TEMP_Y
    bra _loopDeriveY

_deriveDone
    #callFunc move32Bit, IMAG, INIT_IMAG
    #callFunc move32Bit, REAL, INIT_REAL

    rts


; --------------------------------------------------
; This routine determines the point in the complex plane for which the pixel
; at COUNT_X and COUNT_Y stands and sets the zoomlevel as provided in ZOOM_LEVEL. 
; The values in COUNT_X and COUNT_Y are expected to be positions on the text screen. 
; Therefore they are multiplied by 4 before they are used.
;
; deriveFromBasicValues has no return value. As a side effect it changes
; INIT_REAL, INIT_IMAG, STEP_X and STEP_Y.
; --------------------------------------------------
deriveFromBasicValues
    asl COUNT_Y
    asl COUNT_Y
    stz COUNT_X+1
    #double16Bit COUNT_X
    #double16Bit COUNT_X
    jsr deriveParametersFromPixel
    jsr setZoomLevel
    rts

PROG_SIG .text "MGSJ"