global ai, aiMove
global aiPlayer
global curPlayer
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

global rightEdge
global leftEdge
global topEdge
global bottomEdge

global fillWhiteBoard
global fillBlackBoard
global removePiece
global boardBuffer
global whiteBoard
global blackBoard

extern print
extern printSpace
extern printBitMap
extern pushGame
extern popGame
extern pushWinningMove
extern popWinningMove
;piece move procedures
extern bishopMoves

section .data
	aiDepth		dq	3	;depth for negaMax tree
	aiPlayer	dq 	1	;if ai is black/white 1 = white -1 = black

	curDepth	dq 	0	;used by negaMax during loop
	curPlayer	dq 	0
	curScore	dq 	0	;used by negamax for score keepin

	numMovs	 	dq	0	;num of moves for a certain piece
	pieceDie	dq	0	;1 if piece died
	noGoodMove	dq	0	;flag is on ai doens't find good move

	blackBoard 	dq 	0x0	;used to store black pieces when calc
	whiteBoard 	dq 	0x0	;used to store white pieces when calc

	boardBuffer 	dq	0x0	;used as temporary move storage
	;used to check if piece is on an edge we fill bits where valid area
	leftEdge	dq	0xFEFEFEFEFEFEFEFE
	rightEdge	dq	0x7F7F7F7F7F7F7F7F
	topEdge		dq	0xFFFFFFFFFFFFFF
	bottomEdge	dq	0xFFFFFFFFFFFFFF00
					;bitboards for white
	whitePawns 		dq 	0xff00
	whiteBishops 	dq	0x24
	whiteKnights 	dq 	0x42
	whiteCastles 	dq 	0x81
	whiteQueens 	dq 	0x8
	whiteKing 		dq 	0x10
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
	mov rcx, [aiPlayer]
	mov [curPlayer], rcx
	;mov qWord [noGoodMove], 1
	xor rcx, rcx	;hold higest move score
	mov rcx, -300
	call getMoves	;does moves and gets # of them - in stack
	call print
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
	;imul rax, qWord [aiPlayer]
	imul rax, -1
	call print
;call fillWhiteBoard
;push rax
;mov rax, [whiteBoard]
;call printBitMap
;pop rax
	call popGame

	cmp rcx, rax
	jg continueLoopAI
	mov rcx, rax	;store greater score
	;call printSpace
	;call print
	;mov qWord [noGoodMove],0
	call pushWinningMove
continueLoopAI:
	pop rax
	dec rax		;dec loop
	cmp rax, 0
	jne loopAI
	;cmp qWord [noGoodMove], 1
	;je doneAI
	call popWinningMove
doneAI:
	ret

;search deep to find the best move
depthNega:
	push rbx

	;store rcx
	push rcx
	cmp qWord [curDepth],  0
	je doneNega	;reached bottom of our search tree
	dec qWord [curDepth]	;dec tree search depth
	;mov qWord [curScore], -300	;large worse case score
	mov rbx, -300
	;change PLayer
	mov rax, [curPlayer]
	imul rax, -1
	mov [curPlayer], rax
	call getMoves	;check moves for all unique piece types on given side
	mov rcx, rax
	xor rax, rax
allMoves:		;loop over all players posible moves
	;do moves
	call popGame	;pop the game to that move from getMoves
	;recurse
	call depthNega	;recurse
	;imul rax, -1	;negate returned value from eval
	;call print
	cmp rbx,rax	;is new score (rax) higher?
	jg nextMove
swapMaxScore:
	mov rbx, rax	;swap max with score
nextMove:
	dec rcx
	cmp rcx, 0
	jne allMoves
	mov rax, rbx
	pop rcx
	pop rbx
	ret
doneNega:
	call eval	;get an evaluation, return in rax
	pop rcx
	pop rbx
	ret		;done

