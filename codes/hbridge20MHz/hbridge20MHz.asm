    ; hbrigde.asm
    ;
    ; codigo que controla los IGBT de un inversor
    ; microcontrolador utilizado: PIC16F84A
    ; Cristal de 20MHz
    ;
    ; Autores:
    ; Jorge Lambrano
    ; Julian Rojas
    ; Juan Sanchez
    ;
    ; Electronica de potencia, primer semestre 2018
    ; Universidad del Norte
    ;-------------------------------------------------------------------------

	    __CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC	 ; configuracion
	    ; No hay proteccion del codigo  _CP_OFF
	    ; No se habilita el whatdig	    _WDT_OFF
	    ; Se habita el reset mediante Power-Up timer _PWRTE_ON
	    ; Se utiliza el oscilador por cristal de cuarzo _X_OSC

	    LIST P = 16F84A
	    INCLUDE <p16f84a.inc>

; ------------------------------------------------------------------------------
; CONSTANTES
TM0_2777    EQU       -d'108'
TM0_5555    EQU       -d'216'

STATES      EQU       0x0C
RET_REG     EQU       0x0D

; SALIDA:
; Parte alta del puerto B
; PORTB, 4 , controla al transistor P1.0 M2
; PORTB, 5 , controla al transistor P1.1 M4
; PORTB, 6 , controla al transistor P1.2 M1
; PORTB, 7 , controla al transistor P1.3 M3
;-------------------------------------------------------------------------------

		;PROGRAMA

                ; salto al programa principal
                ORG     0h
                goto    INICIO

                ; Vector de interrupcion
                ORG     4h
                goto    INT_TM0

INICIO:
                clrf    PORTB                   ; limpia la salida
                clrf    STATES                  ; limpa el registro de los
                                                ; estados

                bsf	STATUS,RP0		; Acceso al Banco 1.
                movlw   b'00001111'             ; establece la parte alta del
                movwf   TRISB                   ; del puerto B como salida
                movlw	b'00001111'             ; Carga el registro w
		movwf	TRISA                   ; Se carga en el registro lo
                                                ; lo contenido en W, se
                                                ; configura el puerto A como
                                                ; entrada

                movlw	b'00000110'
                movwf	OPTION_REG		; prescaler de 128.
                bcf	STATUS,RP0		; Acceso al Banco 0.
                movlw	TM0_2777		; Carga el TMR0.
                movwf	TMR0
                movlw	b'10100000'
                movwf	INTCON			; Autoriza interrupción T0I
PPAL:
                goto    $                       ; ciclo infinito, no se coloca
                                                ; el microcontrolador en bajo
                                                ; consumo porque se apaga el
                                                ; Timer0

INT_TM0:
                call    RETARDO
                movfw   STATES
                addwf   PCL, f                  ; Salta al estado actual
TABLA:
                goto    ESTADO0
                goto    ESTADO1
                goto    ESTADO2
                goto    ESTADO3

ESTADO0:
                movlw   b'10100000'             ; Enciende los transistores
                movwf   PORTB                   ; P10 Y P13

                call    RETARDO2

                movlw   TM0_5555                ; carga el temporizador
                movwf   TMR0
                goto    FIN_INT

ESTADO1:
                movlw   b'00000000'             ; Apaga todos los transistores
                movwf   PORTB
                movlw   TM0_2777                ; carga el temporizador
                movwf   TMR0
                goto    FIN_INT
ESTADO2:
                movlw   b'01010000'             ; Enciende los transistores
                movwf   PORTB                   ; P11 Y P12

                call    RETARDO2

                movlw   TM0_5555                ; carga el temporizador
                movwf   TMR0
                goto    FIN_INT
ESTADO3:
                movlw   b'00000000'             ; Apaga todos los transistores
                movwf   PORTB
                movlw   TM0_2777                ; carga el temporizador
                movwf   TMR0

FIN_INT:
                incf    STATES
                movlw   b'00000011'
                andwf   STATES, f
                bcf	INTCON,T0IF
                retfie

RETARDO2:
                movlw   d'5'
                movwf   RET_REG

DENUEVO2:
                decfsz  RET_REG
                goto    DENUEVO2

                ; continua con el otro retardo

RETARDO:
                movlw   d'14'
                movwf   RET_REG

DENUEVO:        decfsz  RET_REG
                goto    DENUEVO

                nop
                nop

                return

                END
