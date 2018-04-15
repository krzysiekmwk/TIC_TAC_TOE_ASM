.ORG 0x0000 rjmp SETUP
.ORG 0x001C rjmp MULTIP_LED

SETUP:

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

cli						; wyl¹czenie przerwan
ldi R16, HIGH(RAMEND)   ; zaladowanie adresu konca pamieci[stala RAMEND - zdefiniowana w pliku](starszej jego czesci) SRAM do R16 
out SPH, R16            ; zaladowanie zawartosci rejestru R16 do SPH(starszej czesci) rejestru ktory przechowuje tzw. wskaznik konca stosu 
ldi R16, LOW(RAMEND)    ; zaladowanie (mlodszej czesci) adresu konca pamieci sram do R16 
out SPL, R16			; przepisanie R16 do SPL - rejestru który przechowuje wskaznik konca stosu(mlodszej czesci) 

.DEF BUTTON_PIN = R21		; Miejsce w pamieci na ktory zostal wcisniety
LDI BUTTON_PIN, 0x00		; Przypisanie zera do przycisku - zaden nie zostal wcisniety

LDI R31, 0b00111000		; PIN 3,4,5 portu B ustawione jako wyjscia
OUT DDRB, R31			; Przypisanie wartosci do portu
LDI R31, 0b00111111		; rezystory pull-up na pinie 0,1,2,3,4,5
OUT PORTB, R31			; Przypisanie wartosci do portu. Sterowanie bêdzie 0

ldi R31, 0b00000111		; Ustawienie portu C jako wyjscia (domyslnie stan 1, ale jako ze kolumna steruje 0, to to sie bedzie pozniej zmieniac)
out DDRC, R31
ldi R31, 0xFF			; Caly port D ustawiony jako wyjscie - wszystkie ledy planszy + sygnalizacja gracza
out DDRD, R31

; Ustawienie przerwan
; Diody zeby mrugaly z czestotliwoscia 30Hz, to 30*18 daje 540Hz - co tyle sie bedzie uruchamialo przerwanie
; 16MHz / 1024 / 540 = 29 -> taka wartoscia sie powinno ladowac OCR0
LDI R31, 0b0000010		; Ustawienie tryby CTC przerwan -> reset zegara co przepelnienie porownujac do wartosci OCR
OUT TCCR0A, R31
LDI R31, 0b00000101		; Ustawienie preskalera na 1024
OUT TCCR0B, R31
LDI R31, 0b00000010		; Ustawienie compare match do porownan z OCR0A
STS TIMSK0, R31
LDI R31, 29				; Ustawienie OCR0
OUT OCR0A, R31


LDI R28, 0x01
SEI		; Odblokowanie przerwan

; Skok w trakcie przerwania do multipleksowania diody

start:	; Glowna petla programu
	RCALL setP1

    /*RCALL checkButtons	; Wywolanie funkcji do sprawdzenia przyciskow

	; Taki switch - case troche
	LDI R30, 0x09		; SWITCH - Numer przycisku do porownania
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 9
	BREQ longsetdiode02G	; jesli przycisk == 9 zapal diode 9
	dec R30				; jesli nie, to nastepuje dekrementacja i kolejne sprawdzenie
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 8
	BREQ longsetdiode01G
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 7
	BREQ longsetdiode00G
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 6
	BREQ longsetdiode12G
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 5
	BREQ longsetdiode11G
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 4
	BREQ longsetdiode10G
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 3
	BREQ longsetdiode22G
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 2
	BREQ longsetdiode21G
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 1
	BREQ longsetdiode20G
	//jmp alldiodesOFF
	*/
	//dalej:				; miejsce do powrotu z funcji warunkowych

    rjmp start

MULTIP_LED:
	//POP R28
	//push R16
	//in R16,SREG
	//push R16
	rcall alldiodesOFF
	
	LDI R30, 0x01		; do porownania czy 1 czy 0
	CP R28, R30
	BREQ longsetdiode00G
	jmp longsetdiode01G

	dalej:

	//pop R16	
	//out SREG, R16
	//pop R16
	//PUSH R28

	reti

