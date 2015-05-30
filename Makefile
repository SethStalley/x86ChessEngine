TARGET =  main	#main target to compile
NAME = Chess

all: $(TARGET:=.o)
	gcc $(TARGET:=.o) ai.o printProcedures.o bishop.o gameState.o chessGUI.c `pkg-config --cflags --libs gtk+-2.0` -o $(NAME)

$(TARGET:=.o): board
	nasm -felf64 $(TARGET:=.asm)
board: gameState
	nasm -felf64 ai.asm
gameState: printProcedures
	nasm -felf64 gameState.asm
printProcedures: bishops
	nasm -felf64 printProcedures.asm
bishops: clean
	nasm -felf64 bishop.asm
clean:
	-rm -f $(TARGET:=.o)
	-rm -f ai.o
	-rm -f gameState.o
	-rm -f bishop.o
	-rm -f printProcedures.o
	-rm -f $(NAME)
