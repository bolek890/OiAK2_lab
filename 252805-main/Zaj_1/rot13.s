SYSEXIT32 = 1
SYSCALL32 = 0x80
SYSREAD = 3
EXIT_SUCCESS = 0
SYSOPEN = 5
SYSWRITE = 4
STDOUT = 1
STDIN = 0

.data
message_first: .ascii "Podaj zdanie: "	#zmienne potrzebne do zadania
message_first_length = . - message_first	#długość zmiennej potrzebna do funkcji systemowej
message_endl: .ascii "\n"
message_endl_length = . - message_endl
message_rot: .ascii "Rot13: "
message_rot_length = . - message_rot
message_user: .ascii "                "
message_user_length = . - message_user

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
movl $message_user, %ecx	# argument drugi dres początku łańcucha ascii
movl $message_user_length, %edx	# argument trzeci długość łańcucha ascii
int $SYSCALL32	# wywołanie fukcji

# licznik pętli dla każdego znaku z napisu wprowadzonego przez użytkownika
movl $message_user, %eax
movl $message_user_length, %ecx 
movl $0, %ebx

# pętla przekształcająca łańcuch znaków na ROT13

begin:  #flaga początku
cmpl $0, %ecx # warunek porównujący czy są jeszcze jakieś znaki do przekształcenia
je ending # jeżeli nie przejdź do końca programu
mov (%eax), %bl #kopiujemy jeden znak z rejestru eax (czyli z adresu początkowego wiadomości użytkownika) do rejestru 8 bitowego bl
cmpb $'A', %bl  # Warunki sprawdzające czy dany znak jest literą kod ASCII ('A'=65 do 'z'=122)
jb add_adress	# Jeżeli mniejsza wartość od 65 to znaczy że to nie jest znak, przeskocz do kolejnego
cmpb $'z', %bl	# porównaj znak z wartością 122='z'
ja add_adress # Jeżeli wieksza wartość od 122 to znaczy że to nie jest znak, przeskocz do kolejnego
cmpb $'a', %bl # warunek sprawdzający czy to mała litera
jae low_letter # jeżeli wartość większa lub równa 'a'=97 przeskocz do flagi małej litery

#przypadek wielkich liter
big_letter:
addb $13, %bl	#dodanie stałej 13 do kodu ascii np. 65->78 = 'A'->'N'
cmpb $'Z', %bl	#porównanie czy znak nie wyszedł ponad zakres wielkich liter
jbe add_adress	#jeżeli nie przejdź do kolejnego znaku
subb $26, %bl	#w innym przypadku odejmij 26 np. 'W'=87 ... 87+13= 100>90 100-26=74 'W'->'J'
jmp add_adress #przejdź do kolejnej litery

#przypadek małych liter
low_letter:
addb $13, %bl #dodanie stałej 13 do kodu ascii np. 97->110 = 'a'->'n'
cmpb $'z', %bl #porównanie czy znak nie wyszedł ponad zakres małych liter
jbe add_adress #jeżeli nie przejdź do kolejnego znaku
subb $26, %bl #w innym przypadku odejmij 26 np. 'w'=119 ... 119+13= 132>122 132-26=106 'w'->'j'

#funkcja dodająca adres
add_adress:
movb %bl, (%eax) #aktualizacja znaku w pamięci na rot13
addl $1, %eax	#przeskoczenie do kolejnego znaku w łańcuchu
subl $1, %ecx	#iteracja licznika pętli
jmp begin


ending:
#wypisanie wterminalu napisu "Rot13:"
movl $SYSWRITE, %eax
movl $STDOUT, %ebx
movl $message_rot, %ecx
movl $message_rot_length, %edx
int $SYSCALL32

#wypisanie w terminalu napisu użytkownika w kodzie rot13
movl $SYSWRITE, %eax
movl $STDOUT, %ebx
movl $message_user, %ecx
movl $message_user_length, %edx
int $SYSCALL32

#wypisanie w terminalu '\n'
movl $SYSWRITE, %eax
movl $STDOUT, %ebx
movl $message_endl, %ecx
movl $message_endl_length, %edx
int $SYSCALL32

movl $SYSEXIT32, %eax
movl $EXIT_SUCCESS, %ebx
int $SYSCALL32
