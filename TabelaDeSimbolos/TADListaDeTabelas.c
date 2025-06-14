#include "TADListaDeTabelas.h"
#include <string.h>

void FLVaziaListaTabela(ListaDeTabelas *pLista){
    pLista->pPrimeiro = (ApontadorListaDeTabelas)malloc(sizeof(CelulaListaDeTabelas));
    pLista->pUltimo = pLista->pPrimeiro;
    pLista->pPrimeiro->pProx = NULL;
}

int EhVaziaLista(ListaDeTabelas *pLista){
    return (pLista->pPrimeiro == NULL);
}

int LInsereListaTabela(ListaDeTabelas *pLista, TabelaDeSimbolos *pTabela){
    pLista->pUltimo->pProx = (ApontadorListaDeTabelas) malloc(sizeof(CelulaListaDeTabelas));
    pLista->pUltimo = pLista->pUltimo->pProx;
    pLista->pUltimo->tabela = *pTabela;
    pLista->pUltimo->pProx = NULL;
}
// Depois vamos precisar remover os escopos :( - pensando aqui temos que remover sempre
// a ultima tabela que foi adicionada 
int LRemoveListaTabela(ListaDeTabelas *pLista){
    if (pLista->pPrimeiro == NULL || pLista->pPrimeiro->pProx == NULL) {
        return 0;
    }

    ApontadorListaDeTabelas anterior = pLista->pPrimeiro;
    ApontadorListaDeTabelas atual = pLista->pPrimeiro->pProx;

    while (atual->pProx != NULL) {
        anterior = atual;
        atual = atual->pProx;
    }
    anterior->pProx = NULL;
    pLista->pUltimo = anterior;
    free(atual);
    return 1;
}

int ImprimeListaTabela(ListaDeTabelas *pLista){
    ApontadorListaDeTabelas pAux;
    pAux = pLista->pPrimeiro->pProx;
    int cont = 1;
    while(pAux != NULL){
        printf("Imprimindo a tabela %d\n", cont);
        ImprimeTabela(&pAux->tabela);
        pAux = pAux->pProx;
        cont++;
    }
    return 1;
}


//Buscar tabelas em tabelas tendo em vista uma variável alvo
// implementar null
char* LBuscaTabela(ListaDeTabelas *pLista, char *variavel){
    TabelaDeSimbolos *guardaTabela;
    Simbolo simbolo;
    char *valor = "Essa variavel nao existe";
    
    ApontadorListaDeTabelas pAux = pLista->pPrimeiro->pProx;
    while(pAux != NULL){
        Simbolo simbolo = buscaSimbolo(&(pAux->tabela), variavel);
        if (strcmp(simbolo.nome, variavel) == 0){
            guardaTabela = &pAux->tabela;
            
        }
        pAux = pAux->pProx;
    }
    
    simbolo = buscaSimbolo(guardaTabela, variavel);
    valor = simbolo.valor;
    printf("%s\n", valor);
    return valor;
}

