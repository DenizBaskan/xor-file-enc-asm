all:
	nasm -f elf64 -o bin/main.o main.asm
	ld -o bin/main bin/main.o
