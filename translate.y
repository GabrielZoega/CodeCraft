%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TabelaDeSimbolos/TADListaDeTabelas.h"
#include "TabelaDeSimbolos/TADTabelaDeSimbolos.h"
#include "EstruturasAuxiliares/ListaExpressoes.h"
#include "EstruturasAuxiliares/QuadruplaCodigo.h"

void yyerror(char const *mensagem);
ListaExpressoes realizaOperacao(ListaExpressoes operando1, char *operador, ListaExpressoes operando2);
int retornaEnum(char *tipo);

extern int yylex();
extern int num_linha;
extern char *yytext;                                                                        // Texto do token atual (fornecido pelo Flex)
extern int ultimo_token;
extern ListaDeTabelas listaDeTabelas;                                                       // Lista de tabelas de símbolos
int auxValueTamanho;

extern vetorQuadruplas vetor_quadruplas;

void patch_quad_result(int quad_index, char* result);
void geraQuadrupla(char *op, char *arg1, char *arg2, char *result);
void geraOperacaoInt(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, int op1_int, int op2_int);
void geraOperacaoChar(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, char* op1_char, char* op2_char);
void geraOperacaoFloat(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, float op1_float, float op2_float);
void geraOperacaoDouble(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, double op1_double, double op2_double);
void geraOperacaoString(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, char* op1_string, char *op2_string);
void geraOperacaoBooleano(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, char *op1_bool, char *op2_bool);
int tempCount = 0;
int labelCount = 0;
char *novoTemp();
char *novaLabel();

char *retornaTipo(TipoSimples tipo);
char idEnum[240] = "enum.";

extern char linha_atual[1024];
extern int pos_na_linha;

%}
%define parse.lac full
%define parse.error verbose                                                                 // Diretiva que gera mensagens de erro mais complexas
%code requires{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TabelaDeSimbolos/TADListaDeTabelas.h"
#include "TabelaDeSimbolos/TADTabelaDeSimbolos.h"
#include "EstruturasAuxiliares/ListaExpressoes.h"
#include "EstruturasAuxiliares/QuadruplaCodigo.h"
}

// Tipos disponiveis
%union{
    char *stringVal;
    char *charVal;
    void* nulo;
    int intVal;
    float floatVal;
    double doubleVal;
    char *booleano;
    int tipoEnum;
    ListaExpressoes listaExpr;
    int quad_addr;
}

// Definição dos Tokens da linguagem
%token FUNCAO PROCEDIMENTO
%token VETOR ENUM
%token <intVal> DIGITO_POSITIVO DIGITO_NEGATIVO 
%token <floatVal> DECIMAL
%token <stringVal>  STRING_LITERAL IDENTIFICADOR FUNC_MAIN
%token <charVal> CHAR_LITERAL
%token BLOCO
%token <stringVal> TK_TRUE TK_FALSE
%token <stringVal> SOMA SUBTRACAO MULTIPLICACAO DIVISAO MOD MAIS_IGUAL MENOS_IGUAL MULTIPLICADOR_IGUAL AND OR IGUAL DIFERENTE MENOR MAIOR MENOR_IGUAL MAIOR_IGUAL
%token INCREMENTO DECREMENTO CONCATENAR
%token DOIS_PONTOS
%token RECEBE
%token ABRE_PARENTESES FECHA_PARENTESES

// Definição de tipos
%token INTEIRO FLOAT BOOL DOUBLE STRING CHAR
%token ABRE_BLOCO FECHA_BLOCO ABRE_COLCHETE FECHA_COLCHETE VIRGULA
%token ESCOPO IF ELSE WHILE DO FOR SWITCH CASE DEFAULT
%token <stringVal> TK_NULL
%token BREAK CONTINUE RETURN IMPORT TYPECAST VOID PRINT 
%token FIM_DE_LINHA
%token DEL_DOUBLE DEL_FLOAT

%type <tipoEnum> tipo
%type <stringVal> nomeFuncao
%type <stringVal> booleano
%type <stringVal> variavel variavelArg
%type <stringVal> vetor
%type <stringVal> argumento argumentos parametro parametros
%type <listaExpr> /*listaExpressoes*/ fator exprAritmetico exprRelacional exprLogico expr atribuicao exprRepet chamadaFuncaoExpr
%type <stringVal> opAritmetico opLogico opRelacional
%type <intVal> inteiro
%type <floatVal> float
%type <doubleVal> double
%type <stringVal> minerarExpr colocarBlocoExpr ComMinerar ComColocarBloco
%type <stringVal> M_novaLabel
%type <quad_addr> M_desvio_cond M_desvio_inc

%%



/*---------- GRAMÁTICA ----------*/

start : import topLevel
      ;

topLevel : topLevelElem topLevel {/*printf("\nReduziu topLevel\n");*/}
         | /* vazio */
         ;

topLevelElem : inventario       {/*printf("\nReduziu topLevelElem\n");*/}
             | defFuncao        {/*printf("\nReduziu topLevelElem\n");*/}
             ;

import : IMPORT STRING_LITERAL import
       | /*vazio*/
       ;

/*---------- MARCADORES ----------*/

M_novaLabel : /* vazio */                                                   { $$ = novaLabel(); }
            ;

// Gera um salto condicional IF_FALSE para um destino '?'
M_desvio_cond : exprRepet                                                 {
                                                                            $$ = vetor_quadruplas.tamanho;
                                                                            /*printf("\t\t\t\t #################%s\n", $<listaExpr>-1.temp);*/
                                                                            geraQuadrupla("IfFalse", $1.temp, NULL, "?");
                                                                            }
              ;

// Gera um salto incondicional para um destino '?'
M_desvio_inc : /* vazio */                                                  {
                                                                            $$ = vetor_quadruplas.tamanho;
                                                                            geraQuadrupla("GOTO", NULL, NULL, "?");
                                                                            }
            ;

/*---------- FIM MARCADORES ----------*/

// Abre_Bloco -> Cria um novo escopo e consequentemente uma nova tabela de símbolos
abre_bloco : ABRE_BLOCO { TabelaDeSimbolos tabelaDeSimbolos; FLVaziaTabela(&tabelaDeSimbolos); LInsereListaTabela(&listaDeTabelas, &tabelaDeSimbolos);}
           ;
// Fecha_Bloco -> Apaga o último escopo e apaga a última tabela de símbolos
fecha_bloco : FECHA_BLOCO { LRemoveListaTabela(&listaDeTabelas);}
            ;

inventario : ESCOPO ABRE_BLOCO declaracoesVar FECHA_BLOCO       {/*printf("\nReduziu inventario \n");*/}
           ;

declaracoesVar : declaraVarTipo declaracoesVar          {/*printf("\nReduziu declaracoesVar\n");*/}
               | declaraVarTipoVetor declaracoesVar     {/*printf("\nReduziu declaracoesVar\n");*/}
               | definicaoEnum declaracoesVar           {/*printf("\nReduziu declaracoesVar\n");*/}
               | /*vazio*/
               ;

defFuncao : assinaturas abre_bloco listaComandos fecha_bloco     {/*printf("\nReduziu defFuncao\n");*/}
          ;

assinaturas : assinaturaFuncao  {/*printf("\nReduziu assinaturas\n");*/}
            | assinaturaProced  {/*printf("\nReduziu assinaturas\n");*/}
            ;

assinaturaFuncao : tipo FUNCAO nomeFuncao ABRE_PARENTESES argumentos FECHA_PARENTESES       {/*printf("\nReduziu assinaturaFuncao\n");*/
                                                                                            if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $3).id < 0){
                                                                                                LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, retornaTipo($1), $3, $5);
                                                                                                ImprimeListaTabela(&listaDeTabelas);
                                                                                            }
                                                                                            else
                                                                                                yyerror("Erro Semântico: Essa função já está declarada nesse escopo\n");
                                                                                            }
                 ;
nomeFuncao : IDENTIFICADOR  {$$ = $1;}
           | FUNC_MAIN      {$$ = $1;}
           ;
assinaturaProced : VOID PROCEDIMENTO IDENTIFICADOR ABRE_PARENTESES argumentos FECHA_PARENTESES  {/*printf("\nReduziu assinaturaProced\n");*/
                                                                                                if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $3).id < 0){
                                                                                                    LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, "vazio", $3, $5);
                                                                                                    ImprimeListaTabela(&listaDeTabelas);
                                                                                                }
                                                                                                else
                                                                                                    yyerror("Erro Semântico: Esse procedimento já está declarado nesse escopo\n");
                                                                                                } 
                 ;

