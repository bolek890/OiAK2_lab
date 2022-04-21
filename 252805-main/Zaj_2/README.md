# OiAK-Laboratorium zajęcia drugie
## Treść zadania 2:
Proszę napisać program w języku assemblera w architekturze 32-bitowej na platformę Linux. Program powinien zapytać użytkownika o podanie dwóch liczb rzeczywistych, operacji do wykonanie (+ - * /) oraz sposobu zaokrąglania wyniku FPU.
Program powinien wypisać na standardowe wyjście wynik danej operacji zaokrąglony w wybrany sposób.
do wczytywania / wyświetlania można używać funkcji z libc (printf, scanf)
* liczby wpisywane są w sposób dziesiętny, np. 1.23456789
* wynik wyświetlamy też w sposobie dziesiętnym
* sposoby zaokrąglania FPU (wg FPU control word): nearest (even if tie), down, up, to zero

## Polecenia potrzebne do kompilacji:
```
$ as --32 -o calculator.o calculator.s
$ ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o calculator -lc calculator.o
```
## Polecenia do instalacji potrzebnych bibliotek:
```
$ sudo apt install gcc-multilib
```
## Interfejs programu:
### Pierwsza część interfejsu
```
$ Wpisz dzialanie matematyczne np.(13.2 / 2): 
  Wprowadzone dane:
```
### Druga część interfejsu
```
  Wybierz rodzaj przyblizenia: 
  1.Nearest
  2.Down
  3.Up
  4.To_zero
  5.Default
  Wybrano:
```
Po uruchomnieniu programu zostanie wyświetlony napis: "Wpisz dzialanie matematyczne np.(13.2 / 2): Wprowadzone dane:", należy wpisać liczbę (może nie być całkowita 1.22), następnie znak arytmetyczny z puli (+ - * /) a następnie ponownie liczbę. Przykładowy ciąg znaków: 13.2 + 9,  w innym przypadku zostanie wyświetlony komunikat "SYNTAX ERROR!!!". Po wpisaniu dziłania zostanie wyświetlone menu zaokrąglania. Należy wpisać numer wybranej przez nas opcji, w innym przypadku zostanie wyświetlony komunikat "SYNTAX ERROR!!!". Jeżeli chcemy podzielić przez zero zostanie wyświetlony komunikat "Nie mozna dzielic przez zero!" i program zostanie zakończony. Na końcu zostanie wyświetlony komunikat "Wynik: "
i zaokrąglona wartość wprowadzonego wcześniej wyrażenia arytmetycznego. Opcja zaokrąglenia DEFAULT NIE zaokrągla wyniku tylko wyświetla go z częścią ułamkową.
