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

cli						; wylšczenie przerwan
ldi R16, HIGH(RAMEND)   ; zaladowanie adresu konca pamieci[stala RAMEND - zdefiniowana w pliku](starszej jego czesci) SRAM do R16 
out SPH, R16            ; zaladowanie zawartosci rejestru R16 do SPH(starszej czesci) rejestru ktory przechowuje tzw. wskaznik konca stosu 
ldi R16, LOW(RAMEND)    ; zaladowanie (mlodszej czesci) adresu konca pamieci sram do R16 
out SPL, R16			; przepisanie R16 do SPL - rejestru który przechowuje wskaznik konca stosu(mlodszej czesci) 

.DEF BUTTON_PIN = R21		; Miejsce w pamieci na ktory zostal wcisniety
LDI BUTTON_PIN, 0x00		; Przypisanie zera do przycisku - zaden nie zostal wcisniety

LDI R31, 0b00111000		; PIN 3,4,5 portu B ustawione jako wyjscia
OUT DDRB, R31			; Przypisanie wartosci do portu
LDI R31, 0b00111111		; rezystory pull-up na pinie 0,1,2,3,4,5
OUT PORTB, R31			; Przypisanie wartosci do portu. Sterowanie będzie 0

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

; Latwiejsze korzystanie z diod
.DEF P1_DIODES = R23 ;diody 0-7 playera 1
.DEF P2_DIODES = R24 ;diody 0-7 playera 2
.DEF LAST_DIODES = R25 ;ostatnie diody 8, 0b000000{P2}{P1}
LDI P1_DIODES, 0x00
LDI P2_DIODES, 0x00
LDI LAST_DIODES, 0x00

RCALL setP1
RCALL delay50ms

SEI		; Odblokowanie przerwan

RCALL delay50ms

start:	; Glowna petla programu
    RCALL checkButtons	; Wywolanie funkcji do sprawdzenia przyciskow

	; Taki switch - case troche
	LDI R30, 0x09		; SWITCH - Numer przycisku do porownania
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 9
	BREQ longsetdiode9	; jesli przycisk == 9 ustaw diode 9 w zaleznoci od sprawdzonych waronkow 
	dec R30				; jesli nie, to nastepuje dekrementacja i kolejne sprawdzenie
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 8
	BREQ longsetdiode8
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 7
	BREQ longsetdiode7
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 6
	BREQ longsetdiode6
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 5
	BREQ longsetdiode5
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 4
	BREQ longsetdiode4
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 3
	BREQ longsetdiode3
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 2
	BREQ longsetdiode2
	dec R30				
	CP BUTTON_PIN, R30	; case BUTTON_PIN == 1
	BREQ longsetdiode1

	rjmp dalej
//////////INTRUKCJE POZA PETLA PROGRAMU//////////////////////////////////////////////////////////////////////////////////////////////////////

; BREQ moze skonczyc maksymalnie o 64 instrukcje. RJMP o 2K (w switch bylo za krotko) wiec trzeba wykonac dlugi skok jmp - 4M
longsetdiode9:
	jmp checkAndSetDiodeRegister9
longsetdiode8:
	jmp checkAndSetDiodeRegister8
longsetdiode7:
	jmp checkAndSetDiodeRegister7
longsetdiode6:
	jmp checkAndSetDiodeRegister6
longsetdiode5:
	jmp checkAndSetDiodeRegister5
longsetdiode4:
	jmp checkAndSetDiodeRegister4
longsetdiode3:
	jmp checkAndSetDiodeRegister3
longsetdiode2:
	jmp checkAndSetDiodeRegister2
longsetdiode1:
	jmp checkAndSetDiodeRegister1

	
