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
		IMPORT MOTEUR_DOUBLE_AVANT
	
			

__main	
		BL SYSCTL_INIT
		BL LEDS_INIT
		BL SWITCH_INIT
		BL BUMPER_INIT
		BL	MOTEUR_INIT	
		BL LED2_ON
		BL LED3_ON
; PREMIERE ETAPE: Le robot avance tout droit tant que l'un des deux bumpers n'est pas activé

step1
		; Faire avancer le robot
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DOUBLE_AVANT
		
		; Initialisation des bumpers
		ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
		ldr r9, [r7] ; bumper gauche
		ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
		ldr r8, [r7] ; bumper droit
		
		; Si le bumper gauche est activé
		cmp r9, #0
		; on passe a la première question
		BEQ question1_tempo
		
		; Si le bumper droit est activé
		cmp r8, #0
		; on passe a la première question
		BEQ question1_tempo
		
		; sinon, on retourne a l'étape de base
		B step1

; Etape qui temporise l'appui du bouton pour lancer la prochaine question
question1_tempo
; On éteint les moteurs
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	; on initialise le bouton switch bas
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r6, [r7]
	; si il est appuyé on passe a la question1
	cmp r6, #0
	beq question1
	; sinon on reboucle sur l'étape actuelle
	b question1_tempo

; Première épreuve : type question/réponse
;; Principe : Une question est posée, il faut répondre avec soit le switch du haut (vrai) ou le switch du bas (faux)
;; Réponse : switch du haut

question1
	BL WAIT_BLINK
	
	; Initialisation du switch haut
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r6, [r7]
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r5, [r7]
	; si le switch haut est appuyé
	CMP r6, #0
	
	; on passe à l'étape suivante
	BEQ question1
	CMP r5, #0
	BEQ error_question1
	; sinon, on repart au prompt de la question 1
	B question1 

error_question1
	BL LED4_ON
	BL LED5_ON
	BL WAIT
	BL LED4_OFF
	BL LED5_OFF
	B question1



; Deuxième étape : le robot tourne de 90degré vers la droite et avance tout droit, jusqu'à ce que le bumper gauche ou droit soit activé
step2
		; On active les deux moteurs
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON
		
		; On effectue une rotation de 90deg
		BL MOTEUR_DROIT_ARRIERE
		BL MOTEUR_GAUCHE_AVANT
		BL WAIT
; Deuxième étape temporisée : pour pouvoir rebouclé, on créer cette sous étape qui ne fera qu'avancer
step2_bis
		; On fait avancer le robot
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
	
		; On initialise les deux bumpers gauche et droit
		ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
		ldr r9, [r7] ; bumper gauche
		ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
		ldr r8, [r7] ; bumper droit
		
		; Si le bumper gauche est activé
		cmp r9, #0
		; On peut passer a la question 2
		BEQ question2_tempo
		; Si le bumper droit est activé
		cmp r8, #0
		; On peut passer a la question 2
		BEQ question2_tempo
		
		; Sinon, on repart a l'état de temporisation
		B step2_bis
		
		; Deuxième épreuve : un simon
		;; Principe : Des leds vont s'allumées, l'objectif est de mémorisé l'ordre d'allumage des leds et de les reproduire avec les switchs
		;; Réponse : LED DROITE puis LED GAUCHE, puis LED GAUCHE et enfin LED DROITE. Donc SW BAS, SW HAUT, SW HAUT, SW BAS

; Etape qui temporise l'appui du bouton pour lancer la prochaine question
question2_tempo
; On éteint les moteurs
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	; on initialise le bouton switch bas
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r6, [r7]
	; si il est appuyé on passe a la question2
	cmp r6, #0
	beq question2
	; sinon on reboucle sur l'étape actuelle
	b question2_tempo
	
	
	
question2
	
	
	; On réalise la trame du simon
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
	BL LED4_ON
	BL WAIT
	BL LED4_OFF
	
	LTORG
	; R1 sera la variable d'état, qui nous indiquera où en est le joueur
	mov r1, #0

; Fin du simon, on passe a la lecture de l'entrée, étape de temporisation
question2_bis 
	; On initialise les deux switchs
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r6, [r7]
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r5, [r7]
	
	; Si le switch du bas est appuyé
	cmp r6, #0
	; On vérifie si il devait bien être appuyé selon r1
	beq check_btn_bas
	; Si le switch du haut est appuyé
	cmp r5, #0
	; On vérifie si il devait bien être appuyé selon r1
	beq check_btn_haut
	; pour recommencer le simon
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	cmp r9, #0
	beq question2
	; Si aucun n'a été activé, alors on reboucle sur l'étape de temporisation
	B question2_bis

