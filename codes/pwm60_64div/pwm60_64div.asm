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
                movwf   TRISB                   ; del puerto B como salida
                movlw	b'00001111'             ; Carga el registro w
		movwf	TRISA                   ; Se carga en el registro lo 
                                                ; lo contenido en W, se 
                                                ; configura el puerto A como 
                                                ; entrada
                
                movlw	b'00000001'
                movwf	OPTION_REG		; prescaler de 4
                bcf	STATUS,RP0		; Acceso al Banco 0.
                movlw	TM0_2777		; Carga el TMR0 con suficiente.
                movwf	TMR0                    ; tiempo para que la primera
                                                ; vez que se desborde, el 
                                                ; microcontrolador este 
                                                ; ejecutando la subrrutina
                                                ; PPAL
                movlw	b'10100000'
                movwf	INTCON			; Autoriza interrupción T0I 
PPAL:
                goto    $                       ; ciclo infinito, no se coloca
                                                ; el microcontrolador en bajo 
                                                ; consumo porque se apaga el 
                                                ; Timer0 

INT_TM0:        
                ;call    RETARDO
                
                nop
    
                movlw   b'01111111'
                andwf   INDEX,f
                movf    INDEX, W
                
                btfss   STATUS, Z               
                goto    ESTADOS
                
                ;clrf    PORTB                   ; apaga todos los transistores
                call    RETARDO
                
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

		retlw	0xfb
		retlw	0x73
		retlw	0xf4
		retlw	0x7a
		retlw	0xed
		retlw	0x81
		retlw	0xe6
		retlw	0x88
		retlw	0xdf
		retlw	0x8f
		retlw	0xd9
		retlw	0x95
		retlw	0xd2
		retlw	0x9c
		retlw	0xcb
		retlw	0xa3
		retlw	0xc5
		retlw	0xa9
		retlw	0xbe
		retlw	0xb0
		retlw	0xb8
		retlw	0xb6
		retlw	0xb2
		retlw	0xbc
		retlw	0xac
		retlw	0xc2
		retlw	0xa6
		retlw	0xc8
		retlw	0xa1
		retlw	0xcd
		retlw	0x9c
		retlw	0xd2
		retlw	0x97
		retlw	0xd7
		retlw	0x92
		retlw	0xdc
		retlw	0x8d
		retlw	0xe1
		retlw	0x89
		retlw	0xe5
		retlw	0x85
		retlw	0xe9
		retlw	0x82
		retlw	0xec
		retlw	0x7e
		retlw	0xf0
		retlw	0x7b
		retlw	0xf3
		retlw	0x79
		retlw	0xf5
		retlw	0x76
		retlw	0xf8
		retlw	0x74
		retlw	0xfa
		retlw	0x72
		retlw	0xfc
		retlw	0x71
		retlw	0xfd
		retlw	0x70
		retlw	0xfe
		retlw	0x6f
		retlw	0xfe
		retlw	0x6f
		retlw	0xfe
		retlw	0x6f
		retlw	0xfe
		retlw	0x6f
		retlw	0xfe
		retlw	0x70
		retlw	0xfe
		retlw	0x71
		retlw	0xfd
		retlw	0x72
		retlw	0xfc
		retlw	0x74
		retlw	0xfa
		retlw	0x76
		retlw	0xf8
		retlw	0x79
		retlw	0xf5
		retlw	0x7b
		retlw	0xf3
		retlw	0x7e
		retlw	0xf0
		retlw	0x82
		retlw	0xec
		retlw	0x85
		retlw	0xe9
		retlw	0x89
		retlw	0xe5
		retlw	0x8d
		retlw	0xe1
		retlw	0x92
		retlw	0xdc
		retlw	0x97
		retlw	0xd7
		retlw	0x9c
		retlw	0xd2
		retlw	0xa1
		retlw	0xcd
		retlw	0xa6
		retlw	0xc8
		retlw	0xac
		retlw	0xc2
		retlw	0xb2
		retlw	0xbc
		retlw	0xb8
		retlw	0xb6
		retlw	0xbe
		retlw	0xb0
		retlw	0xc5
		retlw	0xa9
		retlw	0xcb
		retlw	0xa3
		retlw	0xd2
		retlw	0x9c
		retlw	0xd9
		retlw	0x95
		retlw	0xdf
		retlw	0x8f
		retlw	0xe6
		retlw	0x88
		retlw	0xed
		retlw	0x81
		retlw	0xf4
		retlw	0x7a
		retlw	0xfb
		retlw	0x73
                
                
RETARDO:
                movlw   0x0F
                movwf   DEC_REG
AGAIN:
                decfsz  DEC_REG, f
                goto    AGAIN
                nop
                nop
                return
                
                
                END
