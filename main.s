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
	
		
step1	
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON
step1_bis
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		
		
		ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
		ldr r9, [r7] ; bumper gauche
		ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
		ldr r8, [r7] ; bumper droit
		
		cmp r9, #0
		BEQ question1
		cmp r8, #0
		BEQ question1
		
		B step1_bis
		
		
		
question1
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
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
step2_bis
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
	
		
		
		
		ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
		ldr r9, [r7] ; bumper gauche
		ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
		ldr r8, [r7] ; bumper droit
		
		cmp r9, #0
		BEQ question2
		cmp r8, #0
		BEQ question2
		
		B step2_bis
		
question2
	
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	
	ldr r6, [r7]
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r5, [r7]
	
	BL LED4_ON 
	BL WAIT
	BL LED4_OFF
	BL LED5_ON 
	BL WAIT
	BL LED5_OFF 
	BL WAIT_BLINK
	BL LED5_ON 
	BL WAIT
	BL LED5_OFF
question2_bis 
	cmp r6, #0
	BEQ question2_bis_1
	B question2_bis

step3
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON
	
	BL MOTEUR_DROIT_ARRIERE
	BL MOTEUR_GAUCHE_AVANT
	BL WAIT
step3_bis
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT

		
	 
		
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
		
	cmp r9, #0
	BEQ question3
	cmp r8, #0
	BEQ question3
	
	
	B step3_bis
	
	
question3
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF
	
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r11, [r7] ; switch haut
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r10, [r7] ; switch bas
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
	
	
	cmp r11, #0
	BEQ led5_switch
	cmp r10, #0
	BEQ led4_switch
	
	cmp r9, #0
	BEQ led2_switch
	cmp r8, #0
	BEQ led3_switch
	B question3

led4_switch
	ldr r7, = GPIO_PORTF_BASE + (PIN4<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led4_on
	BL LED4_OFF
	B check_question3

led4_on
	BL LED4_ON
	B check_question3

led2_switch
	ldr r7, = GPIO_PORTF_BASE + (PIN2<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led2_on
	BL LED2_OFF
	B check_question3	
	
led2_on
	BL LED2_ON
	B check_question3
	
led3_switch
	ldr r7, = GPIO_PORTF_BASE + (PIN3<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led3_on
	BL LED3_OFF
	B check_question3	
	
led3_on
	BL LED3_ON
	B check_question3

led5_switch
	ldr r7, = GPIO_PORTF_BASE + (PIN5<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led5_on
	BL LED5_OFF
	B check_question3	
	
led5_on
	BL LED5_ON
	B check_question3

check_question3
	ldr r7, = GPIO_PORTF_BASE + (PIN5<<2)
	ldr r6, [r7] ; led5
	ldr r7, = GPIO_PORTF_BASE + (PIN4<<2)
	ldr r5, [r7] ; led4
	ldr r7, = GPIO_PORTF_BASE + (PIN3<<2)
	ldr r4, [r7] ; led3
	ldr r7, = GPIO_PORTF_BASE + (PIN2<<2)
	ldr r3, [r7] ; led2
	
	cmp r6, #PIN5
	beq led5_allume
	b question3
led5_allume
	cmp r5, #PIN4
	beq led3_eteint
	b question3
led3_eteint
	cmp r4, #PIN3
	beq led2_eteint
	B question3
led2_eteint
	cmp r3, #PIN2
	beq step4
	B question3

step4
	BL LED4_OFF
	BL LED5_OFF
	BL LED3_ON
	BL LED2_ON
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON

	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_ARRIERE
	BL WAIT
step4_bis
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT
	
		
	
		
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
		
	cmp r9, #0
	BEQ question4
	cmp r8, #0
	BEQ question4
		
	B step4_bis
		
question4
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r11, [r7] ; switch haut
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r10, [r7] ; switch bas
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
	
	
	cmp r11, #0
	BEQ led5_switch_2
	cmp r10, #0
	BEQ led4_switch_2
	cmp r9, #0
	BEQ led2_switch_2
	cmp r8, #0
	BEQ led3_switch_2
	B question4

led4_switch_2
	ldr r7, = GPIO_PORTF_BASE + (PIN4<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led4_on_2
	BL LED4_OFF
	B check_question4

led4_on_2
	BL LED4_ON
	B check_question4

led2_switch_2
	ldr r7, = GPIO_PORTF_BASE + (PIN2<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led2_on_2
	BL LED2_OFF
	B check_question4	
	
led2_on_2
	BL LED2_ON
	B check_question4
	
led3_switch_2
	ldr r7, = GPIO_PORTF_BASE + (PIN3<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led3_on_2
	BL LED3_OFF
	B check_question4	
	
led3_on_2
	BL LED3_ON
	B check_question4

led5_switch_2
	ldr r7, = GPIO_PORTF_BASE + (PIN5<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led5_on_2
	BL LED5_OFF
	B check_question4	
	
led5_on_2
	BL LED5_ON
	B check_question4

check_question4
	ldr r7, = GPIO_PORTF_BASE + (PIN5<<2)
	ldr r6, [r7] ; led5
	ldr r7, = GPIO_PORTF_BASE + (PIN4<<2)
	ldr r5, [r7] ; led4
	ldr r7, = GPIO_PORTF_BASE + (PIN3<<2)
	ldr r4, [r7] ; led3
	ldr r7, = GPIO_PORTF_BASE + (PIN2<<2)
	ldr r3, [r7] ; led2
	
	cmp r6, #PIN5
	beq led5_allume_2
	b question4
led5_allume_2
	cmp r5, #PIN4
	beq led4_allume_2
	b question4
led4_allume_2
	cmp r4, #0
	beq led3_eteint_2
	b question4
led3_eteint_2
	cmp r3, #PIN2
	beq step5
	b question4

step5
	BL LED4_OFF
	BL LED5_OFF
	BL LED3_ON
	BL LED2_ON
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON

	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_ARRIERE

	
step5_bis
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT
	BL WAIT
		
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
		
	cmp r9, #0
	BEQ blink
	cmp r8, #0
	BEQ blink
		
	B step5_bis
		
blink
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_AVANT
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