Player1WinShowLeds:
	;Zgas wszystkie diody, zapal wszystkie z danego playera i nimi zmrugaj
	RCALL alldiodesOFF
	RCALL setP1
	LDI P2_DIODES, 0b00000000
	LDI P1_DIODES, 0b11111111
	LDI LAST_DIODES, 0b00000001
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	LDI P1_DIODES, 0b00000000
	LDI LAST_DIODES, 0b00000000
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL setP1
	LDI P1_DIODES, 0b11111111
	LDI LAST_DIODES, 0b00000001
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	LDI P1_DIODES, 0b00000000
	LDI LAST_DIODES, 0b00000000
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL setP1
	LDI P1_DIODES, 0b11111111
	LDI LAST_DIODES, 0b00000001
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	LDI P1_DIODES, 0b00000000
	LDI LAST_DIODES, 0b00000000
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL setP1
	LDI P1_DIODES, 0b11111111
	LDI LAST_DIODES, 0b00000001
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	LDI P1_DIODES, 0b00000000
	LDI LAST_DIODES, 0b00000000
	rjmp SETUP
	
Player2WinShowLeds:
	RCALL alldiodesOFF
	RCALL setP2
	LDI P1_DIODES, 0b00000000
	LDI P2_DIODES, 0b11111111
	LDI LAST_DIODES, 0b00000010
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	LDI P2_DIODES, 0b00000000
	LDI LAST_DIODES, 0b00000000
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL setP2
	LDI P2_DIODES, 0b11111111
	LDI LAST_DIODES, 0b00000010
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	LDI P2_DIODES, 0b00000000
	LDI LAST_DIODES, 0b00000000
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL setP2
	LDI P2_DIODES, 0b11111111
	LDI LAST_DIODES, 0b00000010
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	LDI P2_DIODES, 0b00000000
	LDI LAST_DIODES, 0b00000000
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL setP2
	LDI P2_DIODES, 0b11111111
	LDI LAST_DIODES, 0b00000010
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	RCALL delay50ms
	LDI P2_DIODES, 0b00000000
	LDI LAST_DIODES, 0b00000000
	rjmp SETUP

;Sprawdzanie wygranej z ostatnia dioda P1
CheckWithLastDiodeP1:
	LDI R31, 0b11000000
	LDI R17, 0b11000000
	AND R31, P1_DIODES
	CP  R31, R17
	BREQ Player1Win	
			
	LDI R31, 0b00100100
	LDI R17, 0b00100100
	AND R31, P1_DIODES
	CP  R31, R17
	BREQ Player1Win

	LDI R31, 0b00010001
	LDI R17, 0b00010001
	AND R31, P1_DIODES
	CP  R31, R17
	BREQ Player1Win

	rjmp P2LastDiodeCheck

;Sprawdzanie wygranej z ostatnia dioda P2
CheckWithLastDiodeP2:
	LDI R31, 0b11000000
	LDI R17, 0b11000000		
	AND R31, P2_DIODES
	CP  R31, R17
	BREQ Player2Win	
			
	LDI R31, 0b00100100
	LDI R17, 0b00100100
	AND R31, P2_DIODES
	CP  R31, R17
	BREQ Player2Win

	LDI R31, 0b00010001
	LDI R17, 0b00010001
	AND R31, P2_DIODES
	CP  R31, R17
	BREQ Player2Win

	;JEZELI NIKT NIE WYGRAL TO SPRAWDZAJ DALEJ
	rjmp CheckNextOptions
	
;WYGRANA P1 jest tutaj bo relative branch nie siega
Player1Win:
	rjmp Player1WinShowLeds
;Wygrana P2
Player2Win:
	rjmp Player2WinShowLeds
	;RCALL alldiodesOFF
	;rjmp SETUP
//////////INTRUKCJE POZA PETLA PROGRAMU//////////////////////////////////////////////////////////////////////////////////////////////////////

	dalej:				; miejsce do powrotu z funcji warunkowych

	//Sprawdzenie kto wygral///////////////////////////////////////////////////////////////////////////////////////////////////////////////


