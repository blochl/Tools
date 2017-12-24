all: build strip

build:
	gcc -O3 exp.c -static -o exp -lm

strip:
	strip exp

clean:
	rm -f exp tmpdat.dat compare.png tags
