global knightMoves

extern curPlayer
extern whiteKnights
extern blackKnights
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

extern knightTop, knightBottom, knightLeft, knightRight

extern printBitMap
extern print

section .data
    knights  dq  0       ;use this as a dynamic pointer
    fillBoard dq    0   ;use this for fillXBoard procedure
    board     dq    0   ;use this as filled board pointer
section .text
;Rules for knight movement
knightMoves:
    push rdx
    push rcx
    push rbx
    push rax

    xor rcx, rcx
    mov rax, 0x8000000000000000
    cmp qWord [curPlayer], 1;what player are we?
    jne blackKnight

    ;move white stuff to buffers
    mov rdx, whiteKnights
    mov [knights], rdx
    mov rdx, fillWhiteBoard
    mov [fillBoard], rdx
    mov rdx, whiteBoard
    mov [board], rdx
    jmp Knight
blackKnight:
    ;move black stuff to buffers
    mov rdx, blackKnights       ;save black knights address
    mov [knights], rdx          ;use knights as pointer
    mov rdx, fillBlackBoard
    mov [fillBoard], rdx
    mov rdx, blackBoard
    mov [board], rdx
Knight:
    mov rdx, qWord [knights]
    cmp rax,0x0		    ;if we checked all the bits
    je doneKnightMove	;check for all knights
    push rax

    push rax		    ;save bit being checked
    and rax, [rdx]		;same color piece here?
    cmp rax, 0
    pop rax
    je nextKnight		;else check next position

    ;get knights rdx points to
    push rax
    mov rax, [rdx]
    mov rdx, rax
    pop rax

    ;remove piece's original place in the board
    xor rdx, rax
    mov qWord [boardBuffer], rdx

    TopRight:              ;top move white
    ;check for the move
    push rax

    and rax, [rightEdge]    ;make sure we are not on right edge
    and rax, [knightTop]    ;make sure it is a knight safe distance
    cmp rax, 0
    je TopLeft        ;is a friendly piece already here?

    ;do the move
    shl rax, 17        ;two places forward
    ;valid move?
    call [fillBoard]
    push rax
    push rdx
    mov rdx, [board]  ;pass address to knight board
    and rax, [rdx]      ;acess data
    pop rdx
    cmp rax, 0          ;check if same color piece here
    pop rax
    jne TopLeft       ;is a friendly piece already here?

    ;if not friendly here, store move
    inc rcx			;if valid move inc move counter
    or rdx, rax
    ;store the move
    push rcx
    mov rcx, [knights]  ;push pointer to knigt bitmap
    push qWord [rcx]          ;push the bitmap
    ;apply move to the knight bitmap
    mov [rcx], rdx
    call removePiece	;remove black piece
    pop qWord [rcx]           ;get it back
    pop rcx
    mov rdx, [boardBuffer]

    ;check for a push left move
    TopLeft:
    pop rax
    push rax

    and rax, [leftEdge]    ;make sure we are not on right edge
    and rax, [knightTop]    ;make sure it is a knight safe distance
    cmp rax, 0
    je BottomLeft        ;is a friendly piece already here?

    ;do the move
    shl rax, 15        ;two places forward
    ;valid move?
    call [fillBoard]
    push rax
    push rdx
    mov rdx, [board]  ;pass address to knight board
    and rax, [rdx]      ;acess data
    pop rdx
    cmp rax, 0          ;check if same color piece here
    pop rax
    jne BottomLeft       ;is a friendly piece already here?

    ;if not friendly here, store move
    inc rcx			;if valid move inc move counter
    or rdx, rax
    ;store the move
    push rcx
    mov rcx, [knights]  ;push pointer to knigt bitmap
    push qWord [rcx]          ;push the bitmap
    ;apply move to the knight bitmap
    mov [rcx], rdx
    call removePiece	;remove black piece
    pop qWord [rcx]           ;get it back
    pop rcx
    mov rdx, [boardBuffer]


    ;check for a knight bottom LEFT move
    BottomLeft:
    pop rax
    push rax

    and rax, [leftEdge]    ;make sure we are not on right edge
    and rax, [knightBottom]    ;make sure it is a knight safe distance
    cmp rax, 0
    je BottomRight        ;is a friendly piece already here?

    ;do the move
    shr rax, 17        ;two places forward
    ;valid move?
    call [fillBoard]
    push rax
    push rdx
    mov rdx, [board]  ;pass address to knight board
    and rax, [rdx]      ;acess data
    pop rdx
    cmp rax, 0          ;check if same color piece here
    pop rax
    jne BottomRight       ;is a friendly piece already here?

    ;if not friendly here, store move
    inc rcx			;if valid move inc move counter
    or rdx, rax
    ;store the move
    push rcx
    mov rcx, [knights]  ;push pointer to knigt bitmap
    push qWord [rcx]          ;push the bitmap
    ;apply move to the knight bitmap
    mov [rcx], rdx
    call removePiece	;remove black piece
    pop qWord [rcx]           ;get it back
    pop rcx
    mov rdx, [boardBuffer]

    ;check for knight bottom rigth move
    BottomRight:
    pop rax
    push rax

    pop rax
    push rax

    and rax, [rightEdge]    ;make sure we are not on right edge
    and rax, [knightBottom]    ;make sure it is a knight safe distance
    cmp rax, 0
    je RightUp        ;is a friendly piece already here?

    ;do the move
    shr rax, 15        ;two places forward
    ;valid move?
    call [fillBoard]
    push rax
    push rdx
    mov rdx, [board]  ;pass address to knight board
    and rax, [rdx]      ;acess data
    pop rdx
    cmp rax, 0          ;check if same color piece here
    pop rax
    jne RightUp       ;is a friendly piece already here?

    ;if not friendly here, store move
    inc rcx			;if valid move inc move counter
    or rdx, rax
    ;store the move
    push rcx
    mov rcx, [knights]  ;push pointer to knigt bitmap
    push qWord [rcx]          ;push the bitmap
    ;apply move to the knight bitmap
    mov [rcx], rdx
    call removePiece	;remove black piece
    pop qWord [rcx]           ;get it back
    pop rcx
    mov rdx, [boardBuffer]


    ;check for a right up move
    RightUp:
    pop rax

    nextKnight:
        pop rax
    	shr rax, 1		;check next poss for pawn
    	jmp Knight		;loop



doneKnightMove:
    pop rax
    add rax, rcx		;return number of pawn moves
    pop rbx
    pop rcx
    pop rdx
    ret
