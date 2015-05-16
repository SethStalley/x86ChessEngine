global aiMove
extern	printf

section .data
	printD			db	"%d",10,0
	board dd 0x0
					;bitboards for white
	whitePawns 	dq 	0xff00
	whiteBishops 	dq	0x24
	whiteKnights 	dq 	0x42
	whiteCastles 	dq 	0x81
	whiteQueens 	dq 	0x8
	whiteKing 	dq 	0x10

					;bitboards for black
	blackPawns 	dq 	0xff000000000000
	blackBishops 	dq 	0x2400000000000000
	blackKnights 	dq 	0x4200000000000000
	blackCastles	dq	0x8100000000000000
	blackQueens 	dq 	0x800000000000000
	blacKing	dq	0x1000000000000000

section .code
aiMove:
	mov rax, [whitePawns]
	call calcMove
	ret

;-------------------------------
;Push lower and upper bitmap
;Push piece mov function
;-------------------------------
calcMove:		
	mov rcx, 0x1
loopPieces:
	push rax
	push rcx

	and rcx, rax
	mov rsi, rcx
	mov edi, printD
	mov eax, 0
	call printf

	pop rcx
	pop rax
	
	cmp rcx, 0x8000000000000000
	je endMovCalc

	shl rcx, 0x1
	jmp loopPieces
endMovCalc:
	ret
