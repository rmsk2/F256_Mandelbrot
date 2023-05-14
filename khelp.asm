CURSOR_X = $D014
CURSOR_Y = $D016

; value of event buffer at program start (likely set by `superbasic`)
oldEvent .byte 0, 0
; the new event buffer
myEvent .dstruct kernel.event.event_t


; --------------------------------------------------
; This routine saves the current value of the pointer to the kernel event 
; buffer and sets that pointer to the address of myEvent. This in essence
; disconnects superbasic from the kernel event stream.
;--------------------------------------------------
initEvents
    #move16Bit kernel.args.events, oldEvent
    #load16BitImmediate myEvent, kernel.args.events
    rts


; --------------------------------------------------
; This routine restores the pointer to the kernel event buffer to the value
; encountered at program start. This reconnects superbasic to the kernel
; event stream.
;--------------------------------------------------
restoreEvents
    #move16Bit oldEvent, kernel.args.events
    rts


; --------------------------------------------------
; This macro prints a string to the screen at a given x and y coordinate. The 
; macro has the following parameters
;
; 1. x coordinate
; 2. y coordinate
; 3. address of text to print
; 4. length of text to print
; 5. address of color information
;--------------------------------------------------
kprint .macro x, y, txtPtr, len, colPtr
     lda #\x                                     ; set x coordinate
     sta kernel.args.display.x
     lda #\y                                     ; set y coordinate
     sta kernel.args.display.y
     #load16BitImmediate \txtPtr, kernel.args.display.text
     lda #\len                                   ; set text length
     sta kernel.args.display.buflen
     #load16BitImmediate \colPtr, kernel.args.display.color
     jsr kernel.Display.DrawRow                  ; print to the screen
     .endmacro


setCursor
    stz CURSOR_X+1
    stx CURSOR_X
    stz CURSOR_Y+1
    sta CURSOR_Y
    rts    