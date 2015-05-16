global initBoard

section .data
	board dd 0x0
	
	whitePawnLower dd 0x0000ff00	;pawn positions on bitboard

section .code
initBoard:
	mov eax, [whitePawnLower]
	ret
