//#include "TADTabelaDeSimbolos.h"
#include "TADListaDeTabelas.h"

int main(){
    TabelaDeSimbolos tabela,tabela02;
    ListaDeTabelas lista;
    
    // testando a primeira função
    FLVaziaTabela(&tabela);
    FLVaziaTabela(&tabela02);
    // Testando a função de insere
    LInsereSimboloTabela(&tabela, "int","batata",10);
    LInsereValorSimbolo(&tabela, 1, "5");

    LInsereSimboloTabela(&tabela, "int","rocambole",14);
    LInsereValorSimbolo(&tabela, 2, "8");

    LInsereSimboloTabela(&tabela02, "int","batataFrita",6);
    LInsereValorSimbolo(&tabela02, 1, "5");

    LInsereSimboloTabela(&tabela02, "int","rocamboleFrito",8);
    LInsereValorSimbolo(&tabela02, 2, "8");

    FLVaziaListaTabela(&lista);
    LInsereListaTabela(&lista,&tabela);
    LInsereListaTabela(&lista,&tabela02);
    printf("Imprimindo a lista tabela antes da remoção:\n");
    ImprimeListaTabela(&lista);

    LRemoveListaTabela(&lista);
    printf("\n\n\nImprimindo a lista tabela depois da remoção:\n");
    ImprimeListaTabela(&lista);
    //ImprimeTabela(&tabela);

    LBuscaTabela(&lista, "batata");

    

    // Simbolo simbolo = buscaSimbolo(&tabela,"ana");
    // if (simbolo.id == -1){
    //     printf("buscaSimbolo retornou NULL\n");
    // }else{
    //     printf("buscaSimbolo retornou %s\n", simbolo.nome);
    // }
    

    
    return 0;
}