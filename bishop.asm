global bishopMoves

extern rightEdge
extern fillWhiteBoard
extern whitePawns
extern removePiece
extern whiteBishops
extern curPlayer
extern boardBuffer
extern whiteBoard

bishopMoves:
	push rcx
	push rbx
	push rax
	xor rcx, rcx
	mov rax, 0x8000000000000000
	cmp qWord [curPlayer], 1	;which player are we
	jne blackBishop
whiteBishop:
	;loop for every bit bishop map
	mov rdx, [whiteBishops]
	cmp rax, 0x0
	je doneBishopMoves
	push rax			;save bit bein checked
	and rax, rdx			;if there is a bishop
	cmp rax, 0
	je nextWBishop
	mov qWord [boardBuffer], rax
	;check right diagonal foward
	rightDiagonalFoward:
	and rax, qWord [rightEdge]	;if it's on right edge
	cmp rax, 0			;can't move then
	jne leftDiagonalFoward
	;check for right diagonal mov
	mov rax, qWord [boardBuffer]
	mov rdx, [whiteBishops]
	not rax
	and rdx, rax			;remove current bishop
	not rax				;get piece back
	shl rax, 9			;attack
	call fillWhiteBoard
	not qWord [whiteBoard]
	and rax, qWord [whiteBoard]
	cmp rax, 0			;if 0 invalid move
	je leftDiagonalFoward		;check other dir
	;valid move, store it
	inc rcx
	or rdx, rax
	push qWord [whiteBishops]
	mov [whiteBishops], rdx
	call removePiece		;if captured oposite
	pop qWord [whiteBishops]
	
	;check left diagonal foward
	leftDiagonalFoward:

nextWBishop:
	pop rax
	shr rax, 1			;check next bit place
	jmp whiteBishop			;loop
blackBishop:
doneBishopMoves:
	pop rax
	add rax, rcx
	pop rbx
	pop rcx
	ret
