TARGET =  main	#main target to compile
NAME = Chess

all: $(TARGET:=.o)
	gcc $(TARGET:=.o) board.o printProcedures.o gameState.o -o $(NAME) 

$(TARGET:=.o): board
	nasm -felf64 $(TARGET:=.asm)

board: gameState
	nasm -felf64 board.asm
gameState: printProcedures
	nasm -felf64 gameState.asm
printProcedures: clean
	nasm -felf64 printProcedures.asm
clean:
	-rm -f $(TARGET:=.o)
	-rm -f board.o
	-rm -f gameState.o
	-rm -f printProcedures.o
	-rm -f $(NAME)
