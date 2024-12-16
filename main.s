	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui même)
		AREA    |.text|, CODE, READONLY
			
PIN4 EQU 0x10
	
BROCHE6				EQU 	0x40		; bouton bumper 1
BROCHE7				EQU 	0x80		; bouton bumper 2
	
BROCHE0				EQU 	0x01		; bouton poussoir 1
BROCHE1      		EQU 	0x02		; bouton poussoir 2
	
GPIO_PORTD_BASE		EQU	0x40007000	
GPIO_PORTE_BASE		EQU	0x40024000
	
		ENTRY
		EXPORT	__main
		
		;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; déactiver le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arrière
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arrière
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
		
		IMPORT LEDS_INIT
		IMPORT LED2_ON
		IMPORT LED2_OFF
		IMPORT LED3_ON
		IMPORT LED3_OFF
		IMPORT LED4_ON
		IMPORT LED4_OFF
		IMPORT LED5_ON
		IMPORT LED5_OFF
		IMPORT SYSCTL_INIT
		IMPORT SWITCH_INIT
		IMPORT BUMPER_INIT
			

__main	
		BL SYSCTL_INIT
		BL LEDS_INIT
		BL SWITCH_INIT
		BL BUMPER_INIT
		BL	MOTEUR_INIT	 
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		
		ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)

DOUBLE_AVANT
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT
	BL WAIT
	BL WAIT
	BX LR
TOURNE_DROIT
		BL MOTEUR_DROIT_ARRIERE
		BL MOTEUR_GAUCHE_AVANT
		BL WAIT
		BX LR
TOURNE_GAUCHE
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_AVANT
		BL WAIT
		BX LR
cond
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON
		
		B DOUBLE_AVANT
		
		B TOURNE_DROIT
		
		B DOUBLE_AVANT
		
		B TOURNE_DROIT
		
		B DOUBLE_AVANT
		
		B TOURNE_GAUCHE
		
		B DOUBLE_AVANT
		
		B TOURNE_GAUCHE
		
		B DOUBLE_AVANT
		
		
		B TOURNE_DROIT
		
		B DOUBLE_AVANT
		
		B TOURNE_DROIT
		
		B DOUBLE_AVANT
		
		
	



		;; BL Branchement vers un lien (sous programme)

		; Configure les PWM + GPIO
		   
		
		; Activer les deux moteurs droit et gauche
		

	
WAIT	ldr r1, =0xAFFFFF 
wait1	subs r1, #1
        bne wait1
		
		;; retour à la suite du lien de branchement
		BX	LR

		NOP
        END
