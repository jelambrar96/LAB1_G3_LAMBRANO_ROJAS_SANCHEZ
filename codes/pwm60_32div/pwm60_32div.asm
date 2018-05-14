    ; pwm60.asm
    ;
    ; codigo que controla los IGBT de un inversor
    ; microcontrolador utilizado: PIC16F84A
    ; Cristal de 20MHz
    ; cada ciclo de instruccion dura 200ns
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
TM0_2777    EQU       0xFF

; se guardan las variables a partir de la direccion
; 0x0C ya que si se hacen antes, intefieren con los
; datos de los registros principales
INDEX       EQU       0x0C
STATE       EQU       0x0D
DEC_REG     EQU       0x0E

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
                clrf    INDEX                   ; limpa el registro de los
                                                ; estados
                clrf    STATE

                bsf	STATUS,RP0		; Acceso al Banco 1.
                movlw   b'00001111'             ; establece la parte alta del
                movwf   TRISB                  ; del puerto B como salida
                movlw	b'00001111'             ; Carga el registro w
		movwf	TRISA                   ; Se carga en el registro lo
                                                ; lo contenido en W, se
                                                ; configura el puerto A como
                                                ; entrada

                movlw	b'00000010'
                movwf	OPTION_REG		; prescaler de 8
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

                nop
                nop

                movlw   b'00111111'
                andwf   INDEX,f
                movf    INDEX, W

                btfss   STATUS, Z
                goto    ESTADOS

                call    RETARDO2
                ;clrf    PORTB                   ; apaga todos los transistores

                movfw   STATE
                addwf   PCL, f

                goto    ESTADO2
                goto    ESTADO2
                goto    ESTADO0
                goto    ESTADO0

ESTADOS:
                movfw   STATE
                addwf   PCL, f                  ; Salta al estado actual

                goto    ESTADO0
                goto    ESTADO1
                goto    ESTADO2
                goto    ESTADO3

ESTADO0:
                movlw   b'10100000'             ; Enciende los transistores
                movwf   PORTB                   ; P10 Y P13
                movlw   b'00000001'
                movwf   STATE
                goto    LOAD_TM0

ESTADO1:
                movlw   b'00000000'             ; apaga los transistores
                movwf   PORTB                   ; P10 Y P13
                movlw   b'00000000'
                movwf   STATE
                goto    LOAD_TM0

ESTADO2:
                movlw   b'01010000'             ; Enciende los transistores
                movwf   PORTB                   ; P11 Y P12
                movlw   b'00000011'
                movwf   STATE
                goto    LOAD_TM0

ESTADO3:
                movlw   b'00000000'             ; Apaga los transistores
                movwf   PORTB                   ; P10 Y P13
                movlw   b'00000010'
                movwf   STATE
                nop
                nop


LOAD_TM0:
                call    TABLE                   ; Carga el valor del temporiza
                                                ; dor en el acumulador
                movwf   TMR0                    ; Carga el nuevo valor del
                                                ; temporizador
;FIN_INT:
                incf    INDEX                   ; incrementa el indice

FIN_INT:
                bcf	INTCON,T0IF
                retfie

; Tabla de valores PWM
TABLE:
                movf    INDEX, W
                addwf	PCL,F

		retlw	0xf8
		retlw	0x6e
		retlw	0xe9
		retlw	0x7d
		retlw	0xda
		retlw	0x8c
		retlw	0xcc
		retlw	0x9a
		retlw	0xbe
		retlw	0xa8
		retlw	0xb1
		retlw	0xb5
		retlw	0xa4
		retlw	0xc2
		retlw	0x99
		retlw	0xcd
		retlw	0x8e
		retlw	0xd8
		retlw	0x85
		retlw	0xe1
		retlw	0x7d
		retlw	0xe9
		retlw	0x76
		retlw	0xf0
		retlw	0x70
		retlw	0xf6
		retlw	0x6c
		retlw	0xfa
		retlw	0x69
		retlw	0xfd
		retlw	0x67
		retlw	0xfe
		retlw	0x67
		retlw	0xfe
		retlw	0x69
		retlw	0xfd
		retlw	0x6c
		retlw	0xfa
		retlw	0x70
		retlw	0xf6
		retlw	0x76
		retlw	0xf0
		retlw	0x7d
		retlw	0xe9
		retlw	0x85
		retlw	0xe1
		retlw	0x8e
		retlw	0xd8
		retlw	0x99
		retlw	0xcd
		retlw	0xa4
		retlw	0xc2
		retlw	0xb1
		retlw	0xb5
		retlw	0xbe
		retlw	0xa8
		retlw	0xcc
		retlw	0x9a
		retlw	0xda
		retlw	0x8c
		retlw	0xe9
		retlw	0x7d
		retlw	0xf8
		retlw	0x6e

RETARDO2:
                movlw   0x0F
                movwf   DEC_REG
AGAIN:
                decfsz  DEC_REG, f
                goto    AGAIN
                nop
                nop
                return

RETARDO:
                nop
                return

                END