;SPRAWDZANIE CZY OSTATNIA DIODA P1 JEST WLACZONA JEZELI TAK TO MOZNA SPRAWDZAC WARUNKI KTORE JA OBEJMUJA
	LDI R31, 0b00000001
	LDI R17, 0b00000001
	AND R31, LAST_DIODES
	CP  R31, R17
	BREQ CheckWithLastDiodeP1

;SPRAWDZANIE CZY OSTATNIA DIODA P2 JEST WLACZONA JEZELI TAK TO MOZNA SPRAWDZAC WARUNKI KTORE JA OBEJMUJA
P2LastDiodeCheck:
	LDI R31, 0b00000010
	LDI R17, 0b00000010
	AND R31, LAST_DIODES
	CP  R31, R17
	BREQ CheckWithLastDiodeP2
	
CheckNextOptions: ;wyjscie z CheckWithLastDiodeP2

;sprawdzenie P1 bez ostatniej diody
;rzad
	LDI R31, 0b00000111
	LDI R17, 0b00000111
	AND R31, P1_DIODES
	CP  R31, R17
	BREQ Player1Win	

	LDI R31, 0b00111000
	LDI R17, 0b00111000
	AND R31, P1_DIODES
	CP  R31, R17
	BREQ Player1Win	
;pion
	LDI R31, 0b10010010	
	LDI R17, 0b10010010	
	AND R31, P1_DIODES
	CP  R31, R17
	BREQ Player1Win	
			
	LDI R31, 0b01001001
	LDI R17, 0b01001001
	AND R31, P1_DIODES
	CP  R31, R17
	BREQ Player1Win
;ukos
	LDI R31, 0b01010100
	LDI R17, 0b01010100
	AND R31, P1_DIODES
	CP  R31, R17
	BREQ Player1Win

;Wygrane P2 bez ostatniej diody
;rzad
	LDI R31, 0b00000111
	LDI R17, 0b00000111
	AND R31, P2_DIODES
	CP  R31, R17	
	BREQ Player2Win	

	LDI R31, 0b00111000
	LDI R17, 0b00111000
	AND R31, P2_DIODES
	CP  R31, R17
	BREQ Player2Win	
;pion
	LDI R31, 0b10010010	
	LDI R17, 0b10010010	
	AND R31, P2_DIODES
	CP  R31, R17 
	BREQ Player2Win	
			
	LDI R31, 0b01001001
	LDI R17, 0b01001001
	AND R31, P2_DIODES
	CP  R31, R17
	BREQ Player2Win
;ukos
	LDI R31, 0b01010100
	LDI R17, 0b01010100
	AND R31, P2_DIODES
	CP  R31, R17
	BREQ Player2Win

;czy remis
IfDraw:
	LDI R31, 0x00
	CP LAST_DIODES, R31 ;jezeli LAST_DIODES jest NIERÓWNE 0 to znaczy ze ktores jest zaswiecone wiec jest sens sprawdzac dalej
	BREQ NotDraw

	LDI R31, 0xFF
	MOV R17, P1_DIODES 
	OR R17, P2_DIODES ;jezeli wszystkie pola zostaly juz wykorzystane to remis
	CP R17, R31
	BREQ Draw

NotDraw:
	;petla glowna
    rjmp start

;remis
Draw:
	RCALL alldiodesOFF
	rjmp SETUP




//Schemat dzialania: 
//Sprawdzic czy nie nie jest juz cos ustawione na danym pinie (OR, a potem AND)
//Jesli jest to wyskocz, jesli nie to:
//sprawdzic jaki jest aktualny player ustawiony, ustawic dla niego diode i zmienic playera
checkAndSetDiodeRegister9:
	LDI R31, 0b00000011
	AND R31, LAST_DIODES	; AND sprawdza czy na danym bicie jest jeden czy nie
	TST R31					; Ustawia flage, sprawdzajac czy AND jest zerem
	BREQ checkColorDiode9	; jesli jest zerem to ustawia odpowiednia diode
	jmp dalej				; jesli nie jest to wraca do programu (za przyciskami)

