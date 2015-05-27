extern printf, aiMove, aiPlayer
section .data
	msg    db "%d",10,0
section .text
    	global main

main:	
	mov rax, 1
	mov rcx, 15
gameLoop:
	push rcx
	push rax
	mov [aiPlayer], rax
	call aiMove
	pop rax
	pop rcx
	imul rax, -1		;swap player
	dec rcx
	cmp rcx, 0
	jne gameLoop
	
	
    	xor eax, eax	;exit code
	ret
