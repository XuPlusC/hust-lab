PROG=lexer.exe

all::
	gcc -o $(PROG) main.c re.c fa.c

.PHONY=clean run gdb

clean:
	rm -fr $(PROG) 

run:
	./$(PROG)

gdb:
	gdb $(PROG)

