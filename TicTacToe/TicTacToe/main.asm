cli						; wyl¹czenie przerwan
ldi R16, HIGH(RAMEND)   ; zaladowanie adresu konca pamieci[stala RAMEND - zdefiniowana w pliku](starszej jego czesci) SRAM do R16 
out SPH, R16            ; zaladowanie zawartosci rejestru R16 do SPH(starszej czesci) rejestru ktory przechowuje tzw. wskaznik konca stosu 
ldi R16, LOW(RAMEND)    ; zaladowanie (mlodszej czesci) adresu konca pamieci sram do R16 
out SPL, R16			; przepisanie R16 do SPL - rejestru który przechowuje wskaznik konca stosu(mlodszej czesci) 

.DEF BUTTON_PIN = R21		; Miejsce w pamieci na ktory zostal wcisniety
.DEF LED_PIN = R17			; Rejestr na trzymanie w pamieci diody
LDI BUTTON_PIN, 0x00		; Przypisanie zera do przycisku - zaden nie zostal wcisniety
LDI LED_PIN, 0b10000000		; bit diody	(PB5) (Pin 13 ARDU) - sluzy do debugowania

LDI R31, 0b00111000		; PIN 3,4,5 portu B ustawione jako wyjscia
OUT DDRB, R31			; Przypisanie wartosci do portu
LDI R31, 0b00111111		; rezystory pull-up na pinie 0,1,2,3,4,5
OUT PORTB, R31			; Przypisanie wartosci do portu. Sterowanie bêdzie 0

OUT DDRD, LED_PIN		; Ustawienie pinu diody jako wyjscie

start:	; Glowna petla programu
    RCALL checkButtons	; Wywolanie funkcji do sprawdzenia przyciskow

	LDI R30, 0x01		; Numer przycisku do porownania (na jego podstawie wlaczy sie dioda)

	CP BUTTON_PIN, R30	; Porownanie przycisku z rejestrem porownawczym
	BREQ zapal			; Jesli warunek jest spelniony (zmienne sa sobie rowne, to zapal)
	rjmp zgas			; Jesli warunek nie jest spelniony. Tu mozna byloby uzyc RCALL, ale wyzej niestety nie, przez co nie bylo gdzie wrocic
	dalej:				; miejsce do powrotu z funcji warunkowych

    rjmp start

zapal:
	SBI PORTD, 7		; Ustawienie na 7 bicie stanu wysokiego (zapalenie diody)
	rjmp dalej			; powrot do instrukcji (Jesli przycisk jest przytrzymany, to dioda sie swieci ciagle)

zgas:
	CBI PORTD, 7		; Ustawienie na 7 bicie stanu niskiego (zgaszenie diody)
	rjmp dalej			; powrot dalej do petli programu

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