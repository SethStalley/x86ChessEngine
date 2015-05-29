extern printf, aiMove, aiPlayer, initGui, gtk_init
section .data
	msg    db "%d",10,0
	temp   db 0
section .text
    	global main

main:
	;call gtk init function
	push rbp
	mov rsi, temp
	mov rdi, temp
	xor rax, rax
	call gtk_init
	pop rbp

	;load all the gtk gui elements
	push rbp
	mov rsi, [temp]
	mov rdi, [temp]
	xor rax, rax
	call initGui
	pop rbp
	xor rax, rax		;return 0
	jmp exitMain       ;temp jump

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

exitMain:
    xor eax, eax	;exit code
	ret
