TARGET =  main	#main target to compile
NAME = Chess

all: $(TARGET:=.o)
	gcc $(TARGET:=.o) ai.o printProcedures.o pawn.o knight.o bishop.o gameState.o chessGUI.c `pkg-config --cflags --libs gtk+-2.0` -o $(NAME)

$(TARGET:=.o): board
	nasm -felf64 $(TARGET:=.asm)
board: gameState
	nasm -felf64 ai.asm
gameState: pawns
	nasm -felf64 gameState.asm
pawns: knight
		nasm -felf64 pawn.asm
knight: printProcedures
		nasm -felf64 knight.asm
printProcedures: bishops
	nasm -felf64 printProcedures.asm
bishops: clean
	nasm -felf64 bishop.asm
clean:
	-rm -f $(TARGET:=.o)
	-rm -f ai.o
	-rm -f gameState.o
	-rm -f pawn.o
	-rm -f knight.o
	-rm -f bishop.o
	-rm -f printProcedures.o
	-rm -f $(NAME)
