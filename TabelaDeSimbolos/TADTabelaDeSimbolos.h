#ifndef TADTABELADESIMBOLO_H
#define TADTABELADESIMBOLO_H

#include <stdio.h>
#include <stdlib.h>

typedef struct Simbolo* ApontadorTabelaDeSimbolos;

typedef struct Simbolo{
    int id; // identificador do item
    char *tipo;
    char *nome;
    char *enderecoVarMem; // isso é o endereço da variável na memória
    char *valor;
} Simbolo;

typedef struct CelulaSimbolo* ApontadorListaDeTabelas;
typedef struct CelulaSimbolo { 
    Simbolo simbolo;
    struct CelulaSimbolo* pProx; // ponteiro para a próxima célula
} CelulaSimbolo;

typedef struct TabelaDeSimbolos{
    ApontadorListaDeTabelas pPrimeiro;// apontador para a celula cabeça
    ApontadorListaDeTabelas pUltimo;// Apontador para a ultima celula existente
} TabelaDeSimbolos; // guarda os símbolos da tabela, ou seja, os identificadores


// Funções para manipulação da Tabelas de Símbolos 
void FLVaziaTabela (TabelaDeSimbolos *pLista);
int EhVaziaTabela (TabelaDeSimbolos *pLista);
int LInsereSimbolo (TabelaDeSimbolos *pLista, char *tipo, char *nome, char *enderecoVarMem);
int LRemoveSimbolo (TabelaDeSimbolos *pLista, int id);
int ImprimeTabela(TabelaDeSimbolos *pLista);
Simbolo* buscaSimbolo(TabelaDeSimbolos *pLista, int id);

// Funções para manipulação do Símbolos da Tabela
int LInsereValorSimbolo(TabelaDeSimbolos *pLista, int id, char *valor); 
void ImprimeSimbolo(Simbolo *pSimbolo);

#endif