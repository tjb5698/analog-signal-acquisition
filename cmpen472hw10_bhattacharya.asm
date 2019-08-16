;***************************************************************
;*
;* Title: Analog Signal Acquisition with HCS12
;*
;* Objective: CMPEN472 Homework 10
;* 
;* Revision: V2.1
;*
;* Date: April 08 2019
;*
;* Programmer: Trishita Bhattacharya
;*
;* Company : The Pennsylvania State Uninveristy, EECS
;*
;* Algorithm: Timer module and interrupt based Analog Signal Acquisition programming
;*
;* Register use: A: Serial port input, counters, temporary values, 
;*                  time,operators
;*               B: counters, temporary values, time         
;*             X,Y: pointers to memory locations, print messages
;*
;* Memory use: RAM Locations from $3000 for data, 
;*                                $3100 for program
;*
;* Input: Signals waves generated by tone generator (440Hz, 550Hz and 1000Hz)
;* 
;* Output: Digital values of the analog signal sampled at the rate of 8KHz in RxData3.txt and graphs generated by it
;*
;* Observation: This is a program that uses use serial port, 
;*              arithmetic instructions, simple command line 
;*               parsing, and basic I/O system subroutines.
;*
;***************************************************************
; export symbols
            XDEF        Entry        ; export 'Entry' symbol
            ABSENTRY    Entry        ; for assembly entry point

; include derivative specific macros

ATDCTL2     EQU         $0082
ATDCTL3     EQU         $0083
ATDCTL4     EQU         $0084
ATDCTL5     EQU         $0085
ATDSTAT0    EQU         $0086
ATDDR0H     EQU         $0090
ATDDR0L     EQU         $0091
ATDDR7H     EQU         $009e
ATDDR7L     EQU         $009f

PTIP        EQU         $0259        ; PORT P input register
DDRP        EQU         $025A        ; PORT P data direction register
PERP        EQU         $025C        ; PORT P pull device enable register
PPSP        EQU         $025D        ; PORT P polarity select register

SCIBDH      EQU         $00c8        ; Serial port (SCI) Baud Rate Register H
SCISR1      EQU         $00cc        ; Serial port (SCI) Status Register 1
SCIDRL      EQU         $00cf        ; Serial port (SCI) Data Register

TIOS        EQU         $0040        ; Timer Input Capture (IC) or Output Compare (OC) select
TIE         EQU         $004C        ; Timer interrupt enable register
TCNTH       EQU         $0044        ; Timer free runing main counter
TSCR1       EQU         $0046        ; Timer system control 1
TSCR2       EQU         $004D        ; Timer system control 2
TFLG1       EQU         $004E        ; Timer interrupt flag 1
TC2H        EQU         $0054        ; Timer channel 2 register

CR          equ         $0d          ; carriage return, ASCII 'Return' key
LF          equ         $0a          ; line feed, ASCII 'next line' character
                                                                 
;*******************************************************
; interrupt vector section

            ORG     $3FEA            ; Timer channel 2 interrupt vector setup
            DC.W    oc2isr

;*******************************************************
; variable/data section
            ORG     $3000            ; RAMStart defined as $3000

msg1        DC.B    'Baud rate changed! Please reopen the HyperTerminal with 115.2Kbaud', $00
msg2        DC.B    'Please connect the audio cable to HCS12 board.', $00
msg3        DC.B    'Well>  ', $00

loopct      DC.B    $00              ; keeps a track of when to accept 'a' command
tbct        DC.W    $0000            ; transmit byte counter

; following escape sequence works on Hyper Terminal (but NOT the TestTerminal)
ResetTerm       DC.B    $1B, 'c', $00                 ; reset terminal to default setting
ClearScreen     DC.B    $1B, '[2J', $00               ; clear the Hyper Terminal screen

;*******************************************************
; code section
            ORG     $3100
Entry
            LDS     #Entry             ; initialize the stack pointer

            LDAA    #%00000011
            STAA    PERP               ; enable the pull up/down feature at PORTP bit 0 and 1
            BCLR    PPSP,%00000011     ; select pull up feature at PORTP bit 0 and 1 for the
                                       ; Push Button Switch 1 and 2.
            BCLR    DDRP,%00000011     ; Push Button Switch 1 and 2 at PORTP bit 0 and 1
            
            LDAA    #%11000000         ; Turn ON ADC, clear flags, Disable ATD interrupt
            STAA    ATDCTL2
            LDAA    #%00001000         ; Single conversion per sequence, no FIFO
            STAA    ATDCTL3
            LDAA    #%01000111         ; 10bit, ADCLK=24MHz/16=1.5MHz, sampling time=8*(1/ADCLK)
            STAA    ATDCTL4                         ; set PORTP bit 0 and 1 as input

            ldx     #ResetTerm         ; reset Hyper Terminal to default values
            jsr     printmsg
            ldx     #ClearScreen       ; clear the Hyper Terminal Screen first
            jsr     printmsg

            ldx     #msg1              ; print the first message about baud rate change
            jsr     printmsg
            jsr     nextline
            
            jsr     delay10ms          ; wait to finish sending characters
            
            LDX     #$000D             ; Change the SCI port baud rate to 115.2K
            STX     SCIBDH

