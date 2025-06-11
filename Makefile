.PHONY: all lex yacc clean

LEX_SRC = Lex/lex.l
YACC_SRC = sintaxe.y
EXEC = out

LEX_C = lex.yy.c
YACC_C = y.tab.c
YACC_H = y.tab.h

CC = gcc

all: yacc lex $(EXEC)

yacc:
	yacc -v -d $(YACC_SRC)

lex:
	flex -o $(LEX_C) $(LEX_SRC)

$(EXEC): $(LEX_C) $(YACC_C)
	$(CC) $(LEX_C) $(YACC_C) -o $(EXEC)

exec: 
	./out < teste.txt

exec_input:
	./out -d

clean:
	rm -f $(LEX_C) $(YACC_C) $(YACC_H) $(EXEC)
