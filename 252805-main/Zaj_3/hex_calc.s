SYSEXIT32 = 1
SYSCALL32 = 0x80
SYSREAD = 3
EXIT_SUCCESS = 0
SYSOPEN = 5
SYSWRITE = 4
STDOUT = 1
STDIN = 0


.data
message_first: .ascii "Podaj liczbe: "	#zmienne potrzebne do zadania
message_first_length = . - message_first	#długość zmiennej potrzebna do funkcji systemowej
message_second: .ascii "Kolejna liczba: "	#zmienne potrzebne do zadania
message_second_length = . - message_second
message_endl: .ascii "\n"
message_endl_length = . - message_endl
message_user_one: .ascii "                "
message_user_one_length = . - message_user_one
message_user_two: .ascii "                "
message_user_two_length = . - message_user_two
space_one = (message_user_one_length/2)
space_two = (message_user_two_length/2)
equal_len = (space_one+space_two)*4
equal_space = equal_len*4
equal_space_write = equal_space/2
.bss
number_one: 
.space space_one
number_two: 
.space space_two
equal:
.space equal_len
equal_write: 
.space equal_space_write
.text

.global _start

_start:

mov $SYSWRITE, %eax	# funkcja do wywołania - SYSWRITE (wypisanie danych na ekranie)
mov $STDOUT, %ebx	# argument pierwszy systemowy deskryptor stdout
mov $message_first, %ecx	# argument drugi dres początku łańcucha ascii
mov $message_first_length, %edx	# argument trzeci długość łańcucha ascii
int $SYSCALL32	# wywołanie fukcji

movl $SYSREAD, %eax	# funkcja do wywołania - SYSREAD (pobranie danych)
movl $STDIN, %ebx	# argument pierwszy systemowy deskryptor stdin
movl $message_user_one, %ecx	# argument drugi dres początku łańcucha ascii
movl $message_user_one_length, %edx	# argument trzeci długość łańcucha ascii
int $SYSCALL32	# wywołanie fukcji

mov $SYSWRITE, %eax	# funkcja do wywołania - SYSWRITE (wypisanie danych na ekranie)
mov $STDOUT, %ebx	# argument pierwszy systemowy deskryptor stdout
mov $message_second, %ecx	# argument drugi dres początku łańcucha ascii
mov $message_second_length, %edx	# argument trzeci długość łańcucha ascii
int $SYSCALL32	# wywołanie fukcji

movl $SYSREAD, %eax	# funkcja do wywołania - SYSREAD (pobranie danych)
movl $STDIN, %ebx	# argument pierwszy systemowy deskryptor stdin
movl $message_user_two, %ecx	# argument drugi dres początku łańcucha ascii
movl $message_user_two_length, %edx	# argument trzeci długość łańcucha ascii
int $SYSCALL32	# wywołanie fukcji


# pętla przekształcająca łańcuch znaków ASCII na HEX dla pierwszej liczby
movl $0, %ecx
movl $0, %ebx

begin:
movl $0, %eax
movb message_user_one(,%ebx,1), %al
cmpb $0x30, %al
jb end
subb $0x30, %al
cmpb $0x0A, %al
jb number
subb $0x7, %al
 
number:
shll $4, number_one(,%ecx,4)
addl %eax, number_one(,%ecx,4)
incl %ebx
cmpl $message_user_two_length, %ebx
je end
jmp begin

end:

movl $0, %ecx
movl $0, %ebx

# pętla przekształcająca łańcuch znaków ASCII na HEX dla drugiej liczby
begin_2:
movl $0, %eax
movb message_user_two(,%ebx,1), %al
cmpb $0x30, %al
jb end_2
subb $0x30, %al
cmpb $0x0A, %al
jb number_2
subb $0x7, %al
 
number_2:
shll $4, number_two(,%ecx,4)
addl %eax, number_two(,%ecx,4)
incl %ebx
cmpl $message_user_two_length, %ebx
je end_2
jmp begin_2

end_2:

movl $0, %ebx
multiplication_x: 
cmpl $4, %ebx
jz ending
movl $0, %ecx
movl $0, %esi


# dwie zagnieżdżone pętle wykonujące mnożenie
multiplication_s:
movl $0, %edi
cmpl $4, %ecx
jz end_s
movl number_one(,%ebx,4), %eax
movl number_two(,%ecx,4), %edx
mull %edx
addl %ebx, %ecx
addl equal(,%ecx,4), %edx
movl %eax, equal(,%ecx,4)
incl %ecx
adcl equal(,%ecx,4), %edx
adcl $0, %edi
adcl %esi, %edx
adcl $0, %edi
movl %edi, %esi
movl %edx, equal(,%ecx,4)
subl %ebx, %ecx
jmp multiplication_s
end_s:
incl %ebx
jmp multiplication_x

#konwersja wyniku na ascii (niedziałająca)
ending:
movl $equal_len, %ecx
movl $equal, %ebx
movl $equal_write, %eax

#
#converter:
#movb message_user_two(,%ebx,1), %al
#movb %al, %bl
#and $15, %al
#cmpb $9, %al
#jbe num_in_num
#addb $55, %al
#jmp second
#num_in_num:
#addb $48, %al

#second:
#shr $4, %bl
#cmpb $9, %bl
#jbe num_in_num_2
#addb $55, %bl
#jmp overwrite
#num_in_num_2:
#addb $48, %bl

#overwrite:
#movb %al, (%eax)
#movb %bl, (%eax)
#incl %eax
#addl $1, %ebx
#subl $1, %ecx
#cmpl $0, %ecx
#tu:
#je ending_program
#jmp converter

ending_program:
#mov $SYSWRITE, %eax	# funkcja do wywołania - SYSWRITE (wypisanie danych na ekranie)
#mov $STDOUT, %ebx	# argument pierwszy systemowy deskryptor stdout
#mov $equal_write, %ecx	# argument drugi dres początku łańcucha ascii
#mov $equal_space_write, %edx	# argument trzeci długość łańcucha ascii
#int $SYSCALL32	# wywołanie fukcji

movl $SYSEXIT32, %eax
movl $EXIT_SUCCESS, %ebx
int $SYSCALL32
