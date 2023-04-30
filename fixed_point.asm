; zero page
ARITH_SCRATCH1 = $90
ARITH_SCRATCH2 = $91
ARITH_SCRATCH3 = $92
ARITH_SCRATCH4 = $93
LOOKUP_SCRATCH1 = $94
LOOKUP_SCRATCH2 = $95
LOOKUP_SCRATCH3 = $96
;COUNT_L = $97
;COUNT_R = $98
HELP_MUL = $99
TEMP_MUL = $9A           ; 8 bytes
LEFT_GREATER_EQUAL_RIGHT = $A2


; --------------------------------------------------
; load16BitImmediate loads the 16 bit value given in .val into the memory location given
; by .addr 
; --------------------------------------------------
load16BitImmediate .macro  val, addr 
    lda #<\val
    sta \addr
    lda #>\val
    sta \addr+1
.endmacro

; --------------------------------------------------
; move16Bit copies the 16 bit value stored at .memAddr1 to .memAddr2
; --------------------------------------------------
move16Bit .macro  memAddr1, memAddr2 
    ; copy lo byte
    lda \memAddr1
    sta \memAddr2
    ; copy hi byte
    lda \memAddr1+1
    sta \memAddr2+1
.endmacro

; --------------------------------------------------
; double16Bit multiplies the 16 bit value stored at .memAddr by 2
; --------------------------------------------------
double16Bit .macro  memAddr 
    asl \memAddr+1
    asl \memAddr                     
    bcc _noCarry                     ; no carry set => we are already done
    ; carry set => set least significant bit in hi byte. No add or inc is required as bit 0 
    ; of .memAddr+1 has to be zero due to previous left shift
    lda #$01
    ora \memAddr+1                   
    sta \memAddr+1
_noCarry    
.endmacro

; --------------------------------------------------
; halve16Bit divides the 16 bit value stored at .memAddr by 2
; --------------------------------------------------
halve16Bit .macro  memAddr 
    clc
    lda \memAddr+1
    ror
    sta \memAddr+1
    lda \memAddr
    ror
    sta \memAddr
.endmacro


; --------------------------------------------------
; sub16Bit subtracts the value stored at .memAddr1 from the value stored at the
; address .memAddr2. The result is stored in .memAddr2
; --------------------------------------------------
sub16Bit .macro  memAddr1, memAddr2 
    sec
    lda \memAddr2
    sbc \memAddr1
    sta \memAddr2
    lda \memAddr2+1
    sbc \memAddr1+1
    sta \memAddr2+1
.endmacro

; --------------------------------------------------
; add16Bit implements a 16 bit add of the values stored at memAddr1 and memAddr2 
; The result is stored in .memAddr2
; --------------------------------------------------
add16Bit .macro  memAddr1, memAddr2 
    clc
    ; add lo bytes
    lda \memAddr1
    adc \memAddr2
    sta \memAddr2
    ; add hi bytes
    lda \memAddr1+1
    adc \memAddr2+1
    sta \memAddr2+1
.endmacro

; --------------------------------------------------
; add16BitImmediate implements a 16 bit add of an immediate value to value stored at memAddr2 
; The result is stored in .memAddr2
; --------------------------------------------------
add16BitImmediate .macro  value, memAddr2 
    clc
    ; add lo bytes
    lda #<\value
    adc \memAddr2
    sta \memAddr2
    ; add hi bytes
    lda #>\value
    adc \memAddr2+1
    sta \memAddr2+1
.endmacro


; --------------------------------------------------
; inc16Bit implements a 16 bit increment of the 16 bit value stored at .memAddr 
; --------------------------------------------------
inc16Bit .macro  memAddr 
    clc
    lda #1
    adc \memAddr
    sta \memAddr
    bcc _noCarryInc
    inc \memAddr+1
_noCarryInc
.endmacro

; --------------------------------------------------
; dec16Bit implements a 16 bit decrement of the 16 bit value stored at .memAddr 
; --------------------------------------------------
dec16Bit .macro  memAddr
    lda \memAddr
    sec
    sbc #1
    sta \memAddr
    lda \memAddr+1
    sbc #0
    sta \memAddr+1
.endmacro


; --------------------------------------------------
; cmp16Bit compares the 16 bit values stored at memAddr1 and memAddr2 
; Z  flag is set in case these values are equal
; --------------------------------------------------
cmp16Bit .macro  memAddr1, memAddr2 
    lda \memAddr1+1
    cmp \memAddr2+1
    bne _unequal
    lda \memAddr1
    cmp \memAddr2
_unequal
.endmacro

; --------------------------------------------------
; cmp16BitImmediate compares the 16 bit value stored at memAddr with
; the immediate value given in .value.
; 
; Z  flag is set in case these values are equal. Carry is set
; if .value is greater or equal than the value store at .memAddr
; --------------------------------------------------
cmp16BitImmediate .macro  value, memAddr 
    lda #>\value
    cmp \memAddr+1
    bne _unequal2
    lda #<\value
    cmp \memAddr
