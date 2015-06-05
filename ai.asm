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
global pieceDie

global kingMove

global knightTop, knightBottom, knightLeft, knightRight
global firstWhitePawnRow, fistBlackPawnRow

extern print
extern printSpace
extern printBitMap
extern pushGame
extern popGame
extern pushWinningMove
extern popWinningMove
;piece move procedures
extern pawnMoves
extern bishopMoves
extern knightMoves
extern castleMoves
	;sub tree depth from eval, sooner is better

extern lastMovA

section .data
	aiDepth		dq	2	;depth for negaMax tree
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

	knightTop	dq	0xFFFFFFFFFFFF
	knightBottom	dq	0xFFFFFFFFFFFF0000
	knightLeft	dq	0xFCFCFCFCFCFCFCFC
	knightRight	dq	0x3F3F3F3F3F3F3F3F

	firstWhitePawnRow dq 0xff00
	fistBlackPawnRow dq 0xff000000000000

	;game helper flags
	kingMove	dq	0		;if it is a king move

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
;--------------------------------------
;NegaMax Procedure
;This is the backbone of our AI
;analyzes all best moves to "AIdepth"
;for each player choose best for itself
;--------------------------------------
;Upper negaMax gets score for every current move on one side
ai:
	mov rdx, qWord [aiPlayer]		;move ai player into cur player
	mov qWord [curPlayer], rdx
	mov qWord [curScore], -3000		;worst posible score "-infinity"
	call pushGame				;save current board state
	call getMoves				;get all posible moves for cur player
loopai:
	call popGame				;get first of those moves off a stack
	call pushGame				;save cur game state
	mov rcx, qWord [aiDepth]		;how deep nega max to eval
	inc rcx					;inc depth to offset initial dec
	push rax				;loop every piece counter
	push qWord [curScore]			;save cur game score so we don't loose
	imul rdx, -1				;change player
	push rdx				;push player into stack
	push rcx				;push ai depth into stack for nega
	call NegaMax				;get best move score
	call popGame				;get game state back
	pop rcx					;get args back
	pop rdx
	pop qWord [curScore]			;get current best score back
	imul rax, -1				;get nega max best score, imul because it's nega
	imul rdx, -1				;change player
	cmp rax, qWord [curScore]		;compare nega score to current one
	jng finalScore				;if it's not creater loop
	mov qWord [curScore], rax		;if it is greater swap it
	call print
	call pushWinningMove			;save this move, it may be best one
finalScore:
	pop rax					;pop the loop counter
	dec rax					;dec the counter
	cmp rax, 0				;check every piece?
	jne loopai				;if not then loop
	;if checkMate don't do anything
	;cmp qWord [curScore], -1500		;commented this because resulted in ai not finishing mate	
	;jl checkMate
	;cmp qWord [curScore], 1500
	;jg checkMate
	call popWinningMove			;make the move
	ret
checkMate:
	call popGame				;if checkmate just give current game back
	ret

;this is our AI, nega max recursive algorithm
NegaMax:
	push rbp				;save base pointer

	mov rbp, rsp				;get pushed parameter
	add rbp, 16				;align pointer to second arg
	mov rcx, [rbp]				;move depth parameter to rcx
	add rbp, 8				;move pointer to first arg
	mov rdx, [rbp]				;score player to eval

	dec rcx					;dec the depth counter
	cmp rcx, 0				;if 0 we are done
	je doneNegaMax

	;minimum score
	push rdx			
	mov rdx, -3000				;base worse score
	mov qWord [curScore], rdx		;save it in curScore
	pop rdx

	mov qWord [curPlayer], rdx		;move cur player

	call getMoves				;get all posible movs for that player
	cmp rax, 0				;if we checked all moves we are done
	je doneNegaMax
negaLoop:
	;for every move
	call popGame				;get a move off stack

	push rax				;loop counter
	push rbx
	push rdx		
	push qWord [curScore]   		;save score
	imul rdx, -1				;switch player
	push rdx
	push rcx				;push parameter
	call NegaMax				;recurse
	pop rcx					;get args back
	pop rdx
	pop qWord [curScore]			;get score back
	pop rdx					;get player back
	imul rax, -1				;negate the retuned eval
	;is new score higer? if so then swap
	cmp rax, qWord [curScore]		;is next score greater?
	jng	keepScore			;if it's not greater keep the current
	mov qWord [curScore], rax		;if greater store it
keepScore:			;not greater keep current
	pop rbx
	pop rax

	dec rax			;dec moves to do counter
	cmp rax, 0		;if we analyzed all moves 0 we are done
	jne negaLoop		;else loop for next move
	pop rbp
	mov rax, qWord [curScore];return our score
	ret
doneNegaMax:
	call eval		;bottom of tree eval the game state
	imul rax, rdx		;imul it by player color
	pop rbp			;give base pointer back for param
	ret			;base return of negamax

