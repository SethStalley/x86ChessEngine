global initBoard
extern	printf

section .data
	printD			db	"%d",10,0
	board dd 0x0
					;bitboards for white
	whiteLowerPawns 	dd 	0xff00
	whiteLowerBishops 	dd	0x24
	whiteLowerKnights 	dd 	0x42
	whiteLowerCastles 	dd 	0x81
	whiteLowerQueens 	dd 	0x8
	whiteLowerKing 		dd 	0x10

	whiteUpperPawns 	dd 	0x0
	whiteUpperBishops 	dd 	0x0
	whiteUpperKnights 	dd 	0x0
	whiteUpperCastles 	dd 	0x0
	whiteUpperQueens	dd	0x0
	whiteUpperKing 		dd 	0x0

					;bitboards for black
	blackUpperPawns 	dd 	0xff0000
	blackUpperBishops 	dd 	0x24000000
	blackUpperKnights 	dd 	0x42000000
	blackUpperCastles	dd	0x81000000
	blackUpperQueens 	dd 	0x8000000
	blackUpperKing		dd	0x10000000
	
	blackLowerPawns		dd 	0x0
	blackLowerBishops	dd	0x0
	blackLowerKnights	dd	0x0
	blackLowerCastles	dd	0x0
	blackLowerQueens	dd	0x0
	blackLowerKing		dd	0x0


section .code
initBoard:
	mov eax, [whiteLowerPawns]
	push eax
	call calcMove
	ret

;-------------------------------
;Push lower and upper bitmap
;Push piece mov function
;-------------------------------
calcMove:		
	add esp, 4
upperMoves:			;second run through to calc upper board
	pop eax
	mov ecx, 0x1
loop:			
	push eax		;save bitboard
	push ecx
	and eax, ecx		;is there a piece here?
	push eax
	push printD
	call printf
	add esp, 8
	pop ecx
	pop eax
	
	cmp ecx, 0x80000000	;if we compared all the bits
	je endMovCalc

	shl ecx, 0x1		;shift right one bit
	jne loop
endMovCalc:
	ret
