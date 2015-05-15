TARGET =  main	#main target to compile
NAME = Chess

all: $(TARGET:=.o)
	gcc -m32 $(TARGET:=.o) board.o -o $(NAME) 

$(TARGET:=.o): board
	nasm -felf32 $(TARGET:=.asm)

board: clean
	nasm -felf32 board.asm

clean:
	-rm -f $(TARGET:=.o)
	-rm -f $(NAME)
