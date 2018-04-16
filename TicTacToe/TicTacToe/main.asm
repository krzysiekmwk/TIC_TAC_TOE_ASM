.ORG 0x0000 rjmp SETUP
.ORG 0x001C rjmp MULTIP_LED ; Skok w trakcie przerwania do multipleksowania diody

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

.DEF LED_NUMBER = R16	; Miejsce w pamieci na diode ktora ma sie zapalic
LDI LED_NUMBER, 0x09

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
LDI R31, 0b00000010		; Ustawienie tryby CTC przerwan -> reset zegara co przepelnienie porownujac do wartosci OCR
OUT TCCR0A, R31
LDI R31, 0b00000101		; Ustawienie preskalera na 1024
OUT TCCR0B, R31
LDI R31, 0b00000010		; Ustawienie compare match do porownan z OCR0A
STS TIMSK0, R31
LDI R31, 29				; Ustawienie OCR0
OUT OCR0A, R31

LDI R23, 0b10000000
LDI R24, 0b00010001
LDI R25, 0b00000010
SEI		; Odblokowanie przerwan

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
	rcall alldiodesOFF

	;switch - case
	LDI R27, 0x09		; SWITCH - Numer diody do porownania
	CP LED_NUMBER, R27	; case LED_NUMBER == 9
	BREQ longCheckDiode9	; jesli nr diody == 9 zapal diode 9
	backDiode9:
	dec R27				; jesli nie, to nastepuje dekrementacja i kolejne sprawdzenie
	CP LED_NUMBER, R27	; case LED_NUMBER == 8
	BREQ longCheckDiode8
	backDiode8:
	dec R27				
	CP LED_NUMBER, R27	; case LED_NUMBER == 7
	BREQ longCheckDiode7
	backDiode7:
	dec R27				
	CP LED_NUMBER, R27	; case LED_NUMBER == 6
	BREQ longCheckDiode6
	backDiode6:
	dec R27				
	CP LED_NUMBER, R27	; case LED_NUMBER == 5
	BREQ longCheckDiode5
	backDiode5:
	dec R27				
	CP LED_NUMBER, R27	; case LED_NUMBER == 4
	BREQ longCheckDiode4
	backDiode4:
	dec R27				
	CP LED_NUMBER, R27	; case LED_NUMBER == 3
	BREQ longCheckDiode3
	backDiode3:
	dec R27				
	CP LED_NUMBER, R27	; case LED_NUMBER == 2
	BREQ longCheckDiode2
	backDiode2:
	dec R27				
	CP LED_NUMBER, R27	; case LED_NUMBER == 1
	BREQ longCheckDiode1
	backDiode1:

	LDI LED_NUMBER, 0x09

	reti

; BREQ moze skonczyc maksymalnie o 64 instrukcje. RJMP o 2K (w switch bylo za krotko) wiec trzeba wykonac dlugi skok jmp - 4M
longCheckDiode9:
	jmp checkDiode9
longCheckDiode8:
	jmp checkDiode8
longCheckDiode7:
	jmp checkDiode7
longCheckDiode6:
	jmp checkDiode6
longCheckDiode5:
	jmp checkDiode5
longCheckDiode4:
	jmp checkDiode4
longCheckDiode3:
	jmp checkDiode3
longCheckDiode2:
	jmp checkDiode2
longCheckDiode1:
	jmp checkDiode1

checkDiode9:
	LDI R28, 0b00000001		; to czy dana dioda ma sie zapalic jest zakodowane w rejestrach R23 R24 oraz R25
	AND R28, R25			; AND sprawdza czy na danym bicie jest jeden czy nie
	TST R28					; Ustawia flage, sprawdzajac czy AND jest zerem
	BRNE longsetdiode02G	; Jesli nie jest zerem, to zaswiec diode
	LDI R28, 0b00000010		; Jesli jest to idzie i sprawdza dalej
	AND R28, R25
	TST R28
	BRNE longsetdiode02R
	LDI LED_NUMBER, 0x08	; Jesli zadna dioda sie nie zapalila, to zmniejsza index numeru diody do zaswiecenia
	jmp backDiode9			; wraca do petli instrukcji switch case - do srodka

longsetdiode02R:
	LDI LED_NUMBER, 0x08	; Zmniejsza index numeru diody do zaswiecenia
	jmp setdiode02R			; Zapala dana diode
longsetdiode02G:
	LDI LED_NUMBER, 0x08
	jmp setdiode02G

checkDiode8:
	LDI R28, 0b10000000
	AND R28, R23
	TST R28
	BRNE longsetdiode01G
	LDI R28, 0b10000000
	AND R28, R24
	TST R28
	BRNE longsetdiode01R
	LDI LED_NUMBER, 0x07
	jmp backDiode8

longsetdiode01R:
	LDI LED_NUMBER, 0x07
	jmp setdiode01R
longsetdiode01G:
	LDI LED_NUMBER, 0x07
	jmp setdiode01G

checkDiode7:
	LDI R28, 0b01000000
	AND R28, R23
	TST R28
	BRNE longsetdiode00G
	LDI R28, 0b01000000
	AND R28, R24
	TST R28
	BRNE longsetdiode00R
	LDI LED_NUMBER, 0x06
	jmp backDiode7

longsetdiode00R:
	LDI LED_NUMBER, 0x06
	jmp setdiode00R
longsetdiode00G:
	LDI LED_NUMBER, 0x06
	jmp setdiode00G

