

#include <iostream>
#include <fstream>
#include <string>

using namespace std;

//struktura przechowujaca dany pixel w pamieci
struct Pixel
{
	unsigned char red;
	unsigned char green;
	unsigned char blue;
};

char* bitMap = NULL;
int width = 0, height = 0, lineSize = 0, sizeOfData = 0;
//tablica przechowujaca 'naglowek zdjecia'
unsigned char header[54];
struct Pixel* photo_pixels = NULL;


// funkcja odczytujaca zdjecie BMP
bool loadBMPfile(char* BmpfielName)
{
	FILE* bitmapFile;
	//otwieranie w trybie binarnym, potrzebnym do edycji pliku
	fopen_s(&bitmapFile, BmpfielName, "rb");

	if (bitmapFile == NULL)
	{

		cout << "(!) Nie mozna otworzyc zdjecia!!!";
		return false;
	}

	//teorzenie adresow prtrzebnych do kodow asemblerowych
	//odczytanie naglowka pliku za pomoca funkcji fread
	fread(header, sizeof(unsigned char), 54, bitmapFile);
	unsigned char* header_address = &header[0];
	int* width_address = &width;
	int* height_address = &height;
	int* sizeOfData_address = &sizeOfData;

	//odczywywanie poszczegolnych atrybutow zdjecia za pomoca funkcji asemblerowych
	__asm
	{
		mov		esi, header_address
		// odczyt rozdzielczosci zdjecia - szerokosc
		mov		edi, width_address

		movzx	eax, BYTE PTR[esi + 18]
		mov		BYTE PTR[edi], al

		movzx	eax, BYTE PTR[esi + 19]
		mov		BYTE PTR[edi + 1], al

		movzx	eax, BYTE PTR[esi + 20]
		mov		BYTE PTR[edi + 2], al

		movzx	eax, BYTE PTR[esi + 21]
		mov		BYTE PTR[edi + 3], al

		// odczyt rozdzielczosci zdjecia - wysokosc
		mov		edi, height_address

		movzx	eax, BYTE PTR[esi + 22]
		mov		BYTE PTR[edi], al

		movzx	eax, BYTE PTR[esi + 23]
		mov		BYTE PTR[edi + 1], al

		movzx	eax, BYTE PTR[esi + 24]
		mov		BYTE PTR[edi + 2], al

		movzx	eax, BYTE PTR[esi + 25]
		mov		BYTE PTR[edi + 3], al

		// rozmiar widocznego rozmiaru zdjecia (nie liczac naglowka)
		mov		edi, sizeOfData_address

		movzx	eax, BYTE PTR[esi + 34]
		mov		BYTE PTR[edi], al

		movzx	eax, BYTE PTR[esi + 35]
		mov		BYTE PTR[edi + 1], al

		movzx	eax, BYTE PTR[esi + 36]
		mov		BYTE PTR[edi + 2], al

		movzx	eax, BYTE PTR[esi + 37]
		mov		BYTE PTR[edi + 3], al
	}

	int* lineSize_address = &lineSize;

	//bajty wypełniające mogą być dodawane na końcu każdego wiersza od liczby bajtów
	//mnożymy szerokosc *3 poniewaz kazdy piksel to BGR (trzy kolory)
	__asm
	{	
		mov		esi, width_address
		mov		eax, [esi]
		mov		ebx, 3
		mul		ebx	
		add		eax, 3
		not ebx
		and eax, ebx
		mov		ecx, lineSize_address
		mov		DWORD PTR[ecx], eax
	}

	// stworzenie miejsca na nowy plik BMP
	bitMap = new char[lineSize];
	//tablica przechowujaca informacje na temat kolorow kazdego piksela
	photo_pixels = new Pixel[width * height];
	// licznik pikseli
	int counter_pixel = 0;

	// poniewaz czytamy pilk od konca kolejnosc kolorow jest rozna , zamiast RGB mamy wiec BGR
	for (int row = 0; row < height; row++)
	{
		//odczytanie wartosci pojedynczej linii
		fread(bitMap, sizeof(unsigned char), lineSize, bitmapFile);
		
		//odczyt kazdego piksela w linii
		for (int col = 0; col < width * 3; col += 3)
		{
			// odczyt piksela niebieskiego i zapis do struktury
			photo_pixels[counter_pixel].blue = bitMap[col];
			// odczyt zielonego niebieskiego i zapis do struktury
			photo_pixels[counter_pixel].green = bitMap[col + 1];
			// odczyt czerownego niebieskiego i zapis do struktury
			photo_pixels[counter_pixel].red = bitMap[col + 2];
			//przjescie do kolejnego piksela
			counter_pixel++;
		}
	}

	//zamkniecie pliku 
	fclose(bitmapFile);

	// w przypadku poprawnego odczytu bitmapy = true
	return true;
}

