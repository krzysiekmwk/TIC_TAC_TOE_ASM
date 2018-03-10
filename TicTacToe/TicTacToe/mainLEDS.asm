;
; AKleds.asm
;
; Created: 10.03.2018 15:03:17
; Author : Piotr Borowski
;

.include "m328pdef.inc"

;columns PORTC
.equ COL0 =	0b00000001
.equ COL1 =	0b00000010
.equ COL2 =	0b00000100
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
	

;TODO: USTAWINIE PLAYER I WIERSZA BEZ ZAKLOCANIA SIEBIE NAWZAJEM

;setdiode[column][row][color]
setdiode00G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW0
	or r17, r18
	out PORTD, r17
	rjmp alldiodesOFF 
setdiode00R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW0
	out PORTD, r17 
	rjmp alldiodesOFF
setdiode01G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW1
	out PORTD, r17
	rjmp alldiodesOFF 
setdiode01R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW1
	out PORTD, r17 
	rjmp alldiodesOFF
setdiode02G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW2
	out PORTD, r17
	rjmp alldiodesOFF 
setdiode02R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW2
	out PORTD, r17 
	rjmp alldiodesOFF
setdiode10G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW0
	out PORTD, r17
	rjmp alldiodesOFF 
setdiode10R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW0
	out PORTD, r17 
	rjmp alldiodesOFF
setdiode11G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW1
	out PORTD, r17
	rjmp alldiodesOFF 
setdiode11R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW1
	out PORTD, r17 
	rjmp alldiodesOFF
setdiode12G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW2
	out PORTD, r17
	rjmp alldiodesOFF 
setdiode12R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW2
	out PORTD, r17 
	rjmp alldiodesOFF
setdiode20G:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, GROW0
	out PORTD, r17
	rjmp alldiodesOFF 
setdiode21R:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, RROW1
	out PORTD, r17 
	rjmp alldiodesOFF
setdiode22G:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, GROW2
	out PORTD, r17
	rjmp alldiodesOFF 
setdiode22R:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, RROW2
	out PORTD, r17 
	rjmp alldiodesOFF
alldiodesOFF:
	ldi r17, 0x00
	out PORTC, r17
	ldi r17, 0b11000000
	and r17, r18
	out PORTD, r17 
	rjmp display