chamadaFuncaoExpr : FUNCAO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES    {/*printf("\nReduziu chamadaFuncaoExpr\n");*/
                                                                                        if (LBuscaTabela(&listaDeTabelas, $2).id == -1)
                                                                                            yyerror("Erro Semântico: Essa função não foi declarada\n");
                                                                                        
                                                                                        if(strcmp(LBuscaTabela(&listaDeTabelas, $2).args, $4) != 0){
                                                                                            yyerror("Erro Semântico: Os parâmetros devem possuir o mesmo tipo da declaração.");
                                                                                        }
                                                                                        ListaExpressoes listaExpr;
                                                                                        listaExpr.flagId = 1;
                                                                                        listaExpr.tipoExpr = retornaEnum(LBuscaTabela(&listaDeTabelas, $2).tipo);
                                                                                        listaExpr.valor.intVal = 0;
                                                                                        $$ = listaExpr;
                                                                                        }
              ;
chamadaFuncao : FUNCAO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES FIM_DE_LINHA   {/*printf("\nReduziu chamadaFuncao\n");*/
                                                                                                if (LBuscaTabela(&listaDeTabelas, $2).id == -1)
                                                                                                    yyerror("Erro Semântico: Essa função não foi declarada\n");
                                                                                                if(strcmp(LBuscaTabela(&listaDeTabelas, $2).args, $4) != 0){
                                                                                                    /*printf("\n========= ENTROU =========");*/
                                                                                                    yyerror("Erro Semântico: Os parâmetros devem possuir o mesmo tipo da declaração.");
                                                                                                }
                                                                                                }
              ;

chamadaProcedimento : PROCEDIMENTO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES FIM_DE_LINHA       {/*printf("\nReduziu chamadaProcedimento\n");*/
                                                                                                                if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id == -1)
                                                                                                                    yyerror("Erro Semântico: Esse procedimento não foi declarado\n");
                                                                                                                if(strcmp(LBuscaTabela(&listaDeTabelas, $2).args, $4) != 0){
                                                                                                                    yyerror("Erro Semântico: Os parâmetros devem possuir o mesmo tipo da declaração.");
                                                                                                                }
                                                                                                                }
                    ;

declaraVarTipo : tipo IDENTIFICADOR atribuicao          {/*printf("\nReduziu declaraVarTipo\n");*/
                                                        if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id < 0){
                                                            LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, retornaTipo($1), $2, "");
                                                            ImprimeListaTabela(&listaDeTabelas);
                                                        }
                                                        else
                                                            yyerror("Erro Semântico: Essa variável já está declarada nesse escopo\n");

                                                        ListaExpressoes atribuir = $3;
                                                        if (strcmp(LBuscaTabela(&listaDeTabelas, $2).tipo, retornaTipo(atribuir.tipoExpr)) != 0){
                                                            yyerror("Erro Semântico: Essa variável não pode receber valores desse tipo");
                                                        }
                                                        else{
                                                            //printf("\nTIPOEXPR: %d\n", atribuir.tipoExpr);
                                                            switch(atribuir.tipoExpr){
                                                                case T_INT:
                                                                    //printf("\n int \n");
                                                                    //printf("TESTE VALOR: %d\n", atribuir.valor.intVal);
                                                                    int value_int = atribuir.valor.intVal;
                                                                    char valorTabelaInt[100];
                                                                    //printf("\nVARIAVEL: %s\n", $2);
                                                                    sprintf(valorTabelaInt, "%d", value_int);
                                                                    InsereValorTabela(&listaDeTabelas, $2, valorTabelaInt);
                                                                    if (atribuir.temp != NULL){
                                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($2));
                                                                    }
                                                                    else{
                                                                        geraQuadrupla(NULL, valorTabelaInt, NULL, strdup($2));
                                                                    }
                                                                    break;
                                                                case T_FLOAT:
                                                                    /*printf("\n float \n");*/
                                                                    float value_float = atribuir.valor.floatVal;
                                                                    char valorTabelaFloat[100];
                                                                    sprintf(valorTabelaFloat, "%f", value_float);
                                                                    InsereValorTabela(&listaDeTabelas, $2, valorTabelaFloat);
                                                                    
                                                                    if (atribuir.temp != NULL){
                                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($2));
                                                                    }
                                                                    else{
                                                                        geraQuadrupla(NULL, valorTabelaFloat, NULL, strdup($2));
                                                                    }
                                                                    break;
                                                                case T_DOUBLE:
                                                                    /*printf("\n double \n");*/
                                                                    double value_double = atribuir.valor.doubleVal;
                                                                    char valorTabelaDouble[100];
                                                                    sprintf(valorTabelaDouble, "%lf", value_double);
                                                                    InsereValorTabela(&listaDeTabelas, $2, valorTabelaDouble);
                                                                    
                                                                    if (atribuir.temp != NULL){
                                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($2));
                                                                    }
                                                                    else{
                                                                        geraQuadrupla(NULL, valorTabelaDouble, NULL, strdup($2));
                                                                    }
                                                                    break;
                                                                case T_STRING:
                                                                    /*printf("\n string \n");*/
                                                                    InsereValorTabela(&listaDeTabelas, $2, atribuir.valor.stringVal);
                                                                    
                                                                    if (atribuir.temp != NULL){
                                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($2));
                                                                    }
                                                                    else{
                                                                        geraQuadrupla(NULL, atribuir.valor.stringVal, NULL, strdup($2));
                                                                    }
                                                                    break;
                                                                case T_CHAR:
                                                                    /*printf("\n char \n");*/
                                                                    InsereValorTabela(&listaDeTabelas, $2, atribuir.valor.stringVal);

                                                                    if (atribuir.temp != NULL){
                                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($2));
                                                                    }
                                                                    else{
                                                                        geraQuadrupla(NULL, atribuir.valor.stringVal, NULL, strdup($2));
                                                                    }
                                                                    break;
                                                                case T_BOOL:
                                                                    /*printf("\n bool \n");*/
                                                                    InsereValorTabela(&listaDeTabelas, $2, atribuir.valor.stringVal);

                                                                    if (atribuir.temp != NULL){
                                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($2));
                                                                    }
                                                                    else{
                                                                        geraQuadrupla(NULL, atribuir.valor.stringVal, NULL, strdup($2));
                                                                    }
                                                                    break;
                                                                case T_NULO:
                                                                    /*printf("\n nulo \n");*/
                                                                    InsereValorTabela(&listaDeTabelas, $2, atribuir.valor.stringVal);

                                                                    if (atribuir.temp != NULL){
                                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($2));
                                                                    }
                                                                    else{
                                                                        geraQuadrupla(NULL, atribuir.valor.stringVal, NULL, strdup($2));
                                                                    }
                                                                    break;
                                                                default:
                                                                    printf("\nERRO\n");
                                                                    break;
                                                            }
                                                        }
                                                        }
               | tipo IDENTIFICADOR FIM_DE_LINHA        {/*printf("\nReduziu declaraVarTipo\n");*/
                                                        if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id < 0){
                                                            LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, retornaTipo($1), $2, "");
                                                            ImprimeListaTabela(&listaDeTabelas);
                                                        }
                                                        else
                                                            yyerror("Erro Semântico: Essa variável já está declarada nesse escopo\n");
                                                        }
               ;

declaraVarTipoVetor : VETOR tipo IDENTIFICADOR ABRE_COLCHETE inteiro FECHA_COLCHETE FIM_DE_LINHA    {/*printf("\nReduziu declaraVarTipoVetor\n");*/
                                                                                                    if(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $3).id < 0){
                                                                                                        LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, retornaTipo($2), $3, "");
                                                                                                        ImprimeListaTabela(&listaDeTabelas);
                                                                                                    }
                                                                                                    else
                                                                                                        yyerror("Erro Semântico: Essa variável já está declarada nesse escopo\n");
                                                                                                    }
                    ;

