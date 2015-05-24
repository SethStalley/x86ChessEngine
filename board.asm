global aiMove
extern	printf

section .data
	printH		db	"%016llx",10,0	;print in hex 64bit
	printD		db	"%d",10,0	;print normal decimal
	printHere	db	"Here",10,0	;test msg

	aiDepth		db	2	;depth for negaMax tree
	aiPlayer	db 	1	;if ai is black/white default black

	curDepth	db 	0	;used by negaMax during loop
	curPlayer	db 	0
	curScore	dw 	0	;used by negamax for score keepin

	blackBoard 	dq 	0x0	;used to store black pieces when calc
	whiteBoard 	dq 	0x0	;used to store white pieces when calc

					;bitboards for white
	whitePawns 	dq 	0xff00
	whiteBishops 	dq	0x24
	whiteKnights 	dq 	0x42
	whiteCastles 	dq 	0x81
	whiteQueens 	dq 	0x8
	whiteKing 	dq 	0x10

							;bitboards for black
	blackPawns  	dq 	0xff000000000000
	blackBishops 	dq 	0x2400000000000000
	blackKnights 	dq 	0x4200000000000000
	blackCastles	dq	0x8100000000000000
	blackQueens 	dq 	0x800000000000000
	blackKing    	dq	0x1000000000000000

section .bss
	resb 1024
section .text
aiMove:
	;set depth and player
	mov cl, [aiDepth]
	mov ch, [aiPlayer]
	mov [curPlayer], ch
	mov [curDepth], cl
	call ai
	ret

print:			;print rax for testing
	push rsi
	push rdi
	mov rsi,rax
	mov edi, printD
	call printf
	pop rdi
	pop rsi
	ret
	

;--------------------------------------
;NegaMax Procedure
;This is the backbone of our AI
;analyzes all best moves to "AIdepth"
;for each player choces best for itself
;---------
;Expects depth in cl
;--------------------------------------
;Upper negaMax gets score for every current move on one side
ai:
	xor rax, rax	;what piece's move we are on
	xor rcx, rcx	;hold higest move score
	call getMoves	;does moves and gets # of them - in stack
	;call print
loopAI:
	call pushGame	;save current game state
	sub rsp, 8*12	
	sub rsp, 8*12	;align sp to top of move to pop
	call popGame	;pop the game to that move from getMoves
	push rax
	call depthNega	;get depth score for that move
	cmp rax, rcx
	jg continueLoopAI
	mov rcx, rax	;store greater score
continueLoopAI:
	pop rax
	add rsp, 8*12	;align sp to top of that move
	call popGame	;undo moves
	add rsp, 8*12
	dec rax		;dec loop
	cmp rax, 0	
	je doneAI
doneAI:
	ret

;search deep to find the best move
depthNega:
	cmp [curDepth], byte 0
	je doneNega	;reached bottom of our search tree
	dec byte [curDepth]	;dec tree search depth
	mov [curScore], word -300	;worse case score
	call getMoves	;check moves for all unique piece types on given side
allMoves:		;loop over all players posible moves
	push rax
	;do moves
	call pushGame	;save current game state
	sub rsp, 8*12	
	sub rsp, 8*12	
	call popGame	;pop the game to that move from getMoves
	;recurse
	push word [curScore]
	call depthNega	;recurse
	pop bx		;pop last max score
	add rsp, 8*12	;align sp to top of that move
	call popGame	;undo moves
	add rsp, 8*12
			;restore all bitboards
			;undo move
	imul bx, -1	;negate returned value from eval 
	cmp [curScore],bx	;is new score (rbx) higher?
	jng nextMove
swapMaxScore:
	mov [curScore], bx	;swap max with score
nextMove:
	pop rax
	dec rax
	cmp rax, 0
	jne allMoves
doneNega:
	call eval	;get an evaluation
	ret		;done


