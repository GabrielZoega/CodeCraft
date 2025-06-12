#include "TADListaDeTabelas.h"

void FLVaziaListaTabela(ListaDeTabelas *pLista)
{
    pLista->pPrimeiro = (ApontadorTabelaDeSimbolo)malloc(sizeof(TabelaDeSimbolo));
    pLista->pUltimo = pLista->pPrimeiro;
    pLista0
}

int EhVaziaLista(ListaDeTabelas *pLista)
{
    return (pLista->pPrimeiro == NULL);
}

int LInsereListaTabela(ListaDeTabelas *pLista, TabelaDeSimbolo *pTabela)
{
}

int LRemoveListaTabela(ListaDeTabelas *pLista, TabelaDeSimbolo *pTabela)
{
}

int ImprimeListaTabela(ListaDeTabelas *pLista)
{
}

TabelaDeSimbolo *LBuscaTabela(ListaDeTabelas *pLista, TabelaDeSimbolo *pTabela)
{
}