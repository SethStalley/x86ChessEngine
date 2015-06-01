global castleMoves

extern curPlayer
extern whiteCastles
extern blackCastles
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

extern kingMove

extern printBitMap
extern print

section .data
    piece  dq  0       ;use this as a dynamic pointer
    fillBoard dq    0   ;use this for fillXBoard procedure
    board     dq    0   ;use this as filled board pointer

section .text
;Rules for castle movement
castleMoves:
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
    jne blackCastle

    ;move white stuff to buffers
    ;mov rdx, whiteCastles
    ;mov [piece], rdx
    mov rdx, fillWhiteBoard
    mov [fillBoard], rdx
    mov rdx, whiteBoard
    mov [board], rdx
    jmp Castle
    blackCastle:
    ;move black stuff to buffers
    mov rdx, [piece]       ;save white piece address
    add rdx, 8*6         ;get black variant of piece
    mov [piece], rdx   ;use save as pointer to the black one
    mov rdx, fillBlackBoard
    mov [fillBoard], rdx
    mov rdx, blackBoard
    mov [board], rdx

Castle:
    mov rdx, qWord [piece]

    cmp rax,0x0		    ;if we checked all the bits
    je doneCastleMove	;check for all knights
    push rax

    push rax		    ;save bit being checked
    and rax, [rdx]		;same color piece here?
    cmp rax, 0
    pop rax
    je nextCastle		;else check next position

    ;get castles rdx points to
    push rax
    mov rax, [rdx]
    mov rdx, rax
    pop rax

    ;remove piece's original place in the board
    xor rdx, rax
    mov qWord [boardBuffer], rdx

    Top:              ;top move
    ;check for the move
    push rax
topLoop:
    and rax, [topEdge]    ;make sure it is not on top edge
    cmp rax, 0
    je Down        ;is a friendly piece already here?

    ;do the move
    shl rax, 8        ;one place forward
    ;valid move?
    call [fillBoard]
    push rax
    push rdx
    mov rdx, [board]  ;pass address to piece's board
    and rax, [rdx]      ;acess data
    pop rdx
    cmp rax, 0          ;check if same color piece here
    pop rax
    jne Down       ;is a friendly piece already here?

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
    je Down
    ;if we made it here try farther
    jmp topLoop


    Down:
    pop rax
    push rax
downLoop:
    and rax, [bottomEdge]    ;make sure it is not on top edge
    cmp rax, 0
    je Right        ;is a friendly piece already here?

    ;do the move
    shr rax, 8        ;one place forward
    ;valid move?
    call [fillBoard]
    push rax
    push rdx
    mov rdx, [board]  ;pass address to knight board
    and rax, [rdx]      ;acess data
    pop rdx
    cmp rax, 0          ;check if same color piece here
    pop rax
    jne Right       ;is a friendly piece already here?

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
    je Right
    ;if we made it here try farther
    jmp downLoop

    Right:
    pop rax
    push rax
rightLoop:
    and rax, [rightEdge]    ;make sure it is not on top edge
    cmp rax, 0
    je Left        ;is a friendly piece already here?

    ;do the move
    shl rax, 1        ;one place forward
    ;valid move?
    call [fillBoard]
    push rax
    push rdx
    mov rdx, [board]  ;pass address to knight board
    and rax, [rdx]      ;acess data
    pop rdx
    cmp rax, 0          ;check if same color piece here
    pop rax
    jne Left       ;is a friendly piece already here?

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
    je Left
    ;if we made it here try farther
    jmp rightLoop

    Left:
    pop rax
leftLoop:
    and rax, [leftEdge]    ;make sure it is not on top edge
    cmp rax, 0
    je nextCastle        ;is a friendly piece already here?

    ;do the move
    shr rax, 1        ;one place forward
    ;valid move?
    call [fillBoard]
    push rax
    push rdx
    mov rdx, [board]  ;pass address to knight board
    and rax, [rdx]      ;acess data
    pop rdx
    cmp rax, 0          ;check if same color piece here
    pop rax
    jne nextCastle       ;is a friendly piece already here?

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
    je nextCastle
    ;if we made it here try farther
    jmp leftLoop

    nextCastle:
        pop rax
        shr rax, 1		;check next poss for pawn
        jmp Castle		;loop


doneCastleMove:
    pop rax
    add rax, rcx		;return number of pawn moves
    pop rbx
    pop rcx
    pop rdx
    ret