checkColorDiode9:			; Znaczy ze trzeba dana diode ustawic. Tu nastapi sprawdzenie playera by okreslic ktora
	ldi r17, P1
	AND r17, R22			
	TST r17					; Sprawdzenie czy jest to ruch player 1
	BRNE setGreenDiode9		; Jesli jest to ustaw zielona diode
	jmp setRedDiode9		; Jesli nie to czerwona diode

setRedDiode9:
	RCALL setP1
	LDI R31, 0b00000010
	OR LAST_DIODES, R31
	jmp dalej

setGreenDiode9:
	RCALL setP2
	LDI R31, 0b00000001
	OR LAST_DIODES, R31
	jmp dalej

checkAndSetDiodeRegister8:
	LDI R31, 0b10000000
	LDI R17, 0b00000000
	OR R17, P1_DIODES
	OR R17, P2_DIODES
	AND R31, R17
	TST R31
	BREQ checkColorDiode8
	jmp dalej

checkColorDiode8:
	ldi r17, P1
	AND r17, R22			
	TST r17
	BRNE setGreenDiode8	
	jmp setRedDiode8

setRedDiode8:
	RCALL setP1
	LDI R31, 0b10000000
	OR P2_DIODES, R31
	jmp dalej

setGreenDiode8:
	RCALL setP2
	LDI R31, 0b10000000
	OR P1_DIODES, R31
	jmp dalej

checkAndSetDiodeRegister7:
	LDI R31, 0b01000000
	LDI R17, 0b00000000
	OR R17, P1_DIODES
	OR R17, P2_DIODES
	AND R31, R17
	TST R31
	BREQ checkColorDiode7
	jmp dalej

checkColorDiode7:
	ldi r17, P1
	AND r17, R22			
	TST r17
	BRNE setGreenDiode7	
	jmp setRedDiode7

setRedDiode7:
	RCALL setP1
	LDI R31, 0b01000000
	OR P2_DIODES, R31
	jmp dalej

setGreenDiode7:
	RCALL setP2
	LDI R31, 0b01000000
	OR P1_DIODES, R31
	jmp dalej

checkAndSetDiodeRegister6:
	LDI R31, 0b00100000
	LDI R17, 0b00000000
	OR R17, P1_DIODES
	OR R17, P2_DIODES
	AND R31, R17
	TST R31
	BREQ checkColorDiode6
	jmp dalej

checkColorDiode6:
	ldi r17, P1
	AND r17, R22			
	TST r17
	BRNE setGreenDiode6	
	jmp setRedDiode6

setRedDiode6:
	RCALL setP1
	LDI R31, 0b00100000
	OR P2_DIODES, R31
	jmp dalej

setGreenDiode6:
	RCALL setP2
	LDI R31, 0b00100000
	OR P1_DIODES, R31
	jmp dalej

checkAndSetDiodeRegister5:
	LDI R31, 0b00010000
	LDI R17, 0b00000000
	OR R17, P1_DIODES
	OR R17, P2_DIODES
	AND R31, R17
	TST R31
	BREQ checkColorDiode5
	jmp dalej

checkColorDiode5:
	ldi r17, P1
	AND r17, R22			
	TST r17
	BRNE setGreenDiode5	
	jmp setRedDiode5

setRedDiode5:
	RCALL setP1
	LDI R31, 0b00010000
	OR P2_DIODES, R31
	jmp dalej

setGreenDiode5:
	RCALL setP2
	LDI R31, 0b00010000
	OR P1_DIODES, R31
	jmp dalej

checkAndSetDiodeRegister4:
	LDI R31, 0b00001000
	LDI R17, 0b00000000
	OR R17, P1_DIODES
	OR R17, P2_DIODES
	AND R31, R17
	TST R31
	BREQ checkColorDiode4
	jmp dalej

