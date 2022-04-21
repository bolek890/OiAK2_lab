 # OiAK-Laboratorium zajęcia trzecie
## Treść zadania 3:
Proszę napisać program w języku asemblera w architekturze 32 bit. Program powinien zapytać użytkownika o dwie całkowite liczby. Użytkownik wpisuje liczby w notacji hexadecymalnej (szestanstkowo). Program powinien wypisać na standardowe wyjście wynik mnożenia tych dwóch liczb.
Uwagi:
* liczby są podawane z klawiatury, a więc jako tekst, trzeba je sobie przekonwertować do obliczeń
* podane liczby mogą być bardzo duże, w szczególności możemy się umówić na limit 200 znaków (np CF00A1 - to jest 6 znaków)
* należy wykorzystać odpowiedni algorytm mnożenia dużych liczb (np. mnożenie przez części)
## Polecenia potrzebne do kompilacji:
```
$ as hex_calc.s --32 -o hex_calc.o -g
$ ld hex_calc.o -m elf_i386 -o hex_calc
```
## Interfejs programu:
### Pierwsza część interfejsu
```
$ ./hex_calc
Podaj liczbe:
```
Należy wpisać liczbę w postaci szesnastkowej z wielkimi literami np: 21AABB
### Druga część interfejsu
```
Kolejna liczba:
```
Należy wpisać następną liczbę w postaci szesnastkowej z wielkimi literami np: 21AABB

