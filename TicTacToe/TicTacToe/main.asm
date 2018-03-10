
cli //wy��czenie przerwa� 
ldi R16, HIGH(RAMEND)        //za�adowanie adresu ko�ca pami�ci[sta�a RAMEND - zdefiniowana w pliku m32def.inc](starszej jego cz��i) SRAM do R16 
out SPH, R16                //za�adowanie zawarto�ci rejestru R16 do SPH(starszej cz��i) rejestru kt�ry przechowuje tzw. wska�nik ko�ca stosu 
ldi R16, LOW(RAMEND)        //za�adowanie (mlodszej czesci) adresu konca pamieci sram do R16 
out SPL, R16                //przepisanie R16 do SPL -rejestru kt�ry przechowuje wska�nik ko�ca stosu(m�odszej czesci) 

.DEF BUTTON_PIN = R21	; Przycisk ktory zostal wcisniety
.DEF LED_PIN = R17 ; bit diody	(PB5)	(Pin 13 ARDU)
LDI BUTTON_PIN, 0x00
LDI LED_PIN, 0b10000000

LDI R31, 0b00111000		; PIN 3,4,5 portu B ustawione jako wyjscia
OUT DDRB, R31			; Przypisanie wartosci do portu
LDI R31, 0b00111111		; rezystory pull-up na pinie 3,4,5
OUT PORTB, R31			; Przypisanie wartosci do portu. Sterowanie b�dzie 0

OUT DDRD, LED_PIN

start:
    RCALL checkButtons

	LDI R30, 0x01
	CP BUTTON_PIN, R30
	BREQ delayAndCheckButtonsAgain ; delay
	backDelay:

	CP BUTTON_PIN, R30
	BREQ zapal
	rjmp zgas
	dalej:

	//LDI BUTTON_PIN, 0x00	; Wyczyszczenie z pamieci ostatniego przycisku (zostal juz obsluzony)
    rjmp start


zapal:
	SBI PORTD, 7
	rjmp dalej

zgas:
	CBI PORTD, 7
	rjmp dalej

delayAndCheckButtonsAgain:
	RCALL delay50ms
	RCALL checkButtons
	rjmp backDelay

delay50ms:
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

checkButtons:
	NOP
	LDI R31, 0b00110111
	OUT PORTB, R31
	NOP
	SBIS PINB, 0
		rjmp pin1
	SBIS PINB, 1
		rjmp pin2
	SBIS PINB, 2
		rjmp pin3

	NOP
	LDI R31, 0b00101111
	OUT PORTB, R31
	NOP
	SBIS PINB, 0
		rjmp pin4
	SBIS PINB, 1
		rjmp pin5
	SBIS PINB, 2
		rjmp pin6

	NOP
	LDI R31, 0b00011111
	OUT PORTB, R31
	NOP
	SBIS PINB, 0
		rjmp pin7
	SBIS PINB, 1
		rjmp pin8
	SBIS PINB, 2
		rjmp pin9
ret

pin1:
	LDI BUTTON_PIN, 0x01
	ret

pin2:
	LDI BUTTON_PIN, 0x02
	ret

pin3:
	LDI BUTTON_PIN, 0x03
	ret

pin4:
	LDI BUTTON_PIN, 0x04
	ret

pin5:
	LDI BUTTON_PIN, 0x05
	ret

pin6:
	LDI BUTTON_PIN, 0x06
	ret

pin7:
	LDI BUTTON_PIN, 0x07
	ret

pin8:
	LDI BUTTON_PIN, 0x08
	ret

pin9:
	LDI BUTTON_PIN, 0x09
	ret