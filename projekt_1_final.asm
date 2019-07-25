
	.globl main
	.data
	
size:		.space 4	# rozmiar pliku bmp
width:		.space 4	# szerokosc pliku bmp
height:		.space 4	# wysokosc pliku bmp
off:		.space 4	# offset - poczatek adres bitow w tablicy pikseli
temp:		.space 4	# bufor wczytywania
poczatek:	.space 4	# adres poczatku linijki
padding:	.space 1	# bufor wczytywania
red1:		.space 1	# bufor wczytywania
green1:		.space 1	# bufor wczytywania
blue1:		.space 1	# bufor wczytywania
red2:		.space 1	# bufor wczytywania
green2:		.space 1	# bufor wczytywania
blue2:		.space 1	# bufor wczytywania

hello:		.asciiz	"Cieniowanie trojkata\n"
opened:		.asciiz "Plik zostal pomyslnie otwarty\n"
input:		.asciiz	"in.bmp"
output:		.asciiz "out.bmp"
err1:		.asciiz "Blad odczytu pliku zrodlowego\n"
err2:		.asciiz "Blad tworzenia pliku docelowego\n"
		.text
	
main:	la $a0, hello	# wczytanie adresu stringa hello do rejestru a0
	li $v0, 4	# ustawienie syscall na wypisywanie stringa
	syscall		# wypisanie na ekranie zawartosci stringa hello
	
wczytaj_plik:
	la $a0, input	# wczytanie nazwy pliku do otwarcia
	li $a1, 0	# flagi otwarcia
	li $a2, 0	# tryb otwarcia
	li $v0, 13	# ustawienie syscall na otwieranie pliku
	syscall		# otwarcie pliku, zostawienie w $v0 jego deskryptora
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	
	bltz $t0, blad_plik	# przeskocz do blad_plik jesli wczytywanie sie nie powiodlo
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, temp	# wskazanie bufora wczytywania
	li $a2, 2	# ustawienie odczytu 2 pierwszych bajtow (BM)
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# odczytanie z pliku
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, size	# wskazanie zmiennej do przechowywania wczytanych danych
	li $a2, 4	# ustawienie odczytu 4 bajtow
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# wczytanie rozmiaru pliku do size
	
	lw $t7, size	# przekopiowanie rozmiaru pliku do rejestru t7
	
	move $a0, $t7	# przekopiowanie rozmiaru pliku do a0
	li $v0, 9	# ustawienie syscall na alokacje pamieci
	syscall		# zaalokowanie pamieci o rozmiarze pliku
	move $t1, $v0	# przekopiowanie adesu zaalokowanej pamieci do rejestru t1
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, temp	# wskazanie bufora wczytywania
	li $a2, 4	# ustawienie odczytu 4 bajtow zarezerwowanych
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# przejscie o 4 bajty od przodu
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, off	# wskazanie zmiennej do przechowywania offsetu
	li $a2, 4	# ustawienie odczytu 4 bajtow offsetu
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# wczytanie offsetu do off
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, temp	# wskazanie bufora wczytywania
	li $a2, 4	# ustawienie odczytu 4 bajtow - wielkosci naglowka informacyjnego
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# przejscie o 4 bajty od przodu
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, width	# wskazanie zmiennej do przechowywania szerokosci
	li $a2, 4	# ustawienie odczytu 4 bajtow - szerokosci
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# wczytanie szerokosci bitmapy
	
	lw $t2, width	# zaladowanie szerokosci do rejestru t2
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, height	# wskazanie zmiennej do przechowywania wysokosci
	li $a2, 4	# ustawienie odczytu 4 bajtow - wysokosci
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# wczytanie wysokosci bitmapy
	
	lw $t3, height	# zaladowanie wysokosci do rejestru t3
	
	move $a0, $t0	# przekopiowanie deskryptora pliku do a0
	li $v0, 16	# ustawienie syscall na zamkniecie pliku
	syscall		# zamkniecie pliku o deskryptorze w a0
	
alokacja_plik:
	la $a0, input	# wczytanie nazwy pliku do otwarcia
	li $a1, 0	# flagi otwarcia
	li $a2, 0	# tryb otwarcia
	li $v0, 13	# ustawienie syscall na otwieranie pliku
	syscall		# otwarcie pliku, zostawienie w $v0 jego deskryptora
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	
	bltz $t0, blad_plik	# przeskocz do blad_plik jesli wczytywanie sie nie powiodlo
	
	move $a0, $t0	# przekopiowanie deskryptora 
	la $a1, ($t1)	# wskazanie wczesniej zaalokowanej pamieci jako miejsca do wczytania
	la $a2, ($t7)	# ustawienie odczytu tylu bajtow ile ma plik
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall
	
	lw $t7, size	# ponowne wczytanie rozmiaru pliku do rejestru t7
	
	move $a0, $t0	# przekopiowanie deskryptora 
	li $v0, 16	# ustawienie syscall na zamkniecie pliku
	syscall		# zamkniecie pliku o deskryptorze w a0

