#ifndef TADTABELADESIMBOLOS_H
#define TADTABELADESIMBOLOS_H

#include <stdio.h>
#include <stdlib.h>

typedef struct Simbolo{
    int id;
    char *tipo;
    char *nome;
    char *args;
    char *valor;
} Simbolo;

typedef struct CelulaSimbolo* ApontadorTabelaDeSimbolos;
typedef struct CelulaSimbolo { 
    Simbolo simbolo;
    struct CelulaSimbolo* pProx;
} CelulaSimbolo;

typedef struct TabelaDeSimbolos{
    ApontadorTabelaDeSimbolos pPrimeiro;
    ApontadorTabelaDeSimbolos pUltimo;
} TabelaDeSimbolos;


// Funções para manipulação da Tabelas de Símbolos 
void FLVaziaTabela (TabelaDeSimbolos *pLista);
int EhVaziaTabela (TabelaDeSimbolos *pLista);
void LInsereSimboloTabela (TabelaDeSimbolos *pLista, char *tipo, char *nome, char *args);

void ImprimeTabela(TabelaDeSimbolos *pLista);
Simbolo buscaSimbolo(TabelaDeSimbolos *pLista, char * nome);

// Funções para manipulação do Símbolos da Tabela
int LInsereValorSimbolo(TabelaDeSimbolos *pLista, int id, char *valor); 

#endif