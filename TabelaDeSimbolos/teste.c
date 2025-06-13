#include "TADTabelaDeSimbolos.h"

int main(){
    TabelaDeSimbolos tabela;
    
    // testando a primeira função
    FLVaziaTabela(&tabela);
    // Testando a função de insere
    LInsereSimboloTabela(&tabela, "int","batata",10);
    LInsereValorSimbolo(&tabela, 1, "5");

    LInsereSimboloTabela(&tabela, "int","rocambole",14);
    LInsereValorSimbolo(&tabela, 2, "8");

    ImprimeTabela(&tabela);

    Simbolo simbolo = buscaSimbolo(&tabela,"ana");
    if (simbolo.id == -1){
        printf("buscaSimbolo retornou NULL\n");
    }else{
        printf("buscaSimbolo retornou %s\n", simbolo.nome);
    }
    
    
    return 0;
}