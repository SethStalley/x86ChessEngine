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
	mov rdx, qWord [aiPlayer]
	mov qWord [curPlayer], rdx
	mov qWord [curScore], -3000
	call pushGame
	call getMoves
loopai:
	call popGame
	call pushGame
	mov rcx, qWord [aiDepth]
	inc rcx						;to counter initial dec in ai
	push rax					;loop every piece counter
	push qWord [curScore]
	imul rdx, -1
	push rdx
	push rcx
	call NegaMax				;get best move score
	call popGame				;get game state back
	pop rcx
	pop rdx
	pop qWord [curScore]
	imul rax, -1
	imul rdx, -1				;change player
	cmp rax, qWord [curScore]
	jng finalScore
	mov qWord [curScore], rax
	call print
	call pushWinningMove
finalScore:
	pop rax
	dec rax
	cmp rax, 0					;check every piece?
	jne loopai
	;if checkMate don't do anything
	cmp qWord [curScore], -1500
	jl checkMate
	cmp qWord [curScore], 1500
	jg checkMate
	call popWinningMove			;make the move
	ret
checkMate:
	call popGame
	ret

;this is our AI, nega max recursive algorithm
NegaMax:
	push rbp					;save base pointer

	mov rbp, rsp				;get pushed parameter
	add rbp, 16
	mov rcx, [rbp]				;move depth parameter to rcx
	add rbp, 8
	mov rdx, [rbp]

	dec rcx
	cmp rcx, 0
	je doneNegaMax

	;minimum score
	push rdx
	mov rdx, -3000		;base score
	mov qWord [curScore], rdx
	pop rdx

	mov qWord [curPlayer], rdx	;move cur player

	call getMoves		;get all posible movs for that player
	cmp rax, 0
	je doneNegaMax
negaLoop:
	;for every move
	call popGame

	push rax		;loop counter
	push rbx
	push rdx
	push qWord [curScore]   ;save score
	imul rdx, -1			;switch player
	push rdx
	push rcx					;push parameter
	call NegaMax
	pop rcx
	pop rdx
	pop qWord [curScore]	;get score back
	pop rdx
	imul rax, -1
	;is new score higer? if so then swap
	cmp rax, qWord [curScore]	;is nex score greater?
	jng	keepScore
	mov qWord [curScore], rax
keepScore:			;not greater keep current
	pop rbx
	pop rax

	dec rax			;dec moves to do counter
	cmp rax, 0
	jne negaLoop
	pop rbp
	mov rax, qWord [curScore]
	ret
doneNegaMax:
	call eval
	imul rax, rdx
	pop rbp
	ret

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
	popcnt rcx, [rbx]		;bishop bitBoard
	imul rcx, 10		;bishop weight
	add rax, rcx			;add it to values
	popcnt rcx, [rbx+ 48]
	imul rcx, 10
	sub rax, rcx

	;Bishops
	add rbx, 8
	popcnt rcx, [rbx]		;bishop bitBoard
	imul rcx, 30			;bishop weight
	add rax, rcx			;add it to values
	popcnt rcx, [rbx+ 48]
	imul rcx, 30
	sub rax, rcx

	;Knights
	add rbx, 8
	popcnt rcx, [rbx]		;kights to bitboard
	imul rcx, 30			;knight weight
	add rax, rcx
	popcnt rcx, [rbx+48]
	imul rcx, 30
	sub rax, rcx

	;Castles
	add rbx, 8
	popcnt rcx, [rbx]		;rooks
	imul rcx, 50			;rook value
	add rax, rcx
	popcnt rcx, [rbx+48]
	imul rcx, 50
	sub rax, rcx

	;Queens
	add rbx, 8
	popcnt rcx, [rbx]		;queens
	imul rcx, 90			;queen value
	add rax, rcx
	popcnt rcx, [rbx+48]
	imul rcx, 90
	sub rax, rcx

	;King
	add rbx, 8
	popcnt rcx, [rbx]		;still have a king?
	imul rcx, 2000			;king's value
	add rax, rcx
	popcnt rcx, [rbx+48]
	imul rcx, 2000
	sub rax, rcx

	;calculate mobility as part of EVAL
	push qWord [curPlayer]
	push qWord [lastMovA]
	push rax
	mov qWord [curPlayer], 1
	call numMoves			;get num moves posible
	mov rcx, rax
	pop rax
	add rax, rcx			;add mobility weight
	push rax
	mov qWord [curPlayer], -1	;now for black player
	call numMoves			;num of moves
	mov rcx, rax			;sub num black moves
	pop rax
	sub rax, rcx
	pop qWord [lastMovA]
	pop qWord [curPlayer]

	pop rcx
	pop rbx
	ret				;end of procedure

;-------------------------------
;when white attack happens remove
;the black piece from board
;-------------------------------
removePiece:
	mov qWord [pieceDie], 0
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
	pop rax
	je checkNextPieceRemove
	xor rcx, rax
	mov qWord [pieceDie], 1	;mark that a piece died
checkNextPieceRemove:
	mov [rbx], rcx
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
