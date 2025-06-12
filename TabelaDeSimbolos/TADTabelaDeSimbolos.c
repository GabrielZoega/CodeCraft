#include "TADTabelaDeSimbolos.h"


// Funções para manipulação da Tabelas de Símbolos
void FLVaziaTabela(TabelaDeSimbolos *pLista){
    pLista ->pPrimeiro = (ApontadorListaDeTabelas) malloc(sizeof(CelulaSimbolo));
    pLista->pUltimo = pLista->pPrimeiro;
    pLista->pPrimeiro->pProx = NULL;

}

int EhVaziaTabela(TabelaDeSimbolos *pLista){
    return (pLista->pPrimeiro == NULL);
}

int LInsereSimboloTabela(TabelaDeSimbolos *pLista, char *tipo, char *nome, char *enderecoVarMem){
    pLista->pUltimo->pProx = (ApontadorListaDeTabelas) malloc(sizeof(CelulaSimbolo));
    pLista->pUltimo = pLista->pUltimo->pProx;
    pLista->pUltimo->simbolo.enderecoVarMem = enderecoVarMem;
    pLista->pUltimo->simbolo.nome = nome; // possíveis erros: será que tenho que fazer srtcopy lá ou como é ponteiro deixo assim?
    pLista->pUltimo->simbolo.tipo = tipo;
    // como vamos fazer o id? 
}

int LRemoveSimboloTabela(TabelaDeSimbolos *pLista, int id){
    CelulaSimbolo pAux;
    if(EhVaziaTabela(pLista)){
        return 0;
    }
    // Será que vai precisar mesmo desse id? Até onde eu sei isso era para recupara o id
    // Esse remove é aquele que remove o último ou primeiro item da tabela, vamos ter que modificar 

}

int ImprimeTabela(TabelaDeSimbolos *pLista){
    ApontadorListaDeTabelas pAux;
    pAux = pLista->pPrimeiro->pProx;
    while (pAux != NULL){
        printf("Nome: %s\n", pLista->pPrimeiro->simbolo.nome);// depois tem que conferir isso -  eu nunca sei o que to fazendo lalalalala
        printf("Tipo: %s\n", pLista->pPrimeiro->simbolo.tipo);
        printf("Id: %s\n", pLista->pPrimeiro->simbolo.id);
        printf("Valor: %s\n", pLista->pPrimeiro->simbolo.valor);
        printf("Endereço na memoria: %s\n", pLista->pPrimeiro->simbolo.enderecoVarMem);
        pAux = pAux-> pProx;
    }

}

int LInsereSimbolo(TabelaDeSimbolos *pLista, int id, char *tipo, char *nome, char *enderecoVarMem){// Isso aqui precisa existir mesmo??
}

Simbolo *buscaSimbolo(TabelaDeSimbolos * pLista, int id){
    ApontadorListaDeTabelas atual = pLista->pPrimeiro;
    while (atual != NULL)
    {
        if (atual->simbolo.id == id) // tmb nn boto a mão no fogo que isso ta certo nn 
            return atual;
        atual = atual->pProx;
    }
    return NULL;
}

int LInsereValorSimbolo(TabelaDeSimbolos *pLista, int id, char *valor){
    ApontadorListaDeTabelas atual = pLista->pPrimeiro;
    while (atual != NULL)
    {
        if (atual->simbolo.id == id)
            atual->simbolo.valor = valor;
            return 1; // deu certo colocar o valor
        atual = atual->pProx;
    }
    return 0;
}