padding_sprawdzenie:
	lw $t9, off		# zaladowanie offsetu do rejestru t9
	addu $t9, $t9, $t1	# przesuniecie na poczatek mapy pikseli
	
	li $t6, 4		# zaladowanie 4 do t6
	divu $t2, $t6		# dzielenie t2 przez t6, reszta z dzielenia w hi
	mfhi $t6		# przekopiowanie hi do t6
	
	li $s7, 1		# licznik pikseli w wierszu zainicjuj na 1
	
	mul $t8, $t2, $t3	# szerokosc * wysokosc
	mul $t8, $t8, 3		# pomnozenie przez 3 (3 bajty na pixel)
	
	beq $t6, 0, padding_0	# reszta = 0, czyli bez paddingu
	beq $t6, 1, padding_1	# reszta = 1, czyli padding 1 bajt na linijke
	beq $t6, 2, padding_2	# reszta = 2, czyli padding 2 bajty na linijke
	beq $t6, 3, padding_3	# reszta = 3, czyli padding 3 bajty na linijke
		
padding_0:
	addu $t8, $t8, $t1	# dodanie wskaznika pamieci
	lw $t6, off		# dodanie offsetu
	addu $t8, $t8, $t6	# w t8 mamy adres konca pliku
	li $t6, 0
	b zacznij_linijke

padding_1:
	mul $t6, $t3, 1		# ilosc bajtow paddingowych
	addu $t8, $t8, $t6	# dodanie paddingu
	addu $t8, $t8, $t1	# dodanie wskaznika pamieci
	lw $t6, off		# dodanie offsetu
	addu $t8, $t8, $t6	# w t8 mamy adres konca pliku
	mul $t6, $t3, 1
	li $t6, 1
	b zacznij_linijke
	
padding_2:
	mul $t6, $t3, 2		# ilosc bajtow paddingowych
	addu $t8, $t8, $t6	# dodanie paddingu
	addu $t8, $t8, $t1	# dodanie wskaznika pamieci
	lw $t6, off		# dodanie offsetu
	addu $t8, $t8, $t6	# w t8 mamy adres konca pliku
	mul $t6, $t3, 2
	li $t6, 2
	b zacznij_linijke
	
padding_3:
	mul $t6, $t3, 3		# ilosc bajtow paddingowych
	addu $t8, $t8, $t6	# dodanie paddingu
	addu $t8, $t8, $t1	# dodanie wskaznika pamieci
	lw $t6, off		# dodanie offsetu
	addu $t8, $t8, $t6	# w t8 mamy adres konca pliku
	mul $t6, $t3, 3
	li $t6, 3
	b zacznij_linijke
	
zacznij_linijke:
	sw $t6, padding
	sw $t9, poczatek
	j szukaj_poczatek
	
szukaj_poczatek:
	jal wczytaj_pixel		# wczytaj pixel do sprawdzenia
	
	bne $s0, 255, pocz_czarny	# szukanie czarnego piksela
	bne $s1, 255, pocz_czarny	# jesli znalazl to idz do pocz_czarny
	bne $s2, 255, pocz_czarny	# jak nie to szukaj dalej
	
	jal przesun_prawo
	bge $s7, $t2, koniec_linijki	# jesli doszedl do konca linijki, przeskocz do nowej
	
	j szukaj_poczatek
	
pocz_czarny:
	jal zapamietaj_pocz
	jal przesun_prawo
	bge $s7, $t2, koniec_linijki	# jesli doszedl do konca linijki, przeskocz do nowej
	
	jal wczytaj_pixel
	
	bne $s0, 255, pocz_czarny1	# szukanie nastepnego czarnego piksela po czarnym
	bne $s1, 255, pocz_czarny1	# jesli znalazl do idz do pocz_czarny1
	bne $s2, 255, pocz_czarny1	# jak nie to zacznij szukac konca
	
	jal przesun_prawo
	bge $s7, $t2, koniec_linijki	# jesli doszedl do konca linijki, przeskocz do nowej
	
	j szukaj_koniec
	
pocz_czarny1:
	jal zapamietaj_pocz
	jal przesun_prawo
	bge $s7, $t2, koniec_linijki	# jesli doszedl do konca linijki, przeskocz do nowej
	
	j szukaj_koniec
	
szukaj_koniec:
	jal wczytaj_pixel
	
	bne $s0, 255, kon	# szukanie czarnego piksela
	bne $s1, 255, kon	# jesli znalazl do idz do kon
	bne $s2, 255, kon	# jak nie to szukaj dalej
	
	jal przesun_prawo
	bge $s7, $t2, koniec_linijki	# jesli doszedl do konca linijki, przeskocz do nowej
	
	j szukaj_koniec
	
kon:
	jal zapamietaj_kon
	
	j gradient
	
gradient:
	move $t9, $t3 		# przesun sie na poczatek gradientu
	jal przesun_prawo_bezw
	j rysuj
	
rysuj:
	jal pokoloruj
	jal przesun_prawo_bezw
	bge $t9, $t4, koniec_linijki	# jesli skonczyl rysowac do przeskocz do nowej linijki
	j rysuj

	
