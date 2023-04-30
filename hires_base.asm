hires .namespace

MMU_IO_CTRL = $0001
VKY_MSTR_CTRL_0 = $D000
VKY_MSTR_CTRL_1 = $D001

LAYER_REG1 = $D002
LAYER_REG2 = $D003
BITMAP_0_ENABLE = $D100
BITMAP_0_ADDR_LOW = $D101
BITMAP_0_ADDR_MDL = $D102
BITMAP_0_ADDR_HI = $D103

BITMAP_1_ENABLE = $D108
BITMAP_2_ENABLE = $D110

BITMAP_0_MEM = $40000
BITMAP_WINDOW = $6000
ZP_GRAPHIC_PTR = $90


; --------------------------------------------------
; This routine turns the bitmap mode on and clears the
; (hires) screen.
;--------------------------------------------------
On
    ; switch to I/O page 0 
    stz MMU_IO_CTRL

    ; setup layers, we want bitmap 0 in layer 0 and nothing in layer 1 or 2
    ; we therefore only set a value for layer 0
    stz LAYER_REG1  

    ; Explicitly disable bitmaps 1 and 2
    stz BITMAP_1_ENABLE
    stz BITMAP_2_ENABLE

    ; set address of bitmap 0 memory, i.e $40000
    lda #<BITMAP_0_MEM
    sta BITMAP_0_ADDR_LOW
    lda #>BITMAP_0_MEM
    sta BITMAP_0_ADDR_MDL
    lda #`BITMAP_0_MEM
    sta BITMAP_0_ADDR_HI

    ; use color map 0 and turn bitmap 0 on
    lda #1
    sta BITMAP_0_ENABLE

    ; turn on graphics mode on and allow for displaying bitmap layers
    lda #%00001100
    sta VKY_MSTR_CTRL_0
    stz VKY_MSTR_CTRL_1

    jsr clearBitmap

    rts


; --------------------------------------------------
; This routine turns the bitmap mode off again.
;--------------------------------------------------
Off
    lda #1
    sta VKY_MSTR_CTRL_0
    stz VKY_MSTR_CTRL_1
    rts


setCodeWindow
    lda #3
    sta 11
    rts


backgroundColor .byte 0

clearBitmap
    stz COUNT_WINDOWS
    lda COUNT_WINDOWS
_nextWindow
    jsr setBitmapWindow
    lda #32
    sta MAX_256_BYTE_BLOCK
    jsr clearBitmapWindow
    inc COUNT_WINDOWS
    lda COUNT_WINDOWS
    cmp #9
    bne _nextWindow

    jsr setBitmapWindow

    lda #12
    sta MAX_256_BYTE_BLOCK
    jsr clearBitmapWindow

    jsr setCodeWindow

    rts

strSetPixelArgs .struct 
x               .word 0
y               .byte 0
col             .byte 0
                .endstruct

setPixelArgs .dstruct strSetPixelArgs

; --------------------------------------------------
; This routine sets a pixel in the bitmap using XPOS, YPOS and
; COLOR from above
;--------------------------------------------------
setPixel
    ; multiply 320 and y position
    ; multiplication result is stored at $DE04-$DE07
    lda setPixelArgs.y
    sta $DE00
    stz $DE01
    #load16BitImmediate 320, $DE02

    ; calculate (320 * YPOS) + XPOS    
    clc
    lda $DE04
    adc setPixelArgs.x
    sta ZP_GRAPHIC_PTR
    lda $DE05
    adc setPixelArgs.x+1
    sta GRAPHIC_ADDRESS
    lda #0
    adc $DE06
    sta GRAPHIC_ADDRESS+1

    ; get address in 8K window => look at lower 13 bits
    ; caclulate ((320 * YPOS + XPOS) MOD 8192) + $6000
    lda GRAPHIC_ADDRESS
    and #%00011111
    clc 
    adc #>BITMAP_WINDOW
    sta ZP_GRAPHIC_PTR+1

    ; determine 8K window to write to
    ; calculate (320 * YPOS + XPOS) DIV 8192
    ; get lower three bits 
    lda GRAPHIC_ADDRESS
    lsr
    lsr 
    lsr 
    lsr
    lsr 
    ; get most significant bit for bitmap window 
    ; GRAPHIC_ADDRESS+1 can either be zero or one
    ldy GRAPHIC_ADDRESS+1
    beq _writeColor
    ora #8
_writeColor    
    #setWindow
    ; set pixel
    lda setPixelArgs.col
    sta (ZP_GRAPHIC_PTR)

    rts


;------------------------------------------------------------------

setWindow .macro
    clc
    adc #(BITMAP_0_MEM/8192)
    sta 11
    .endmacro


setBitmapWindow
    #setWindow
    rts


clearBitmapWindow
    #load16BitImmediate BITMAP_WINDOW, ZP_GRAPHIC_PTR
    ldx #0
_nextBlock
    ldy #0
    lda backgroundColor
_loopBlock
    sta (ZP_GRAPHIC_PTR), Y
    iny
    bne _loopBlock
    inc ZP_GRAPHIC_PTR+1
    inx
    cpx MAX_256_BYTE_BLOCK
    bne _nextBlock
    rts


COUNT_WINDOWS .byte 0
MAX_256_BYTE_BLOCK .byte 0
BMP_WIN .byte 0
GRAPHIC_ADDRESS .byte 0,0

.endnamespace