#include "TADTabelaDeSimbolos.h"
#include <string.h>
//#include "TADListaDeTabelas.h"


// Funções para manipulação da Tabelas de Símbolos
void FLVaziaTabela(TabelaDeSimbolos *pLista){
    pLista ->pPrimeiro = (ApontadorTabelaDeSimbolos) malloc(sizeof(CelulaSimbolo));
    pLista->pUltimo = pLista->pPrimeiro;
    pLista->pPrimeiro->pProx = NULL;

}

int EhVaziaTabela(TabelaDeSimbolos *pLista){
    return (pLista->pPrimeiro == NULL);
}

int LInsereSimboloTabela(TabelaDeSimbolos *pLista, char *tipo, char *nome, int enderecoVarMem){
    pLista->pUltimo->pProx = (ApontadorTabelaDeSimbolos) malloc(sizeof(CelulaSimbolo));
    pLista->pUltimo = pLista->pUltimo->pProx;
    pLista->pUltimo->simbolo.enderecoVarMem = enderecoVarMem;
    pLista->pUltimo->simbolo.nome = nome; //possíveis erros: será que tenho que fazer srtcopy lá ou como é ponteiro deixo assim?
    pLista->pUltimo->simbolo.tipo = tipo;
    // Testei e funcionou -  começa do 1
    int id = 0;
    ApontadorTabelaDeSimbolos pAux;
    pAux = pLista->pPrimeiro->pProx;
    while (pAux != NULL){
        id++;
        pAux = pAux->pProx;
    }
    pLista->pUltimo->simbolo.id = id;
}

// NÃO FAZ SENTIDO REMOVER O SÍMBOLO DA TABELA - POR ENQUANTO ELA NN PRECISA EXISTIR

// int LRemoveSimboloTabela(TabelaDeSimbolos *pLista, int id){
//     CelulaSimbolo pAux;
//     if(EhVaziaTabela(pLista)){
//         return 0;
//     }
//     // Será que vai precisar mesmo desse id? Até onde eu sei isso era para recupara o id
//     // Esse remove é aquele que remove o último ou primeiro item da tabela, vamos ter que modificar 

// }

int ImprimeTabela(TabelaDeSimbolos *pLista){
    ApontadorTabelaDeSimbolos pAux;
    pAux = pLista->pPrimeiro->pProx;
    while (pAux != NULL){
        printf("\tNome: %s\n", pAux->simbolo.nome);// depois tem que conferir isso -  eu nunca sei o que to fazendo lalalalala
        printf("\tTipo: %s\n", pAux->simbolo.tipo);
        printf("\tId: %d\n", pAux->simbolo.id);
        printf("\tValor: %s\n", pAux->simbolo.valor);
        printf("\tEndereço na memoria: %d\n", pAux->simbolo.enderecoVarMem);
        printf("\n");
        pAux = pAux-> pProx;
    }

}

//int LInsereSimbolo(TabelaDeSimbolos *pLista, int id, char *tipo, char *nome, char *enderecoVarMem){// Isso aqui precisa existir mesmo??
//}

Simbolo buscaSimbolo(TabelaDeSimbolos * pLista, char* variavel){
    ApontadorTabelaDeSimbolos atual = pLista->pPrimeiro->pProx;
    Simbolo simbolo = { -1,
        NULL,
        NULL,
        -1,
        NULL};
        
    while (atual != NULL) {
        printf("at: %s\nvari: %s\n", atual->simbolo.nome, variavel);
        if (atual->simbolo.nome == variavel){ // tmb nn boto a mão no fogo que isso ta certo nn 
            printf("buscaSimbolo\n");
            //printf("%s",atual->simbolo.nome);
            simbolo = atual->simbolo;
        }
        atual = atual->pProx;
    }
    return simbolo;
}

int LInsereValorSimbolo(TabelaDeSimbolos *pLista, int id, char *valor){
    ApontadorTabelaDeSimbolos atual = pLista->pPrimeiro;
    while (atual != NULL)
    {
        if (atual->simbolo.id == id){
            atual->simbolo.valor = valor;
            return 1; // deu certo colocar o valor
        }
        atual = atual->pProx;
    }
    return 0;
}
