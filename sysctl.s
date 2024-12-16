                                                                                  	
	;;;;;;;; SETUP SYSCTL
	
	
	AREA |.text|, CODE, READONLY
		
SYSCTL EQU 0x400FE108
	ENTRY
	
	EXPORT SYSCTL_INIT

SYSCTL_INIT	  	
	ldr r6, =SYSCTL
	mov r0, #0x00000038
	str r0, [r6]
	nop
	nop
	nop
	BX LR
