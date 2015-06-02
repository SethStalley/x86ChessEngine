NAME = Chess

all: board
	gcc ai.o printProcedures.o pawn.o castle.o knight.o bishop.o gameState.o chessGUI.c `pkg-config --cflags --libs gtk+-2.0` -o $(NAME)

board: gameState
	nasm -felf64 ai.asm
gameState: pawns
	nasm -felf64 gameState.asm
pawns: knight
		nasm -felf64 pawn.asm
knight: castle
		nasm -felf64 knight.asm
castle: printProcedures
		nasm -felf64 castle.asm
printProcedures: bishops
	nasm -felf64 printProcedures.asm
bishops: clean
	nasm -felf64 bishop.asm
clean:
	-rm -f ai.o
	-rm -f castle.o
	-rm -f gameState.o
	-rm -f pawn.o
	-rm -f knight.o
	-rm -f bishop.o
	-rm -f board.o
	-rm -f printProcedures.o
	-rm -f $(NAME)
