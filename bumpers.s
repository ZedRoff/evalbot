
	;;;;;;;;;;;; SETUP BUMPER
	
	AREA |.text|, CODE, READONLY
GPIO_I_PUR EQU 0x510 
GPIO_PORTE_BASE		EQU	0x40024000	
GPIO_O_DEN EQU 0x51C
BROCHE0				EQU 	0x01	; bouton poussoir 1
BROCHE1 EQU 0x02
	ENTRY
	
	EXPORT BUMPER_INIT

BUMPER_INIT

	ldr r7, = GPIO_PORTE_BASE+GPIO_I_PUR	;; Pul_up 
    ldr r0, =(BROCHE0+BROCHE1)
    str r0, [r7]
		
	ldr r7, = GPIO_PORTE_BASE+GPIO_O_DEN	;; Enable Digital Function 
    ldr r0, =(BROCHE0+BROCHE1)	
    str r0, [r7]     
	BX LR
		
