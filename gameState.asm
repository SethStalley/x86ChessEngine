extern whitePawns
extern whiteBishops
extern whiteKnights
extern whiteCastles
extern whiteQueens
extern whiteKing
extern blackPawns
extern blackBishops
extern blackKnights
extern blackCastles
extern blackQueens
extern blackKing
extern curPlayer

global pushGame
global popGame
global pushWinningMove
global popWinningMove

section .data
	lastMovA	dq	moves	;last game push move address
section .bss
	moves		resq	8*12*2000000	;store game states here
	winningMove	resq	8*12 	;ai's move
section .text

;-------------------------------
;We should save that winning move
;changes every time NegaMax finds
;a better move in it's root loop
;-------------------------------
pushWinningMove:
	push rax
	push rdx
	mov rdx, winningMove
	mov rax, [whitePawns]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteBishops]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteKnights]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteCastles]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteQueens]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteKing]
	mov [rdx], rax
	add rdx, 8

	mov rax, [blackPawns]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackBishops]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackKnights]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackCastles]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackQueens]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackKing]
	mov [rdx], rax
	pop rdx
	pop rax
	ret

;-------------------------------
;Get the move
;-------------------------------
popWinningMove:
	push rax
	push rdx
	mov rdx, winningMove
	mov rax, [rdx]
	mov [whitePawns], rax
	add rdx, 8
	mov rax, [rdx]
	mov [whiteBishops], rax
	add rdx, 8
	mov rax, [rdx]
	mov [whiteKnights], rax
	add rdx, 8
	mov rax, [rdx]
	mov [whiteCastles], rax
	add rdx, 8
	mov rax, [rdx]
	mov [whiteQueens], rax
	add rdx, 8
	mov rax, [rdx]
	mov [whiteKing], rax
	add rdx, 8
	mov rax, [rdx]

	mov [blackPawns], rax
	add rdx, 8
	mov rax, [rdx]
	mov [blackBishops], rax
	add rdx, 8
	mov rax, [rdx]
	mov [blackKnights], rax
	add rdx, 8
	mov rax, [rdx]
	mov [blackCastles], rax
	add rdx, 8
	mov rax, [rdx]
	mov [blackQueens], rax
	add rdx, 8
	mov rax, [rdx]
	mov [blackKing], rax
	pop rdx
	pop rax
	ret


;-------------------------------
;Push all bitboard into stack
;Negamax uses this to save game state
;as it checks all moves
;For every push we need to do a pop
;-------------------------------
pushGame:			;push all bitboards down into mov array
	push rax
	push rdx
	mov rdx, [lastMovA]
	mov rax, [whitePawns]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteBishops]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteKnights]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteCastles]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteQueens]
	mov [rdx], rax
	add rdx, 8
	mov rax, [whiteKing]
	mov [rdx], rax
	add rdx, 8

	mov rax, [blackPawns]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackBishops]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackKnights]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackCastles]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackQueens]
	mov [rdx], rax
	add rdx, 8
	mov rax, [blackKing]
	mov [rdx], rax
	add rdx, 8
	mov [lastMovA], rdx
	pop rdx
	pop rax
	ret

;-------------------------------
;Pop back all bitboards from stack
;-------------------------------
popGame:
	push rax
	push rdx
	mov rdx, [lastMovA]
	sub rdx, 8
	mov rax, [rdx]
	mov [blackKing], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [blackQueens], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [blackCastles], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [blackKnights], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [blackBishops], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [blackPawns], rax

	sub rdx, 8
	mov rax, [rdx]
	mov [whiteKing], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [whiteQueens], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [whiteCastles], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [whiteKnights], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [whiteBishops], rax
	sub rdx, 8
	mov rax, [rdx]
	mov [whitePawns], rax
	mov [lastMovA], rdx
	pop rdx
	pop rax
	ret

;-------------------------------
;push oposite color to curPlayer
;used for piece capturing
;-------------------------------
pushOposite:
	push rax
	push rdx
	push rbx
	mov rdx, [curPlayer]
	cmp rdx, 1
	je pushWhite
	mov rbx, blackPawns
	jmp pushThatSide
pushWhite:
	mov rbx, whitePawns
pushThatSide:
	mov rdx, [lastMovA]
	mov rax, [rbx]
	mov [rdx], rax
	add rbx, 8
	mov rax, [rbx]
	mov [rdx], rax
	add rbx, 8
	mov rax, [rbx]
	mov [rdx], rax
	add rbx, 8
	mov rax, [rbx]
	mov [rdx], rax
	add rbx, 8
	mov rax, [rbx]
	mov [rdx], rax
	add rbx, 8
	mov rax, [rbx]
	mov [rdx], rax
	pop rbx
	pop rdx
	pop rax
	ret
