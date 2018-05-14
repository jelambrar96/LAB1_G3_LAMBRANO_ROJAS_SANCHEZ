    ; hbrigde.asm
    ;
    ; codigo que controla los IGBT de un inversor
    ; microcontrolador utilizado: PIC16F84A
    ; Cristal de 4MHz
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
TM0_2777    EQU       -d'86'
TM0_5555    EQU       -d'173'
STATES      EQU       0x0C

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

                movlw	b'00000100'
                movwf	OPTION_REG		; prescaler de 32.
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
                nop                             ; ciclo de no instruccion
                nop                             ; retardo para obtener un
                nop                             ; periodo lo mas cercano
                ;                                ; posible a 60 Hz


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
                movlw   TM0_5555                ; carga el temporizador
                movwf   TMR0
                goto    FIN_INT

ESTADO1:
                call    RETARDO
                movlw   b'00000000'             ; Apaga todos los transistores
                movwf   PORTB
                movlw   TM0_2777                ; carga el temporizador
                movwf   TMR0
                goto    FIN_INT
ESTADO2:
                movlw   b'01010000'             ; Enciende los transistores
                movwf   PORTB                   ; P11 Y P12
                movlw   TM0_5555                ; carga el temporizador
                movwf   TMR0
                goto    FIN_INT
ESTADO3:
                call    RETARDO
                movlw   b'00000000'             ; Apaga todos los transistores
                movwf   PORTB
                movlw   TM0_2777                ; carga el temporizador
                movwf   TMR0
                nop
                nop

FIN_INT:
                incf    STATES
                movlw   b'00000011'
                andwf   STATES, f

                ;nop                             ; ciclo de no instruccion
                ;nop                             ; retardo para obtener un
                ;nop                             ; periodo lo mas cercano
                ;                                ; posible a 60 Hz

                bcf	INTCON,T0IF
                retfie

RETARDO:
                                                ; ciclo de no instruccion
                nop                             ; retardo para obtener un
                nop                             ; periodo lo mas cercano
                                                ; posible a 60 Hz
                return

                END