variavel : IDENTIFICADOR        {/*printf("\nReduziu variavel\n");*/
                                if (LBuscaTabela(&listaDeTabelas, $1).id == -1)
                                    yyerror("Erro Semântico: essa variável não foi declarada\n");
                                else
                                    $$ = $1;
                                }
         | vetor                {/*printf("\nReduziu variavel\n");*/
                                if (LBuscaTabela(&listaDeTabelas, $1).id == -1)
                                    yyerror("Erro Semântico: essa variável não foi declarada\n");
                                else
                                    $$ = $1;
                                }
         ;

variavelArg : IDENTIFICADOR             {/*printf("\nReduziu variavelArg\n");*/
                                        $$ = $1;
                                        }
            | vetor                     {/*printf("\nReduziu variavelArg\n");*/
                                        $$ = $1;
                                        }            
                ;

atribuiVar : variavel atribuicao        {/*printf("\nReduziu atribuiVar\n");*/
                                        ListaExpressoes atribuir = $2;
                                        if (strcmp(LBuscaTabela(&listaDeTabelas, $1).tipo, retornaTipo(atribuir.tipoExpr)) != 0){
                                            yyerror("Erro Semântico: Essa variável não pode receber valores desse tipo");
                                        }
                                        else{
                                            /*printf("\nTIPOEXPR: %d\n", atribuir.tipoExpr);*/
                                            switch(atribuir.tipoExpr){
                                                case T_INT:
                                                    /*printf("\n int \n");*/
                                                    /*printf("TESTE VALOR: %d\n", atribuir.valor.intVal);*/
                                                    int value_int = atribuir.valor.intVal;
                                                    char valorTabelaInt[100];
                                                    sprintf(valorTabelaInt, "%d", value_int);
                                                    InsereValorTabela(&listaDeTabelas, $1, valorTabelaInt);
                                                    
                                                    if (atribuir.temp != NULL){
                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($1));
                                                    }
                                                    else{
                                                        geraQuadrupla(NULL, strdup(valorTabelaInt), NULL, strdup($1));
                                                    }
                                                    break;
                                                case T_FLOAT:
                                                    /*printf("\n float \n");*/
                                                    float value_float = atribuir.valor.floatVal;
                                                    char valorTabelaFloat[100];
                                                    sprintf(valorTabelaFloat, "%f", value_float);
                                                    InsereValorTabela(&listaDeTabelas, $1, valorTabelaFloat);
                                                    
                                                    if (atribuir.temp != NULL){
                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($1));
                                                    }
                                                    else{
                                                        geraQuadrupla(NULL, strdup(valorTabelaFloat), NULL, strdup($1));
                                                    }
                                                    break;
                                                case T_DOUBLE:
                                                    /*printf("\n double \n");*/
                                                    double value_double = atribuir.valor.doubleVal;
                                                    char valorTabelaDouble[100];
                                                    sprintf(valorTabelaDouble, "%lf", value_double);
                                                    InsereValorTabela(&listaDeTabelas, $1, valorTabelaDouble);
                                                    
                                                    if (atribuir.temp != NULL){
                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($1));
                                                    }
                                                    else{
                                                        geraQuadrupla(NULL, strdup(valorTabelaDouble), NULL, strdup($1));
                                                    }
                                                    break;
                                                case T_STRING:
                                                    /*printf("\n string \n");*/
                                                    InsereValorTabela(&listaDeTabelas, $1, atribuir.valor.stringVal);
                                                    
                                                    if (atribuir.temp != NULL){
                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($1));
                                                    }
                                                    else{
                                                        geraQuadrupla(NULL, strdup(atribuir.valor.stringVal), NULL, strdup($1));
                                                    }
                                                    break;
                                                case T_CHAR:
                                                    /*printf("\n char \n");*/
                                                    InsereValorTabela(&listaDeTabelas, $1, atribuir.valor.stringVal);

                                                    if (atribuir.temp != NULL){
                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($1));
                                                    }
                                                    else{
                                                        geraQuadrupla(NULL, strdup(atribuir.valor.stringVal), NULL, strdup($1));
                                                    }
                                                    break;
                                                case T_BOOL:
                                                    /*printf("\n bool \n");*/
                                                    InsereValorTabela(&listaDeTabelas, $1, atribuir.valor.stringVal);

                                                    if (atribuir.temp != NULL){
                                                        geraQuadrupla(NULL, strdup(atribuir.temp), NULL, strdup($1));
                                                    }
                                                    else{
                                                        geraQuadrupla(NULL, strdup(atribuir.valor.stringVal), NULL, strdup($1));
                                                    }
                                                    break;
                                                case T_NULO:
                                                    /*printf("\n nulo \n");*/
                                                    InsereValorTabela(&listaDeTabelas, $1, atribuir.valor.stringVal);
                                                    //geraQuadrupla(NULL, strdup(atribuir.valor.stringVal), NULL, strdup($1));
                                                    break;
                                            }
                                        }
                                        }
           ;

atribuicao : RECEBE expr FIM_DE_LINHA       {/*printf("\nReduziu atribuicao\n");*/
                                            $$ = $2;
                                            }
           ;

argumentos : argumento argumentos       {/*printf("\nReduziu argumentos\n");*/
                                        char tipoAux[1024];
                                        tipoAux[0] = '\0';
                                        strcat(tipoAux, $1);
                                        strcat(tipoAux, $2);
                                        $$ = strdup(tipoAux);
                                        }
           | VIRGULA argumentos         {/*printf("\nReduziu argumentos\n");*/ $$ = strdup($2);}
           | /*vazio*/                  {/*printf("\nReduziu argumentos\n");*/ $$ = "";}
           ;

argumento : tipo variavelArg                {/*printf("\nReduziu argumento\n");*/
                                            if (LBuscaTabela(&listaDeTabelas, $2).id == -1){
                                                LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, retornaTipo($1), $2, "");
                                                ImprimeListaTabela(&listaDeTabelas);
                                            }
                                            
                                            char tipoAux[1024];
                                            tipoAux[0] = '\0';
                                            strcat(tipoAux, retornaTipo($1));
                                            strcat(tipoAux, " ");
                                            $$ = strdup(tipoAux);
                                            /*printf("\n\t\t\t\t$$: %s", $$);*/
                                            }
          ;

parametros : parametro parametros       {/*printf("\nReduziu parametros\n");*/
                                        char tipoAux[1024];
                                        tipoAux[0] = '\0';
                                        strcat(tipoAux, $1);
                                        strcat(tipoAux, $2);
                                        $$ = strdup(tipoAux);
                                        }
           | VIRGULA parametros         { /*printf("\nReduziu parametros\n");*/ $$ = strdup($2);}
           | /*vazio*/                  { /*printf("\nReduziu parametros\n");*/ $$ = "";}
           ;

parametro: expr                         { /*printf("\nReduziu parametro\n");*/
                                        ListaExpressoes expr = $1;
                                        char tipoAux[1024];
                                        tipoAux[0] = '\0';
                                        strcat(tipoAux, retornaTipo(expr.tipoExpr));
                                        strcat(tipoAux, " ");
                                        $$ = strdup(tipoAux);
                                        /*printf("\n\t\t\t\t$$: %s", $$);*/
                                        }
         ;


/*---------- EXPRESSOES ----------*/

// listaExpressoes : expr                                  {printf("\nReduziu listaExpressoes\n"); $$ = $1;}
//                 | expr VIRGULA listaExpressoes          {printf("\nReduziu listaExpressoes\n");}
//                 ;

expr : exprLogico                                       {/*printf("\nReduziu expr\n"); $$ = $1;*/}
     ;

exprLogico : exprRelacional                             {/*printf("\nReduziu exprLogico\n"); $$ = $1;*/}
           | exprLogico opLogico exprRelacional         {/*printf("\nReduziu exprLogico\n");*/ $$ = realizaOperacao($1, $2, $3);}
           ;

exprRelacional : exprAritmetico                                 {/*printf("\nReduziu exprRelacional\n");*/ $$ = $1;}
               | exprAritmetico opRelacional exprAritmetico     {/*printf("\nReduziu exprRelacional\n");*/ $$ = realizaOperacao($1, $2, $3);}
               ;

exprAritmetico : exprAritmetico opAritmetico fator              {/*printf("\nReduziu exprAritmetico\n");*/
                                                                $$ = realizaOperacao($1, $2, $3);
                                                                }
               | fator                                          {/*printf("\nReduziu exprAritmetico\n");*/
                                                                $$ = $1;
                                                                }
               ;

