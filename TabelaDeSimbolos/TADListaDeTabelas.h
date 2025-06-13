#ifndef TADLISTADETABELAS_H
#define TADLISTADETABELAS_H

#include <stdio.h>
#include <stdlib.h>

#include "TADTabelaDeSimbolos.h"

typedef struct CelulaListaDeTabelas* ApontadorListaDeTabelas;
typedef struct CelulaListaDeTabelas { 
    TabelaDeSimbolos tabela;
    struct CelulaListaDeTabelas* pProx; 
} CelulaListaDeTabelas;

typedef struct {
    ApontadorListaDeTabelas pPrimeiro;
    ApontadorListaDeTabelas pUltimo;
} ListaDeTabelas;


// Funções para manipulação da Lista de Tabelas 
void FLVaziaListaTabela (ListaDeTabelas *pLista);
int EhVaziaLista (ListaDeTabelas *pLista);
int LInsereListaTabela(ListaDeTabelas *pLista, TabelaDeSimbolos *pTabela);
int LRemoveListaTabela(ListaDeTabelas *pLista);
int ImprimeListaTabela(ListaDeTabelas *pLista);
char* LBuscaTabela(ListaDeTabelas *pLista, char * variavel);

#endif