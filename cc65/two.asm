
;*******************************************************************************
;* Reverses the screen                                                         *
;*                                                                             *
;* Written By John C. Dale                                                     *
;* Tutorial #02                                                                *
;* Date : 28th Dec 2016                                                       *
;*                                                                             *
;*******************************************************************************
;*                                                                             *
;*******************************************************************************

SCRN_START=$0400

.macro ReverseScreenLocation scrnAddr
    lda scrnAddr,x
    eor #128
    sta scrnAddr,x
.endmacro

    ldx #0          ; Initialise Offset
LOOP:
    ReverseScreenLocation SCRN_START ; Screen Bank 0
    ReverseScreenLocation SCRN_START + $0100 ; Screen Bank 1
    ReverseScreenLocation SCRN_START + $0200 ; Screen Bank 2
    ReverseScreenLocation SCRN_START + $0300 ; Screen Bank 3
    inx
    bne LOOP
    rts
