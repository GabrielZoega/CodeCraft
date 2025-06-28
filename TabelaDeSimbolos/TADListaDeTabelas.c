#include "TADListaDeTabelas.h"
#include <string.h>

// Cria uma Lista de Tabelas vazia
void FLVaziaListaTabela(ListaDeTabelas *pLista){
    pLista->pPrimeiro = (ApontadorListaDeTabelas)malloc(sizeof(CelulaListaDeTabelas));
    pLista->pUltimo = pLista->pPrimeiro;
    pLista->pPrimeiro->pProx = NULL;
}

// Verifica se a lista de tabelas é vazia
int EhVaziaLista(ListaDeTabelas *pLista){
    return (pLista->pPrimeiro == NULL);
}

// Insere uma tabela à lista
int LInsereListaTabela(ListaDeTabelas *pLista, TabelaDeSimbolos *pTabela){
    pLista->pUltimo->pProx = (ApontadorListaDeTabelas) malloc(sizeof(CelulaListaDeTabelas));
    pLista->pUltimo = pLista->pUltimo->pProx;
    pLista->pUltimo->tabela = *pTabela;
    pLista->pUltimo->pProx = NULL;
}

// Remove a última tabela da lista
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

// Imprime a lista de tabelas de símbolos
int ImprimeListaTabela(ListaDeTabelas *pLista){
    ApontadorListaDeTabelas pAux;
    pAux = pLista->pPrimeiro->pProx;
    int cont = 1;
    while(pAux != NULL){
        printf("\033[31mImprimindo a Tabela: %d\033[0m\n", cont);
        ImprimeTabela(&pAux->tabela);
        pAux = pAux->pProx;
        cont++;
    }
    return 1;
}


//Buscar o valor de uma variável com base no seu nome
Simbolo LBuscaTabela(ListaDeTabelas *pLista, char *variavel){
    TabelaDeSimbolos *guardaTabela = NULL;
    Simbolo simbolo;
    char *valor = "Essa variavel nao existe";
    
    ApontadorListaDeTabelas pAux = pLista->pPrimeiro->pProx;
    while(pAux != NULL){
        Simbolo simbolo = buscaSimbolo(&(pAux->tabela), variavel);
        if (simbolo.nome != NULL){
            if (strcmp(simbolo.nome, variavel) == 0){
                guardaTabela = &pAux->tabela;            }
        }
        pAux = pAux->pProx;
    }
    if (guardaTabela != NULL){
        simbolo = buscaSimbolo(guardaTabela, variavel);
    }
    else{
        simbolo = (Simbolo){-1, NULL, NULL, "", NULL};
    }
    return simbolo;
}

void InsereValorTabela(ListaDeTabelas *pLista, char *variavel, char *valor){

    // printf("\n\t\t\t\t### variavel: %s | valor: %s\n\n", variavel, valor);

    TabelaDeSimbolos *guardaTabela; // guarda a tabela que está com o símbolo mais recente
    Simbolo simbolo;
    
    ApontadorListaDeTabelas pAux = pLista->pPrimeiro->pProx;
    while(pAux != NULL){
        simbolo = buscaSimbolo(&(pAux->tabela), variavel); // procurando o símbolo da variável
        if (simbolo.nome != NULL){
            if (strcmp(simbolo.nome, variavel) == 0){
                guardaTabela = &pAux->tabela;
                break;
                
            }
        }
        pAux = pAux->pProx;
    }

    LInsereValorSimbolo(guardaTabela, simbolo.id, valor);

    return;
}