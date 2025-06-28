#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TabelaDeSimbolos/TADListaDeTabelas.h"
#include "TabelaDeSimbolos/TADTabelaDeSimbolos.h"
#include "EstruturasAuxiliares/QuadruplaCodigo.h"

extern int yyparse();
extern FILE *yyin;
ListaDeTabelas listaDeTabelas;
TabelaDeSimbolos tabelaDeSimbolos;
vetorQuadruplas vetor_quadruplas;

// Imprime o programa fonte com as linhas numeradas.
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

    inicializarVetor(&vetor_quadruplas, 10);

    // Inicializando a lista de tabelas e adicionando a tabela do escopo global
    FLVaziaListaTabela(&listaDeTabelas);
    FLVaziaTabela(&tabelaDeSimbolos);
    LInsereListaTabela(&listaDeTabelas, &tabelaDeSimbolos);
    char *extensao = strrchr(argv[1], '.');

    if (argc != 2){
        fprintf(stderr, "Envie um arquivo de entrada.\n");
        return 1;
    }
    
    // verificando se o arquivo enviado tem a extensão correta
    if (extensao != NULL){
        if (strcmp(extensao, ".craft") != 0) {
            printf("Envie um arquivo com uma extensão .craft!");
            return 1;
        }
    }
        

    imprimeProgramaNumerado(argv[1]);
    yyparse();
    printf("\nO Programa está sintaticamente correto!\n");
    
    //TODO: depois fazer uma função que lê as quadruplas e coloca no txt como código de três endereços;

    return 0;
}