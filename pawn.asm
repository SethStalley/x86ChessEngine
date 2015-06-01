global pawnMoves

extern curPlayer
extern whitePawns
extern blackPawns
extern boardBuffer

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

extern firstWhitePawnRow, fistBlackPawnRow

extern print

;--------------------------------
;Pawn movement AI
; [curPlayer] = 1 white	player
; [curPlayer] = -1 black player
;--------------------------------
pawnMoves:
	push rcx
	push rbx
	push rax
	xor rcx, rcx
	mov rax, 0x8000000000000000
	cmp qWord [curPlayer], 1;what player are we?
	jne blackPawn
whitePawn:			;moves for white pawn
	mov rdx, qWord [whitePawns]
	cmp rax,0x0		;if we check all the bits
	je donePawnMove		;check for all pawns
	push rax		;save bit being checked
	and rax, rdx		;if there is a pawn there
	and rax, qWord [topEdge] ;and it is not at top
	cmp rax, 0
	je nextWPawn		;check next poss for pawn

	mov qWord [boardBuffer], rax

	not rax			;not our move
	and rdx, rax		;remove current pawn position
	not rax			;get move back
	shl rax, 0x8		;move pawn one foward
	call fillWhiteBoard
	not qWord [whiteBoard]
	and rax, qWord [whiteBoard]	;if W piece here we can't move there
	call fillBlackBoard
	not qWord [blackBoard]	;if black piece here can't move either
	and rax, qWord [blackBoard]
	cmp rax, 0
	je pRAttack
	;store move
	inc rcx			;pawn move is valid inc move counter
	or rdx, rax		;apply the move to the pawn's bitmap
	push qWord [whitePawns] ;save the current pawns
	mov [whitePawns], rdx	;make the pawnMove
	call pushGame		;save the game move for the ai
	pop qWord [whitePawns]  ;restore them to check other pawn
pRAttack:;right push attack
	;load move back up
	mov rax, qWord [boardBuffer]	;get original piece to move back
	;check if piece is on the edge
	and rax, qWord [rightEdge]
	cmp rax, 0
	je pLAttack			;on right edge can only attack left

	;check for right diagonal attack
	mov rax, qWord [boardBuffer]
	mov rdx, [whitePawns]
	not rax
	and rdx, rax		;remove current pawn's position
	not rax

	shl rax, 9		;right attack
	call fillWhiteBoard
	not qWord [whiteBoard]
	and rax, qWord [whiteBoard]
	call fillBlackBoard
	and rax, qWord [blackBoard]
	cmp rax, 0		;if white piece here can't move
	je pLAttack
	;store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	push qWord [whitePawns]
	mov [whitePawns], rdx
	call removePiece	;remove black piece & pushes game
	pop qWord [whitePawns]
pLAttack:;left push attack
	;load move back up
	mov rax, qWord [boardBuffer]	;get original piece to move back
	;check if piece is on the edge
	and rax, qWord [leftEdge]
	cmp rax, 0
	je pDoblePush			;on right edge can only attack left

	;check for right diagonal attack
	mov rax, qWord [boardBuffer]
	mov rdx, [whitePawns]
	not rax
	and rdx, rax		;remove current pawn's position
	not rax

	shl rax, 7		;right attack
	call fillWhiteBoard
	call fillBlackBoard
	not qWord [whiteBoard]
	and rax, qWord [whiteBoard]
	and rax, qWord [blackBoard]
	cmp rax, 0		;if white piece here can't move
	je pDoblePush
	;store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	push qWord [whitePawns]
	mov [whitePawns], rdx
	call removePiece	;remove black piece
	pop qWord [whitePawns]

pDoblePush:
    mov rax, qWord [boardBuffer]	;get original piece to move back
    ;check if piece is on the initial row
    and rax, qWord [firstWhitePawnRow]
    cmp rax, 0
    je nextWPawn			;on right edge can only attack left

    mov rdx, qWord [whitePawns]
    not rax
    and rdx, rax		;remove current pawn's position
    not rax

    shl rax, 8  		;doble push foward
    call fillWhiteBoard
    call fillBlackBoard
    not qWord [blackBoard]
    not qWord [whiteBoard]
    and rax, qWord [blackBoard]
    and rax, qWord [whiteBoard]
    shl rax, 8		;doble push foward
    and rax, qWord [blackBoard]
    and rax, qWord [whiteBoard]
    cmp rax, 0		;if black piece here can't move
    je nextWPawn
    ;store move
    inc rcx			;if valid move inc move counter
    or rdx, rax
    push qWord [whitePawns]
    mov [whitePawns], rdx
    call pushGame	;remove black piece
    pop qWord [whitePawns]