koniec_linijki:
	lw $t9, poczatek		# przesun sie na poczatek linijki
	
	mul $a0, $t2, 3		
	addu $t9, $t9, $a0	# dodaj bajty szerokosci
	
	lb $t6, padding
	addu $t9, $t9, $t6	# dodaj padding, wtedy nastepuje przejscie do nastepnej linijki
	
	li $s7, 1		# zresetuj licznik linijki
	li $t3, 0		# zresetuj adres poczatku gradientu
	li $t4, 0		# zresetuj adres konca gradientu
	
	bge $t9, $t8, zapisz_plik
	j zacznij_linijke
	
zapisz_plik:
	la $a0, output	# wczytanie nazwy pliku do otwarcia
	li $a1, 1	# flagi otwarcia
	li $a2, 0	# tryb otwarcia
	li $v0, 13	# ustawienie syscall na otwieranie pliku
	syscall		# otwarcie pliku, zostawienie w $v0 jego deskryptora
	
	move $v0, $t0	# przekopiowanie deskryptora do rejestru t0
	lw $t7, size
	
	bltz $t0, blad_plik_out	# przeskocz do blad_plik_out jesli wczytywanie sie nie powiodlo
	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, ($t1)	# wskazanie wczesniej zaalokowanej pamieci jako danych do zapisania
	la $a2, ($t7)	# ustawienie zapisu tylu bajtow ile ma plik
	li $v0, 15	# ustawienie syscall na zapis do pliku
	syscall		# wczytanie wysokosci bitmapy
	
	j zamknij_plik	# zamknij plik
	
blad_plik:
	la $a0, err1
	li $v0, 4
	syscall
	j koniec
	
blad_plik_out:
	la $a0, err2
	li $v0, 4
	syscall
	j koniec
	
zamknij_plik:
	move $a0, $t0	# przekopiowanie deskryptora pliku do a0
	li $v0, 16	# ustawienie syscall na zakmniecie pliku
	syscall		# zamkniecie pliku o deskryptorze w a0

koniec:	li $v0, 10	# ustawienie syscall na terminate
	syscall		# wyjscie z programu

wczytaj_pixel:
	lbu $s0, ($t9)		# wczytaj red piksela do s0 // powinno byc blue
	addiu $t9, $t9, 1

	lbu $s1, ($t9)		# wczytaj green piksela do s1
	addiu $t9, $t9, 1
	
	lbu $s2, ($t9)		# wczytaj blue piksela do s2 // powinno byc red
	
	subiu $t9, $t9, 2

	jr $ra

przesun_prawo:
	addiu $t9, $t9, 3
	addiu $s7, $s7, 1
	
	jr $ra

przesun_prawo_bezw:
	addiu $t9, $t9, 3
	
	jr $ra

przesun_lewo:
	subiu $t9, $t9, 3
	
	jr $ra
	
pokoloruj:
	subu $s4, $t9, $t3	# odleglosc wzgledem poczatku
	subu $s3, $t4, $t9	# odleglosc wzgledem konca
	
	#div $s4, $s4, 3
	#div $s3, $s3, 3

	lbu $a1, red1
	mul $a1, $a1, $s3	# odleglosc1 * red1
	
	lbu $a2, red2
	mul $a2, $a2, $s4	# odleglosc2 * red2
	
	add $a1, $a1, $a2	# odleglosc1 * red1 + odleglosc2 * red2
	
	li $a2, 0
	add $a2, $a2, $s3
	add $a2, $a2, $s4	# odleglosc1 + odleglosc2
	
	divu $a1, $a1, $a2	# srednia wazona
	
	sb $a1, ($t9)		# zapisz red piksela
	
	addi $t9, $t9, 1
	
	lbu $a1, green1
	mul $a1, $a1, $s3	# odleglosc1 * green1
	
	lbu $a2, green2
	mul $a2, $a2, $s4	# odleglosc2 * green2
	
	add $a1, $a1, $a2	# odleglosc1 * green1 + odleglosc2 * green2
	
	li $a2, 0
	add $a2, $a2, $s3
	add $a2, $a2, $s4	# odleglosc1 + odleglosc2
	
	divu $a1, $a1, $a2	# srednia wazona
	
	sb $a1, ($t9)		# zapisz green piksela
	
	addi $t9, $t9, 1
	
	lbu $a1, blue1
	mul $a1, $a1, $s3	# odleglosc1 * blue1
	
	lbu $a2, blue2
	mul $a2, $a2, $s4	# odleglosc2 * blue2
	
	add $a1, $a1, $a2	# odleglosc1 * blue1 + odleglosc2 * blue2
	
	li $a2, 0
	add $a2, $a2, $s3
	add $a2, $a2, $s4	# odleglosc1 + odleglosc2
	
	divu $a1, $a1, $a2	# srednia wazona
	
	sb $a1, ($t9)		# zapisz blue piksela
	
	subi $t9, $t9, 2
	
	jr $ra
	
zapamietaj_pocz:
	sb $s0, red1
	sb $s1, green1
	sb $s2, blue1
	
	move $t3, $t9
	
	jr $ra
	
zapamietaj_kon:
	sb $s0, red2
	sb $s1, green2
	sb $s2, blue2
	
	move $t4, $t9
	
	jr $ra