fator : ABRE_PARENTESES expr FECHA_PARENTESES                   {/*printf("\nReduziu fator\n");*/
                                                                $$ = $2;
                                                                }
      | chamadaFuncaoExpr                                       {/*printf("\nReduziu fator\n");*/
                                                                $$ = $1;
                                                                }
      | minerarExpr                                             {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 1;
                                                                listaExpr.tipoExpr = T_INT;

                                                                int valor = atoi(LBuscaTabela(&listaDeTabelas, $1).valor);
                                                                listaExpr.valor.intVal = valor;
                                                                char valorStr[100];
                                                                sprintf(valorStr, "%d", valor+1);
                                                                InsereValorTabela(&listaDeTabelas, $1, valorStr);
                                                                
                                                                char valorTabelaInt[100];
                                                                sprintf(valorTabelaInt, "%d", 1);
                                                                geraQuadrupla("+", strdup($1), strdup(valorTabelaInt), strdup($1));

                                                                $$ = listaExpr;
                                                                }
      | colocarBlocoExpr                                        {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 1;
                                                                listaExpr.tipoExpr = T_INT;

                                                                int valor = atoi(LBuscaTabela(&listaDeTabelas, $1).valor);
                                                                listaExpr.valor.intVal = valor;
                                                                char valorStr[100];
                                                                sprintf(valorStr, "%d", valor-1);
                                                                InsereValorTabela(&listaDeTabelas, $1, valorStr);

                                                                char valorTabelaInt[100];
                                                                sprintf(valorTabelaInt, "%d", 1);
                                                                geraQuadrupla("-", strdup($1), strdup(valorTabelaInt), strdup($1));

                                                                $$ = listaExpr;
                                                                }
      | float                                                   {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipoExpr = T_FLOAT;
                                                                listaExpr.valor.floatVal = $1;

                                                                char valorTabelaFloat[100];
                                                                sprintf(valorTabelaFloat, "%f", $1);
                                                                char *t = novoTemp();
                                                                /*printf("\n========== VAR: %f ==========\033[0m\n", $1);*/
                                                                geraQuadrupla(NULL, strdup(valorTabelaFloat), NULL, t);
                                                                listaExpr.temp = t;
                                                                $$ = listaExpr;
                                                                }
      | double                                                  {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipoExpr = T_DOUBLE;
                                                                listaExpr.valor.doubleVal = $1;


                                                                char valorTabelaDouble[100];
                                                                sprintf(valorTabelaDouble, "%lf", $1);
                                                                char *t = novoTemp();
                                                                /*printf("\n========== VAR: %lf ==========\033[0m\n", $1);*/
                                                                geraQuadrupla(NULL, strdup(valorTabelaDouble), NULL, t);
                                                                listaExpr.temp = t;
                                                                $$ = listaExpr;
                                                                }
      | inteiro                                                 {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipoExpr = T_INT;
                                                                listaExpr.valor.intVal = $1;
                                                                
                                                                char valorTabelaInt[100];
                                                                sprintf(valorTabelaInt, "%d", $1);
                                                                char *t = novoTemp();
                                                                /*printf("\n========== VAR: %d ==========\033[0m\n", $1);*/
                                                                geraQuadrupla(NULL, strdup(valorTabelaInt), NULL, t);
                                                                listaExpr.temp = t;
                                                                $$ = listaExpr;
                                                                }
      | booleano                                                {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipoExpr = T_BOOL;
                                                                listaExpr.valor.boolVal = $1;

                                                                char *t = novoTemp();
                                                                /*printf("\n========== VAR: %s ==========\033[0m\n", $1);*/
                                                                geraQuadrupla(NULL, strdup($1), NULL, t);
                                                                listaExpr.temp = t;
                                                                $$ = listaExpr;
                                                                }
      | TK_NULL                                               {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipoExpr = T_NULO;
                                                                listaExpr.valor.nuloVal = $1;
                                                                $$ = listaExpr;
                                                                // Não sei se tem null em código de três endereços
                                                                }
      | STRING_LITERAL                                          {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipoExpr = T_STRING;
                                                                listaExpr.valor.stringVal = $1;

                                                                char *t = novoTemp();
                                                                /*printf("\n========== VAR: %s ==========\033[0m\n", $1);*/
                                                                geraQuadrupla(NULL, strdup($1), NULL, t);
                                                                listaExpr.temp = t;
                                                                $$ = listaExpr;
                                                                }
      | CHAR_LITERAL                                            {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipoExpr = T_CHAR;
                                                                listaExpr.valor.charVal = $1;

                                                                char *t = novoTemp();
                                                                /*printf("\n========== VAR: %s ==========\033[0m\n", $1);*/
                                                                geraQuadrupla(NULL, strdup($1), NULL, t);
                                                                listaExpr.temp = t;
                                                                $$ = listaExpr;
                                                                }
      | variavel                                                {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 1;
                                                                listaExpr.tipoExpr = retornaEnum(LBuscaTabela(&listaDeTabelas, $1).tipo);
                                                                listaExpr.valor.stringVal = $1;

                                                                char *t = novoTemp();
                                                                /*printf("\n========== VAR: %s ==========\033[0m\n", $1);*/
                                                                geraQuadrupla(NULL, strdup($1), NULL, t);
                                                                listaExpr.temp = t;
                                                                $$ = listaExpr;
                                                                }
      ;




opAritmetico : SOMA                     {/*printf("\nReduziu opAritmetico\n");*/ $$ = $1;}
             | SUBTRACAO                {/*printf("\nReduziu opAritmetico\n");*/ $$ = $1;}
             | MULTIPLICACAO            {/*printf("\nReduziu opAritmetico\n");*/ $$ = $1;}
             | DIVISAO                  {/*printf("\nReduziu opAritmetico\n");*/ $$ = $1;}
             | MOD                      {/*printf("\nReduziu opAritmetico\n");*/ $$ = $1;}
             ;

opRelacional : IGUAL                    {/*printf("\nReduziu opRelacional\n");*/ $$ = $1;}
             | DIFERENTE                {/*printf("\nReduziu opRelacional\n");*/ $$ = $1;}
             | MENOR                    {/*printf("\nReduziu opRelacional\n");*/ $$ = $1;}
             | MAIOR                    {/*printf("\nReduziu opRelacional\n");*/ $$ = $1;}
             | MENOR_IGUAL              {/*printf("\nReduziu opRelacional\n");*/ $$ = $1;}
             | MAIOR_IGUAL              {/*printf("\nReduziu opRelacional\n");*/ $$ = $1;}
             ;

opLogico : AND                          {/*printf("\nReduziu opLogico\n");*/ $$ = $1;}
         | OR                           {/*printf("\nReduziu opLogico\n");*/ $$ = $1;}
         ;
      
/*---------- COMANDOS ----------*/

listaComandos : comando listaComandos           {/*printf("\nReduziu listaComandos\n");*/}
              | /* vazio */
              ;

comando : ComRepetidor                          {/*printf("\nReduziu comando\n");*/}
        | ComObservador                         {/*printf("\nReduziu comando\n");*/}
        | ComComparador                         {/*printf("\nReduziu comando\n");*/}
        | ComRedstone                           {/*printf("\nReduziu comando\n");*/}
        | ComEnd                                {/*printf("\nReduziu comando\n");*/}
        | ComPular                              {/*printf("\nReduziu comando\n");*/}
        | ComOverworld                          {/*printf("\nReduziu comando\n");*/}
        | ComCarrinho                           {/*printf("\nReduziu comando\n");*/}
        | ComAtribuicao                         {/*printf("\nReduziu comando\n");*/}
        | ComMinerar                            {/*printf("\nReduziu comando\n");*/}
        | ComColocarBloco                       {/*printf("\nReduziu comando\n");*/}
        | ComVillager                           {/*printf("\nReduziu comando\n");*/}
        | ComRegenerar                          {/*printf("\nReduziu comando\n");*/}
        | ComVeneno                             {/*printf("\nReduziu comando\n");*/}
        | ComCreeper                            {/*printf("\nReduziu comando\n");*/}
        | ComBloco                              {/*printf("\nReduziu comando\n");*/}
        | chamadaProcedimento                   {/*printf("\nReduziu comando\n");*/}
        | chamadaFuncao                         {/*printf("\nReduziu comando\n");*/}
        | ComImprimir                           {/*printf("\nReduziu comando\n");*/}
        | inventario                            {/*printf("\nReduziu comando\n");*/}
        | defFuncao                             {/*printf("\nReduziu comando\n");*/}
        ;

