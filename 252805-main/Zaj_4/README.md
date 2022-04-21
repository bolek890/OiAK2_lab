
 # OiAK-Laboratorium zajęcia czwarte
## Treść zadania 4:
Proszę napisać program w języku asemblera w architekturze 32 bit. Program powinien we wskazanym pliku BMP za pomocą techniki steganografii ukryć wiadomość tekstową podaną przez użytkownika. Powinien także umożliwić użytkownikowi odczyt ukrytej wiadomości z pliku BMP. Potrzebne są więc dwa tryby działania.
Uwagi:
* Dane ukrywamy na najmłodszych bitach pikseli. Proszę zbadać ile najmłodszych bitów pikseli można wykorzystać, żeby zmiany nie zmieniły znacząco obrazu (empirycznie)
* Proszę pamiętać że pliki BMP mogą mieć różną liczbę bitów na piksel.
* Do wczytywania i zapisywania plików, tudzież wczytywania parametrów z linii poleceń można (ale nie trzeba) użyć kodu w C. Natomiast główny algorytm steganograficzny musi być zrobiony w asemblerze.
* Proszę pamiętać, że pliki BMP mają strukturę i metadane (nagłówki), do operowania na plikach BMP można używać kodu w C.
## Kompilacja:
Program został napisany i zkompilowany za pomocą Visual Studio 2019
W katalogu znajduje się również plik wykonywalny .exe
## Interfejs programu:
### Pierwsza część interfejsu
```
>Prosze podac nazwe zdjecia (np. image.bmp): \image.bmp\
>Co chcesz zrobic?
>1. Zakoduj wiadomosc
>2. Odczytaj wiadomosc
>Opcja nr: 
```
### Druga część interfejsu
```
Dla opcji 1:
>Podaj wiadomosc do zapisania: \Ala ma kota\
>Prosze podac nazwe zdjecia po zakodowaniu wiadomosci (np: image2.bmp): \image2.bmp\
>(!) Wiadomosc zakodowana poprawnie!!!

Dla opcji 2:
(wyswietlana jest wiadomosc)
```
Po uruchomieniu programu zostanie wyświetlony napis: "Prosze podac nazwe zdjecia (np. image.bmp):", należy wpisać nazwę pliku graficznego o rozszerzeniu BMP, wraz z rozszerzeniem np. 'sample.bmp' (należy pamiętać aby plik BMP znajdował się w tej samej lokalizacji co prgoram główny. 
Nastepnie wybieramy opcję która nas interesuje wpisując cyfre 1 lub 2, wpisanie innej cyfry spowoduje wyłączenie programu.
Jeżeli wyświetlona zostanie opcja pierwszza, najeży wówczas wpisać iadomość którą chcemy zakodować i kliknąć ENTER. W przypadku wybrania opcji nr 2 zostanie wyświetlona wiadomość zakodowana w zdjęciu.
