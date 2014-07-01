width=1000
height=1000

all: gra

gra: gra.c runda.o
	gcc -D SZEROKOSC=${width} -D WYSOKOSC=${height} -Wall -pedantic -o gra gra.c runda.o

runda.o: runda.asm
	nasm -D SZEROKOSC=${width} -D WYSOKOSC=${height} -f elf64 runda.asm

test:
	chmod +x test.sh
	./test.sh

clean:
	rm -f *~ *.o life *.out
