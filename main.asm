section .data
	fmt     db "%u  %s",10,0
	msg1    db "Hello",0
section .text
 	extern printf
    	global main

main:
    mov  edx, msg1
    mov  esi, 1
    mov  edi, fmt
    mov  eax, 0     ; no f.p. args
    call printf

    	xor eax, eax
	popa
	ret
