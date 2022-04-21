# OiAK-Laboratorium zajęcia pierwsze
Treść zadania 1:
Program 32 bitowy, który wczytuje dane od użytkownika i wyświetla je w konsoli w postaci szyfru rot13. Znaki specjalne takie jak 'ą', 'ę', ' ', '=' pozostają bez zmian. Maksymalna długość łańcucha wprowadzonego przez użytkownika to 100 znaków.

Polecenia potrzebne do kompilacji:

ld rot13.o -m elf_i386 -o rot13

as rot13.s --32 -o rot13.o -g

Interfejs programu:
Program uruchamiany jest w terminalu Linuxa. Zostaje wyświetlony napis "Podaj zdanie: ". Należy wpisać wybrany przez nas ciąg znaków a następnie nacisnąć klawisz "Enter". Pojawi się komunikat: "Rot13: " a po nim nasze zdanie przekonwertowane na szyfr Rot13.
