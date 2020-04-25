; 10 SYS (2304)

*=$0801

    !byte    $0E, $08, $0A, $00, $9E, $20, $28
    !byte    $32, $33, $30, $34, $29, $00, $00, $00

;*******************************************************************************
;* Reverses the screen                                                         *
;*                                                                             *
;* Written By John C. Dale                                                     *
;* Tutorial #02                                                                *
;* Date : 28th Dec, 2016                                                       *
;*                                                                             *
;*******************************************************************************
;*                                                                             *
;*******************************************************************************

*=$0900
SCRN_START=$0400

!macro ReverseScreenLocation .t {
    lda .t,x
    eor #128
    sta .t,x
}

    ldx #0          ; Initialise Offset
LOOP
    +ReverseScreenLocation SCRN_START ; Screen Bank 0
    +ReverseScreenLocation SCRN_START + $0100 ; Screen Bank 1
    +ReverseScreenLocation SCRN_START + $0200 ; Screen Bank 2
    +ReverseScreenLocation SCRN_START + $0300 ; Screen Bank 3
    inx
    bne LOOP
    rts
