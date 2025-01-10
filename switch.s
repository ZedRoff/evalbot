
	;;;;;;;;;;;; SETUP SWITCH
	
	AREA |.text|, CODE, READONLY
GPIO_I_PUR EQU 0x510 ; Pull up resistor 
GPIO_PORTD_BASE		EQU	0x40007000	; Port D de base pour les switchs
GPIO_O_DEN EQU 0x51C ; Digital Enable
BROCHE6				EQU 	0x40		; bouton poussoir 1
BROCHE7 EQU 0x80 ; bouton poussoir 2
	ENTRY
	
	EXPORT SWITCH_INIT ; on exporte l'étiquette

SWITCH_INIT

	ldr r7, = GPIO_PORTD_BASE+GPIO_I_PUR	;; Adresse du pull up resistor du portD
    ldr r0, =(BROCHE6+BROCHE7) ; on stock l'addition
    str r0, [r7] ; on écrit dans la mémoire pour activer le PUR des deux switchs
		
	ldr r7, = GPIO_PORTD_BASE+GPIO_O_DEN	;; Activé la fonction digitale 
    ldr r0, =(BROCHE6+BROCHE7)	; on stock l'addition
    str r0, [r7]   ; on écrit dans la mémoire pour activer le DEN des deux switchs  
	BX LR
		