// funkcja tworzaca nowy plik BMp z podana nazwą
void writeBMPfile(char* BmpfielName)
{
	char* photo = NULL;

	// tablica przechowujaca dane mapy bitowej
	photo = new char[sizeOfData];


	// tam gdzie nie sa potrzebne bity wypelniajace czyli gdzie szerokosc jest wielokrotnoscia 4
	if (width % 4 == 0)
	{
		//iterator dla kazdego piksela
		int it_px = 0;

		//wczytywanie danych o kolorach kazdeko piksela w mapie bitowej
		for (int pixel = 0; pixel < height * width; pixel++)
		{
			// zapisanie wartosci bajtu niebieskiego
			photo[it_px] = photo_pixels[pixel].blue;
			// zapisanie wartosci bajtu zielonego
			photo[it_px + 1] = photo_pixels[pixel].green;
			// zapisanie wartosci bajtu czerwonego
			photo[it_px + 2] = photo_pixels[pixel].red;

			//przejscie do kolejnych wartosci danego piksela
			it_px = it_px +3;
		}
	}
	//przypadek gdzie bity wypelaniajace sa konieczne
	else
	{

		int it_px = 0;
		int line_nr = 0;

		// przejscie po kazdym pikselu
		for (int pixel = 0; pixel < height * width; pixel++)
		{
			if (pixel == (width * (line_nr + 1)))
			{
				//przechodzienie do kolejnej linii pikseli
				line_nr++;
				// pominiecie bitow wypelnienia
				it_px = 0;
			}
			// zapisanie wartosci bajtu niebieskiego
			photo[(lineSize * line_nr) + (it_px)] = photo_pixels[pixel].blue;
			// zapisanie wartosci bajtu zielonego
			photo[(lineSize * line_nr) + (it_px + 1)] = photo_pixels[pixel].green;
			// zapisanie wartosci bajtu czerwonego
			photo[(lineSize * line_nr) + (it_px + 2)] = photo_pixels[pixel].red;
			// przejiscie do kolejnego pixela
			it_px = it_px + 3;
		}

	}
	// tworzenie nowego pilku bmp z wiadomoscia
	FILE* newBitmapFile;
	// otwarcie go w trybie zapisu binarnego
	fopen_s(&newBitmapFile, BmpfielName, "wb");
	// stworzenie naglowka BMP 
	fwrite(&header, sizeof(char), 54, newBitmapFile);
	// przypisanie kolorow pikseli
	fwrite(photo, sizeof(char), sizeOfData, newBitmapFile);
	// zamkniecie pliku z zaszyforwana wiadomoscia
	fclose(newBitmapFile);

	delete[] photo;
	photo = NULL;
}

// funkcja rozbijajaca kazdy znak ascii na cztery bity mniej znaczacie i 4 bity znaczace
extern "C" void make_bits(int& pixels_address, int& char_address)
{
	__asm
	{
		// pobranie adresow wiadomosci uzytkownika i adresu tablicy z informacjami o pikselach
		mov		esi, char_address
		mov		edi, pixels_address
		//pobranie 4 bitow mniej znaczacych
		movzx	eax, BYTE PTR[esi]
		and eax, 0Fh
		movzx	ebx, BYTE PTR[edi]
		// ustawianie 4 nizszych bitow w kolorze czerwonym
		and ebx, 0F0h
		or eax, ebx
		// nadpisanie znaku w tablicy pikseli
		mov		BYTE PTR[edi], al
		// pobranie 4 wyzszych bitow z znaku ASCII
		movzx	eax, BYTE PTR[esi]
		and eax, 0F0h
		// ustawienie 4 mniej znaczacych bitow w kolorze zielonym
		shr		eax, 4
		movzx	ebx, BYTE PTR[edi + 1]
		and ebx, 0F0h
		or eax, ebx
		// nadpisanie znaku w tablicy pikseli
		mov		BYTE PTR[edi + 1], al
	}
}

// funkcja zapisujaca przetworzona tablice znaków ASCII do mapy bitowej
extern "C" void writein_BMP_message(Pixel* photo_pixels_address, string msg)
{
	// stworznie zmiennych przechowujacych adres potrzebnej aktualnie zmiennej w kodzie asemblera
	char* msg_address = &msg[0];
	int msg_len = msg.length();

	// przypisanie struktury przechowujacej informacje o kolorach poszczególnych pikseli
	photo_pixels_address = photo_pixels;
	int pixels_array_size = sizeOfData;

	// blok kodu niskiego poziomu
	__asm
	{
		// przygotowanie iteratorów petli dla tablicy wiadomosci i tablicy struktur Pixel
		xor ecx, ecx
		xor edx, edx
		// na pierwszych 4 bajtach bedzie przechowywana dlugosc zakodowanej wiadomosci
		mov		edi, photo_pixels_address
		mov		ebx, msg_len
		mov		DWORD PTR[edi], ebx
		// przechodzimy dalej przez pierwsze dwa piksele
		add		edx, 6
		// poczatek petli kodowana znakow w zdjeciu
		start_loop:
		// jesli koniec wiadomosci to przerwij petle
		cmp		ecx, msg_len
			jge		end_loop
			mov		esi, msg_address
			mov		edi, photo_pixels_address
			// zapisanie adresu piksela do eax
			mov		eax, edi
			add		eax, edx
			// adres znaku do ebx
			mov		ebx, esi
			add		ebx, ecx
			push	ecx
			push	edx
			//kodowanie aktualnego znaku - wywolanie funkcji make_bits
			push	ebx
			push	eax
			call	make_bits
			add		esp, 8
			// wez rejestry ze stosu bo byly uzywane w funkcji make_bits
			pop		edx
			pop		ecx
			//przejdz do kolejnego znaku
			inc		ecx	
			//przejdz do kolejnego piksela
			add		edx, 3	
			// rozpocznij kodowanie dla kolejnego znaku od poczatku
			jmp		start_loop
			end_loop:
	}
}

