                                                                                  	
	;;;;;;;; SETUP SYSCTL
	
	
	AREA |.text|, CODE, READONLY
		
SYSCTL EQU 0x400FE108 ; Port GPIO_SYSTEMCONTROL pour activer les clocks
	ENTRY
	
	EXPORT SYSCTL_INIT ; on exporte l'étiquette SYSCTL_INIT 

SYSCTL_INIT	  	
	ldr r6, =SYSCTL
	mov r0, #0x00000038 ; valeur qui permet d'activer les ports D, E et F
	str r0, [r6] ; on range la valeur ci-dessus dans l'adresse de SYSCTL
 	; 3 nop pour laisser la clock s'activée
	nop
	nop
	nop
	BX LR ; on repart à l'endroit où l'étiquette a été appelée