_unequal2
.endmacro


TEMP_SIGN
.byte 0
TEMP_VAL
.byte 0,0,0,0
TEMP_ADDR
.byte 0,0


; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4 
; and adds them. This routine ignores the sign byte.
;
; The result is returned in the second operand, i.e. *opR <- *opL + *opR 
; --------------------------------------------------
add32BitUnsigned
    ldy #1                         ; skip over sign byte
    clc
    lda (ARITH_SCRATCH1),y
    adc (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y
    iny
    lda (ARITH_SCRATCH1),y
    adc (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y    
    iny
    lda (ARITH_SCRATCH1),y
    adc (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y    
    iny
    lda (ARITH_SCRATCH1),y
    adc (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y    

    rts

; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4 
; and subtracts them. The caller has to ensure that *opL >= *opR
;
; The result is returned in the second operand, i.e. *opR <- *opL - *opR 
; --------------------------------------------------
sub32BitUnsigned
    ldy #1                         ; skip over sign byte
    sec
    lda (ARITH_SCRATCH1),y
    sbc (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y
    iny
    lda (ARITH_SCRATCH1),y
    sbc (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y    
    iny
    lda (ARITH_SCRATCH1),y
    sbc (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y    
    iny
    lda (ARITH_SCRATCH1),y
    sbc (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y    
    rts

; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4 
; and subtracts them. The caller has to ensure that *opR >= *opL. This routine ignores the sign bytes.
;
; The result is returned in the second operand, i.e. *opR <- *opR - *opL 
; --------------------------------------------------
sub32SwitchedUnsigned
    ldy #1                         ; skip over sign byte
    sec
    lda (ARITH_SCRATCH3),y
    sbc (ARITH_SCRATCH1),y
    sta (ARITH_SCRATCH3),y
    iny
    lda (ARITH_SCRATCH3),y
    sbc (ARITH_SCRATCH1),y
    sta (ARITH_SCRATCH3),y    
    iny
    lda (ARITH_SCRATCH3),y
    sbc (ARITH_SCRATCH1),y
    sta (ARITH_SCRATCH3),y    
    iny
    lda (ARITH_SCRATCH3),y
    sbc (ARITH_SCRATCH1),y
    sta (ARITH_SCRATCH3),y    
    rts


OPER_L = $DE00
OPER_R = $DE02

COPROC_RES = $DE04

; --------------------------------------------------
; This macro copies a 16 bit integer starting at a given offset from the value
; to which zpAddr points to a target loaction.
; --------------------------------------------------
copyOperand  .macro offset, zpAddr, target
    ldy #\offset+1                                  ; skip sign byte
    lda (\zpAddr), y
    sta \target
    iny
    lda (\zpAddr), y
    sta \target+1
.endmacro

; --------------------------------------------------
; This macro adds the current multiplication result to the multiplication
; buffer at the specified offset.
; --------------------------------------------------
addMulRes .macro offset
    clc
    lda COPROC_RES
    adc TEMP_MUL + \offset
    sta TEMP_MUL + \offset
    lda COPROC_RES + 1
    adc TEMP_MUL + \offset + 1
    sta TEMP_MUL + \offset + 1
    lda COPROC_RES + 2
    adc TEMP_MUL + \offset + 2
    sta TEMP_MUL + \offset + 2
    lda COPROC_RES + 3
    adc TEMP_MUL + \offset + 3
    sta TEMP_MUL + \offset + 3
    bcc _nocarry
    ldx #\offset + 3
_carryLoop   
    inx
    lda #0
    adc TEMP_MUL, x
    sta TEMP_MUL, x
    bcs _carryLoop
_nocarry
.endmacro

; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4.
; It multiplies its operands as if they were unsigned 32 bit integers.
;
; The result is returned in the eight byte buffer starting at TEMP_MUL. 
; --------------------------------------------------
mul32BitCoProc
    ; clear upper half of temp buffer
    ldx #3                        
    lda #0
_clear                            
    sta TEMP_MUL + 4,x
    dex
    bpl _clear

    ; multiply two leftmost 16 bit digits
    #copyOperand 0, ARITH_SCRATCH1, OPER_L
    #copyOperand 0, ARITH_SCRATCH3, OPER_R

    ; copy multiplication result to lower half of temp buffer
    ldx #3
_copyRes1
    lda COPROC_RES, x                            
    sta TEMP_MUL,x
    dex
    bpl _copyRes1

    #copyOperand 0, ARITH_SCRATCH1, OPER_L
    #copyOperand 2, ARITH_SCRATCH3, OPER_R
    #addMulRes 2

    #copyOperand 2, ARITH_SCRATCH1, OPER_L
    #copyOperand 0, ARITH_SCRATCH3, OPER_R
    #addMulRes 2

    #copyOperand 2, ARITH_SCRATCH1, OPER_L
    #copyOperand 2, ARITH_SCRATCH3, OPER_R
    #addMulRes 4

    rts


; --------------------------------------------------
; This subroutine expects its operand in ARITH_SCRATCH1/2.
; It squares its operand as if it was an unsigned 32 bit integer.
;
; The result is returned in the eight byte buffer starting at TEMP_MUL. 
; --------------------------------------------------
square32BitCoProc
    ; clear upper half of temp buffer
    ldx #3                        
    lda #0
_clear                            
    sta TEMP_MUL + 4,x
    dex
    bpl _clear

    ; multiply two leftmost 16 bit digits
    #copyOperand 0, ARITH_SCRATCH1, OPER_L
    #copyOperand 0, ARITH_SCRATCH1, OPER_R

    ; copy multiplication result to lower half of temp buffer
    ldx #3
_copyRes1
    lda COPROC_RES, x                            
    sta TEMP_MUL,x
    dex
    bpl _copyRes1

    #copyOperand 0, ARITH_SCRATCH1, OPER_L
    #copyOperand 2, ARITH_SCRATCH1, OPER_R
    #addMulRes 2
    #addMulRes 2

    #copyOperand 2, ARITH_SCRATCH1, OPER_L
    #copyOperand 2, ARITH_SCRATCH1, OPER_R
    #addMulRes 4

    rts

; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4 
; and compares them. This routine ignores the sign byte it only compares the absolute values.
;
; The result is returned in the carry flag. Its is set if *opL >= *opR. In addition the the zero flag is set
; when the values are equal.
; --------------------------------------------------
cmp32BitUnsigned
    ldy #4                       ; start at MSB
    lda (ARITH_SCRATCH1), y
    cmp (ARITH_SCRATCH3), y
    beq _next1                   ; continue if equal
    rts                          ; carry contains result                   
_next1
    dey
    lda (ARITH_SCRATCH1), y
    cmp (ARITH_SCRATCH3), y
    beq _next2                   ; continue if equal
    rts                          ; carry contains result
_next2
    dey
    lda (ARITH_SCRATCH1), y
    cmp (ARITH_SCRATCH3), y
    beq _next3                   ; continue if equal
    rts                          ; carry contains result
_next3                           ; We get here only if all bytes before were equal
    dey
    lda (ARITH_SCRATCH1), y
    cmp (ARITH_SCRATCH3), y      ; carry contains result even if values are equal
_endCmp
    rts


; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4 
; The routine copies the value of oL to oR
;
; The result is returned in the second operand, i.e. *opR <- *opL 
; --------------------------------------------------
move32Bit
    ldy #4
_loopMove
    lda (ARITH_SCRATCH1),y
    sta (ARITH_SCRATCH3),y
    dey
    bpl _loopMove

    rts

move32BitInline .macro  src, target 
    ldy #4
_loopMove
    lda \src,y
    sta \target,y
    dey
    bpl _loopMove
.endmacro

; --------------------------------------------------
; This subroutine expects its operand in ARITH_SCRATCH1/2.
; The routine then doubles the value of its operand by simply performing a left shift. It
; ignores the sign byte.
;
; The operand is modified, i.e. *op <- 2 * *op 
; --------------------------------------------------
double32Bit
    ldy #1                        ; skip sign value
    lda (ARITH_SCRATCH1),y
    asl
    sta (ARITH_SCRATCH1),y

    iny
    lda (ARITH_SCRATCH1),y
    rol
    sta (ARITH_SCRATCH1),y

    iny
    lda (ARITH_SCRATCH1),y
    rol
    sta (ARITH_SCRATCH1),y

    iny
    lda (ARITH_SCRATCH1),y
    rol
    sta (ARITH_SCRATCH1),y

    rts


; --------------------------------------------------
; This subroutine expects it operand in ARITH_SCRATCH1/2.
; The routine then halves the value of its operand by simply performing a right shift. It
; ignores the sign byte.
;
; The operand is modified, i.e. *op <- *op / 2 
; --------------------------------------------------
halve32Bit
    clc
    ldy #4 
    lda (ARITH_SCRATCH1),y                       
    ror 
    sta (ARITH_SCRATCH1),y
    dey

    lda (ARITH_SCRATCH1),y                       
    ror 
    sta (ARITH_SCRATCH1),y
    dey

    lda (ARITH_SCRATCH1),y                       
    ror 
    sta (ARITH_SCRATCH1),y
    dey

    lda (ARITH_SCRATCH1),y                       
    ror 
    sta (ARITH_SCRATCH1),y

    rts


prepareAddSub .macro  
    lda #0
    sta LEFT_GREATER_EQUAL_RIGHT
    jsr cmp32BitUnsigned
    bcc _leftLessThanRight
    inc LEFT_GREATER_EQUAL_RIGHT
_leftLessThanRight
.endmacro

; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4.
; The routine adds the two operands and handles their signs correctly.
;
; The result is returned in the second operand, i.e. *opR <- *opL + *opR 
; --------------------------------------------------
add32Bit
    #prepareAddSub
    ldy #0
    lda (ARITH_SCRATCH1), y
    eor (ARITH_SCRATCH3), y
    beq _simpleAdd                         ; signs are equal => simply add values
    lda LEFT_GREATER_EQUAL_RIGHT
    bne _normalSub
    ; switched subtraction
    ; sign of result is sign of opR
    ; result is opR
    jsr sub32SwitchedUnsigned
    rts
_normalSub
    ; normal subtraction
    ; sign of result is sign of opL
    ; result is OpR
    lda (ARITH_SCRATCH1), y                ; set sign of result   
    sta (ARITH_SCRATCH3), y
    jsr sub32BitUnsigned
    rts
_simpleAdd
    ; addition
    ; sign of both operands is equal
    ; sign does not change
    jsr add32BitUnsigned
    rts


; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4.
; The routine subtracts the two operands and handles their signs correctly.
;
; The result is returned in the second operand, i.e. *opR <- *opL - *opR 
; --------------------------------------------------
sub32Bit
    #prepareAddSub
    ldy #0
    lda (ARITH_SCRATCH1), y
    eor (ARITH_SCRATCH3), y
    bne _simpleAdd2                       ; signs are different
    lda LEFT_GREATER_EQUAL_RIGHT
    bne _normalSub2
    ; switched subtraction
    ; sign of result is flipped
    ; result is opR
    lda (ARITH_SCRATCH3), y               ; set sign of result
    eor #1
    sta (ARITH_SCRATCH3), y
    jsr sub32SwitchedUnsigned
    rts
_normalSub2
    ; normal subtraction
    ; sign of result is unchanged
    ; result is opR
    jsr sub32BitUnsigned
    rts
_simpleAdd2
    ; add both operands
    ; sign of result is sign of opL
    ; result is opR
    lda (ARITH_SCRATCH1), y               ; set sign of result
    sta (ARITH_SCRATCH3), y
    jsr add32BitUnsigned
    rts

; --------------------------------------------------
; This subroutine expects its operand in ARITH_SCRATCH1/2. 
; The routine flips the sign of its operand
;
; The operand is modified, i.e. *op <- -*op 
; --------------------------------------------------
neg32
    ldy #0
    lda (ARITH_SCRATCH1), y
    eor #1
    sta (ARITH_SCRATCH1), y
    rts

neg32Inline .macro  addr 
    lda \addr
    eor #1
    sta \addr
.endmacro


; --------------------------------------------------
; This subroutine expects its operands in ARITH_SCRATCH1/2 and ARITH_SCRATCH3/4.
; The routine multiplies the two operands and handles their signs correctly.
;
; The result is returned in the second operand, i.e. *opR <- *opL * *opR 
; --------------------------------------------------
mul32BitNormalized
    ldy #0
    lda (ARITH_SCRATCH1),y                ; set sign of result
    eor (ARITH_SCRATCH3),y
    sta (ARITH_SCRATCH3),y

    jsr mul32BitCoProc

    ; copy bytes 3,4,5,6 from TEMP_MUL
    ; to bytes 1,2,3,4 of (ARITH_SCRATCH3)
    ldy #1
_loopNorm2
    lda TEMP_MUL+2, y
    sta (ARITH_SCRATCH3), y
    iny
    cpy #5
    bne _loopNorm2

    rts


; --------------------------------------------------
; This subroutine expects its operand in ARITH_SCRATCH1/2.
; The routine squres its operand and handles the sign correctly.
;
; The result is returned in the operand, i.e. *opL <- *opL * *opL 
; --------------------------------------------------
square32BitNormalized
    ; The sign of the result always positive
    lda #0
    ldy #0
    sta (ARITH_SCRATCH1), y                 

    jsr square32BitCoProc

    ; copy bytes 3,4,5,6 from TEMP_MUL
    ; to bytes 1,2,3,4 of (ARITH_SCRATCH1)
    ldy #1
_loopNorm3
    lda TEMP_MUL+2, y
    sta (ARITH_SCRATCH1), y
    iny
    cpy #5
    bne _loopNorm3

    rts    

callFunc .macro  func, addrL, addrR 
    #load16BitImmediate \addrL, ARITH_SCRATCH1
    #load16BitImmediate \addrR, ARITH_SCRATCH3
    jsr \func
.endmacro

callFuncMono .macro  func, addrL
    #load16BitImmediate \addrL, ARITH_SCRATCH1
    jsr \func
.endmacro

