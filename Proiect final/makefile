
all:
	rm -f lex.yy.c limbaj y.tab.c y.tab.h
	yacc -d limbaj.y
	lex limbaj.l 
	gcc lex.yy.c y.tab.c -o limbaj
	./limbaj c.txt