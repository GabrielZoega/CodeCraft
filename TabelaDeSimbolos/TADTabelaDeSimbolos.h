#include <stdio.h>
#include <stdlib.h>

typedef struct Simbolo *Apontador;

typedef struct Simbolo{
    int id; // identificador do item
    char *tipo;
    char *nome;
    char *enderecoVarMem; // isso é o endereço da variável na memória
    char *valor;
    struct Simbolo * pProx;// ponteiro para a próxima célula
} Simbolo;

typedef struct TabelaDeSimbolo{
    Apontador pPrimeiro;// apontador para a celula cabeça
    Apontador pUltimo;// Apontador para a ultima celula existente
    
    struct TabelaDeSimbolo *pProx;
} TabelaDeSimbolo; // guarda os símbolos da tabela, ou seja, os identificadores

// a struct a cima é a célula da tabela a baixo 
typedef TabelaDeSimbolo *ApontadorTabelaDeSimbolo;

// Funções para manipulação da Tabelas de Símbolos 
void FLVaziaTabela (TabelaDeSimbolo *pLista);
int EhVaziaTabela (TabelaDeSimbolo *pLista);
int LInsereSimbolo (TabelaDeSimbolo *pLista, char *tipo, char *nome, char *enderecoVarMem);
int LRemoveSimbolo (TabelaDeSimbolo *pLista, int id);
int ImprimeTabela(TabelaDeSimbolo *pLista);
Simbolo* buscaSimbolo(TabelaDeSimbolo *pLista, int id);

// Funções para manipulação do Símbolos da Tabela
int LInsereValorSimbolo(TabelaDeSimbolo *pLista, int id, char *valor); 
void ImprimeSimbolo(Simbolo *pSimbolo);

