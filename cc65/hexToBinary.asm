jmp INIT

; .include "Character_ASCII_Const.asm"

;;;;;;WORDS ARE EASIER TO REMEMBER THAN ADDRESSES, LETS ASSIGN NAMES TO OUR ADRESSES

BLNSW = $CC   ; Cursor blink on or off

SPENA = $D015 ; Sprite Enable Register

SSDP0 = $07F8 ; Sprite Shape Data Pointers
SSDP1 = $07F9

SP0X = $D000 ; Sprite 0 Horizontal Position

SP0Y = $D001 ; Sprite 0 Vertical Position

SP1X = $D002 ; Sprite 1 Horizontal Position

SP1Y = $D003 ; Sprite 1 Vertical Posilooption

MSIGX = $D010 ; Most Significant Bits of Sprites 0-7 Horizontal Position

YXPAND = $D017 ; Sprite Vertical Expansion Register

XXPAND = $D01D ; Sprite Horizontal Expansion Register

SP0COL = $D027 ; Sprite 0 Color Register

SP1COL = $D028 ; Sprite 1 Color Register

SPMC = $D01C ; Sprite Multicolor Registers 

SP0DATA = $2000 ; Sprite 0 and 1 data start

SP1DATA = $2040

; Kernal routines
CHROUT = $FFD2        ; Character out  
SCNKEY = $FF9F        ; Scan keyboard for keypress    
GETIN = $FFE4         ; Get Input from the buffer and store it in A
PLOT = $FFF0          ; Set/Read cursor location

; Variables
BYTECOUNTER = $033F   ; As data is entered by the user, we will count how many characters are entered.
                      ; BYTECOUNTER will record this count.
                      ; $033C-$03FB is the Datasette buffer

OURHEXNUM = $033C     ; The sum of the user's two keystrokes.
LOWBYTE = $033D       ; first digit input storage
HIGHBYTE = $033E      ; second digit input storage

TESTBYTE = $0345      ; 

BIT7 = $0708          ; This is the location of the 7th bit, required room for
                      ; 8 contiguous bytes after the starting address
                      ; using 0708 dumps it right to screen ram, bottom center


greeting_TEXT:
  .byte "please guess the number (0 - 255)"
  brk

htlo=$14
hthi=$15
INIT:
  lda #$93
  jsr CHROUT

START:
  ldy #$80        ; Our first bit test for bit 7 must be 10000000 $80 
  sty TESTBYTE

  ldx #$00
  stx BLNSW       ; Set Blinking Cursor to true
  stx BYTECOUNTER
  
  jsr WRITELABEL

  jsr SCANKBD

SETCONVERT:
  ldx #$00

CONVERSION:
  lda OURHEXNUM   ; E.g. 03 or 0000 0011
  and TESTBYTE    ;      1000 0000 so A becomes 0000 0000
  cmp #$00
  bne STORE1
  lda #$30        ; $30 is pet ascii for '0'
  jmp CONTINUE

STORE1:
  lda #$31        ; $31 is pet ascii for '1'

CONTINUE:
  sta BIT7,x
  inx
  lda TESTBYTE
  
  lsr             ; divide A by 2
  sta TESTBYTE
  cpx #$08
  bne CONVERSION

;;;;;;;;; BLANK THE TWO DIGITS, SET CURSOR TO THE ORIGINAL POSITION OF INPUT
  lda #$20        ; $20 is a blank space
  sta $0413
  sta $0414
  clc 
  ldx #$00
  ldy #$00
  jsr PLOT
  jmp START

;;;;;;;;;;;;;;;;  Our scan keyboard function, if a key is pressed, it will appear
;;;;;;;;;;;;;;;;  In the accumulator, hex value, and tested
SCANKBD:
  jsr SCNKEY        ; our kernel routines for scanning the keyboard
  jsr GETIN         ; our kernel routine for, is key found dump in Accumulator
  cmp #$51          ; Compare A to 'Q'
  beq END           ; if A == 'Q' then beq

  cmp #$30          ; less than the hex value for 0?
  bcc SCANKBD  ; If A < '0' then bcc

  cmp #$3A          ; less than the hex value of 9 but greater than 0?
  bcc DIGITCONVERT  ; jump to our function to convert a digit

  cmp #$41          ; Compare A to 'A'
  bcc SCANKBD  ; If A < 'A' then bcc

  cmp #$47          ; Compare A to 'G'
  bcc LETTERCONVERT ; If A < 'G' then bcc

  jmp SCANKBD  ; else SCANKBD

PROCESS:
  ldx BYTECOUNTER ; BYTECOUNTER is either 0 or 1.
  sta LOWBYTE,x   ; A contains the character last entered by the user ([0-9]|[A-F])
  inx
  stx BYTECOUNTER
  cpx #$02
  bne SCANKBD

  clc             ; pre-emptively clc just in case
  lda LOWBYTE     ; Max value of lowbyte is 0F
  adc HIGHBYTE    ; Max value of highbyte is F0
  sta OURHEXNUM
  jmp SETCONVERT

LETTERCONVERT:
  jsr CHROUT

  sbc #$36        ; Subtracts $36 from the screen code in the accumulator that the represents the letter that the user pressed (A-F)
  jmp MAINCONVERT

DIGITCONVERT:
  jsr CHROUT
  sbc #$2F        ; Subtracts $2F from the screen code in the accumulator that the represents the letter that the user pressed (A-F)

MAINCONVERT:
  ldy BYTECOUNTER
  cpy #$01        ; Has the user entered two values? 
  beq PROCESS     ; Is yes, then branch
  asl             ; 4 of these has the effect of multiplying the value in A by $10.  So $03 becomes $30
  asl
  asl
  asl
  jmp PROCESS

END:
  rts

WRITELABEL:
  lda #<greeting_TEXT
  ldy #>greeting_TEXT

  sta htlo
  sty hthi

  ldy #0

loop:
  lda (htlo),y
  cmp #0
  beq END
  jsr CHROUT

  clc
  inc htlo
  bne loop
  inc hthi
  jmp loop

  rts