mloop1      jsr     getchar
            cmpa    #0
            beq     mloop1
            jsr     putchar            ; type writer, with echo print
            cmpa    #CR
            bne     mloop1             ; if Enter/Return key is pressed, move the
            ldaa    #LF                ; cursor to next line
            jsr     putchar
            ldx     #msg2            
            jsr     printmsg           ; print 'connect audio cable'
            jsr     nextline
            ldx     #msg3              ; print 'Well> '
            jsr     printmsg
                        
mloop2      ldab    loopct
            jsr     getchar
            cmpa    #0
            beq     mloop2
            cmpa    #CR
            beq     mloopnext          ; if Enter/Return key is pressed
            cmpb    #$00
            beq     mloop2
            cmpa    #$61               ; if 'a' 
            beq     mloopexit
            bra     mloop2
            
mloopnext   jsr     putchar
            incb
            stab    loopct
            ldaa    #LF                ; if return key is pressed, cursor to next line
            jsr     putchar
            jsr     go2ADC             ; single ADC on AN7 pin 
            ldx     #msg3              ; print 'Well> '
            jsr     printmsg
            bra     mloop2             ; repeat last two steps in case of return key
            
mloopexit   jsr     putchar
            jsr     nextline
            ldx     #msg4              ; print 'Please disconnect the HyperTerminal'
            jsr     printmsg
            jsr     nextline
            ldx     #msg5              ; print 'Start NCH Tone Generator program'
            jsr     printmsg
            jsr     nextline
            ldx     #msg6              ; print 'Start SB Data Receive program'
            jsr     printmsg
            jsr     nextline
            ldx     #msg7              ; print 'Then press the switch SW1, '
            jsr     printmsg
            ldx     #msg8              ; print 'for 1024 point analog to digital conversions'
            jsr     printmsg
            jsr     nextline            
                       

loopTx      LDAA   #%00000000
            STAA   TIE                 ; set CH2 interrupt Enable
            
            LDAA    PTIP               ; read push button SW1 at PORTP0
            ANDA    #%00000001         ; check the bit 0 only
            BNE     loopTx             ; SW1 not pushed

            ldx     #0                 ; initialize transmit byte counter to 0
            stx     tbct
            
            JSR     StartTimer2oc      ; enable/start interrupt service

loop1024    ldx     tbct               ; SW1 pushed
            cpx     #1030              ; 1031 bytes will be sent, the receiver at Windows PC 
            beq     loopTx             ; will only take 1028 bytes.  The SB Data Receive program, 
                                       ; then trim first three and the last one 
                                       ; to make the file RxData3.txt with exactly 1024 data 
                                       ; points.            
            bra     loop1024           ; Assume the SB Data Receive program running on Windows PC 


;***********Timer OC2 interrupt service routine***************
oc2isr
            ldd     #3000              ; 125usec with (24MHz/1 clock)
            addd    TC2H               ; for next interrupt
            std     TC2H               ; + Fast clear timer CH2 interrupt flag
            
            ldaa    ATDDR0H            ; pick up the upper 8bit result of last ADC result   
            jsr     putchar
            
            ldx     tbct               
            cpx     #1030              ; if 1030 data points have been collected 
            sei                        ; stop interrupt routine
            beq     oc2done            ; and exit
            inx                        ; else increase transmit byte counter by one 
            stx     tbct
            
            jsr     go2ADC            ; single ADC on AN7 pin
            
oc2done     RTI

;***********end of Timer OC2 interrupt service routine********