checkColorDiode4:
	ldi r17, P1
	AND r17, R22			
	TST r17
	BRNE setGreenDiode4	
	jmp setRedDiode4

setRedDiode4:
	RCALL setP1
	LDI R31, 0b00001000
	OR P2_DIODES, R31
	jmp dalej

setGreenDiode4:
	RCALL setP2
	LDI R31, 0b00001000
	OR P1_DIODES, R31
	jmp dalej

checkAndSetDiodeRegister3:
	LDI R31, 0b00000100
	LDI R17, 0b00000000
	OR R17, P1_DIODES
	OR R17, P2_DIODES
	AND R31, R17
	TST R31
	BREQ checkColorDiode3
	jmp dalej

checkColorDiode3:
	ldi r17, P1
	AND r17, R22			
	TST r17
	BRNE setGreenDiode3
	jmp setRedDiode3

setRedDiode3:
	RCALL setP1
	LDI R31, 0b00000100
	OR P2_DIODES, R31
	jmp dalej

setGreenDiode3:
	RCALL setP2
	LDI R31, 0b00000100
	OR P1_DIODES, R31
	jmp dalej

checkAndSetDiodeRegister2:
	LDI R31, 0b00000010
	LDI R17, 0b00000000
	OR R17, P1_DIODES
	OR R17, P2_DIODES
	AND R31, R17
	TST R31
	BREQ checkColorDiode2
	jmp dalej

checkColorDiode2:
	ldi r17, P1
	AND r17, R22			
	TST r17
	BRNE setGreenDiode2	
	jmp setRedDiode2

setRedDiode2:
	RCALL setP1
	LDI R31, 0b00000010
	OR P2_DIODES, R31
	jmp dalej

setGreenDiode2:
	RCALL setP2
	LDI R31, 0b00000010
	OR P1_DIODES, R31
	jmp dalej

checkAndSetDiodeRegister1:
	LDI R31, 0b00000001
	LDI R17, 0b00000000
	OR R17, P1_DIODES
	OR R17, P2_DIODES
	AND R31, R17
	TST R31
	BREQ checkColorDiode1
	jmp dalej

checkColorDiode1:
	ldi r17, P1
	AND r17, R22			
	TST r17
	BRNE setGreenDiode1
	jmp setRedDiode1

setRedDiode1:
	RCALL setP1
	LDI R31, 0b00000001
	OR P2_DIODES, R31
	jmp dalej

setGreenDiode1:
	RCALL setP2
	LDI R31, 0b00000001
	OR P1_DIODES, R31
	jmp dalej


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
		NOP
		NOP
		RCALL delay50ms
		SBIS PINB, 0		; Sprawdzenie czy jest 0 odczytane na pinie 0. Jesli tak, to wykonaj instrukcje, a jesli nie, to idz dalej
			rjmp pin1
		NOP
		NOP
		NOP
		RCALL delay50ms
		SBIS PINB, 1
			rjmp pin2
		NOP
		NOP
		NOP
		RCALL delay50ms
		SBIS PINB, 2
			rjmp pin3

		LDI R31, 0b00101111	; Schemat dzialania podobny, tylko teraz inna kolumna jest wyzerowana
		OUT PORTB, R31
		NOP
		NOP
		NOP
		RCALL delay50ms
		SBIS PINB, 0
			rjmp pin4
		NOP
		NOP
		NOP
		RCALL delay50ms
		SBIS PINB, 1
			rjmp pin5
		NOP
		NOP
		NOP
		RCALL delay50ms
		SBIS PINB, 2
			rjmp pin6

		LDI R31, 0b00011111
		OUT PORTB, R31
		NOP
		NOP
		NOP
		RCALL delay50ms
		SBIS PINB, 0
			rjmp pin7
		NOP
		NOP
		NOP
		RCALL delay50ms
		SBIS PINB, 1
			rjmp pin8
		NOP
		NOP
		NOP
		RCALL delay50ms
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