checkDiode6:
	LDI R28, 0b00100000
	AND R28, R23
	TST R28
	BRNE longsetdiode12G
	LDI R28, 0b00100000
	AND R28, R24
	TST R28
	BRNE longsetdiode12R
	LDI LED_NUMBER, 0x05
	jmp backDiode6

longsetdiode12R:
	LDI LED_NUMBER, 0x05
	jmp setdiode12R
longsetdiode12G:
	LDI LED_NUMBER, 0x05
	jmp setdiode12G

checkDiode5:
	LDI R28, 0b00010000
	AND R28, R23
	TST R28
	BRNE longsetdiode11G
	LDI R28, 0b00010000
	AND R28, R24
	TST R28
	BRNE longsetdiode11R
	LDI LED_NUMBER, 0x04
	jmp backDiode5

longsetdiode11R:
	LDI LED_NUMBER, 0x04
	jmp setdiode11R
longsetdiode11G:
	LDI LED_NUMBER, 0x04
	jmp setdiode11G

checkDiode4:
	LDI R28, 0b00001000
	AND R28, R23
	TST R28
	BRNE longsetdiode10G
	LDI R28, 0b00001000
	AND R28, R24
	TST R28
	BRNE longsetdiode10R
	LDI LED_NUMBER, 0x03
	jmp backDiode4

longsetdiode10R:
	LDI LED_NUMBER, 0x03
	jmp setdiode10R
longsetdiode10G:
	LDI LED_NUMBER, 0x03
	jmp setdiode10G

checkDiode3:
	LDI R28, 0b00000100
	AND R28, R23
	TST R28
	BRNE longsetdiode22G
	LDI R28, 0b00000100
	AND R28, R24
	TST R28
	BRNE longsetdiode22R
	LDI LED_NUMBER, 0x02
	jmp backDiode3

longsetdiode22R:
	LDI LED_NUMBER, 0x02
	jmp setdiode22R
longsetdiode22G:
	LDI LED_NUMBER, 0x02
	jmp setdiode22G

checkDiode2:
	LDI R28, 0b00000010
	AND R28, R23
	TST R28
	BRNE longsetdiode21G
	LDI R28, 0b00000010
	AND R28, R24
	TST R28
	BRNE longsetdiode21R
	LDI LED_NUMBER, 0x01
	jmp backDiode2

longsetdiode21R:
	LDI LED_NUMBER, 0x01
	jmp setdiode21R
longsetdiode21G:
	LDI LED_NUMBER, 0x01
	jmp setdiode21G

checkDiode1:
	LDI R28, 0b00000001
	AND R28, R23
	TST R28
	BRNE longsetdiode20G
	LDI R28, 0b00000001
	AND R28, R24
	TST R28
	BRNE longsetdiode20R
	LDI LED_NUMBER, 0x00
	jmp backDiode1

longsetdiode20R:
	LDI LED_NUMBER, 0x00
	jmp setdiode20R
longsetdiode20G:
	LDI LED_NUMBER, 0x00
	jmp setdiode20G

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
	ldi r17, COL0	; Wpisanie odpowiedniej kolumny i wiersza
	out PORTC, r17
	ldi r17, GROW0
	or r17, r22		; Dopisanie aktualnego playera
	out PORTD, r17
	reti			; Powrot z przerwania
setdiode00R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW0
	or r17, r22
	out PORTD, r17 
	reti
setdiode01G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW1
	or r17, r22
	out PORTD, r17
	reti
setdiode01R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW1
	or r17, r22
	out PORTD, r17 
	reti
setdiode02G:
	ldi r17, COL0	
	out PORTC, r17
	ldi r17, GROW2
	or r17, r22
	out PORTD, r17
	reti
setdiode02R:
	ldi r17, COL0
	out PORTC, r17
	ldi r17, RROW2
	or r17, r22
	out PORTD, r17 
	reti
setdiode10G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW0
	or r17, r22
	out PORTD, r17
	reti
setdiode10R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW0
	or r17, r22
	out PORTD, r17 
	reti
setdiode11G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW1
	or r17, r22
	out PORTD, r17
	reti
setdiode11R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW1
	or r17, r22
	out PORTD, r17 
	reti
setdiode12G:
	ldi r17, COL1	
	out PORTC, r17
	ldi r17, GROW2
	or r17, r22
	out PORTD, r17
	reti
setdiode12R:
	ldi r17, COL1
	out PORTC, r17
	ldi r17, RROW2
	or r17, r22
	out PORTD, r17 
	reti
setdiode20G:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, GROW0
	or r17, r22
	out PORTD, r17
	reti
setdiode20R:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, RROW0
	or r17, r22
	out PORTD, r17
	reti
setdiode21G:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, GROW1
	or r17, r22
	out PORTD, r17 
	reti
setdiode21R:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, RROW1
	or r17, r22
	out PORTD, r17 
	reti
setdiode22G:
	ldi r17, COL2	
	out PORTC, r17
	ldi r17, GROW2
	or r17, r22
	out PORTD, r17
	reti
setdiode22R:
	ldi r17, COL2
	out PORTC, r17
	ldi r17, RROW2
	or r17, r22
	out PORTD, r17 
	reti
alldiodesOFF:			; Wywolywane w przerwaniu jako funkcja przez RCALL, dlatego wraca przez instrukcje RET.
	ldi r17, 0b00000111
	out PORTC, r17
	ldi r17, 0b11000000
	and r17, r22
	out PORTD, r17 
	ret