;-------------------------------
;Push all bitboard into stack
;Negamax uses this to save game state
;as it checks all moves
;For every push we need to do a pop
;-------------------------------
pushGame:			;push all bitboards down into stack
	push qWord [whitePawns]
	push qWord [whiteBishops]
	push qWord [whiteKnights]
	push qWord [whiteCastles]
	push qWord [whiteQueens]
	push qWord [whiteKing]


	push qWord [blackPawns]
	push qWord [blackBishops]
	push qWord [blackKnights]
	push qWord [blackCastles]
	push qWord [blackQueens]
	push qWord [blackKing]

	;jmp afterGamePush
	add rsp, 8 * 12
	ret

;-------------------------------
;Pop back all bitboards from stack
;-------------------------------
popGame:
	pop qWord [blackKing]
	pop qWord [blackQueens]
	pop qWord [blackCastles]
	pop qWord [blackKnights]
	pop qWord [blackBishops]
	pop qWord [blackPawns]

	pop qWord [whiteKing]
	pop qWord [whiteQueens]
	pop qWord [whiteCastles]
	pop qWord [whiteKnights]
	pop qWord [whiteBishops]
	pop qWord [whitePawns]

	;jmp afterGamePop
	sub rsp, 8*12
	ret

;-------------------------------
;Evaluates a players side against the oposite
;Sned player to evar in rcx, 1 = white | -1 = black
;------------------
;values:
;pawns = 1
;bishops & knights = 3
;rooks = 5
;queen = 9
;king = 200
;-------------------------------
eval:
	push rbx
	mov rbx, whitePawns		;address of white pawns
	push rcx
	popcnt rax, [rbx]		;count how many bits are on
	popcnt rcx, [rbx+8]		;bishop bitBoard
	imul rcx, 3			;bishop weight
	add rax, rcx			;add it to values
	popcnt rcx, [rbx+16]		;kights to bitboard
	imul rcx, 3			;knight weight
	add rax, rcx
	popcnt rcx, [rbx+24]		;rooks
	imul rcx, 5			;rook value
	add rax, rcx
	popcnt rcx, [rbx+32]		;queens
	imul rcx, 9			;queen value
	add rax, rcx
	popcnt rcx, [rbx+40]		;still have a king?
	imul rcx, 200			;king's value
	add rax, rcx
	pop rcx
	pop rbx

	push rdx
	xor edx, edx
	mov dl, ch			;what player side
	imul rax, rdx			;mul by player color
	pop rdx
	ret							;end of procedure

;-------------------------------
;Fill board with all black positions
;-------------------------------
fillBlackBoard:
	push rax
	push rcx
	push rbx
	mov rcx, 6
	mov rbx, blackPawns			;start of black bitboards address
	xor rax, rax
loopfillBlackBoard:				;loop through the bitboards
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
fillWhiteBoard:					;same as fillBlackBoard but white
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

;--------------------------------
;Push all posible moves into stack
;also place num of posible moves in rax
;--------------------------------
getMoves:
	call pawnMoves	;figure out pawn moves
	ret


;--------------------------------
;Pawn movement AI, send it pawn
; rcx = 1 white	player
; rcx = -1 black player
;--------------------------------
pawnMoves:
	mov rdx, [whitePawns]
	popcnt rcx, [whitePawns]
	xor rax, rax		;loop counter
whitePawn:			;moves for eachPawn 
	push rcx		;push num of white pawn 
	push rax
	push rdx		;save original pawns place
	shl rdx, 0x8		;check one move forward

	call fillWhiteBoard
	mov rax, [whiteBoard]
	not rax
	and rdx, rax
	pop rax			;get original pawn pos back in rax

	cmp rdx, 0		;if not posible move we are done
	je donePawnMove

	push qWord [whitePawns] ;save the current pawns
	xor [whitePawns], rax	;eliminate the pawn to move
	xor [whitePawns], rcx	;make the pawnMove
	call pushGame		;same the game move for the ai
	pop qWord [whitePawns]  ;retore them

donePawnMove:
	pop rax			;pop loop counter
	pop rcx			;pop num of pawns
	inc rax
	cmp rax, rcx
	jl whitePawn
	ret			;end pawn move
