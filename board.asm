global aiMove
global whitePawns
global whiteBishops
global whiteKnights
global whiteCastles
global whiteQueens
global whiteKing
global blackPawns
global blackBishops
global blackKnights
global blackCastles
global blackQueens
global blackKing

extern print
extern printSpace
extern printBitMap
extern pushGame
extern popGame
extern pushWinningMove
extern popWinningMove

section .data
	aiDepth		dq	2	;depth for negaMax tree
	aiPlayer	dq 	1	;if ai is black/white default black

	curDepth	dq 	0	;used by negaMax during loop
	curPlayer	dq 	1
	curScore	dq 	0	;used by negamax for score keepin

	numMovs	 	dq	0	;num of moves for a certain piece

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

section .text
aiMove:
	call ai
	call fillBlackBoard
	call fillWhiteBoard
	mov rax, [whiteBoard]
	or rax, [blackBoard]
	call printBitMap
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
	xor rcx, rcx	;hold higest move score
	mov rcx, -300
	call getMoves	;does moves and gets # of them - in stack
loopAI:	;loop all moves for ai player
	push rax	;store loop counter
	call popGame	;pop the game to that move from getMoves
	;set depth and player
	mov rax, [aiDepth]
	mov [curDepth], rax
	mov rax, [aiPlayer]
	mov [curPlayer], rax	
	;get score
	call pushGame
	call depthNega	;get depth score for that move
	call popGame
	cmp rcx, rax
	jg continueLoopAI
	mov rcx, rax	;store greater score
	call pushWinningMove
continueLoopAI:
	pop rax
	;call popGame	;undo moves
	dec rax		;dec loop
	cmp rax, 0	
	jne loopAI
doneAI:
	call popWinningMove ;do the move
	ret

;search deep to find the best move
depthNega:
	;change PLayer
	mov rax, [curPlayer]
	imul rax, -1
	mov [curPlayer], rax
	;store rcx
	push rcx
	cmp qWord [curDepth],  0
	je doneNega	;reached bottom of our search tree
	dec qWord [curDepth]	;dec tree search depth
	mov qWord [curScore], -300	;large worse case score
	call getMoves	;check moves for all unique piece types on given side
	mov rcx, rax
allMoves:		;loop over all players posible moves
	;do moves
	call popGame	;pop the game to that move from getMoves

	;print board state for debug
	;call fillWhiteBoard
	;call fillBlackBoard
	;mov rax, [whiteBoard]
	;or rax, [blackBoard]
	;call printBitMap

	;recurse
	call depthNega	;recurse
	imul rax, -1	;negate returned value from eval 
	cmp [curScore],rax	;is new score (rbx) higher?
	jng nextMove
swapMaxScore:
	mov [curScore], rax	;swap max with score
nextMove:
	dec rcx
	cmp rcx, 0
	jne allMoves
doneNega:
	mov rax, [curPlayer]
	call eval	;get an evaluation
	pop rcx
	ret		;done




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
	push rcx
	cmp qWord [curPlayer], 1
	jne evalBlack
	mov rbx, whitePawns		;address of white pawns
	jmp whiteEval
evalBlack:
	mov rbx, blackPawns
whiteEval:
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
	mov rcx, [curPlayer]
	imul rax, rcx			;negate score if black
	pop rcx
	pop rbx

	ret							;end of procedure

;-------------------------------
;Fill board with all black positions
;-------------------------------
fillBlackBoard:
	push rax
	push rcx
	mov rcx, 5
	mov rbx, blackPawns			;start of black bitboards address
	xor rax, rax
loopfillBlackBoard:				;loop through the bitboards
	or rax, [blackPawns + rcx * 8]	
	dec rcx
	cmp rcx, 0
	jnl loopfillBlackBoard
	mov [blackBoard], rax
	pop rcx
	pop rax
	ret

;-------------------------------
;Fill board with all white positions
;-------------------------------
fillWhiteBoard:					;same as fillBlackBoard but white
	push rax
	push rcx
	mov rcx, 5
	xor rax, rax
loopfillWhiteBoard:
	or rax, [whitePawns + rcx * 8]
	dec rcx
	cmp rcx, 0
	jnl loopfillWhiteBoard
	mov [whiteBoard], rax
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
; [curPlayer] = 1 white	player
; [curPlayer] = -1 black player
;--------------------------------
pawnMoves:
	push rcx
	xor rcx, rcx
	mov rax, 0x8000000000000000
	mov qWord [numMovs], 0	;set move counter in 0
	cmp qWord [curPlayer], 1;what player are we?
	jne blackPawn
whitePawn:			;moves for white pawn
	mov rdx, [whitePawns]
	cmp rax,0x0		;if we check all the bits
	je donePawnMove		;check for all pawns
	push rax		;save bit being checked
	and rax, rdx		;if there is a pawn there
	cmp rax, 0
	je nextWPawn		;check next poss for pawn
	
	not rax			;not our move
	and rdx, rax		;remove current pawn position
	not rax			;get move back
	shl rax, 0x8		;move pawn one foward
	call fillWhiteBoard
	not qWord [whiteBoard]
	and rax, qWord [whiteBoard]	;if piece here we can't move there
	cmp rax, 0
	je nextWPawn
	
	inc rcx			;pawn move is valid inc move counter
	or rdx, rax		;apply the move to the pawn's bitmap
	push qWord [whitePawns] ;save the current pawns
	not qWord [whiteBoard]
	mov [whitePawns], rdx	;make the pawnMove
	call pushGame		;save the game move for the ai
	pop qWord [whitePawns]  ;restore them to check other pawn
nextWPawn:
	pop rax
	shr rax, 1		;check next poss for pawn
	jmp whitePawn		;loop
	jmp donePawnMove

blackPawn:			;same but for each Black pawn		
	mov rdx, [blackPawns]
	cmp rax, 0x0		;if we check all the bits
	je donePawnMove		;check for all pawns
	push rax		;save bit being checked
	and rax, rdx		;if there is a pawn there
	cmp rax, 0
	je nextBPawn		;check next poss for pawn

	not rax			;not our move
	and rdx, rax		;remove current pawn position
	not rax			;get move back
	shr rax, 0x8		;move pawn one foward

	call fillBlackBoard
	not qWord [blackBoard]
	and rax, qWord [blackBoard]	;if piece here we can't move there
	cmp rax, 0
	je nextBPawn
	
	inc rcx			;pawn move is valid inc move counter
	or rdx, rax		;apply the move to the pawn's bitmap
	push qWord [blackPawns] ;save the current pawns
	not qWord [blackBoard]
	mov [blackPawns], rdx	;make the pawnMove
	call pushGame		;save the game move for the ai	
	pop qWord [blackPawns]  ;restore them to check other pawn
nextBPawn:
	pop rax
	shr rax, 1		;check next poss for pawn
	jmp blackPawn		;loop
donePawnMove:
	mov rax, rcx		;return number of pawn moves
	pop rcx
	ret			;end pawn move
