#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h> 
#include <sys/types.h>
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


void geraCodigoTresEnderecos(FILE *codigo, QuadruplaCodigo quadrupla){
    
    
    if (codigo == NULL){
        printf("Um erro ocorreu ao abrir o txt do código de três endereços.\n");
    }
    if (quadrupla.op == NULL){
        fprintf(codigo, "%s = %s\n", quadrupla.result, quadrupla.arg1);
        // printf("%s = %s\n", quadrupla.result, quadrupla.arg1);
    }
    else if (strcmp(quadrupla.op, "GOTO") == 0){
        fprintf(codigo, "%s: %s\n", quadrupla.op, quadrupla.result);
        // printf("%s: %s\n", quadrupla.op, quadrupla.result);
    }
    else if (strcmp(quadrupla.op, "LABEL") == 0){
        fprintf(codigo, "%s:\n", quadrupla.result);
        // printf("%s:\n", quadrupla.result);
    }
    else if (strcmp(quadrupla.op, "IfFalse") == 0){
        fprintf(codigo, "IfFalse %s goto %s\n", quadrupla.arg1, quadrupla.result);
        // printf("IfFalse %s goto %s\n", quadrupla.arg1, quadrupla.result);
    }
    else{
        fprintf(codigo, "%s = %s %s %s\n", quadrupla.result, quadrupla.arg1, quadrupla.op, quadrupla.arg2);
        // printf("%s = %s %s %s\n", quadrupla.result, quadrupla.arg1, quadrupla.op, quadrupla.arg2);
    }
}

void imprimeVetor(vetorQuadruplas *vetor) {
    FILE *codigo;
    int codigoExiste = 1;

    // Verifica se a pasta existe; se não, cria
    if (access("CodigosTresEnderecos", F_OK) == -1) {
        if (mkdir("CodigosTresEnderecos", 0755) == -1) {
            perror("Erro ao criar a pasta CodigosTresEnderecos");
            exit(EXIT_FAILURE);
        }
    }

    // Verifica se o arquivo de código de três endereços já existe
    if (access("CodigosTresEnderecos/codigo_tres_enderecos.txt", F_OK) == -1) {
        codigo = fopen("CodigosTresEnderecos/codigo_tres_enderecos.txt", "a");
    } else {
        char nomeArquivo[100];
        sprintf(nomeArquivo, "CodigosTresEnderecos/codigo_tres_enderecos (%d).txt", codigoExiste);
        while (access(nomeArquivo, F_OK) == 0) {
            codigoExiste++;
            sprintf(nomeArquivo, "CodigosTresEnderecos/codigo_tres_enderecos (%d).txt", codigoExiste);
        }
        codigo = fopen(nomeArquivo, "a");
    }

    for (int i = 0; i < vetor->tamanho; i++) {
        geraCodigoTresEnderecos(codigo, vetor->quadrupla[i]);
    }

    fclose(codigo);
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
    imprimeVetor(&vetor_quadruplas);

    return 0;
}