; Vérification selon R1 du switch haut
check_btn_haut 

	; Si on est a l'étape 1
	cmp r1, #0
	; Faux, c'est le switch du bas qui est censé s'activé à l'étape 1
	BEQ not_ok
	
	; Si on est a l'étape 2
	cmp r1, #1
	; Vrai, c'est bien ce switch qui doit être activé
	BEQ second_ok
	
	; Si on est a l'étape 3
	cmp r1, #2
	; Vrai, c'est bien ce switch qui doit être activé
	BEQ third_ok
	
	; Si on est a l'étape 4
	cmp r1, #3
	; Faux, c'est le switch du bas qui est censé s'activé à l'étape finale
	BEQ not_ok

; Vérification selon R1 du switch bas
check_btn_bas
	
	; Si on est a l'étape 1
	cmp r1, #0
	; Vrai, c'est bien ce switch qui doit être activé à la première étape
	BEQ first_ok
	
	; Si on est a l'étape 2
	cmp r1, #1
	; Faux, c'est le switch du haut qui est censé s'activé à l'étape 2
	BEQ not_ok
	
	; Si on est a l'étape 3
	cmp r1, #2
	; Faux, c'est le switch du haut qui est censé s'activé à l'étape 3
	BEQ not_ok
	
	; Si on est a l'étape 4
	cmp r1, #3
	; Vrai, c'est bien ce switch qui doit être activé a l'étape finale
	BEQ fourth_ok

; Cas où il y avait une erreur, on reset la valeur de r1 et signalons au joueur que c'est faux
not_ok
	; On allume les deux leds
	BL LED4_ON
	BL LED5_ON
	BL WAIT
	; On les éteins
	BL LED4_OFF
	BL LED5_OFF
	; On reset la valeur de r1
	mov r1, #0
	; On repart a l'étape de base
	b question2_bis
	
; Cas première étape réussie
first_ok
	; On allume la led a droite
	BL LED4_ON
	BL WAIT
	; On éteint la led a droite
	BL LED4_OFF
	; On passe a l'état suivant
	mov r1,  #1
	; On repart a l'étape de vérification
	b question2_bis
; Cas deuxième étape réussie
second_ok
	; On allume la led a gauche
	BL LED5_ON
	BL WAIT
	; On éteint la led a a gauche
	BL LED5_OFF
	; On passe a l'état suivant
	mov r1,  #2
	; On repart a l'étape de vérification
	b question2_bis
; idem
third_ok
	BL LED5_ON
	BL WAIT
	BL LED5_OFF
	mov r1,  #3
	b question2_bis
; idem
fourth_ok
	BL LED4_ON
	BL WAIT
	BL LED4_OFF

	b step3
	; Troisième étape : Le robot tourne de 90 degrés vers la gauche, puis avance jusqu'à ce que le bumper gauche ou droit soit activé
step3
	; On allume les moteurs
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON
	
	; On tourne a gauche de 90deg
	BL MOTEUR_DROIT_ARRIERE
	BL MOTEUR_GAUCHE_AVANT
	BL WAIT
	; Troisième étape de temporisation : Etat où les roues ne font que avancer, on attend que l'un des deux bumpers entre en collision
step3_bis
	; On fait avancer les deux moteurs
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT
	; Initialisation des bumpers
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
	; Si le bumper gauche est activé
	cmp r9, #0
	; On passe a la question 3
	BEQ question3_tempo
	; Si le bumper droit est activé
	cmp r8, #0
	; On passe a la question 3
	BEQ question3_tempo
	
	; Sinon, on repart a l'étape de temporisation
	B step3_bis
	
	; Troisième épreuve : type calcul binaire
	;; Principe : Un calcul binaire vous sera posé, et vous devez allumer les leds pour reconstruire un nombre binaire a 4 bits
	;; led la plus a gauche est le bit de poids fort et celle la plus a droite représente le bit de poids faible
	;; Réponse : 1011
; Etape qui temporise l'appui du bouton pour lancer la prochaine question
question3_tempo
; On éteint les moteurs
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	; on initialise le bouton switch bas
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r6, [r7]
	; si il est appuyé on passe a la question3
	cmp r6, #0
	beq question3
	; sinon on reboucle sur l'étape actuelle
	b question3_tempo
