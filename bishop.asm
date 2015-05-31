global bishopMoves

extern rightEdge
extern leftEdge
extern topEdge
extern bottomEdge

extern fillWhiteBoard
extern fillBlackBoard
extern whitePawns
extern removePiece
extern pieceDie
extern whiteBishops
extern curPlayer
extern boardBuffer
extern whiteBoard
extern blackBoard

extern print
extern printBitMap

section .text
bishopMoves:
	push rcx
	push rbx
	push rax
	xor rcx, rcx
	mov rax, 0x8000000000000000
	cmp qWord [curPlayer], 1	;which player are we
	jne blackBishop
whiteBishop:
	xor rbx, rbx
	jmp Bishop
blackBishop:
	mov rbx, 48			;displace to black bishop bitboard
Bishop:
	;loop for every bit bishop map
	mov rdx, qWord [whiteBishops + rbx]
	cmp rax, 0x0
	je doneBishopMoves
	push rax			;save bit being checked
	and rax, rdx			;if there is a bishop
	cmp rax, 0
	je nextBishop
	mov qWord [boardBuffer], rax

	;check right diagonal foward
	rightDiagonalFoward:
	and rax, qWord [rightEdge]	;if it's on right edge
	and rax, qWord [topEdge]
	cmp rax, 0			;can't move then
	je leftDiagonalFoward
	;check for right diagonal mov
	mov rdx, [whiteBishops + rbx]
	not qWord [boardBuffer]		;not piece place
	and rdx, qWord [boardBuffer]	;remove current bishop
	not qWord [boardBuffer]		;get piece back
	shl rax, 9
	cmp qWord [curPlayer], 1
	jne blackCheck1
	call whitePieceCheck	;check if white piece there
	jmp whiteCheck1
	blackCheck1:
	call blackPieceCheck
	whiteCheck1:
	cmp rax, 0			;if 0 invalid move
	je leftDiagonalFoward		;check other dir
	;valid move, store it
	inc rcx
	or rdx, rax
	push qWord [whiteBishops + rbx]
	mov [whiteBishops + rbx], rdx
	call removePiece		;if captured oposite
	pop qWord [whiteBishops + rbx]
	cmp qWord [pieceDie], 1
	;je leftDiagonalFoward
	jmp rightDiagonalFoward		;slide all the way

	;check left diagonal foward
	leftDiagonalFoward:
	mov rax, qWord [boardBuffer]
lDFowardLoop:
	and rax, qWord [leftEdge]	;if it's on LEFT edge
	and rax, qWord [topEdge]
	cmp rax, 0			;can't move then
	je rightDiagonalBackward
	;check for right diagonal mov
	mov rdx, [whiteBishops + rbx]
	not qWord [boardBuffer]	;not piece place
	and rdx, qWord [boardBuffer]	;remove current bishop
	not qWord [boardBuffer]					;get piece back
	shl rax, 7			;attack
	cmp qWord [curPlayer], 1
	jne blackCheck2
	call whitePieceCheck					;check if white piece there
	jmp whiteCheck2
	blackCheck2:
	call blackPieceCheck
	whiteCheck2:
	cmp rax, 0			;if 0 invalid move
	je rightDiagonalBackward		;check other dir
	;valid move, store it
	inc rcx
	or rdx, rax
	push qWord [whiteBishops + rbx]
	mov [whiteBishops + rbx], rdx
	call removePiece		;if captured oposite
	pop qWord [whiteBishops + rbx]
	cmp qWord [pieceDie], 1
	;je leftDiagonalBackward
	jmp lDFowardLoop


	rightDiagonalBackward:
	mov rax, qWord [boardBuffer]
rDBackLoop:
	and rax, qWord [leftEdge]	;if it's on LEFT edge
	and rax, qWord [bottomEdge]
	cmp rax, 0			;can't move then
	je leftDiagonalBackward
	;check for right diagonal mov
	mov rdx, [whiteBishops + rbx]
	not qWord [boardBuffer]	;not piece place
	and rdx, qWord [boardBuffer]			;remove current bishop
	not qWord [boardBuffer]					;get piece back
	shr rax, 9			;attack
	cmp qWord [curPlayer], 1
	jne blackCheck3
	call whitePieceCheck					;check if white piece there
	jmp whiteCheck3
	blackCheck3:
	call blackPieceCheck
	whiteCheck3:
	cmp rax, 0			;if 0 invalid move
	je leftDiagonalBackward 		;check other dir
	;valid move, store it
	inc rcx
	or rdx, rax
	push qWord [whiteBishops + rbx]
	mov [whiteBishops + rbx], rdx
	call removePiece		;if captured oposite
	pop qWord [whiteBishops + rbx]
	cmp qWord [pieceDie], 1
	;je leftDiagonalBackward
	jmp rDBackLoop			;slide all the way

	leftDiagonalBackward:
	mov rax, qWord [boardBuffer]
lDBackLoop:
	and rax, qWord [rightEdge]	;if it's on RIGHT edge
	and rax, qWord [bottomEdge]
	cmp rax, 0			;can't move then
	je nextBishop
	;check for right diagonal mov
	mov rdx, [whiteBishops + rbx]
	not qWord [boardBuffer]	;not piece place
	and rdx, qWord [boardBuffer]			;remove current bishop
	not qWord [boardBuffer]					;get piece back
	shr rax, 7			;attack
	cmp qWord [curPlayer], 1
	jne blackCheck4
	call whitePieceCheck					;check if white piece there
	jmp whiteCheck4
	blackCheck4:
	call blackPieceCheck
	whiteCheck4:
	cmp rax, 0			;if 0 invalid move
	je nextBishop		;check other dir
	;valid move, store it
	inc rcx
	or rdx, rax
	push qWord [whiteBishops + rbx]
	mov [whiteBishops + rbx], rdx
	call removePiece		;if captured oposite
	pop qWord [whiteBishops + rbx]
	cmp qWord [pieceDie], 1
	;je nextBishop
	jmp lDBackLoop

nextBishop:
	pop rax
	shr rax, 1			;check next bit place
	jmp Bishop			;loop
doneBishopMoves:
	pop rax
	add rax, rcx
	pop rbx
	pop rcx
	ret

;check if white or black piece his already at moving position
whitePieceCheck:
	call fillWhiteBoard
	not qWord [whiteBoard]
	and rax, qWord [whiteBoard]
	ret

blackPieceCheck:
	call fillBlackBoard
	not qWord [blackBoard]
	and rax, qWord [blackBoard]
	ret
