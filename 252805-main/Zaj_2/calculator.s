
.section .data

hellostring:
.ascii "Wpisz dzialanie matematyczne np.(13.2 / 2): \nWprowadzone dane:\0"

error_msg:
.ascii "SYNTAX ERROR!!!\n\0"

temp_for_scanf:  
.ascii "%f %c %f"

equals:
.ascii "Wynik: %f\n\0"

is_zero_message:
.ascii "Nie mozna dzielic przez zero!\n\0"

round_msg:
.ascii "Wybierz rodzaj przyblizenia: \n1.Nearest \n2.Down \n3.Up \n4.To_zero\n5.Default\nWybrano: \0"

#definicja słów kluczowych dla operacji zaokrąglania
old_rounding: .word 0
nearest_rounding: .word 0x0000
down_rounding: .word 0x0400
up_rounding: .word 0x0800
zero_rounding: .word 0x0C00

temp_two_for_scanf:
.ascii "%d"

.section .bss
    .lcomm input_one, 32
    .lcomm input_two, 32
    .lcomm input_sing, 8
    .lcomm type_of_rounding, 8
    
.section .text

.globl _start

_start:
#wpisanie podstawowej konfiguracji zaokrąglenia FPU
fstcw old_rounding

#dwa bity określają zaokrąglenie w słowie sterującym jednostki FPU
#jednak zmiana dwóch bitów i pozostawienie reszty nietknietej potrzebuje operacji
movw old_rounding, %ax
andb $0b11110011, %ah
orw %ax, nearest_rounding
orw %ax, down_rounding
orw %ax, up_rounding
orw %ax, zero_rounding

#wypisanie komunikatu powitalnego do użytkownika
pushl $hellostring
call printf

#wczytanie danych od użytkownika:
 #pierwsza liczba 
 #znak arytmetyczny (rodzaj operacji)
 #druga liczba
pushl $input_one
pushl $input_sing
pushl $input_two
pushl $temp_for_scanf
call scanf

#pokazanie menu zaokraglania
pushl $round_msg
call printf

#zczytanie liczby odpopiadajacej zaokraglaniu
pushl $type_of_rounding
pushl $temp_two_for_scanf
call scanf

#porównywanie znaku wpisanej liczby znaku 
#z odpowiednią etykietą
#i przeskoczenie do odpowiedniego mmiejsca w kodzie
movl $input_sing, %eax
mov (%eax), %bl
cmpb $'+', %bl
je addition
cmpb $'-', %bl
je subtraction
cmpb $'*', %bl
je multiply
cmpb $'/', %bl
je divide

#ogólny błąd który obsługuje wyjątki takie jak 
#nieprawidłowa operacja arytmetyczna
error:
pushl $error_msg
call printf
jmp end

#komunikat dzielenia przez 0
zero:
pushl $is_zero_message
call printf
jmp end

#dodawanie
addition:
fld input_one	#zaladowanie do stosu FPU pierwszej liczby
fld input_two	#zaladowanie do stosu FPU drugiej liczby
faddp		#dodanie dwóch liczb, zapisz w st(1) i pop st(0)
#operacje skokowe zarzadzające obsluga przyblizenia
jmp round_menu

#odejmowanie
subtraction:
fld input_one	#zaladowanie do stosu FPU pierwszej liczby
fld input_two	#zaladowanie do stosu FPU drugiej liczby
fsubp		#odjęcie dwóch liczb st(0)-st(1) i pop st(0)
jmp round_menu

#mnożenie
multiply:
fld input_one	#zaladowanie do stosu FPU pierwszej liczby
fld input_two	#zaladowanie do stosu FPU drugiej liczby
fmulp		#wymnożenie dwóch liczb i zapisz w st(1) i pop st(0)		
jmp round_menu

#dzielenie
divide:
fld input_one
ftst
fnstsw %ax
fwait
sahf
jpe error
ja continue
jb continue
jz zero

#jeśli nie dzielimy przez 0 to wykonuj dalej
continue:
fld input_two
fdivp		#podzielenie dwóch liczb st(1)/st(0)


round_menu:
movl $type_of_rounding, %eax
mov (%eax), %bl
cmpb $1, %bl
je nearest
cmpb $2, %bl
je down
cmpb $3, %bl
je up
cmpb $4, %bl
je chop
cmpb $5, %bl
je default
jmp error

#zaokrąglanie
#najblizsza liczba
nearest:
fldcw nearest_rounding
frndint
jmp show

#do gory (+nieskonczonosc)
up:
fldcw up_rounding 	#załadowanie słowa do jednostki FPU
frndint 	#zaokrąglenie do intigera
jmp show

#do dołu (-nieskonczonosc)
down:
fldcw down_rounding
frndint
jmp show

#po przez obciecie
chop:
fldcw zero_rounding
frndint

#domyślne
default:

show:
#konwersja float na double dla funkcji printf
fstpl (%esp)	#skopiuj liczbę w formacie double do wskaźnika stosu
pushl $equals
call printf	#wypisanie wyniku
pushl $0

end:
#funkcja z bibioteki libc kończąca program
call exit
