.PHONY: all lex yacc clean

LEX_SRC = Lex/lex.l
YACC_SRC = translate.y
MAIN_SRC = main.c
EXEC = compiler

LEX_C = lex.yy.c
YACC_C = translate.tab.c
YACC_H = translate.tab.h

TS_SRC = TabelaDeSimbolos/TADListaDeTabelas.c TabelaDeSimbolos/TADTabelaDeSimbolos.c EstruturasAuxiliares/QuadruplaCodigo.c

CC = gcc

all: yacc lex $(EXEC)

yacc:
	bison -v -d $(YACC_SRC)

lex:
	flex -o $(LEX_C) $(LEX_SRC)

$(EXEC): $(LEX_C) $(YACC_C) $(MAIN_SRC) $(TS_SRC)
	$(CC) $(MAIN_SRC) $(LEX_C) $(YACC_C) $(TS_SRC) -o $(EXEC)

clean:
	rm -f $(LEX_C) $(YACC_C) $(YACC_H) $(EXEC)
