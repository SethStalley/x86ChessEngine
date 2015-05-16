global aiMove
extern	printf

section .data
	printD			db	"%016llx",10,0

	blackBoard dd 0x0		;used to store black pieces when calc
	whiteBoard dd 0x0		;used to store white pieces when calc

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
	blackKing	dq	0x1000000000000000

section .bss
	resb 1024
section .code
aiMove:
	mov rax, [blackCastles]
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

	xor cx, cx
	mov rax, [whitePawns]
	call pawnMove

	mov rsi, [whitePawns]
	mov edi, printD
	mov eax, 0
	call printf

	
	pop rcx
	pop rax

	shl rcx, 0x1
	cmp rcx, 0x8000000000000000
	jne loopPieces
endMovCalc:
	ret

;-------------------------------
;Fill board with all black positions
;-------------------------------
fillBlackBoard:
	push rax
	xor rax, rax
	or rax, [blackPawns]
	or rax, [blackBishops]
	or rax, [blackKnights]
	or rax, [blackCastles]
	or rax, [blackQueens]
	or rax, [blackKing]
	mov [blackBoard], rax
	pop rax
	ret
;-------------------------------
;Fill board with all white positions
;-------------------------------
fillWhiteBoard:
	push rax
	xor rax, rax
	or rax, [whitePawns]
	or rax, [whiteBishops]
	or rax, [whiteKnights]
	or rax, [whiteCastles]
	or rax, [whiteQueens]
	or rax, [whiteKing]
	mov [whiteBoard], rax
	pop rax
	ret

;-------------------------------
;Pawn movement AI, send it pawn 
;bitboard in rax and cx = 0 white
;-------------------------------
pawnMove:
	cmp cx, 0		;if dd then white
	jne blackPawn
whitePawn:
	call fillWhiteBoard
	
	push rax
	add rax, 8		;check one move forward

	mov rcx, [whiteBoard]
	not rcx
	and rax, rcx
	cmp rax, 0		;if not posible move
	je donePawnMove
	
	xor [whitePawns], rax
	jmp donePawnMove
blackPawn:
	call fillBlackBoard
donePawnMove:
	pop rax
>>>>>>> 5d3d20981592348d6b2b2a9484aaea648e78b83f
	ret
