#include "TADTabelaDeSimbolos.h"
#include <string.h>


// Cria uma tabela vazia
void FLVaziaTabela(TabelaDeSimbolos *pLista){
    pLista ->pPrimeiro = (ApontadorTabelaDeSimbolos) malloc(sizeof(CelulaSimbolo));
    pLista->pPrimeiro->pProx = NULL;
    pLista->pUltimo = pLista->pPrimeiro;

}

// Verifica se uma tabela é vazia
int EhVaziaTabela(TabelaDeSimbolos *pLista){
    return (pLista->pPrimeiro == NULL);
}

// Insere um símbolo em uma tabela de símbolos
void LInsereSimboloTabela(TabelaDeSimbolos *pLista, char *tipo, char *nome, char *args){
    pLista->pUltimo->pProx = (ApontadorTabelaDeSimbolos) malloc(sizeof(CelulaSimbolo));
    pLista->pUltimo = pLista->pUltimo->pProx;
    pLista->pUltimo->simbolo.args = args;
    pLista->pUltimo->simbolo.nome = nome; 
    pLista->pUltimo->simbolo.tipo = tipo;

    int id = 0;
    ApontadorTabelaDeSimbolos pAux;
    pAux = pLista->pPrimeiro->pProx;
    while (pAux != NULL){
        id++;
        pAux = pAux->pProx;
    }
    pLista->pUltimo->simbolo.id = id;
}

// Imprime os símbolos dentro de uma tabela
void ImprimeTabela(TabelaDeSimbolos *pLista){
    ApontadorTabelaDeSimbolos pAux;
    pAux = pLista->pPrimeiro->pProx;
    while (pAux != NULL){
        printf("\t\x1b[34mNome: %s\x1b[0m\n", pAux->simbolo.nome);
        printf("\t\x1b[34mTipo: %s\x1b[0m\n", pAux->simbolo.tipo);
        printf("\t\x1b[34mId: %d\x1b[0m\n", pAux->simbolo.id);
        printf("\t\x1b[34mValor: %s\x1b[0m\n", pAux->simbolo.valor);
        printf("\t\x1b[34mArgs: %s\x1b[0m\n", pAux->simbolo.args);
        printf("\n");
        pAux = pAux-> pProx;
    }

}

// Busca um símbolo dentro de uma tabela
Simbolo buscaSimbolo(TabelaDeSimbolos * pLista, char* variavel){
    ApontadorTabelaDeSimbolos atual = pLista->pPrimeiro->pProx; // primeiro item da lista
    Simbolo simbolo = { -1,
        NULL,
        NULL,
        "",
        NULL};

    while (atual != NULL) {
        if (atual->simbolo.nome != NULL){
            if (strcmp(atual->simbolo.nome, variavel) == 0){
                // printf("buscaSimbolo\n");
                simbolo = atual->simbolo;
            }
        }
        atual = atual->pProx;
    }
    
    return simbolo;
}

// Insere um valor dentro de um símbolo passado
int LInsereValorSimbolo(TabelaDeSimbolos *pLista, int id, char *valor){
    // printf("\n\t\t\t\t### idvariavel: %d | valor: %s\n\n", id, valor);
    ApontadorTabelaDeSimbolos atual = pLista->pPrimeiro;
    while (atual != NULL){

        if (atual->simbolo.id == id){
            // printf("\nID: %d\n", atual->simbolo.id);
            atual->simbolo.valor = strdup(valor);
            return 1;
        }
        atual = atual->pProx;
    }
    return 0;
}
