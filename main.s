	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui même)
		AREA    |.text|, CODE, READONLY

PIN2 EQU 0x04
PIN3 EQU 0x08
PIN4 EQU 0x10
PIN5 EQU 0x20
	
BROCHE6				EQU 	0x40		; bouton bumper 1
BROCHE7				EQU 	0x80		; bouton bumper 2
	
BROCHE0				EQU 	0x01		; bouton poussoir 1
BROCHE1      		EQU 	0x02		; bouton poussoir 2
	
GPIO_PORTD_BASE		EQU	0x40007000	
GPIO_PORTE_BASE		EQU	0x40024000
GPIO_PORTF_BASE EQU 0x40025000
cpt EQU 0
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
		BL LED2_ON
		BL LED3_ON
			
		;BL	MOTEUR_DROIT_ON
		;BL	MOTEUR_GAUCHE_ON
		
		
		ldr r0, =cpt
step1		
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON

		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		BL WAIT
		BL MOTEUR_DROIT_OFF
		BL MOTEUR_GAUCHE_OFF 
		B question1
		
question1
	; q: Résultat de 2+2 (=4)
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	
	ldr r6, [r7]
	
	CMP r6, #0
	BEQ step2
	B question1 

step2
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON

		BL MOTEUR_DROIT_ARRIERE
		BL MOTEUR_GAUCHE_AVANT
		BL WAIT
		
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		BL WAIT
		
		BL MOTEUR_DROIT_OFF
		BL MOTEUR_GAUCHE_OFF 
		
		B question2
question2
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)

	ldr r6, [r7]
	cmp r6, #0
	BEQ step3
	B question2

step3
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON

	BL MOTEUR_DROIT_ARRIERE
	BL MOTEUR_GAUCHE_AVANT
	BL WAIT
		
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT
	BL WAIT
		
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
		
	B question3
question3
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)

	ldr r6, [r7]
	cmp r6, #0
	BEQ step4
	B question3

step4
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON

	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_ARRIERE
	BL WAIT
		
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT
	BL WAIT
		
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
		
	B question4
question4
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)

	ldr r6, [r7]
	cmp r6, #0
	BEQ step5
	B question4
	
step5
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON

	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_ARRIERE
	BL WAIT
		
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT
	BL WAIT
		
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
		
	B blink
blink
		BL LED4_ON
		BL WAIT_BLINK
		BL LED4_OFF
		BL LED5_ON
		BL WAIT_BLINK
		BL LED5_OFF
		BL LED2_OFF
		BL WAIT_BLINK
		BL LED2_ON
		BL LED3_OFF
		BL WAIT_BLINK
		BL LED3_ON
		b blink
		

		
		
	



		;; BL Branchement vers un lien (sous programme)

		; Configure les PWM + GPIO
		   
		
		; Activer les deux moteurs droit et gauche
		
WAIT_BLINK ldr r1, =0xFFFFF   
wait_blink	subs r1, #1
			bne wait_blink
			BX LR
			
	
WAIT	ldr r1, =0xAFFFFF 
wait1	subs r1, #1
        bne wait1
		
		;; retour à la suite du lien de branchement
		BX	LR

		NOP
        END