ComRepetidor : FOR ABRE_PARENTESES 
               decRepet 
               M_novaLabel {geraQuadrupla("LABEL", NULL, NULL, $4);} 
               M_desvio_cond M_desvio_inc FIM_DE_LINHA 
               M_novaLabel {geraQuadrupla("LABEL", NULL, NULL, $9);} 
               exprRepet {geraQuadrupla("GOTO", NULL, NULL, $4);} 
               M_novaLabel {geraQuadrupla("LABEL", NULL, NULL, $13); patch_quad_result($7, $13);} 
               FECHA_PARENTESES abre_bloco listaComandos fecha_bloco        
               {/*printf("\nReduziu ComRepetidor\n");*/

                geraQuadrupla("GOTO", NULL, NULL, $9); // Salta para L2 (incremento)

                char* l = novaLabel(); 
                geraQuadrupla("LABEL", NULL, NULL, l); // Emite L4
                patch_quad_result($6, l); 
               }
             ;

decRepet : declaraVarTipo FIM_DE_LINHA               {/*printf("\nReduziu decRepet\n");*/}
         | variavel FIM_DE_LINHA                     {/*printf("\nReduziu decRepet\n");*/}
         | atribuiVar                                {/*printf("\nReduziu decRepet\n");*/}
         | FIM_DE_LINHA                              {/*printf("\nReduziu decRepet\n");*/}
         ;

exprRepet : expr                        {/*printf("\nReduziu exprRepet\n");*/ $$ = $1;}
          | /*vazio*/                   {/*printf("\nReduziu exprRepet\n"); */}
          ;

ComObservador : IF ABRE_PARENTESES M_desvio_cond FECHA_PARENTESES
                abre_bloco listaComandos fecha_bloco
                M_desvio_inc
                M_novaLabel {geraQuadrupla("LABEL", NULL, NULL, $9);}
                ComElse M_novaLabel             
                {/*printf("\nReduziu ComObservador\n");*/
                geraQuadrupla("LABEL", NULL, NULL, $12);
                patch_quad_result($8, $12);

                patch_quad_result($3, $9);
                }
             ;

ComElse : ELSE exprElse abre_bloco listaComandos fecha_bloco                    {/*printf("\nReduziu ComElse\n");*/}
        | /*vazio*/                                                             {/*printf("\nReduziu ComElse\n");*/}
        ;
exprElse : ABRE_PARENTESES expr FECHA_PARENTESES                     {/*printf("\nReduziu exprElse\n");*/}
         | /*vazio*/                                                 {/*printf("\nReduziu exprElse\n");*/}
         ;

ComComparador : WHILE ABRE_PARENTESES expr FECHA_PARENTESES abre_bloco listaComandos fecha_bloco                          {/*printf("\nReduziu ComComparador\n");*/}
              ;

ComRedstone : DO abre_bloco listaComandos fecha_bloco WHILE ABRE_PARENTESES expr FECHA_PARENTESES FIM_DE_LINHA            {/*printf("\nReduziu ComRedstone\n");*/}
            ;

ComEnd : BREAK FIM_DE_LINHA             {/*printf("\nReduziu ComEnd\n");*/}
       ;

ComPular : CONTINUE FIM_DE_LINHA        {/*printf("\nReduziu ComPular\n");*/}
         ;

ComOverworld :  RETURN expr FIM_DE_LINHA        {/*printf("\nReduziu ComOverworld\n");*/}
             ;

ComVillager : TYPECAST ABRE_PARENTESES variavel VIRGULA tipo FECHA_PARENTESES   {/*printf("\nReduziu ComVillager\n");*/}
            ;

trilhos : CASE expr ABRE_BLOCO listaComandos FECHA_BLOCO trilhos        {/*printf("\nReduziu trilhos\n");*/}
        | /*vazio*/                                                     {/*printf("\nReduziu trolhos\n");*/}
        ;

ComCarrinho : SWITCH abre_bloco trilhos DEFAULT ABRE_BLOCO listaComandos FECHA_BLOCO fecha_bloco        {/*printf("\nReduziu ComCarrinho\n");*/}
            ;

ComAtribuicao : atribuiVar      {/*printf("\nReduziu ComAtribuicao\n");*/}
              ;

ComMinerar : INCREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA  {/*printf("\nReduziu ComMinerar\n");*/ $$ = $3;} 
           ;
minerarExpr : INCREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES              {/*printf("\nReduziu ComMinerar\n");*/ $$ = $3;}
            ;

ComColocarBloco : DECREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA     {/*printf("\nReduziu ComColocarBloco\n");*/ $$ = $3;}
                ;
colocarBlocoExpr : DECREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES                 {/*printf("\nReduziu ComColocarBloco\n");*/ $$ = $3;}
                 ;

ComRegenerar : MAIS_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA         {/*printf("\nReduziu ComRegenerar\n");*/}
             ;

ComVeneno : MENOS_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA           {/*printf("\nReduziu ComVeneno\n");*/}
          ;

ComCreeper : MULTIPLICADOR_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA  {/*printf("\nReduziu ComCreeper\n");*/}
           ;

ComBloco : BLOCO ABRE_BLOCO parametros FECHA_BLOCO opAritmetico numero FIM_DE_LINHA    {/*printf("\nReduziu ComBloco\n");*/}
         ;

ComImprimir : PRINT ABRE_PARENTESES imprimivel FECHA_PARENTESES FIM_DE_LINHA       {/*printf("\nReduziu ComImprimir\n");*/}
            ;

imprimivel : expr                              {/*printf("\nReduziu imprimivel\n");*/}
           | expr CONCATENAR imprimivel        {/*printf("\nReduziu imprimivel\n");*/}
           ;


/*---------- TIPOS ----------*/
tipo : INTEIRO                  {$$ = T_INT; /*printf("\nReduziu tipo\n");*/}
     | FLOAT                    {$$ = T_FLOAT; /*printf("\nReduziu tipo\n");*/}
     | BOOL                     {$$ = T_BOOL; /*printf("\nReduziu tipo\n");*/}
     | STRING                   {$$ = T_STRING; /*printf("\nReduziu tipo\n");*/}
     | CHAR                     {$$ = T_CHAR; /*printf("\nReduziu tipo\n");*/}
     | DOUBLE                   {$$ = T_DOUBLE; /*printf("\nReduziu tipo\n");*/}
     ;

definicaoEnum : ENUM IDENTIFICADOR ABRE_BLOCO enumerations FECHA_BLOCO         {/*printf("\nReduziu definicaoEnum\n");*/ LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, "pocao", $2, "");}
              ;
enumerations : IDENTIFICADOR DOIS_PONTOS inteiro FIM_DE_LINHA enumerations             {/*printf("\nReduziu enumerations\n");*/ LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, "hp", strcat(strdup(idEnum), $1), "");}
             | /*vazio*/                                                               {/*printf("\nReduziu enumerations\n");*/}
             ;

/*---------- LITERAIS ----------*/

inteiro : DIGITO_POSITIVO               {/*printf("\nReduziu inteiro\n");*/ $$ = $1;}
        | DIGITO_NEGATIVO               {/*printf("\nReduziu inteiro\n");*/ $$ = $1;}
        ;

float : DECIMAL DEL_FLOAT               {/*printf("\nReduziu float\n");*/ $$ = $1;}
      ;

double : DECIMAL DEL_DOUBLE             {/*printf("\nReduziu double\n");*/ $$ = $1;}
       ;

numero : inteiro                        {/*printf("\nReduziu numero\n");*/ }
       | float                          {/*printf("\nReduziu numero\n");*/ }
       | double                         {/*printf("\nReduziu numero\n");*/ }
       ;

vetor : IDENTIFICADOR ABRE_COLCHETE expr FECHA_COLCHETE         {/*printf("\nReduziu vetor\n");*/ $$ = $1;}
      ;

booleano : TK_TRUE                      {/*printf("\nReduziu booleano\n");*/ $$ = $1;}
         | TK_FALSE                     {/*printf("\nReduziu booleano\n");*/ $$ = $1;}
         ;

%%


