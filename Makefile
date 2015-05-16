TARGET =  main	#main target to compile
NAME = Chess

all: $(TARGET:=.o)
	gcc $(TARGET:=.o) board.o -o $(NAME) 

$(TARGET:=.o): board
	nasm -felf64 $(TARGET:=.asm)

board: clean
	nasm -felf64 board.asm

clean:
	-rm -f $(TARGET:=.o)
	-rm -f $(NAME)