;***************StartTimer2oc************************
;* Program: Start the timer interrupt, timer channel 2 output compare
;* Input:   Constants - channel 2 output compare, 125usec at 24MHz
;* Output:  None, only the timer interrupt
;* Registers modified: D used and CCR modified
;* Algorithm:
;             initialize TIOS, TIE, TSCR1, TSCR2, TC2H, and TFLG1
;**********************************************
StartTimer2oc
            PSHD
            LDAA    #%00000100
            STAA    TIOS              ; set CH2 Output Compare
            STAA    TIE               ; set CH2 interrupt Enable
            LDAA    #%10010000        ; enable timer and set Fast Flag Clear
            STAA    TSCR1
            LDAA    #%00000000        ; TOI Off, TCRE Off, TCLK = BCLK/1
            STAA    TSCR2             ;   not needed if started from reset

            LDD     #3000             ; 125usec with (24MHz/1 clock)
            ADDD    TCNTH             ;    for first interrupt
            STD     TC2H              ;    + Fast clear timer CH2 interrupt flag

            PULD
            BSET    TFLG1,%00000100   ; initial Timer CH2 interrupt flag Clear, not needed if fast clear set

            CLI                       ; enable interrupt
            
            RTS

;***************end of StartTimer2oc*****************

;***********single AD conversiton*********************
; This is a sample, interrupt based
;
go2ADC
            PSHA                   ; Start ATD conversion
            LDAA  #%00000111       ; left justified, unsigned, single conversion,
            STAA  ATDCTL5          ; single channel, CHANNEL 7, start the conversion

            PULA
            RTS

;***********end of AD conversiton**************   

;***********printmsg***************************
;* Program: Output character string to SCI port, print message
;* Input:   Register X points to ASCII characters in memory
;* Output:  message printed on the terminal connected to SCI port
;* 
;* Registers modified: CCR
;* Algorithm:
;     Pick up 1 byte from memory where X register is pointing
;     Send it out to SCI port
;     Update X register to point to the next byte
;     Repeat until the byte data $00 is encountered
;       (String is terminated with NULL=$00)
;**********************************************
NULL            equ     $00
printmsg        psha                   ;Save registers
                pshx
printmsgloop    ldaa    1,X+           ;pick up an ASCII character from string
                                       ;   pointed by X register
                                       ;then update the X register to point to
                                       ;   the next byte
                cmpa    #NULL
                beq     printmsgdone   ;end of strint yet?
                bsr     putchar        ;if not, print character and do next
                bra     printmsgloop
printmsgdone    pulx 
                pula
                rts
;***********end of printmsg********************

;***************putchar************************
;* Program: Send one character to SCI port, terminal
;* Input:   Accumulator A contains an ASCII character, 8bit
;* Output:  Send one character to SCI port, terminal
;* Registers modified: CCR
;* Algorithm:
;    Wait for transmit buffer become empty
;      Transmit buffer empty is indicated by TDRE bit
;      TDRE = 1 : empty - Transmit Data Register Empty, ready to transmit
;      TDRE = 0 : not empty, transmission in progress
;**********************************************
putchar     brclr SCISR1,#%10000000,putchar   ; wait for transmit buffer empty
            staa  SCIDRL                      ; send a character
            rts
;***************end of putchar*****************

;****************getchar***********************
;* Program: Input one character from SCI port (terminal/keyboard)
;*             if a character is received, other wise return NULL
;* Input:   none    
;* Output:  Accumulator A containing the received ASCII character
;*          if a character is received.
;*          Otherwise Accumulator A will contain a NULL character, $00.
;* Registers modified: CCR
;* Algorithm:
;    Check for receive buffer become full
;      Receive buffer full is indicated by RDRF bit
;      RDRF = 1 : full - Receive Data Register Full, 1 byte received
;      RDRF = 0 : not full, 0 byte received
;**********************************************

getchar     brclr SCISR1,#%00100000,getchar7
            ldaa  SCIDRL
            rts
getchar7    clra
            rts
;****************end of getchar**************** 

;****************nextline**********************
nextline    ldaa  #CR              ; move the cursor to beginning of the line
            jsr   putchar          ;   Cariage Return/Enter key
            ldaa  #LF              ; move the cursor to next line, Line Feed
            jsr   putchar
            rts
;****************end of nextline***************

;****************delay10ms**********************
delay10ms:  pshx
            ldx   #$FFFF           ; count down X, $FFFF may be more than 10ms 
d10msloop   nop                    ;   X <= X - 1
            dex                    ; simple loop
            bne   d10msloop
            pulx
            rts
;****************end of delay10ms***************


msg4        DC.B    '1. Please disconnect the HyperTerminal', $00
msg5        DC.B    '2. Start NCH Tone Generator program', $00
msg6        DC.B    '3. Start SB Data Receive program', $00
msg7        DC.B    '4. Then press the switch SW1, for',$00
msg8        DC.B    ' 1024 point analog to digital conversions', $00




            END                    ; this is end of assembly source file
                                   ; lines below are ignored - not assembled