;-------------------------------
;Evaluates a players side against the oposite
;Sned player to evar in rcx, 1 = white | -1 = black
;Algorithm is Weight * (numWhite piece - numBlack Piece) *mobility * color
;------------------
;values:
;pawns = 10
;bishops & knights = 30
;rooks = 50
;queen = 90
;king = 2000
;-------------------------------
eval:
	push rbx
	push rcx			;store these registers to give back
	mov rbx, whitePawns		;store address to first bitmap
	;Pawns
	popcnt rcx, [rbx]		;bishop bitBoard
	imul rcx, 10			;bishop weight
	add rax, rcx			;add it to values
	popcnt rcx, [rbx+ 48]		;black bitboard weight
	imul rcx, 10
	sub rax, rcx			;sub from white

	;Bishops
	add rbx, 8			;move foward to next bitmap
	popcnt rcx, [rbx]		;bishop bitBoard
	imul rcx, 30			;bishop weight
	add rax, rcx			;add it to values
	popcnt rcx, [rbx+ 48]		;now check black bishop
	imul rcx, 30			;mul num by material weight
	sub rax, rcx			;sub it from the white value

	;Knights
	add rbx, 8			;move to knight bitboard
	popcnt rcx, [rbx]		;kights to bitboard
	imul rcx, 30			;knight weight
	add rax, rcx			;add it to the score
	popcnt rcx, [rbx+48]		;move to black knights
	imul rcx, 30			;get black score for knights
	sub rax, rcx			;sub that from white

	;Castles
	add rbx, 8			;mov to castle bitmap
	popcnt rcx, [rbx]		;rooks
	imul rcx, 50			;rook value
	add rax, rcx
	popcnt rcx, [rbx+48]		;jump to black bitmap
	imul rcx, 50
	sub rax, rcx			;sub from white 

	;Queens
	add rbx, 8			;mov to queens
	popcnt rcx, [rbx]		;queens
	imul rcx, 90			;queen value
	add rax, rcx
	popcnt rcx, [rbx+48]		;mov to black queens
	imul rcx, 90
	sub rax, rcx			;sub black from white queens

	;King
	add rbx, 8
	popcnt rcx, [rbx]		;still have a king?
	imul rcx, 2000			;king's value
	add rax, rcx
	popcnt rcx, [rbx+48]		;move black king
	imul rcx, 2000
	sub rax, rcx

	;calculate mobility as part of EVAL
	push qWord [curPlayer]		;save cur player & last movAddress 
	push qWord [lastMovA]
	push rax			;save current score
	mov qWord [curPlayer], 1	
	call numMoves			;get num moves posible for white
	mov rcx, rax
	pop rax
	add rax, rcx			;add mobility weight to score
	push rax
	mov qWord [curPlayer], -1	;now for black player
	call numMoves			;num of moves
	mov rcx, rax			;sub num black moves
	pop rax
	sub rax, rcx			;sbu black mobility from white's
	pop qWord [lastMovA]		;get last move address pointer back
	pop qWord [curPlayer]		;and cur player

	pop rcx
	pop rbx
	ret				;end of procedure

;-------------------------------
;when white attack happens remove
;the black piece from board
;-------------------------------
removePiece:
	mov qWord [pieceDie], 0	;if piece removed we change this flag to 1
	push rdx
	push rbx		;store these
	push rcx
	mov rdx, 6		;there are 6 pieces per side
	cmp qWord [curPlayer], 1;if we are white
	jne whiteRemove
	;remove black piece
	mov rbx, blackPawns	;we are going to remove from black
	jmp beginRemoval
whiteRemove:
	mov rbx, whitePawns	;remove from white
beginRemoval:
	mov rcx, [rbx]		;move bitmap to rcx
	push rcx		
	push rax
	and rax, rcx		;if there is a piece to remove (overlap)
	cmp rax, 0
	pop rax
	je checkNextPieceRemove
	xor rcx, rax		;remove the piece then
	mov qWord [pieceDie], 1	;mark that a piece died
checkNextPieceRemove:
	mov [rbx], rcx		;save the changes back to bimap
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
;Get num of movs posible from a position
;WARNING THIS DOESN"T WORK AS EXPECTED YET
;--------------------------------
numMoves:
	push rdx
	call getMoves
	pop rdx

;--------------------------------
;Push all posible moves into stack
;also place num of posible moves in rax
;--------------------------------
getMoves:
	push rdx
	push rbx
	xor rax, rax

	;KING move, use castle and bishop rules together
	;also turn on kingMove flag so we don't more more
	;than one step at a time
	mov qWord [kingMove], 1
	push qWord whiteKing
	call castleMoves
	add rsp, 8
	push qWord whiteKing
	call bishopMoves
	add rsp, 8
	mov qWord [kingMove], 0

	;queen move, use castle and bishop rules together
	push qWord whiteQueens
	call castleMoves
	add rsp, 8
	push qWord whiteQueens
	call bishopMoves
	add rsp, 8

	;knight Moves
	call knightMoves

	;bishop moves
	push qWord whiteBishops	;addres to bishop bitmap
	call bishopMoves
	add rsp, 8

	;castle moves
    push qWord whiteCastles ;we are passing castle bitboard
	call castleMoves ;can be used with kings and queens too
	add rsp, 8

	call pawnMoves		;figure out pawn moves

	pop rbx
	pop rdx
	ret
