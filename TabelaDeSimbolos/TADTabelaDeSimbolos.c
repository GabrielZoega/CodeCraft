#include "TADTabelaDeSimbolos.h"
#include <string.h>


// Cria uma tabela vazia
void FLVaziaTabela(TabelaDeSimbolos *pLista){
    pLista ->pPrimeiro = (ApontadorTabelaDeSimbolos) malloc(sizeof(CelulaSimbolo));
    pLista->pUltimo = pLista->pPrimeiro;
    pLista->pPrimeiro->pProx = NULL;

}

// Verifica se uma tabela é vazia
int EhVaziaTabela(TabelaDeSimbolos *pLista){
    return (pLista->pPrimeiro == NULL);
}

// Insere um símbolo em uma tabela de símbolos
int LInsereSimboloTabela(TabelaDeSimbolos *pLista, char *tipo, char *nome, int enderecoVarMem){
    pLista->pUltimo->pProx = (ApontadorTabelaDeSimbolos) malloc(sizeof(CelulaSimbolo));
    pLista->pUltimo = pLista->pUltimo->pProx;
    pLista->pUltimo->simbolo.enderecoVarMem = enderecoVarMem;
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
int ImprimeTabela(TabelaDeSimbolos *pLista){
    ApontadorTabelaDeSimbolos pAux;
    pAux = pLista->pPrimeiro->pProx;
    while (pAux != NULL){
        printf("\t\x1b[34mNome: %s\x1b[0m\n", pAux->simbolo.nome);
        printf("\t\x1b[34mTipo: %s\x1b[0m\n", pAux->simbolo.tipo);
        printf("\t\x1b[34mTipo: %d\x1b[0m\n", pAux->simbolo.id);
        printf("\t\x1b[34mTipo: %s\x1b[0m\n", pAux->simbolo.valor);
        printf("\t\x1b[34mTipo: %d\x1b[0m\n", pAux->simbolo.enderecoVarMem);
        printf("\n");
        pAux = pAux-> pProx;
    }

}

// Busca um símbolo dentro de uma tabela
Simbolo buscaSimbolo(TabelaDeSimbolos * pLista, char* variavel){
    ApontadorTabelaDeSimbolos atual = pLista->pPrimeiro->pProx;
    Simbolo simbolo = { -1,
        NULL,
        NULL,
        -1,
        NULL};
        
    while (atual != NULL) {
        printf("at: %s\nvari: %s\n", atual->simbolo.nome, variavel);
        if (atual->simbolo.nome == variavel){
            printf("buscaSimbolo\n");
            simbolo = atual->simbolo;
        }
        atual = atual->pProx;
    }
    return simbolo;
}

// Insere um valor dentro de um símbolo passado
int LInsereValorSimbolo(TabelaDeSimbolos *pLista, int id, char *valor){
    ApontadorTabelaDeSimbolos atual = pLista->pPrimeiro;
    while (atual != NULL)
    {
        if (atual->simbolo.id == id){
            atual->simbolo.valor = valor;
            return 1;
        }
        atual = atual->pProx;
    }
    return 0;
}
