 	extern printf, aiMove
section .data
	msg    db "%d",10,0
section .text
    	global main

main:	
	call aiMove
	
    	xor eax, eax	;exit code
	ret
