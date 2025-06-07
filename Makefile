# Arquivos
LEX_SRC = Lex/lex.l
YACC_SRC = sintaxe.y
EXEC = out

# Arquivos gerados
LEX_C = lex.yy.c
YACC_C = y.tab.c
YACC_H = y.tab.h

# Compilador
CC = gcc

# Regras
all: $(EXEC)

$(YACC_C): $(YACC_SRC)
	yacc -d $(YACC_SRC)

$(LEX_C): $(LEX_SRC)
	flex -o $(LEX_C) $(LEX_SRC)

$(EXEC): $(LEX_C) $(YACC_C)
	$(CC) $(LEX_C) $(YACC_C) -o $(EXEC)

clean:
	rm -f $(LEX_C) $(YACC_C) $(YACC_H) $(EXEC)
