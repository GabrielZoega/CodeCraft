#include "TADTabelaDeSimbolos.h"


// Funções para manipulação da Tabelas de Símbolos
void FLVaziaTabela(TabelaDeSimbolo *pLista)
{
}

int EhVaziaTabela(TabelaDeSimbolo *pLista)
{
    return (pLista->pPrimeiro == NULL);
}

int LInsereSimboloTabela(TabelaDeSimbolo *pLista, char *tipo, char *nome, char *enderecoVarMem)
{
}

int LRemoveSimboloTabela(TabelaDeSimbolo *pLista, int id)
{
}

int ImprimeTabela(TabelaDeSimbolo *pLista)
{
}

int LInsereSimbolo(TabelaDeSimbolo *pLista, int id, char *tipo, char *nome, char *enderecoVarMem)
{
}

Simbolo *buscaSimbolo(TabelaDeSimbolo *pLista, int id)
{
    TabelaDeSimbolo *atual = pLista->pPrimeiro;
    while (atual)
    {
        if (atual->id == id)
            return atual;
        atual = atual->pProx;
    }
    return NULL;
}

int LInsereValorSimbolo(TabelaDeSimbolo *pLista, int id, char *valor)
{
}
