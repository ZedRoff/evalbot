
	;;;;;;;;;;;; SETUP SWITCH
	
	AREA |.text|, CODE, READONLY
GPIO_I_PUR EQU 0x510 
GPIO_PORTD_BASE		EQU	0x40007000	
GPIO_O_DEN EQU 0x51C
BROCHE6				EQU 	0x40		; bouton poussoir 1
BROCHE7 EQU 0x80
	ENTRY
	
	EXPORT SWITCH_INIT

SWITCH_INIT

	ldr r7, = GPIO_PORTD_BASE+GPIO_I_PUR	;; Pul_up 
    ldr r0, =(BROCHE6+BROCHE7)
    str r0, [r7]
		
	ldr r7, = GPIO_PORTD_BASE+GPIO_O_DEN	;; Enable Digital Function 
    ldr r0, =(BROCHE6+BROCHE7)	
    str r0, [r7]     
	BX LR
		
