#ifndef TADTABELADESIMBOLOS_H
#define TADTABELADESIMBOLOS_H

#include <stdio.h>
#include <stdlib.h>

typedef struct Simbolo{
    int id;
    char *tipo;
    char *nome;
    int enderecoVarMem;
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
int LInsereSimboloTabela (TabelaDeSimbolos *pLista, char *tipo, char *nome, int enderecoVarMem);

int ImprimeTabela(TabelaDeSimbolos *pLista);
Simbolo buscaSimbolo(TabelaDeSimbolos *pLista, char * nome);

// Funções para manipulação do Símbolos da Tabela
int LInsereValorSimbolo(TabelaDeSimbolos *pLista, int id, char *valor); 
void ImprimeSimbolo(Simbolo *pSimbolo);

#endif