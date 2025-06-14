#include <stdio.h>
#include <stdlib.h>
#include "TabelaDeSimbolos/TADListaDeTabelas.h"
#include "TabelaDeSimbolos/TADTabelaDeSimbolos.h"

extern int yyparse();
extern FILE *yyin;
ListaDeTabelas listaDeTabelas;
TabelaDeSimbolos tabelaDeSimbolos;


void imprimeProgramaNumerado(char *fileName){
    FILE *file = fopen(fileName, "r");
    if (!file){
        fprintf(stderr, "Erro: Não foi possível abrir o arquivo '%s'\n", fileName);
        exit(1);
    }

    printf("\n==== Código Fonte ====\n");
    char linha[1024];
    int numeroLinha = 1;
    while (fgets(linha, sizeof(linha), file)){
        printf("%d  %s", numeroLinha, linha);
        numeroLinha++;
    }
    printf("\n\n");

    rewind(file);
    yyin = file;
}

int main(int argc, char **argv){

    FLVaziaListaTabela(&listaDeTabelas);
    FLVaziaTabela(&tabelaDeSimbolos);
    LInsereListaTabela(&listaDeTabelas, &tabelaDeSimbolos);

    if (argc != 2){
        fprintf(stderr, "Envie um arquivo de entrada.\n");
        return 1;
    }

    imprimeProgramaNumerado(argv[1]);
    yyparse();
    printf("O Programa está sintaticamente correto!\n");
    
    return 0;
}