;-------------------------------
;Evaluates a players side against the oposite
;Sned player to evar in rcx, 1 = white | -1 = black
;Algorithm is Weight * (numWhite piece - numBlack Piece) * color
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
	mov rbx, whitePawns
	;Pawns
	popcnt rax, [rbx]		;count how many bits are on
	popcnt rcx, [rbx + 48]	;sub from how many for black on
	sub rax, rcx

	;Bishops
	add rbx, 8
	popcnt rcx, [rbx]		;bishop bitBoard
	imul rcx, 3			;bishop weight
	add rax, rcx			;add it to values
	popcnt rcx, [rbx+ 48]
	imul rcx, 3
	sub rax, rcx

	;Knights
	add rbx, 8
	popcnt rcx, [rbx]		;kights to bitboard
	imul rcx, 3			;knight weight
	add rax, rcx
	popcnt rcx, [rbx+48]
	imul rcx, 3
	sub rax, rcx

	;Castles
	add rbx, 8
	popcnt rcx, [rbx]		;rooks
	imul rcx, 5			;rook value
	add rax, rcx
	popcnt rcx, [rbx+48]
	imul rcx, 5
	sub rax, rcx

	;Queens
	add rbx, 8
	popcnt rcx, [rbx]		;queens
	imul rcx, 9			;queen value
	add rax, rcx
	popcnt rcx, [rbx+48]
	imul rcx, 9
	sub rax, rcx

	;King
	add rbx, 8
	popcnt rcx, [rbx]		;still have a king?
	imul rcx, 200			;king's value
	add rax, rcx
	popcnt rcx, [rbx+48]
	imul rcx, 200
	sub rax, rcx
	;mul by player color
	mov rcx, qWord [curPlayer]
	imul rax, rcx			;negate score if black
	pop rcx
	pop rbx
	ret				;end of procedure

;-------------------------------
;when white attack happens remove
;the black piece from board
;-------------------------------
removePiece:
	push rdx
	push rbx
	push rcx
	mov rdx, 6
	cmp qWord [curPlayer], 1
	jne whiteRemove
	;remove black piece
	mov rbx, blackPawns
	jmp beginRemoval
whiteRemove:
	mov rbx, whitePawns
beginRemoval:
	mov rcx, [rbx]
	push rcx
	push rax
	and rax, rcx
	cmp rax, 0
	je checkNextPieceRemove
	xor rcx, rax
checkNextPieceRemove:
	mov [rbx], rcx
	pop rax
	add rbx, 8		;move to the next piece type
	dec rdx			;dec loop
	cmp rdx, 0		;end of loop?
	jne beginRemoval
	call pushGame			;save the game in this state
	sub rbx, 8
beginRestoreRemoved:
	pop qWord [rbx]
	sub rbx, 8
	inc rdx
	cmp rdx, 6
	jne beginRestoreRemoved
	mov qWord [pieceDie], 1
	pop rcx
	pop rbx
	pop rdx
	ret

;-------------------------------
;Fill board with all black positions
;-------------------------------
fillBlackBoard:
	push rax
	push rcx
	mov rcx, 5
	mov rbx, blackPawns		;start of black bitboards address
	xor rax, rax
loopfillBlackBoard:			;loop through the bitboards
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
	xor rax, rax
	call pawnMoves	;figure out pawn moves
	call bishopMoves
	ret


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
	je nextWPawn			;on right edge can only attack left

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
	je nextWPawn
	;store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	push qWord [whitePawns]
	mov [whitePawns], rdx
	call removePiece	;remove black piece
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
	je nextBPawn			;on right edge can only attack left

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
	je nextBPawn
	;store move
	inc rcx			;if valid move inc move counter
	or rdx, rax
	push qWord [blackPawns]
	mov [blackPawns], rdx
	call removePiece	;remove black piece
	pop qWord [blackPawns]

nextBPawn:
	pop rax
	shr rax, 1		;check next poss for pawn
	jmp blackPawn		;loop
donePawnMove:
	pop rax
	xor rax, rax
	add rax, rcx		;return number of pawn moves
	pop rbx
	pop rcx
	ret			;end pawn move