// funkcja odkodowujaca znaki z dwoch kolorow w pikselu z wczytanego pliku BMP
extern "C" void read_bits(int& pixels_address, int& char_address) 
{
	// funkacja w coalosci wykonana w kodzie asemblera
	__asm
	{
		// zaladowanie pustej pamieci na znaki oraz informacje o kolorach 
		// pikseli z ktorych te znaki beda pozyskiwane
		mov		esi, pixels_address
		mov		edi, char_address
		// pobranie 4 mniej znaczacych bitow z koloru czerwonego
		// ustawienie 4 mniej znaczacych bitow znaku
		// zapisanie w tablicy znakow
		movzx	eax, BYTE PTR[esi]
		and eax, 0Fh
		movzx	ebx, BYTE PTR[edi]
		and ebx, 0F0h
		or eax, ebx
		mov		BYTE PTR[edi], al
		// pobranie 4 mniej znaczacych bitow z koloru zielonego
		// ustawienie 4 znaczacych bitow znaku
		// zapisanie w tablicy znakow w miejcu bitow znaczacych
		movzx	eax, BYTE PTR[esi + 1]
		and eax, 0Fh
		shl		eax, 4
		movzx	ebx, BYTE PTR[edi]
		and ebx, 0Fh
		or eax, ebx
		mov		BYTE PTR[edi], al
	}
}

// funkcja odczytujaca tekst z pikseli wczytanech ze zdjecia
extern "C" char* readfrom_BMP_message(Pixel * photo_pixels_address)
{
	// stworznie zmiennych potrzbnych w funkcji
	photo_pixels_address = photo_pixels;
	int pixels_array_size = sizeOfData;

	//stworznie tablicy przechowujacej odczytywana wadomocs
	char* msg_address = new char[pixels_array_size];
	int msg_len;

	// kod asemblerowy odczytujacy kazdy pojedynczy piksel
	__asm
	{
		// przygotowanie iteratorów petli dla tablicy wiadomosci i tablicy struktur Pixel
		xor ecx, ecx
		xor edx, edx
		// zczytanie pierwszych czterech bajtow z dlugoscia wiadomosci z pikseli zdecia
		mov		esi, photo_pixels_address
		mov		ebx, DWORD PTR[esi]
		mov		msg_len, ebx
		// pominiecie dwoch pierwszych pikseli
		add		ecx, 6
		// poczatke petli w ktorej odczytywanie bedzie kazdy piksel
		start_loop :
		// jezeli przeszlismy po wszystkich to koniec operacji
		cmp		edx, msg_len
			jge		end_loop

			mov		esi, photo_pixels_address
			mov		edi, msg_address
			// zapisanie adresu znaku do rejestru ebx i piksela do eax
			mov		ebx, edi
			add		ebx, edx
			mov		eax, esi
			add		eax, ecx
			// zabezpieczenie wartosci relestrow na stosie
			push	ecx
			push	edx
			// odkodowanianie wiadomosci
			push	ebx
			push	eax
			call	read_bits
			add		esp, 8
			pop		edx
			pop		ecx
			// przjescie do kojelnego naku i kolejnego piksela w tablicy
			inc		edx
			add		ecx, 3
			jmp		start_loop
			end_loop :
		mov		BYTE PTR[edi + edx], 0
	}

	return msg_address;
}

// funkcja main 
int main()
{
	string src_filename, dest_filename, msg;
	int option;
	int msg_option;

	//Wczytanie zdjęcia
	cout << "Prosze podac nazwe zdjecia (np: image.bmp):";
	cin >> src_filename;
	bool read = loadBMPfile(&src_filename[0]);

	cout << " Co chcesz robic?" <<endl;
	cout << "1. Zakoduj wiadomosc" << endl;
	cout << "2. Odczytaj wiadomosc" << endl;
	cout << "Opcja nr: ";
	cin >> option;

	if (option == 1) {
		//Wczytanie wiadomości
		cout << "Podaj wiadomosc do zapisania: ";
		cin.ignore();
		msg.clear();
		getline(cin, msg);

		//kodowanie wiadomości
		writein_BMP_message(photo_pixels, msg);

		//Zapisanie wiadomosci
		cout << "Prosze podac nazwe zdjecia po zakodowaniu wiadomosci: (np: image2.bmp):";
		cin >> dest_filename;
		writeBMPfile(&dest_filename[0]);

		cout << endl << "(!) Wiadomosc zakodowana poprawnie!!!" << endl;
	}
	else if (option == 2) {
		string msgTT = readfrom_BMP_message(photo_pixels);
		cout << msgTT << endl;
	}
	else
		return 0;
}

