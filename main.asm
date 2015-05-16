 	extern printf, initBoard
section .data
	msg    db "%d",10,0
section .text
    	global main

main:	
	call initBoard
	
    	xor eax, eax	;exit code
	ret
