;
; AKleds.asm
;
; Created: 10.03.2018 15:03:17
; Author : Piotr Borowski
;

.include "m328pdef.inc"

;columns PORTC
.equ COL0 =	0b00000110
.equ COL1 =	0b00000101
.equ COL2 =	0b00000011
;green rows PORTD
.equ GROW0=	0b00000001
.equ GROW1=	0b00000100
.equ GROW2=	0b00010000
;red rows PORTD
.equ RROW0=	0b00000010
.equ RROW1=	0b00001000
.equ RROW2=	0b00100000
;player
.equ P1 =	0b01000000
.equ P2 =	0b10000000

; Replace with your application code
start:
	ldi r17, 0b00000111
	out DDRC, r17
	ldi r17, 0xFF	
	out DDRD, r17

display:
	;SMTHNG
	 
	sbis PORTD, 7
	rjmp setP2

setP1:
	ldi r17, P1
	out PORTD, r17
	mov r18, r17 ; przypisanie aktualnego playera
	rjmp displed

setP2:
	ldi r17, P2
	out PORTD, r17
	mov r18, r17 ; przypisanie aktualnego playera

displed:	

	;sprawdzanie ktora diode zapalic wtedy
	;rjmp setdiodeYXC
	rjmp setdiode00G
delay:
	ldi  r21, 41
    ldi  r19, 150
    ldi  r20, 128
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r21
    brne L1
	
	rjmp alldiodesoff

;TODO: USTAWINIE PLAYER I WIERSZA BEZ ZAKLOCANIA SIEBIE NAWZAJEM

;setdiode[column][row][color]
setdiode00G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW0
	or r17, r18
	out PORTD, r17
	rjmp delay 
setdiode00R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW0
	out PORTD, r17 
	rjmp delay
setdiode01G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW1
	out PORTD, r17
	rjmp delay 
setdiode01R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW1
	out PORTD, r17 
	rjmp delay
setdiode02G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW2
	out PORTD, r17
	rjmp delay 
setdiode02R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW2
	out PORTD, r17 
	rjmp delay
setdiode10G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW0
	out PORTD, r17
	rjmp delay 
setdiode10R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW0
	out PORTD, r17 
	rjmp delay
setdiode11G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW1
	out PORTD, r17
	rjmp delay 
setdiode11R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW1
	out PORTD, r17 
	rjmp delay
setdiode12G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW2
	out PORTD, r17
	rjmp delay 
setdiode12R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW2
	out PORTD, r17 
	rjmp delay
setdiode20G:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, GROW0
	out PORTD, r17
	rjmp delay 
setdiode21R:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, RROW1
	out PORTD, r17 
	rjmp delay
setdiode22G:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, GROW2
	out PORTD, r17
	rjmp delay 
setdiode22R:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, RROW2
	out PORTD, r17 
	rjmp delay
alldiodesOFF:
	ldi r17, 0b00000111
	out PORTC, r17
	ldi r17, 0b11000000
	and r17, r18
	out PORTD, r17 
	rjmp display