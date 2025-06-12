#ifndef TADLISTADETABELAS_H
#define TADLISTADETABELAS_H

#include <stdio.h>
#include <stdlib.h>

#include "TADTabelaDeSimbolos.h"


typedef struct {
    ApontadorTabelaDeSimbolo pPrimeiro;
    ApontadorTabelaDeSimbolo pUltimo;
} ListaDeTabelas;


// Funções para manipulação da Lista de Tabelas 
void FLVaziaListaTabela (ListaDeTabelas *pLista);
int EhVaziaLista (ListaDeTabelas *pLista);
int LInsereListaTabela(ListaDeTabelas *pLista, TabelaDeSimbolo *pTabela);
int LRemoveListaTabela(ListaDeTabelas *pLista, TabelaDeSimbolo *pTabela);
int ImprimeListaTabela(ListaDeTabelas *pLista);
TabelaDeSimbolo* LBuscaTabela(ListaDeTabelas *pLista, TabelaDeSimbolo *pTabela);

#endif