nextWPawn:
	pop rax
	shr rax, 1		;check next poss for pawn
	jmp whitePawn		;loop

blackPawn:			;same but for each Black pawn
	mov rdx, qWord [blackPawns]
	cmp rax, 0x0		;if we check all the bits
	je donePawnMove		;check for all pawns
	push rax		;save bit being checked
	and rax, rdx		;if there is a pawn there
	and rax, qWord [bottomEdge]
	cmp rax, 0
	je nextBPawn		;check next poss for pawn

	mov qWord [boardBuffer], rax

	not rax			;not our move
	and rdx, rax		;remove current pawn position
	not rax			;get move back
	shr rax, 0x8		;move pawn one foward

	call fillBlackBoard
	call fillWhiteBoard
	not qWord [blackBoard]
	and rax, qWord [blackBoard]	;if piece here we can't move there
	not qWord [whiteBoard]
	and rax, qWord [whiteBoard]
	cmp rax, 0
	je pbRAttack

	inc rcx			;pawn move is valid inc move counter
	or rdx, rax		;apply the move to the pawn's bitmap
	push qWord [blackPawns] ;save the current pawns
	not qWord [blackBoard]
	mov [blackPawns], rdx	;make the pawnMove
	call pushGame		;save the game move for the ai
	pop qWord [blackPawns]  ;restore them to check other pawn

pbRAttack:;right push attack
	;load move back up
	mov rax, qWord [boardBuffer]	;get original piece to move back
	;check if piece is on the edge
	and rax, qWord [leftEdge]
	cmp rax, 0
	je pbLAttack			;on right edge can only attack left

	;check for right diagonal attack
	mov rdx, [blackPawns]
	not rax
	and rdx, rax		;remove current pawn's position
	not rax

	shr rax, 9		;right attack
	call fillWhiteBoard
	call fillBlackBoard
	not qWord [blackBoard]
	and rax, qWord [blackBoard]
	and rax, qWord [whiteBoard]
	cmp rax, 0		;if black piece here can't move
	je pbLAttack
	;store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	push qWord [blackPawns]
	mov [blackPawns], rdx
	call removePiece	;remove white piece
	pop qWord [blackPawns]
pbLAttack:;left push attack
	;load move back up
	mov rax, qWord [boardBuffer]	;get original piece to move back
	;check if piece is on the edge
	and rax, qWord [rightEdge]
	cmp rax, 0
	je pbDoblePush			;on right edge can only attack left

	;check for right diagonal attack
	mov rdx, qWord [blackPawns]
	not rax
	and rdx, rax		;remove current pawn's position
	not rax

	shr rax, 7		;left attack
	call fillWhiteBoard
	call fillBlackBoard
	not qWord [blackBoard]
	and rax, qWord [blackBoard]
	and rax, qWord [whiteBoard]
	cmp rax, 0		;if black piece here can't move
	je pbDoblePush
	;store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	push qWord [blackPawns]
	mov [blackPawns], rdx
	call removePiece	;remove black piece
	pop qWord [blackPawns]

pbDoblePush:
    mov rax, qWord [boardBuffer]	;get original piece to move back
    ;check if piece is on the initial row
    and rax, qWord [fistBlackPawnRow]
    cmp rax, 0
    je nextBPawn			;on right edge can only attack left

    mov rdx, qWord [blackPawns]
    not rax
    and rdx, rax		;remove current pawn's position
    not rax

    shr rax, 8		;doble push foward
    call fillWhiteBoard
    call fillBlackBoard
    not qWord [blackBoard]
    not qWord [whiteBoard]
    and rax, qWord [blackBoard]
    and rax, qWord [whiteBoard]
    shr rax, 8		;doble push foward
    and rax, qWord [blackBoard]
    and rax, qWord [whiteBoard]
    cmp rax, 0		;if black piece here can't move
    je nextBPawn
    ;store move
    inc rcx			;if valid move inc move counter
    or rdx, rax
    push qWord [blackPawns]
    mov [blackPawns], rdx
    call pushGame	;remove black piece
    pop qWord [blackPawns]

nextBPawn:
	pop rax
	shr rax, 1		;check next poss for pawn
	jmp blackPawn		;loop
donePawnMove:
	pop rax
	add rax, rcx		;return number of pawn moves
	pop rbx
	pop rcx
	ret			;end pawn move
