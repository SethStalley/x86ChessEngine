 	extern printf, initBoard
section .data
	msg    db "%d",10,0
section .text
    	global main

main:	
	pusha
	call initBoard
	push eax
	push msg
    	call printf	;c function to call
	add esp,8	;pop stack
	popa
	

    	xor eax, eax	;exit code
	ret