; BREQ moze skonczyc maksymalnie o 64 instrukcje. RJMP o 2K (w switch bylo za krotko) wiec trzeba wykonac dlugi skok jmp - 4M
longsetdiode02G:
	jmp setdiode02G
longsetdiode01G:
	LDI R28, 0x01
	jmp setdiode01G
longsetdiode00G:
	LDI R28, 0x00
	jmp setdiode00G
longsetdiode12G:
	jmp setdiode12G
longsetdiode11G:
	jmp setdiode11G
longsetdiode10G:
	jmp setdiode10G
longsetdiode22G:
	jmp setdiode22G
longsetdiode21G:
	jmp setdiode21G
longsetdiode20G:
	jmp setdiode20G
longalldiodesOFF:
	LDI R28, 0x01
	jmp alldiodesOFF

setP1:
	ldi r17, P1
	//out PORTD, r17
	mov r22, r17 ; przypisanie aktualnego playera
	ret

setP2:
	ldi r17, P2
	//out PORTD, r17
	mov r22, r17 ; przypisanie aktualnego playera
	ret

delay50ms:	; Delay na 50ms. sluzy na debounce przyciskow
	; ============================= 
	;    delay loop generator 
	;     800000 cycles:
	; ----------------------------- 
	; delaying 799996 cycles:
			  ldi  R18, $5F
	WGLOOP0:  ldi  R19, $17
	WGLOOP1:  ldi  R20, $79
	WGLOOP2:  dec  R20
			  brne WGLOOP2
			  dec  R19
			  brne WGLOOP1
			  dec  R18
			  brne WGLOOP0
	; Jak to liczyc?
	; 121 * 3 = 363 na pierwsza petle najbardziej zagniezdzona
	; ona sie wykona 23 razy, co da 8349
	; 2 petla sie wykonuje 23 razy * 3 takty = 69, 8349 + 69 = 8 418
	; To wszystko jest w 3 petli, ktora to wykonuje sie 5F-> 95 razy. 8 418 * 95 = 799 710
	; 95 * 3 = 286, -> 799 996 cykli. Jako ze ret zajmuje 4 cykle, to mozna na tym zakonczyc liczenie. Ewentualnie mozna byloby dac NOP

ret

; Zasada dzialania funkcji:
; - sprawdz czy zostal wcisniety jakis przycisk. 
; Jesli nie, to ustaw stan przycisku na 0
; jesli zostal wcisniety, to przypisuje mu odpowiedni numer i nastepnie
; wchodzi do funkcji, gdzie jest sprawdzany rejestr R29 - ktory dba o to by delay wykonal sie tylko raz
; Jesli jest to pierwsze wykonanie funkcji to odczekaj 50ms i nastepnie znow sprawdz stan przycisku
; jesli dalej jest jakis wcisniety, to zwroc jego numer,
; jesli jednak juz zaden - to zeruje przycisk i nastepuje koniec
; Posiada obsluge DEBOUNCE
checkButtons:		; Sprawdzenie czy zostal wcisniety jakis przycisk
	ldi  R29, 0x02	

	buttonLoop:
		LDI R31, 0b00110111	; Ustawienie na wyjsciu samych 1 i jednego zera. Wejscia podciagniete w gore
		OUT PORTB, R31		; Przypisanie wartosci do portu B
		NOP					; instrukcja NOP -> bez niej nie dziala sprawdzenie portu. Danie chwilki czasu, by procesor ulozyl dane
		SBIS PINB, 0		; Sprawdzenie czy jest 0 odczytane na pinie 0. Jesli tak, to wykonaj instrukcje, a jesli nie, to idz dalej
			rjmp pin1
		SBIS PINB, 1
			rjmp pin2
		SBIS PINB, 2
			rjmp pin3

		LDI R31, 0b00101111	; Schemat dzialania podobny, tylko teraz inna kolumna jest wyzerowana
		OUT PORTB, R31
		NOP
		SBIS PINB, 0
			rjmp pin4
		SBIS PINB, 1
			rjmp pin5
		SBIS PINB, 2
			rjmp pin6

		LDI R31, 0b00011111
		OUT PORTB, R31
		NOP
		SBIS PINB, 0
			rjmp pin7
		SBIS PINB, 1
			rjmp pin8
		SBIS PINB, 2
			rjmp pin9

	LDI BUTTON_PIN, 0x00	; Jesli zaden przycisk nie zostal wcisniety, to przypisz wartosc 0.
