all: rot13

rot13: rot13.o
	ld rot13.o -m elf_i386 -o rot13

rot13.o: rot13.s
	as rot13.s --32 -o rot13.o -g

clean:
	rm rot13.o rot13