ListaExpressoes realizaOperacao(ListaExpressoes operando1, char *operador, ListaExpressoes operando2){
    ListaExpressoes result;
    int op1_int, op2_int;
    float op1_float, op2_float;
    double op1_double, op2_double;
    int op1_bool, op2_bool;
    char op1_char[20], op2_char[20];
    char op1_string[2048], op2_string[2048];

    
    switch(operando1.tipoExpr){
        case T_INT:
            // printf("\n\033[31m========== ENTROU INT OP1 ==========\033[0m\n");
            if(operando1.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                //printf("\n\t\t\t ##### VALOR: %s\n", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor);
                // printf("\n\n\033[31mSTRINGVAL: %s\033[0m\n\n", operando1.valor.stringVal);
                op1_int = atoi(LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor);
                // printf("\n\t\t\t #### OP1_INT: %d", op1_int);
            }
            else{
                op1_int = operando1.valor.intVal;
            }
            break;
        case T_FLOAT:
            // printf("\n\033[31m========== ENTROU FLOAT ==========\033[0m\n");
            if(operando1.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                op1_float = atof(LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor);
            }
            else{
                op1_float = operando1.valor.floatVal;
            }
            break;
        case T_DOUBLE:
            // printf("\n\033[31m========== ENTROU DOUBLE ==========\033[0m\n");
            if(operando1.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                op1_double = strtod(LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor, NULL);
            }
            else{
                op1_double = operando1.valor.doubleVal;
            }
        case T_BOOL:
            // printf("\n\033[31m========== ENTROU BOOLEANO ==========\033[0m\n");
            if(operando1.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                if (strcmp(LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor, "Acesa") == 0)
                    op1_bool = 1;
                else
                    op1_bool = 0;
            }
            else{
                if (strcmp(operando1.valor.boolVal, "Acesa") == 0)
                    op1_bool = 1;
                else
                    op1_bool = 0;
            }
            break;
        case T_CHAR:
            // printf("\n\033[31m========== ENTROU CHAR1 ==========\033[0m\n");
            if(operando1.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                strcpy(op1_char, LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor);
            }
            else{
                strcpy(op1_char, operando1.valor.charVal);
            }
            break;
        case T_STRING:
            // printf("\n\033[31m========== ENTROU STRING ==========\033[0m\n");
            if(operando1.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                strcpy(op1_string, LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor);
            }
            else{
                strcpy(op1_string, operando1.valor.stringVal);
            }
            break;
        default:
            break;
    }

    switch(operando2.tipoExpr){
        case T_INT:
            // printf("\n\033[31m========== ENTROU INT OP2 ==========\033[0m\n");
            if(operando2.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                op2_int = atoi(LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor);
            }
            else{
                op2_int = operando2.valor.intVal;
                // printf("\n\t\t\t #### OP2_INT: %d", op2_int);
            }
            break;
        case T_FLOAT:
            // printf("\n\033[31m========== ENTROU FLOAT ==========\033[0m\n");
            if(operando2.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                op2_float = atof(LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor);
            }
            else{
                op2_float = operando2.valor.floatVal;
            }
            break;
        case T_DOUBLE:
            // printf("\n\033[31m========== ENTROU DOUBLE ==========\033[0m\n");
            if(operando2.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                op2_double = strtod(LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor, NULL);
            }
            else{
                op2_double = operando2.valor.doubleVal;
            }
            break;
        case T_BOOL:
            // printf("\n\033[31m========== ENTROU BOOLEANO ==========\033[0m\n");
            if(operando2.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                if (strcmp(LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor, "Acesa") == 0)
                    op2_bool = 1;
                else
                    op2_bool = 0;
            }
            else{
                if (strcmp(operando2.valor.boolVal, "Acesa") == 0)
                    op2_bool = 1;
                else
                    op2_bool = 0;
            }
            break;
        case T_CHAR:
            // printf("\n\033[31m========== ENTROU CHAR2 ==========\033[0m\n");
            if(operando2.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                strcpy(op2_char, LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor);
            }
            else{
                strcpy(op2_char, operando2.valor.charVal);
            }
            break;
        case T_STRING:
            // printf("\n\033[31m========== ENTROU STRING ==========\033[0m\n");
            if(operando2.flagId != 0){
                result.flagId = 1;
                if (LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor == NULL){
                    char buffer[1024];
                    snprintf(buffer, sizeof(buffer), "Erro Semântico! A variável %s não possui valor.", LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal));
                    yyerror(buffer);
                }
                strcpy(op2_string, LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor);
            }
            else{
                strcpy(op2_string, operando2.valor.stringVal);
            }
            break;
        default:
            break;
    }

    //printf("\n\t\t\t OPERADOR: %s\n", operador);

    if (strcmp(operador, "+") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            // printf("\nOP1: %d  |  OP2: %d\n", op1_int, op2_int);
            result.tipoExpr = T_INT;
            result.valor.intVal = op1_int + op2_int;

            //printf("\n\t\t\t ========= TEMP: %s ==========\n", operando1.temp);
            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_FLOAT;
            result.valor.floatVal = op1_float + op2_float;
            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);

        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.valor.doubleVal = op1_double + op2_double;

            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);

        }
        else if(operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Soma inválida, não é permitido somar booleanos.\n");
        }
        else if(operando1.tipoExpr == T_CHAR || operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Soma inválida, não é permitido somar caracteres.\n");
        }
        else if(operando1.tipoExpr == T_STRING || operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Soma inválida, não é permitido somar strings.\n");
        }
        else{
            yyerror("Erro Semântico: Soma inválida, só é permitido somar operandos do mesmo tipo.\n");
        }
    }
    else if(strcmp(operador, "-") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_INT;
            result.valor.intVal = op1_int - op2_int;

            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_FLOAT;
            result.valor.floatVal = op1_float - op2_float;

            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.valor.doubleVal = op1_double - op2_double;

            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);            
        }
        else if(operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Subtração inválida, não é permitido subtrair booleanos.\n");
        }
        else if(operando1.tipoExpr == T_CHAR || operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Subtração inválida, não é permitido subtrair caracteres.\n");
        }
        else if(operando1.tipoExpr == T_STRING || operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Subtração inválida, não é permitido subtrair strings.\n");
        }
        else{
            yyerror("Erro Semântico: Subtração inválida, só é permitido subtrair operandos do mesmo tipo.\n");
        }
    }
    else if (strcmp(operador, "*") == 0){
        //printf("\nOP1: %d  |  OP2: %d\n", op1_int, op2_int);
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_INT;
            result.valor.intVal = op1_int * op2_int;
        
            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_FLOAT;
            result.valor.intVal = op1_float * op2_float;

            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.valor.intVal = op1_double * op2_double;

            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);
        }
        else if(operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Multiplicação inválida, não é permitido multiplicar booleanos.\n");
        }
        else if(operando1.tipoExpr == T_CHAR || operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Multiplicação inválida, não é permitido multiplicar caracteres.\n");
        }
        else if(operando1.tipoExpr == T_STRING || operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Multiplicação inválida, não é permitido multiplicar strings.\n");
        }
        else{
            yyerror("Erro Semântico: Multiplicação inválida, só é permitido multiplicar operandos do mesmo tipo.\n");
        }
    }
    else if (strcmp(operador, "/") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_INT;
            result.valor.intVal = op1_int / op2_int;

            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_FLOAT;
            result.valor.intVal = op1_float / op2_float;

            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.valor.intVal = op1_double / op2_double;

            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);
        }
        else if(operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Divisão inválida, não é permitido dividir booleanos.\n");
        }
        else if(operando1.tipoExpr == T_CHAR || operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Divisão inválida, não é permitido dividir caracteres.\n");
        }
        else if(operando1.tipoExpr == T_STRING || operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Divisão inválida, não é permitido dividir strings.\n");
        }
        else{
            yyerror("Erro Semântico: Divisão inválida, só é permitido dividir operandos do mesmo tipo.\n");
        }
    }
    else if (strcmp(operador, "%") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_INT;
            result.valor.intVal = op1_int % op2_int;

            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            yyerror("Erro Semântico: Módulo inválido, não é permitido calcular o módulo de números reais.\n");
        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            yyerror("Erro Semântico: Módulo inválido, não é permitido calcular o módulo de números reais.\n");
        }
        else if(operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Módulo inválido, não é permitido calcular o módulo de booleanos.\n");
        }
        else if(operando1.tipoExpr == T_CHAR || operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Módulo inválido, não é permitido calcular o módulo de caracteres.\n");
        }
        else if(operando1.tipoExpr == T_STRING || operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Módulo inválido, não é permitido calcular o módulo de strings.\n");
        }
        else{
            yyerror("Erro Semântico: Módulo inválido, só é permitido calcular o módulo de operandos do mesmo tipo.\n");
        }
    }
    else if (strcmp(operador, "!=") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_BOOL;
            if (op1_int != op2_int)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float != op2_float)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double != op2_double)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);
        }
        else if (operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            result.tipoExpr = T_BOOL;
            if (op1_bool != op2_bool)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoBooleano(operando1, operando2, &result, operador, LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor, LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor);
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            result.tipoExpr = T_BOOL;
            if (strcmp(op1_string, op2_string) != 0)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
                
            geraOperacaoString(operando1, operando2, &result, operador, op1_string, op2_string);
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            result.tipoExpr = T_BOOL;
            if (strcmp(op1_char, op2_char) != 0)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoChar(operando1, operando2, &result, operador, op1_char, op2_char);
        }
        else if (operando1.tipoExpr == T_NULO && operando2.tipoExpr == T_NULO){
            yyerror("Erro Semântico: Comparação inválida, não é permitido comparar operandos nulos.\n");
        }
        else
            yyerror("Erro Semântico: Comparação inválida, só é permitido comparar operandos do mesmo tipo.\n");
    }
    else if (strcmp(operador, "==") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_BOOL;
            if (op1_int == op2_int)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
                
            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float == op2_float)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double == op2_double)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);
        }
        else if (operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            result.tipoExpr = T_BOOL;
            if (op1_bool == op2_bool)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoBooleano(operando1, operando2, &result, operador, LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor, LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor);
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            result.tipoExpr = T_BOOL;
            if (strcmp(op1_string, op2_string) == 0)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoString(operando1, operando2, &result, operador, op1_string, op2_string);
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            result.tipoExpr = T_BOOL;
            if (strcmp(op1_char, op2_char) == 0)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoChar(operando1, operando2, &result, operador, op1_char, op2_char);
        }
        else if (operando1.tipoExpr == T_NULO && operando2.tipoExpr == T_NULO){
            yyerror("Erro Semântico: Comparação inválida, não é permitido comparar operandos nulos.\n");
        }
        else
            yyerror("Erro Semântico: Comparação inválida, só é permitido comparar operandos do mesmo tipo.\n");
    }
    else if (strcmp(operador, "<") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_BOOL;
            if (op1_int < op2_int)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float < op2_float)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double < op2_double)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Não é possível fazer a operação '<' entre strings.");
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Não é possível fazer a operação '<' entre chars.");
        }
        else if (operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Não é possível fazer a operação '<' entre booleanos.");
        }
        else if (operando1.tipoExpr == T_NULO && operando2.tipoExpr == T_NULO){
            yyerror("Erro Semântico: Não é possível fazer a operação '<' entre valores nulos.");
        }
        else
            yyerror("Erro Semântico: Comparação inválida, só é permitido fazer a operação '<' em entre operandos do mesmo tipo.\n");
    }
    else if (strcmp(operador, ">") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_BOOL;
            if (op1_int > op2_int){
                result.valor.boolVal = "Acesa";
            }
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float > op2_float)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double > op2_double)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Não é possível fazer a operação '>' entre strings.");
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Não é possível fazer a operação '>' entre chars.");
        }
        else if (operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Não é possível fazer a operação '>' entre booleanos.");
        }
        else if (operando1.tipoExpr == T_NULO && operando2.tipoExpr == T_NULO){
            yyerror("Erro Semântico: Não é possível fazer a operação '>' entre valores nulos.");
        }
        else
            yyerror("Erro Semântico: Comparação inválida, só é permitido fazer a operação '>' em operandos do mesmo tipo.\n");
    }
    else if (strcmp(operador, "<=") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_BOOL;
            if (op1_int <= op2_int)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal  = "Apagada";

            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float <= op2_float)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double <= op2_double)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Não é possível fazer a operação '<=' entre strings.");
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Não é possível fazer a operação '<=' entre chars.");
        }
        else if (operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Não é possível fazer a operação '<=' entre booleanos.");
        }
        else if (operando1.tipoExpr == T_NULO && operando2.tipoExpr == T_NULO){
            yyerror("Erro Semântico: Não é possível fazer a operação '<=' entre valores nulos.");
        }
        else
            yyerror("Erro Semântico: Comparação inválida, só é permitido fazer a operação '<=' em operandos do mesmo tipo.\n");
    }
    else if (strcmp(operador, ">=") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_BOOL;
            if (op1_int >= op2_int)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoInt(operando1, operando2, &result, operador, op1_int, op2_int);
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float >= op2_float)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoFloat(operando1, operando2, &result, operador, op1_float, op2_float);
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double >= op2_double)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";

            geraOperacaoDouble(operando1, operando2, &result, operador, op1_double, op2_double);
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Não é possível fazer a operação '>=' entre strings.");
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Não é possível fazer a operação '>=' entre chars.");
        }
        else if (operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            yyerror("Erro Semântico: Não é possível fazer a operação '>=' entre booleanos.");
        }
        else if (operando1.tipoExpr == T_NULO && operando2.tipoExpr == T_NULO){
            yyerror("Erro Semântico: Não é possível fazer a operação '>=' entre valores nulos.");
        }
        else
            yyerror("Erro Semântico: Comparação inválida, só é permitido fazer a operação '>=' em operandos do mesmo tipo.\n");
    }
    else if (strcmp(operador, "&&") == 0){
        if (operando1.tipoExpr == T_BOOL && operando1.tipoExpr == T_BOOL){
            result.tipoExpr = T_BOOL;
            if (op1_bool == 1 && op2_bool == 1)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoBooleano(operando1, operando2, &result, operador, LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor, LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor);
        }
        else if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            yyerror("Erro Semântico: Só é possível fazer a operação '&&' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            yyerror("Erro Semântico: Só é possível fazer a operação '&&' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            yyerror("Erro Semântico: Só é possível fazer a operação '&&' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Só é possível fazer a operação '&&' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Só é possível fazer a operação '&&' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_NULO && operando2.tipoExpr == T_NULO){
            yyerror("Erro Semântico: Só é possível fazer a operação '&&' entre valores booleanos.");
        }
        else
           yyerror("Erro Semântico: Comparação inválida, só é permitido fazer a operação '&&' em operandos do mesmo tipo.\n"); 
    }
    else if (strcmp(operador, "||") == 0){
        if (operando1.tipoExpr == T_BOOL && operando1.tipoExpr == T_BOOL){
            result.tipoExpr = T_BOOL;
            if (op1_bool == 1 || op2_bool == 1)
                result.valor.boolVal = "Acesa";
            else
                result.valor.boolVal = "Apagada";
            
            geraOperacaoBooleano(operando1, operando2, &result, operador, LBuscaTabela(&listaDeTabelas, operando1.valor.stringVal).valor, LBuscaTabela(&listaDeTabelas, operando2.valor.stringVal).valor);
        }
        else if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            yyerror("Erro Semântico: Só é possível fazer a operação '||' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            yyerror("Erro Semântico: Só é possível fazer a operação '||' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            yyerror("Erro Semântico: Só é possível fazer a operação '||' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            yyerror("Erro Semântico: Só é possível fazer a operação '||' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            yyerror("Erro Semântico: Só é possível fazer a operação '||' entre valores booleanos.");
        }
        else if (operando1.tipoExpr == T_NULO && operando2.tipoExpr == T_NULO){
            yyerror("Erro Semântico: Só é possível fazer a operação '||' entre valores booleanos.");
        }
        else
           yyerror("Erro Semântico: Comparação inválida, só é permitido fazer a operação '||' em operandos do mesmo tipo.\n"); 
    }
    else{
        yyerror("Erro Semântico: Operador inválido.\n");        
    }
    //printf("\n========== SAIU ==========\033[0m\n");
    return result;
}

// Retorna a string respectiva ao tipo
char* retornaTipo(TipoSimples tipo){
    switch(tipo){
        case T_INT:
            return "hp";
        case T_FLOAT:
            return "xp";
        case T_DOUBLE:
            return "bussola";
        case T_BOOL:
            return "tocha";
        case T_CHAR:
            return "fragmento";
        case T_STRING:
            return "livro";
        default:
            break;
    }
}


int retornaEnum(char *tipo){
    if (strcmp(tipo, "hp") == 0) {
        return T_INT;
    } else if (strcmp(tipo, "xp") == 0) {
        return T_FLOAT;
    } else if (strcmp(tipo, "bussola") == 0) {
        return T_DOUBLE;
    } else if (strcmp(tipo, "tocha") == 0) {
        return T_BOOL;
    } else if (strcmp(tipo, "fragmento") == 0) {
        return T_CHAR;
    } else if (strcmp(tipo, "livro") == 0) {
        return T_STRING;
    } else {
        return -1;
    }
}

char *novoTemp(){
    char temp[20];
    sprintf(temp, "T%d", tempCount);
    tempCount++;
    return strdup(temp);
}

char *novaLabel(){
    char label[20];
    sprintf(label, "L%d", labelCount);
    labelCount++;
    return strdup(label);
}

void patch_quad_result(int quad_index, char* result) {
    if (quad_index < vetor_quadruplas.tamanho) {
        vetor_quadruplas.quadrupla[quad_index].result = strdup(result);
    }
}

void geraQuadrupla(char *op, char *arg1, char *arg2, char *result){
    
    QuadruplaCodigo quadrupla;
    quadrupla.op = op;
    quadrupla.arg1 = arg1;
    quadrupla.arg2 = arg2;
    quadrupla.result = result;
    inserirVetor(&vetor_quadruplas, quadrupla);
}

void geraOperacaoInt(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, int op1_int, int op2_int){
    //printf("\n\033[31m========== GeraOperacaoInt ==========\033[0m\n");
    char *t = novoTemp();
    //printf("\n\033[31m========== op1.temp: %s ==========\033[0m\n", op1.temp);
    //printf("\n\033[31m========== op2.temp: %s ==========\033[0m\n", op2.temp);

    if (op1.temp == NULL && op2.temp == NULL){
        char valorInt1[100];
        char valorInt2[100];
        sprintf(valorInt1, "%d", op1_int);
        sprintf(valorInt2, "%d", op2_int);
        geraQuadrupla(operador, valorInt1, valorInt2, t);
    }
    else if (op1.temp != NULL) {   
        if (op1.temp[0] == 'T' && op2.temp == NULL){
            char valorInt[100];
            sprintf(valorInt, "%d", op2_int);
            geraQuadrupla(operador, strdup(op1.temp), valorInt, t);
        }
        if(op2.temp != NULL){
            if (op1.temp[0] == 'T' && op2.temp[0] == 'T'){
                geraQuadrupla(operador, strdup(op1.temp), strdup(op2.temp), t);
            }
        }
    }else {
        if (op1.temp == NULL && op2.temp[0] == 'T'){
            char valorInt[100];
            sprintf(valorInt, "%d", op1_int);
            geraQuadrupla(operador, valorInt, strdup(op2.temp), t);
        } 
    }
    result->temp = t;
}

void geraOperacaoChar(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, char* op1_char, char* op2_char){
    char *t = novoTemp();
    if (op1.temp != NULL && op2.temp != NULL){
        geraQuadrupla(operador, strdup(op1.temp), strdup(op2.temp), t);
    }
    else if (op1.temp != NULL && op2.temp == NULL){
        geraQuadrupla(operador, strdup(op1.temp), op2_char, t);
    }
    else if (op1.temp == NULL && op2.temp != NULL){
        geraQuadrupla(operador, op1_char, strdup(op2.temp), t);
    }
    else{
        geraQuadrupla(operador, op1_char, op2_char, t);
    }
    result->temp = t;
}

void geraOperacaoDouble(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, double op1_double, double op2_double){
    char *t = novoTemp();
    if (op1.temp != NULL && op2.temp != NULL){
        geraQuadrupla(operador, strdup(op1.temp), strdup(op2.temp), t);
    }
    else if (op1.temp != NULL && op2.temp == NULL){
        char valorDouble[100];
        sprintf(valorDouble, "%lf", op2_double);
        geraQuadrupla(operador, strdup(op1.temp), valorDouble, t);
    }
    else if (op1.temp == NULL && op2.temp != NULL){
        char valorDouble[100];
        sprintf(valorDouble, "%lf", op1_double);
        geraQuadrupla(operador, valorDouble, strdup(op2.temp), t);
    }
    else{
        char valorDouble1[100];
        char valorDouble2[100];
        sprintf(valorDouble1, "%lf", op1_double);
        sprintf(valorDouble2, "%lf", op2_double);
        geraQuadrupla(operador, valorDouble1, valorDouble2, t);
    }
    result->temp = t;
}

void geraOperacaoBooleano(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, char* op1_bool, char* op2_bool){
    char *t = novoTemp();
    if (op1.temp != NULL && op2.temp != NULL){
        geraQuadrupla(operador, strdup(op1.temp), strdup(op2.temp), t);
    }
    else if (op1.temp != NULL && op2.temp == NULL){
        geraQuadrupla(operador, strdup(op1.temp), op2_bool, t);
    }
    else if (op1.temp == NULL && op2.temp != NULL){
        geraQuadrupla(operador, op1_bool, strdup(op2.temp), t);
    }
    else{
        geraQuadrupla(operador, op1_bool, op2_bool, t);
    }
    result->temp = t;
}

void geraOperacaoString(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, char* op1_string, char *op2_string){
    char *t = novoTemp();
    if (op1.temp != NULL && op2.temp != NULL){
        geraQuadrupla(operador, strdup(op1.temp), strdup(op2.temp), t);
    }
    else if (op1.temp != NULL && op2.temp == NULL){
        geraQuadrupla(operador, strdup(op1.temp), op2_string, t);
    }
    else if (op1.temp == NULL && op2.temp != NULL){
        geraQuadrupla(operador, op1_string, strdup(op2.temp), t);
    }
    else{
        geraQuadrupla(operador, op1_string, op2_string, t);
    }
    result->temp = t;
}

void geraOperacaoFloat(ListaExpressoes op1, ListaExpressoes op2, ListaExpressoes *result, char *operador, float op1_float, float op2_float){
    char *t = novoTemp();
    if (op1.temp != NULL && op2.temp != NULL){
        geraQuadrupla(operador, strdup(op1.temp), strdup(op2.temp), t);
    }
    else if (op1.temp != NULL && op2.temp == NULL){
        char valorFloat[100];
        sprintf(valorFloat, "%f", op2_float);
        geraQuadrupla(operador, strdup(op1.temp), valorFloat, t);
    }
    else if (op1.temp == NULL && op2.temp != NULL){
        char valorFloat[100];
        sprintf(valorFloat, "%f", op1_float);
        geraQuadrupla(operador, valorFloat, strdup(op2.temp), t);
    }
    else{
        char valorFloat1[100];
        char valorFloat2[100];
        sprintf(valorFloat1, "%f", op1_float);
        sprintf(valorFloat2, "%f", op2_float);
        geraQuadrupla(operador, valorFloat1, valorFloat2, t);
    }
    result->temp = t;
}

// Remove os \t e " " antes da linha de código
void limpaLinha(char *str) {
    int i = 0;

    while (str[i] == ' ' || str[i] == '\t') {
        i++;
    }

    if (i > 0) {
        memmove(str, str + i, strlen(str + i) + 1);
    }
}

// Exibe a linha e coluna onde o erro ocorreu
void yyerror (char const *mensagem){
    // Diz o token que esperava e o que recebeu.
    fprintf(stderr, "\nErro na linha %d: %s\n", num_linha, mensagem);
    limpaLinha(linha_atual);
    printf("%d - %s\n", num_linha, linha_atual);

    for(int j = 0; j < 5; j++){
        printf(" ");
    }

    for(int i = 0; i < pos_na_linha; i++){
        if(linha_atual[i] == '\t')
                printf("\t");
    else
                printf(" ");
    }
    printf("\033[31m^\033[0m\n");

    // Imprime o que foi usado de forma errada
    if (mensagem[0] != 'E'){
        printf("Parte inesperada: '%s'\n", yytext);
    }
    exit(1);
}