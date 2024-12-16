


;;;;;;; SETUP LEDS

	AREA |.text|, CODE, READONLY

SYSCTL EQU 0x400FE108
GPIO_PORTF_BASE EQU 0x40025000
GPIO_O_DIR EQU 0x400
GPIO_O_DEN EQU 0x51C
GPIO_O_DR2R EQU 0x500
	
PIN2 EQU 0x04
PIN3 EQU 0x08
PIN4 EQU 0x10
PIN5 EQU 0x20
	
	ENTRY
	EXPORT LED2_ON
	EXPORT LED2_OFF
	
	EXPORT LED3_ON
	EXPORT LED3_OFF
		
	EXPORT LED4_ON
	EXPORT LED4_OFF
		
	EXPORT LED5_ON
	EXPORT LED5_OFF
		
	EXPORT LEDS_INIT
		
LEDS_INIT
	ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
    ldr r0, = PIN2 + PIN3 + PIN4 + PIN5
    str r0, [r6]
		
    ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
    ldr r0, = PIN2 + PIN3 + PIN4 + PIN5 		
    str r0, [r6]
 
	ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensité de sortie (2mA)
    ldr r0, = PIN2 + PIN3 + PIN4 + PIN5 			
    str r0, [r6]
	
	BX LR

LED2_ON
	mov r3, #PIN2       					;; Allume portF broche 4 : 00010000
	ldr r6, = GPIO_PORTF_BASE + (PIN2<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
	str r3, [r6]
	BX LR
LED2_OFF
	mov r3, #0       					;; Allume portF broche 4 : 00010000
	ldr r6, = GPIO_PORTF_BASE + (PIN2<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
	str r3, [r6]
	BX LR

LED3_ON
	mov r3, #PIN3       					;; Allume portF broche 4 : 00010000
	ldr r6, = GPIO_PORTF_BASE + (PIN3<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
	str r3, [r6]
	BX LR
LED3_OFF
	mov r3, #0       					;; Allume portF broche 4 : 00010000
	ldr r6, = GPIO_PORTF_BASE + (PIN3<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
	str r3, [r6]
	BX LR

LED4_ON
	mov r3, #PIN4       					;; Allume portF broche 4 : 00010000
	ldr r6, = GPIO_PORTF_BASE + (PIN4<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
	str r3, [r6]
	BX LR	
LED4_OFF
	mov r3, #0       					;; Allume portF broche 4 : 00010000
	ldr r6, = GPIO_PORTF_BASE + (PIN4<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
	str r3, [r6]
	BX LR
	
LED5_ON
	mov r3, #PIN5       					;; Allume portF broche 4 : 00010000
	ldr r6, = GPIO_PORTF_BASE + (PIN5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
	str r3, [r6]
	BX LR	
LED5_OFF
	mov r3, #0       					;; Allume portF broche 4 : 00010000
	ldr r6, = GPIO_PORTF_BASE + (PIN5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
	str r3, [r6]
	BX LR	
