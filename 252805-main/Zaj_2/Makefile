all: calculator

calculator: calculator.o
	ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o calculator -lc calculator.o

calculator.o: calculator.s
	as --32 -o calculator.o calculator.s

clean:
	rm calculator.o calculator