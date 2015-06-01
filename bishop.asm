global bishopMoves

extern curPlayer
extern boardBuffer
extern pieceDie

extern fillWhiteBoard
extern fillBlackBoard
extern whiteBoard
extern blackBoard
extern pushGame
extern removePiece

extern topEdge
extern bottomEdge
extern rightEdge
extern leftEdge

extern printBitMap
extern print

section .data
    piece  dq  0       ;use this as a dynamic pointer
    fillBoard dq    0   ;use this for fillXBoard procedure
    board     dq    0   ;use this as filled board pointer

section .text
;Rules for castle movement
bishopMoves:
    push rdx
    push rcx
    push rbx
    push rax

    ;get pushed piece board
    mov rdx, [rsp+8*5]
    mov qWord [piece], rdx  ;store it's bitmap

    xor rcx, rcx
    mov rax, 0x8000000000000000
    cmp qWord [curPlayer], 1;what player are we?
    jne blackBishop

    ;move white stuff to buffers
    ;mov rdx, whiteCastles
    ;mov [piece], rdx
    mov rdx, fillWhiteBoard
    mov [fillBoard], rdx
    mov rdx, whiteBoard
    mov [board], rdx
    jmp Bishop
	blackBishop:
    ;move black stuff to buffers
    mov rdx, [piece]       ;save white piece address
    add rdx, 8*6         ;get black variant of piece
    mov [piece], rdx   ;use save as pointer to the black one
    mov rdx, fillBlackBoard
    mov [fillBoard], rdx
    mov rdx, blackBoard
    mov [board], rdx

Bishop:
    mov rdx, qWord [piece]

    cmp rax,0x0		    ;if we checked all the bits
    je doneBishopMove	;check for all knights
    push rax

    push rax		    ;save bit being checked
    and rax, [rdx]		;same color piece here?
    cmp rax, 0
    pop rax
    je nextBishop		;else check next position

    ;get castles rdx points to
    push rax
    mov rax, [rdx]
    mov rdx, rax
    pop rax

    ;remove piece's original place in the board
    xor rdx, rax
    mov qWord [boardBuffer], rdx

    topRight:              ;top right move
    ;check for the move
    push rax
tRightLoop:
	and rax, [topEdge]    ;make sure it is not on top edge
	and rax, [rightEdge]
	cmp rax, 0
	je topLeft        ;is a friendly piece already here?

	;do the move
	shl rax, 9        ;one place forward
	;valid move?
	call [fillBoard]
	push rax
	push rdx
	mov rdx, [board]  ;pass address to knight board
	and rax, [rdx]      ;acess data
	pop rdx
	cmp rax, 0          ;check if same color piece here
	pop rax
	jne topLeft       ;is a friendly piece already here?

	;if not friendly here, store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	;store the move
	push rcx
	mov rcx, [piece]  ;push pointer to piece bitmap
	push qWord [rcx]          ;push the bitmap
	;apply move to the knight bitmap
	mov [rcx], rdx
	call removePiece	;remove black piece
	pop qWord [rcx]           ;get it back
	pop rcx
	mov rdx, qWord [boardBuffer]
	cmp qWord [pieceDie], 1
	je topLeft
	;if we made it here try farther
	jmp tRightLoop

	;try move top left
	topLeft:
	pop rax
	push rax
tLeftLoop:
	and rax, [topEdge]    ;make sure it is not on top edge
	and rax, [leftEdge]
	cmp rax, 0
	je botLeft        ;is a friendly piece already here?

	;do the move
	shl rax, 7        ;one place forward
	;valid move?
	call [fillBoard]
	push rax
	push rdx
	mov rdx, [board]  ;pass address to knight board
	and rax, [rdx]      ;acess data
	pop rdx
	cmp rax, 0          ;check if same color piece here
	pop rax
	jne botLeft       ;is a friendly piece already here?

	;if not friendly here, store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	;store the move
	push rcx
	mov rcx, [piece]  ;push pointer to piece bitmap
	push qWord [rcx]          ;push the bitmap
	;apply move to the knight bitmap
	mov [rcx], rdx
	call removePiece	;remove black piece
	pop qWord [rcx]           ;get it back
	pop rcx
	mov rdx, qWord [boardBuffer]
	cmp qWord [pieceDie], 1
	je botLeft
	;if we made it here try farther
	jmp tLeftLoop

	botLeft:
	pop rax
	push rax
bLeftLoop:
	and rax, [bottomEdge]    ;make sure it is not on top edge
	and rax, [leftEdge]
	cmp rax, 0
	je botRight        ;is a friendly piece already here?

	;do the move
	shr rax, 9        ;one place forward
	;valid move?
	call [fillBoard]
	push rax
	push rdx
	mov rdx, [board]  ;pass address to knight board
	and rax, [rdx]      ;acess data
	pop rdx
	cmp rax, 0          ;check if same color piece here
	pop rax
	jne botRight       ;is a friendly piece already here?

	;if not friendly here, store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	;store the move
	push rcx
	mov rcx, [piece]  ;push pointer to piece bitmap
	push qWord [rcx]          ;push the bitmap
	;apply move to the knight bitmap
	mov [rcx], rdx
	call removePiece	;remove black piece
	pop qWord [rcx]           ;get it back
	pop rcx
	mov rdx, qWord [boardBuffer]
	cmp qWord [pieceDie], 1
	je botRight
	;if we made it here try farther
	jmp bLeftLoop


	botRight:
	pop rax
bRightLoop:
	and rax, [bottomEdge]    ;make sure it is not on top edge
	and rax, [rightEdge]
	cmp rax, 0
	je nextBishop        ;is a friendly piece already here?

	;do the move
	shr rax, 7        ;one place forward
	;valid move?
	call [fillBoard]
	push rax
	push rdx
	mov rdx, [board]  ;pass address to knight board
	and rax, [rdx]      ;acess data
	pop rdx
	cmp rax, 0          ;check if same color piece here
	pop rax
	jne nextBishop       ;is a friendly piece already here?

	;if not friendly here, store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	;store the move
	push rcx
	mov rcx, [piece]  ;push pointer to piece bitmap
	push qWord [rcx]          ;push the bitmap
	;apply move to the knight bitmap
	mov [rcx], rdx
	call removePiece	;remove black piece
	pop qWord [rcx]           ;get it back
	pop rcx
	mov rdx, qWord [boardBuffer]
	cmp qWord [pieceDie], 1
	je nextBishop
	;if we made it here try farther
	jmp bRightLoop

nextBishop:
	pop rax
	shr rax, 1		;check next poss for pawn
	jmp Bishop		;loop


doneBishopMove:
	pop rax
	add rax, rcx		;return number of pawn moves
	pop rbx
	pop rcx
	pop rdx
	ret
