global aiMove
extern	printf

section .data
	printD			db	"%016llx",10,0
	printHere		db	"Here",10,0




	blackBoard dq 0x0		;used to store black pieces when calc
	whiteBoard dq 0x0		;used to store white pieces when calc

					;bitboards for white
	whitePawns 	  dq 	0xff00
	whiteBishops 	dq	0x24
	whiteKnights 	dq 	0x42
	whiteCastles 	dq 	0x81
	whiteQueens 	dq 	0x8
	whiteKing 	  dq 	0x10

					;bitboards for black
	blackPawns  	dq 	0xff000000000000
	blackBishops 	dq 	0x2400000000000000
	blackKnights 	dq 	0x4200000000000000
	blackCastles	dq	0x8100000000000000
	blackQueens 	dq 	0x800000000000000
	blackKing	    dq	0x1000000000000000

section .bss
	resb 1024
section .text
aiMove:
	call fillWhiteBoard

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
	call pawnMove						;call the procedure for that piece

	mov rsi, [whitePawns]
	;mov rsi, rcx
	mov edi, printD
	mov eax, 0
	;call printf
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
	push rcx
	push rbx
	mov rcx, 6
	mov rbx, blackPawns					;start of black bitboards address
	xor rax, rax
loopfillBlackBoard:						;loop through the bitboards
	or rax, [rbx + rcx * 8]
	dec rcx
	cmp rcx, 0
	jne loopfillBlackBoard
	mov [blackBoard], rax
	pop rbx
	pop rcx
	pop rax
	ret

;-------------------------------
;Fill board with all white positions
;-------------------------------
fillWhiteBoard:								;same as fillBlackBoard but white
	push rax
	push rcx
	push rbx
	mov rcx, 6
	mov rbx, whitePawns
	xor rax, rax
loopfillWhiteBoard:
	or rax, [rbx + rcx * 8]
	dec rcx
	cmp rcx, 0
	jne loopfillWhiteBoard
	mov [whiteBoard], rax
	pop rbx
	pop rcx
	pop rax
	ret

;-------------------------------
;Pawn movement AI, send it pawn
;bitboard in rax and cx = 0 white
;-------------------------------
pawnMove:
	;cmp cx, 0		;if dd then white
	;jne blackPawn
whitePawn:
	shl rcx, 0x8		;check one move forward

	mov rsi, rcx
	mov edi, printD
	mov eax, 0
	call printf

	mov rax, [whiteBoard]
	not rax
	and rcx, rax
	cmp rcx, 0		;if not posible move
	je donePawnMove

	;mov edi, printHere
	;mov eax, 0
	;call printf

	xor [whitePawns], rcx		;make the pawnMove
	jmp donePawnMove
blackPawn:
	call fillBlackBoard
donePawnMove:
	ret						;end pawn move