question3

	; On éteint les moteurs
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	BL WAIT_BLINK
	
	; On setup les switchs ainsi que les bumpers
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r11, [r7] ; switch haut
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r10, [r7] ; switch bas
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
	
	; Si le switch haut est appuyé
	cmp r11, #0
	; On allume la led a gauche
	BEQ led5_switch_2
	; Si le switch bas est activé
	cmp r10, #0
	; On allume la led a droite
	BEQ led4_switch_2
	; Si le bumper gauche est activé
	cmp r9, #0
	; On allume la led rj45 gauche
	BEQ led2_switch_2
	; Si le bumper droit est activé
	cmp r8, #0
	; On allume la led rj45 droite
	BEQ led3_switch_2
	; Si aucun des cas n'est activé, alors on repart a l'étape de base
	B question3

led4_switch_2
	ldr r7, = GPIO_PORTF_BASE + (PIN4<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led4_on_2
	BL LED4_OFF
	B check_question3

led4_on_2
	BL LED4_ON
	B check_question3

led2_switch_2
	ldr r7, = GPIO_PORTF_BASE + (PIN2<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led2_on_2
	BL LED2_OFF
	B check_question3	
	
led2_on_2
	BL LED2_ON
	B check_question3
	
led3_switch_2
	ldr r7, = GPIO_PORTF_BASE + (PIN3<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led3_on_2
	BL LED3_OFF
	B check_question3	
	
led3_on_2
	BL LED3_ON
	B check_question3

led5_switch_2
	ldr r7, = GPIO_PORTF_BASE + (PIN5<<2)
	ldr r6, [r7]
	cmp r6, #0
	BEQ led5_on_2
	BL LED5_OFF
	B check_question3	
	
led5_on_2
	BL LED5_ON
	B check_question3

; Vérification de la réponse (appelé a chaque appui de switchs/bumper)
check_question3
	; Setup des leds (pour lire leurs états)
	ldr r7, = GPIO_PORTF_BASE + (PIN5<<2)
	ldr r6, [r7] ; led5
	ldr r7, = GPIO_PORTF_BASE + (PIN4<<2)
	ldr r5, [r7] ; led4
	ldr r7, = GPIO_PORTF_BASE + (PIN3<<2)
	ldr r4, [r7] ; led3
	ldr r7, = GPIO_PORTF_BASE + (PIN2<<2)
	ldr r3, [r7] ; led2
	
	; Si la led droite est allumé
	cmp r6, #PIN5
	; On vérifie si l'autre led est activée
	beq led5_allume_2
	; Sinon, on repart a l'étape de base
	b question3
; Cas où la led  droite est allumée, on veut vérifier si la led gauche est allumée
led5_allume_2
	; Si la led a gauche est allumée
	cmp r5, #PIN4
	; On vérifie si l'autre led est activée
	beq led4_allume_2
	; Sinon, on repart a l'étape de base
	b question3
; Cas où la led droite et gauche sont allumées, on veut vérifier si la led rj45 droite est allumée
led4_allume_2
	; Si la led rj45 droite est allumée
	cmp r4, #0
	; On vérifie si l'autre led est éteinte
	beq led3_eteint_2
	 ; Sinon, on repart a l'étape de base
	b question3
; Cas où la led droite, gauche et droite rj45 sont toutes allumées, on veut s'assurer que la led rj45 gauche est éteinte
led3_eteint_2
	; Si la led rj45 gauche est éteinte
	cmp r3, #PIN2
	; On peut passer a l'étape 4
	beq step4
	; Sinon, on repart a l'étape de base
	b question3

; Quatrième étape : Fin, le robot tourne a gauche, avance et lorsque l'un des deux bumpers est activé, se met a tourner sur lui-même 
; et les leds se mettent a clignoter

step4
	; On éteint les leds
	BL LED4_OFF
	BL LED5_OFF
	BL LED3_ON
	BL LED2_ON
	; On allume les moteurs
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON

	; On fait tourner le robot de 90deg
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_ARRIERE
	BL WAIT

; Etape de temporisation en attendant que l'un des bumpers s'activent, le robot ne fera que avancer
step4_bis
	; On fait avancer le robot
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_AVANT
	
		
	; Setup des bumpers
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
		
	; Si l'un des deux bumpers est activé, alors on part a l'état blink
	cmp r9, #0
	BEQ question4_tempo
	cmp r8, #0
	BEQ question4_tempo
		
	B step4_bis

;; Quatrième épreuve
question4_tempo
; On éteint les moteurs
	BL MOTEUR_DROIT_OFF
	BL MOTEUR_GAUCHE_OFF 
	; on initialise le bouton switch bas
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r6, [r7]
	; si il est appuyé on passe a la question3
	cmp r6, #0
	beq question4
	; sinon on reboucle sur l'étape actuelle
	b question4_tempo
	;; Quatrième et dernière épreuve : Un test de rapidité
	;; Principe : Appuyé au bon moment sur le switch de la led allumée
question4
	 
	; On setup les switchs ainsi que les bumpers
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r11, [r7] ; switch haut
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r10, [r7] ; switch bas
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
etape1_tempo
	ldr r1, =0x55555
	BL LED4_OFF
	BL LED5_OFF
	BL LED2_ON
	BL LED3_ON
	
etape1
	BL LED5_OFF
	
	BL LED4_ON
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r10, [r7] ; switch haut
	cmp r10, #0
	beq etape2_tempo
	
	subs r1, #1
	bne etape1
	B error_question4
etape2_tempo
	ldr r1, =0x55555
	
etape2

	BL LED4_OFF
	BL LED5_ON
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r11, [r7] ; switch bas
	cmp r11, #0
	beq etape3_tempo
	subs r1, #1
	bne etape2
	B error_question4

etape3_tempo
	ldr r1, =0x55555

etape3
	BL LED5_OFF
	BL LED2_OFF
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	
	cmp r9, #0
	beq etape4_tempo
	subs r1, #1
	bne etape3
	B error_question4


etape4_tempo
	ldr r1, =0x55555
etape4
	BL LED2_ON
	BL LED3_OFF
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
	
	cmp r8, #0
	beq etape5_tempo
	subs r1, #1
	bne etape4
	B error_question4
etape5_tempo
	ldr r1, =0x55555
etape5
	BL LED3_ON
	BL LED5_ON
	ldr r7, = GPIO_PORTD_BASE + (BROCHE7<<2)
	ldr r11, [r7] ; switch bas
	cmp r11, #0
	beq etape6_tempo
	subs r1, #1
	bne etape5
	B error_question4

etape6_tempo
	ldr r1, =0x55555
etape6
	BL LED5_OFF
	BL LED2_OFF
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r8, [r7] ; bumper gauche
	
	cmp r8, #0
	beq etape7_tempo
	subs r1, #1
	bne etape6
	B error_question4

	
	
etape7_tempo
	ldr r1, =0x55555
etape7
	BL LED2_ON
	BL LED4_ON
	ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2)
	ldr r8, [r7] ; switch haut	
	cmp r8, #0
	beq fin_bis
	subs r1, #1
	bne etape7
	B error_question4
error_question4
	BL LED4_ON
	BL LED5_ON
	BL WAIT
	BL LED4_OFF
	BL LED5_OFF
	B etape1_tempo 

fin_bis
	BL LED4_OFF
	BL MOTEUR_DROIT_ON
	BL MOTEUR_GAUCHE_ON
	BL MOTEUR_DROIT_AVANT
	BL MOTEUR_GAUCHE_ARRIERE
	BL WAIT
fin
	BL MOTEUR_GAUCHE_AVANT
	BL MOTEUR_DROIT_AVANT
	ldr r7, = GPIO_PORTE_BASE + (BROCHE1<<2)
	ldr r9, [r7] ; bumper gauche
	ldr r7, = GPIO_PORTE_BASE + (BROCHE0<<2)
	ldr r8, [r7] ; bumper droit
		
		; Si le bumper gauche est activé
	cmp r9, #0
		; On peut passer au blink
	BEQ blink
		; Si le bumper droit est activé
	cmp r8, #0
		; On peut passer au blink
	BEQ blink
	B fin

; Fin du jeu, le robot tourne sur lui-même et les leds clignotent dans le sens anti-horaire
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
		LTORG
		; Rebouclage a la fin
		b blink
		

; Partie qui permet de faire attendre le programme pendant un court instant, est utilisée pour l'attente entre deux clignottements	
WAIT_BLINK ldr r2, =0xFFFFF   
wait_blink	subs r2, #1
			bne wait_blink
			BX LR
			
; Partie qui permet de faire attendre le programme pendant un bref instant, est utilisée pour l'attente entre une rotation ou une avancée
WAIT	ldr r2, =0xAFFFFF 
wait1	subs r2, #1
        bne wait1
		
		;; retour à la suite du lien de branchement
		BX	LR


		
		
	; Fin du programme, no operation et end
		NOP
        END
