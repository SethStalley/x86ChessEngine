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

global pushGame
global popGame

section .data
	lastMovA	dq	moves	;last game push move address
section .bss
	moves		resq	8*12*67000	;store game states here
section .text
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
