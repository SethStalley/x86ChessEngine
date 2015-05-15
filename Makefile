TARGET =  main	#main target to compile
NAME = Chess

all: $(TARGET:=.o)
	gcc -m32 $(TARGET:=.o) -o $(NAME) 

$(TARGET:=.o): clean
	nasm -felf32 $(TARGET:=.asm)

clean:
	-rm -f $(TARGET:=.o)
	-rm -f $(NAME)
