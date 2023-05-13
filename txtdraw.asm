
rectParam_t .struct 
xpos      .byte 0
ypos      .byte 0
lenx      .byte 0
leny      .byte 0
col       .byte 0
overwrite .byte 0
.endstruct

drawParam_t .struct  leftMost, middle, rightMost
left    .byte \leftMost
middle  .byte \middle
right   .byte \rightMost
.endstruct

txtdraw .namespace

LL_OPER = $DE00
LH_OPER = $DE01
RL_OPER = $DE02
RH_OPER = $DE03
MUL_RES = $DE04

X_MAX = 80
Y_MAX = 60

BLANK_CHAR = 32
LEFT_UPPER_CHAR = 1
RIGHT_UPPER_CHAR = 2
MIDDLE_UPPER_CHAR = 3
LEFT_MIDDLE_CHAR = 4
RIGHT_MIDDLE_CHAR = 5
LEFT_LOWER_CHAR = 6
RIGHT_LOWER_CHAR = 7
MIDDLE_LOWER_CHAR = 8


UPPER_LINE  .dstruct drawParam_t, LEFT_UPPER_CHAR, MIDDLE_UPPER_CHAR, RIGHT_UPPER_CHAR
LOWER_LINE  .dstruct drawParam_t, LEFT_LOWER_CHAR, MIDDLE_LOWER_CHAR, RIGHT_LOWER_CHAR
MIDDLE_LINE .dstruct drawParam_t, LEFT_MIDDLE_CHAR, BLANK_CHAR, RIGHT_MIDDLE_CHAR
CLEAR_LINE  .dstruct drawParam_t, BLANK_CHAR, BLANK_CHAR, BLANK_CHAR
WORKING_LINE .dstruct drawParam_t, 0, 0, 0


calcStartOffset
    stz LH_OPER
    lda #X_MAX
    sta LL_OPER
    stz RH_OPER
    sty RL_OPER
    #move16Bit MUL_RES, OFFSET
    clc
    lda OFFSET
    adc RECT_PARAMS.xpos
    sta OFFSET
    lda OFFSET+1
    adc #0
    sta OFFSET+1
    rts

toTxtMatrix .macro
    lda #2
    sta $01
.endmacro

toColorMatrix .macro
    lda #3
    sta $01
.endmacro

IO_STATE .byte 0
OFFSET .byte 0, 0
LEN_X_COUNT .byte 0
LEN_Y_COUNT .byte 0
DRAW_MIDDLE .byte 0

moveToNextChar .macro
    inx                                                         ; increment draw pos
    inc LEN_X_COUNT                                             ; increment length counter
    #inc16Bit TXT_DRAW_PTR1                                     ; increment memory pointer
.endmacro

drawLine
    ; x contains current x pos. X has to be < 80
    ldx RECT_PARAMS.xpos
    ; LEN_X_COUNT contains number of characters already processed in this line
    ; LEN_X_COUNT has to by < RECT_PARAMS.lenx
    stz LEN_X_COUNT

    ; save current IO state
    lda $01
    sta IO_STATE

    ; calculate start address in text and colour memory
    jsr calcStartOffset
    #add16BitImmediate $C000, OFFSET
    #move16Bit OFFSET, TXT_DRAW_PTR1
    
    ; store leftmost character and its colour in memory
    #toTxtMatrix
    lda WORKING_LINE.left
    sta (TXT_DRAW_PTR1)
    #toColorMatrix
    lda RECT_PARAMS.col 
    sta (TXT_DRAW_PTR1)

    ; move to next character
    #moveToNextChar

_loopMiddle
    cpx #X_MAX                                                  ; Have we left the screen?
    bcs _lineDone                                               ; Yes, we have reached the right border => we are done
    lda LEN_X_COUNT
    cmp RECT_PARAMS.lenx                                        ; Have we drawn all middle characters?
    bcs _middleDone                                             ; We have drawn all middle characters => draw right edge
    lda DRAW_MIDDLE                                             ; do we actually draw the contents?
    beq _nextChar                                               ; no => on to next char
    #toTxtMatrix
    lda WORKING_LINE.middle
    sta (TXT_DRAW_PTR1)
    #toColorMatrix
    lda RECT_PARAMS.col
    sta (TXT_DRAW_PTR1)
_nextChar
    ; move to next character
    #moveToNextChar
    bra _loopMiddle
    ; if we get here then x is still <= 79
    ; otherwise the check at _loopMiddle would have resulted
    ; in a branch to _lineDone.
_middleDone
    #toTxtMatrix
    lda WORKING_LINE.right
    sta (TXT_DRAW_PTR1)
    #toColorMatrix
    lda RECT_PARAMS.col
    sta (TXT_DRAW_PTR1)
_lineDone
    ; restore original IO state
    lda IO_STATE
    sta $01
    rts


.endnamespace

setDrawParams .macro params
    lda \params
    sta txtdraw.WORKING_LINE
    lda \params+1
    sta txtdraw.WORKING_LINE+1
    lda \params+2
    sta txtdraw.WORKING_LINE+2
.endmacro

moveToNextLine .macro
    iny
    inc txtdraw.LEN_Y_COUNT
.endmacro


RECT_PARAMS .dstruct rectParam_t

makeRect .macro UPPER, MIDDLE, LOWER
    ldy RECT_PARAMS.ypos
    stz txtdraw.LEN_Y_COUNT
    #setDrawParams \UPPER
    lda #1
    sta txtdraw.DRAW_MIDDLE
    jsr txtdraw.drawLine
    #setDrawParams \MIDDLE
    #moveToNextLine
    lda RECT_PARAMS.overwrite
    sta txtdraw.DRAW_MIDDLE
_loopLine
    cpy #txtdraw.Y_MAX
    bcs _rectDone
    lda txtdraw.LEN_Y_COUNT
    cmp RECT_PARAMS.leny
    bcs _middleDone
    jsr txtdraw.drawLine
    #moveToNextLine
    bra _loopLine
_middleDone
    #setDrawParams \LOWER
    lda #1
    sta txtdraw.DRAW_MIDDLE
    jsr txtdraw.drawLine
_rectDone
.endmacro

drawRect
    #makeRect txtdraw.UPPER_LINE, txtdraw.MIDDLE_LINE, txtdraw.LOWER_LINE
    rts

clearRect
    #makeRect txtdraw.CLEAR_LINE, txtdraw.CLEAR_LINE, txtdraw.CLEAR_LINE
    rts
