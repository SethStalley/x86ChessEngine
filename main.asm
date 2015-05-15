 	extern printf
section .data
	msg    db "Hello",10,0
section .text
    	global main

main:	
	pusha
	push dword msg	;pointer in stack to msg
    	call printf	;c function to call
	add esp, 4	;pop stack
	popa

    	xor eax, eax	;exit code
	ret
