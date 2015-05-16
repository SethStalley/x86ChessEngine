 	extern printf, initBoard
section .data
	msg    db "%d",10,0
section .text
    	global main

main:	
	pusha
	call initBoard
	popa
	

    	xor eax, eax	;exit code
	ret
