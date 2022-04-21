all: hex_calc

hex_calc: hex_calc.o
	ld hex_calc.o -m elf_i386 -o hex_calc

hex_calc.o: hex_calc.s
	as hex_calc.s --32 -o hex_calc.o -g

clean:
	rm hex_calc.o hex_calc