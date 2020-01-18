all: build strip

build:
	gcc -O2 fw-reboot-needed.c -static -o fw-reboot-needed

strip:
	strip fw-reboot-needed

clean:
	rm fw-reboot-needed