ret

decrement:	; Sprawdzenie ktory raz sie powtarza funkcja. jesli pierwszy raz to dac opoznienie, jesli nie, to wrocic do petli glownej
	dec R29
	brne delayAndCheckButtonsAgain
	ret

delayAndCheckButtonsAgain:	; Odczekaj 50ms i nastepnie wykonaj sprawdzenie przyciskow jeszcze raz
	RCALL delay50ms	; Niweluje DEBOUNCE przycisku
	rjmp buttonLoop

pin1:
	LDI BUTTON_PIN, 0x01	; Przypisz odpowiednia cyfre do przycisku
	rjmp decrement			; wywolaj funkcje dekrement, by zniwelowac DEBOUNCE

pin2:
	LDI BUTTON_PIN, 0x02
	rjmp decrement

pin3:
	LDI BUTTON_PIN, 0x03
	rjmp decrement

pin4:
	LDI BUTTON_PIN, 0x04
	ret

pin5:
	LDI BUTTON_PIN, 0x05
	rjmp decrement

pin6:
	LDI BUTTON_PIN, 0x06
	rjmp decrement

pin7:
	LDI BUTTON_PIN, 0x07
	rjmp decrement

pin8:
	LDI BUTTON_PIN, 0x08
	rjmp decrement

pin9:
	LDI BUTTON_PIN, 0x09
	rjmp decrement


// Obsluga planszy - ledow. 
setdiode00G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW0
	or r17, r22
	out PORTD, r17
	rjmp dalej 
	//reti
setdiode00R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW0
	or r17, r22
	out PORTD, r17 
	//rjmp dalej
	reti
setdiode01G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW1
	or r17, r22
	out PORTD, r17
	rjmp dalej
	//reti
setdiode01R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW1
	or r17, r22
	out PORTD, r17 
	rjmp dalej
setdiode02G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW2
	or r17, r22
	out PORTD, r17
	//rjmp dalej
	reti
setdiode02R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW2
	or r17, r22
	out PORTD, r17 
	rjmp dalej
setdiode10G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW0
	or r17, r22
	out PORTD, r17
	//rjmp dalej 
	reti
setdiode10R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW0
	or r17, r22
	out PORTD, r17 
	rjmp dalej
setdiode11G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW1
	or r17, r22
	out PORTD, r17
	rjmp dalej 
setdiode11R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW1
	or r17, r22
	out PORTD, r17 
	rjmp dalej
setdiode12G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW2
	or r17, r22
	out PORTD, r17
	rjmp dalej 
setdiode12R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW2
	or r17, r22
	out PORTD, r17 
	rjmp dalej
setdiode20G:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, GROW0
	or r17, r22
	out PORTD, r17
	rjmp dalej
setdiode20R:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, RROW0
	or r17, r22
	out PORTD, r17
	rjmp dalej 
setdiode21G:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, GROW1
	or r17, r22
	out PORTD, r17 
	rjmp dalej
setdiode21R:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, RROW1
	or r17, r22
	out PORTD, r17 
	rjmp dalej
setdiode22G:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, GROW2
	or r17, r22
	out PORTD, r17
	rjmp dalej 
setdiode22R:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, RROW2
	or r17, r22
	out PORTD, r17 
	rjmp dalej
alldiodesOFF:
	ldi r17, 0b00000111
	out PORTC, r17
	ldi r17, 0b11000000
	and r17, r22
	out PORTD, r17 
	//rjmp dalej
	ret