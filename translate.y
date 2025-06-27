%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "TabelaDeSimbolos/TADListaDeTabelas.h"
#include "TabelaDeSimbolos/TADTabelaDeSimbolos.h"

void yyerror(char const *mensagem);

typedef enum {T_INT, T_FLOAT, T_BOOL, T_STRING, T_CHAR, T_NULO, T_DOUBLE} TipoSimples;      // Enum para os tipos disponíveis
extern int yylex();
extern int num_linha;
extern char *yytext;                                                                        // Texto do token atual (fornecido pelo Flex)
extern int ultimo_token;
extern ListaDeTabelas listaDeTabelas;                                                       // Lista de tabelas de símbolos
char *retornaTipo(TipoSimples tipo);
char typeBau[24] = "bau ";
char idEnum[240] = "enum.";

typedef struct ListaExpressoes{
    TipoSimples tipoExpr;
    int flagId;
    union {
        int intVal;
        float floatVal;
        double doubleVal;
        char *stringVal;
        char *charVal;
        bool boolVal;
        void nuloVal;
    } valor;
} ListaExpressoes;

extern char linha_atual[1024];
extern int pos_na_linha;

%}
%define parse.lac full
%define parse.error verbose                                                                 // Diretiva que gera mensagens de erro mais complexas


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
    struct ListaExpressoes listaExpr;
}

// Definição dos Tokens da linguagem
%token FUNCAO PROCEDIMENTO
%token VETOR ENUM
%token <intVal> DIGITO_POSITIVO DIGITO_NEGATIVO 
%token <floatVal> DECIMAL
%token <stringVal>  STRING_LITERAL IDENTIFICADOR FUNC_MAIN
%token <charVal> CHAR_LITERAL
%token BLOCO
%token TK_TRUE TK_FALSE
%token SOMA SUBTRACAO MULTIPLICACAO DIVISAO MOD
%token INCREMENTO DECREMENTO MAIS_IGUAL MENOS_IGUAL MULTIPLICADOR_IGUAL CONCATENAR
%token IGUAL DIFERENTE MENOR MAIOR MENOR_IGUAL MAIOR_IGUAL DOIS_PONTOS
%token AND OR RECEBE
%token ABRE_PARENTESES FECHA_PARENTESES

// Definição de tipos
%token INTEIRO FLOAT BOOL DOUBLE STRING CHAR
%token ABRE_BLOCO FECHA_BLOCO ABRE_COLCHETE FECHA_COLCHETE VIRGULA
%token ESCOPO IF ELSE WHILE DO FOR SWITCH CASE DEFAULT TK_NULL
%token BREAK CONTINUE RETURN IMPORT TYPECAST VOID PRINT 
%token FIM_DE_LINHA
%token DEL_DOUBLE DEL_FLOAT
%type <tipoEnum> tipo
%type <stringVal> nomeFuncao
%type <stringVal> variavel
%type <stringVal> vetor
%type <stringVal> argumento
%type <stringVal> argumentos
%type <listaExpr> listaExpressoes, fator, exprAritmetico, exprRelacional, exprLogico
%type <stringVal> opAritmetico, opLogico, opRelacional
%type <intVal> inteiro
%type <floatVal> float
%type <doubleVal> double

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

//TODO: ter um campo no simbolo da função que vai ser "hp xp livro", depois fazer um strip na hora de analisar
assinaturaFuncao : tipo FUNCAO nomeFuncao ABRE_PARENTESES argumentos FECHA_PARENTESES        {/*printf("\nReduziu assinaturaFuncao\n");*/
                                                                                                if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $3).id < 0){
                                                                                                    LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, retornaTipo($1), $3, 0);
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
                                                                                                    LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, "vazio", $3, 0);
                                                                                                    ImprimeListaTabela(&listaDeTabelas);
                                                                                                }
                                                                                                else
                                                                                                    yyerror("Erro Semântico: Esse procedimento já está declarado nesse escopo\n");
                                                                                                } 
                 ;

chamadaFuncaoExpr : FUNCAO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES    {/*printf("\nReduziu chamadaFuncaoExpr\n");*/
                                                                                        if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id == -1)
                                                                                            yyerror("Erro Semântico: Essa função não foi declarada\n");
                                                                                        } //TODO: aqui precisa verificar se os parametros tem o tipo certo
              ;
chamadaFuncao : FUNCAO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES FIM_DE_LINHA   {/*printf("\nReduziu chamadaFuncao\n");*/
                                                                                                if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id == -1)
                                                                                                    yyerror("Erro Semântico: Essa função não foi declarada\n");
                                                                                                } //TODO: aqui precisa verificar se os parametros tem o tipo certo
              ;

chamadaProcedimento : PROCEDIMENTO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES FIM_DE_LINHA       {/*printf("\nReduziu chamadaProcedimento\n");*/
                                                                                                                if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id == -1)
                                                                                                                    yyerror("Erro Semântico: Esse procedimento não foi declarado\n");
                                                                                                                }
                    ;

declaraVarTipo : tipo IDENTIFICADOR atribuicao          {/*printf("\nReduziu declaraVarTipo\n");*/
                                                        if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id < 0){
                                                            LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, retornaTipo($1), $2, 0);
                                                            ImprimeListaTabela(&listaDeTabelas);
                                                        }
                                                        else
                                                            yyerror("Erro Semântico: Essa variável já está declarada nesse escopo\n");
                                                        //TODO: Verificar também se o tipo da atribuição é compatível com o tipo da variável
                                                        }
               | tipo IDENTIFICADOR FIM_DE_LINHA        {/*printf("\nReduziu declaraVarTipo\n");*/ 
                                                        if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id < 0){
                                                            LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, retornaTipo($1), $2, 0);
                                                            ImprimeListaTabela(&listaDeTabelas);
                                                        }
                                                        else
                                                            yyerror("Erro Semântico: Essa variável já está declarada nesse escopo\n");
                                                        }
               ;

declaraVarTipoVetor : VETOR tipo IDENTIFICADOR ABRE_COLCHETE inteiro FECHA_COLCHETE FIM_DE_LINHA    {/*printf("\nReduziu declaraVarTipoVetor\n");*/
                                                                                                    if(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $3).id < 0){
                                                                                                        LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, strcat(strdup(typeBau), retornaTipo($2)), $3, 0);
                                                                                                        ImprimeListaTabela(&listaDeTabelas);
                                                                                                    }
                                                                                                    else
                                                                                                        yyerror("Erro Semântico: Essa variável já está declarada nesse escopo\n");
                                                                                                    }
                    ;

variavel : IDENTIFICADOR        {/*printf("\nReduziu variavel\n");*/
                                if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id == -1)
                                    yyerror("Erro Semântico: essa variável não foi declarada\n");
                                else
                                    $$ = $1;
                                }
         | vetor                {/*printf("\nReduziu variavel\n");*/ 
                                if (buscaSimbolo(&listaDeTabelas.pUltimo->tabela, $2).id == -1)
                                    yyerror("Erro Semântico: essa variável não foi declarada\n");
                                else
                                    $$ = $1;
                                }
         ;

atribuiVar : variavel atribuicao        {/*printf("\nReduziu atribuiVar\n");*/} //TODO: verificar se o valor da atribuição é compatível com o da variavel
           ;

atribuicao : RECEBE listaExpressoes FIM_DE_LINHA        {/*printf("\nReduziu atribuicao\n");*/}
           ;

argumentos : argumento argumentos       {/*printf("\nReduziu argumentos\n");*/ $$ = strcat($1, $2);}
           | VIRGULA argumento          {/*printf("\nReduziu argumentos\n");*/ $$ = $2;}
           | /*vazio*/                  {/*printf("\nReduziu argumentos\n");*/}
           ;

argumento : tipo variavel               {/*printf("\nReduziu argumento\n");*/
                                        $$ = strcat(retornaTipo($1), " ");
                                        }
          ;

parametros : parametro parmOpicionais   {/*printf("\nReduziu parametros\n");*/}
           ;

parmOpicionais : VIRGULA parametro parmOpicionais       {/*printf("\nReduziu parmOpicionais\n");*/}
               | /* vazio */
               ;
               
parametro: expr         {/*printf("\nReduziu parametro\n");*/}
         ;


/*---------- EXPRESSOES ----------*/

// TODO: em todas essas operações, precisamos ver se o tipo dos operandos é compatível
listaExpressoes : expr                                  {/*printf("\nReduziu listaExpressoes\n");*/}
                | expr VIRGULA listaExpressoes          {/*printf("\nReduziu listaExpressoes\n");*/}
                ;

expr : exprLogico                                       {/*printf("\nReduziu expr\n");*/}
     ;

exprLogico : exprRelacional                             {/*printf("\nReduziu exprLogico\n");*/}
           | exprLogico opLogico exprRelacional         {/*printf("\nReduziu exprLogico\n");*/}
           ;

exprRelacional : exprAritmetico                                 {/*printf("\nReduziu exprRelacional\n");*/}
               | exprAritmetico opRelacional exprAritmetico     {/*printf("\nReduziu exprRelacional\n");*/}
               ;
                         
exprAritmetico : exprAritmetico opAritmetico fator              {/*printf("\nReduziu exprAritmetico\n");*/
                                                                $$ = realizaOperacao($1, $2, $3);
                                                                } //TODO: ver como as operações vão ser feitas.
               | fator                                          {/*printf("\nReduziu exprAritmetico\n");*/
                                                                $$ = $1;
                                                                }
               ;
               
fator : ABRE_PARENTESES expr FECHA_PARENTESES                   {/*printf("\nReduziu fator\n");*/
                                                                $$ = $2;
                                                                }
      | chamadaFuncaoExpr                                       {/*printf("\nReduziu fator\n");*/} //TODO: verificar o valor pelo return?
      | minerarExpr                                             {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 1;
                                                                listaExpr.tipo = T_INT;
                                                                listaExpr.valor.intVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | colocarBlocoExpr                                        {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 1;
                                                                listaExpr.tipo = T_INT;
                                                                listaExpr.valor.intVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | float                                                   {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipo = T_FLOAT;
                                                                listaExpr.valor.floatVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | double                                                  {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipo = T_DOUBLE;
                                                                listaExpr.valor.doubleVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | inteiro                                                 {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipo = T_INT;
                                                                listaExpr.valor.intVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | booleano                                                {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipo = T_BOOL;
                                                                listaExpr.valor.boolVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | TK_NULL                                                 {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipo = T_NULO;
                                                                listaExpr.valor.nuloVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | STRING_LITERAL                                          {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipo = T_STRING;
                                                                listaExpr.valor.charVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | CHAR_LITERAL                                            {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 0;
                                                                listaExpr.tipo = T_CHAR;
                                                                listaExpr.valor.charVal = $1;
                                                                $$ = listaExpr;
                                                                }
      | variavel                                                {/*printf("\nReduziu fator\n");*/
                                                                ListaExpressoes listaExpr;
                                                                listaExpr.flagId = 1;
                                                                listaExpr.tipo = T_STRING;
                                                                listaExpr.valor.stringVal = $1;
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

ComRepetidor : FOR ABRE_PARENTESES decRepet FIM_DE_LINHA exprRepet FIM_DE_LINHA exprRepet FECHA_PARENTESES abre_bloco listaComandos fecha_bloco         {/*printf("\nReduziu ComRepetidor\n");*/}
             ;

decRepet : declaraVarTipo               {/*printf("\nReduziu decRepet\n");*/}
         | IDENTIFICADOR                {/*printf("\nReduziu decRepet\n");*/}
         | /*vazio*/                    {/*printf("\nReduziu decRepet\n");*/}
         ;

exprRepet : listaExpressoes             {/*printf("\nReduziu exprRepet\n");*/}
          | /*vazio*/                   {/*printf("\nReduziu exprRepet\n");*/}
          ;

ComObservador : IF ABRE_PARENTESES listaExpressoes FECHA_PARENTESES abre_bloco listaComandos fecha_bloco ComElse                {/*printf("\nReduziu ComObservador\n");*/}
             ;
ComElse : ELSE exprElse abre_bloco listaComandos fecha_bloco                    {/*printf("\nReduziu ComElse\n");*/}
        | /*vazio*/                                                             {/*printf("\nReduziu ComElse\n");*/}
        ;
exprElse : ABRE_PARENTESES listaExpressoes FECHA_PARENTESES                     {/*printf("\nReduziu exprElse\n");*/}
         | /*vazio*/                                                            {/*printf("\nReduziu exprElse\n");*/}
         ;

ComComparador : WHILE ABRE_PARENTESES listaExpressoes FECHA_PARENTESES abre_bloco listaComandos fecha_bloco                          {/*printf("\nReduziu ComComparador\n");*/}
              ;

ComRedstone : DO abre_bloco listaComandos fecha_bloco WHILE ABRE_PARENTESES listaExpressoes FECHA_PARENTESES FIM_DE_LINHA            {/*printf("\nReduziu ComRedstone\n");*/}
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

ComMinerar : INCREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA  {/*printf("\nReduziu ComMinerar\n");*/} //TODO: fazer a operação ++ no valor da variável
           ;
minerarExpr : INCREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES              {/*printf("\nReduziu ComMinerar\n");*/} //TODO: fazer a operação ++ no valor da variável
            ;

ComColocarBloco : DECREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA     {/*printf("\nReduziu ComColocarBloco\n");*/} //TODO: fazer a operação -- no valor da variável
                ;
colocarBlocoExpr : DECREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES                 {/*printf("\nReduziu ComColocarBloco\n");*/} //TODO: fazer a operação -- no valor da variável
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

imprimivel : listaExpressoes                              {/*printf("\nReduziu imprimivel\n");*/}
           | listaExpressoes CONCATENAR imprimivel        {/*printf("\nReduziu imprimivel\n");*/}
           ;


/*---------- TIPOS ----------*/
tipo : INTEIRO                  {$$ = T_INT; /*printf("\nReduziu tipo\n");*/}
     | FLOAT                    {$$ = T_FLOAT; /*printf("\nReduziu tipo\n");*/}
     | BOOL                     {$$ = T_BOOL; /*printf("\nReduziu tipo\n");*/}
     | STRING                   {$$ = T_STRING; /*printf("\nReduziu tipo\n");*/}
     | CHAR                     {$$ = T_CHAR; /*printf("\nReduziu tipo\n");*/}
     | DOUBLE                   {$$ = T_DOUBLE; /*printf("\nReduziu tipo\n");*/}
     ;

definicaoEnum : ENUM IDENTIFICADOR ABRE_BLOCO enumerations FECHA_BLOCO         {/*printf("\nReduziu definicaoEnum\n");*/ LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, "pocao", $2, 0); ImprimeListaTabela(&listaDeTabelas);}
              ;
enumerations : IDENTIFICADOR DOIS_PONTOS inteiro FIM_DE_LINHA enumerations             {/*printf("\nReduziu enumerations\n");*/ LInsereSimboloTabela(&listaDeTabelas.pUltimo->tabela, "hp", strcat(strdup(idEnum), $1), 0); ImprimeListaTabela(&listaDeTabelas);}
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

numero : inteiro                        {/*printf("\nReduziu numero\n");*/}
       | float                          {/*printf("\nReduziu numero\n");*/}
       | double                         {/*printf("\nReduziu numero\n");*/}
       ;

vetor : IDENTIFICADOR ABRE_COLCHETE expr FECHA_COLCHETE         {/*printf("\nReduziu vetor\n");*/ $$ = $1;}
      ;

booleano : TK_TRUE                      {/*printf("\nReduziu booleano\n");*/}
         | TK_FALSE                     {/*printf("\nReduziu booleano\n");*/}
         ;

%%


ListaExpressoes realizaOperacao(ListaExpressoes operando1, char operador, ListaExpressoes operando2){

    ListaExpressoes result;
    int op1_int, op2_int;
    float op1_float, op2_float;
    double op1_double, op2_double;
    int op1_bool, op2_bool;
    char *op1_char, *op2_char;
    char *op1_string, *op2_string;

    switch(operando1.tipoExpr){
        case T_INT:
            if(operando1.flagId != 0){
                op1_int = atoi(buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                op1_int = operando1.intVal;
            }
        case T_FLOAT:
            if(operando1.flagId != 0){
                op1_float = atof(buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                op1_float = operando1.floatVal;
            }
        case T_DOUBLE:
            if(operando1.flagId != 0){
                result.flagId = 1;
                op1_double = strtod(buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                op1_double = operando1.doubleVal;
            }
        case T_BOOL:
            if(operando1.flagId != 0){
                if (strcmp(buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor, "Acesa") == 0)
                    op1_bool = 1;
                else
                    op1_bool = 0;
            }
            else{
                if (strcmp(operando1.boolVal, "Acesa") == 0)
                    op1_bool = 1;
                else
                    op1_bool = 0;
            }
        case T_CHAR:
            if(operando1.flagId != 0){
                strcpy(op1_char, buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                strcpy(op1_char, operando1.charVal);
            }
        case T_STRING:
            if(operando1.flagId != 0){
                strcpy(op1_string, buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                strcpy(op1_string, operando1.stringVal);else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.intVal = op1_double + op2_double;
        }
            }
        default:
            break;
    }


    switch(operando2.tipoExpr){
        case T_INT:
            if(operando1.flagId != 0){
                op2_int = atoi(buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                op2_int = operando1.intVal;
            }
        case T_FLOAT:
            if(operando1.flagId != 0){
                op2_float = atof(buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                op2_float = operando1.floatVal;
            }
        case T_DOUBLE:
            if(operando1.flagId != 0){
                op2_double = strtod(buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                op2_double = operando1.doubleVal;
            }
        case T_BOOL:
            if(operando1.flagId != 0){
                if (strcmp(buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor, "Acesa") == 0)
                    op2_bool = 1;
                else
                    op2_bool = 0;
            }
            else{
                if (strcmp(operando1.boolVal, "Acesa") == 0)
                    op2_bool = 1;
                else
                    op2_bool = 0;
            }
        case T_CHAR:
            if(operando1.flagId != 0){
                strcpy(op2_char, buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                strcpy(op2_char, operando1.charVal);
            }
        case T_STRING:
            if(operando1.flagId != 0){
                strcpy(op2_string, buscaSimbolo(buscaSimbolo(&listaDeTabelas.pUltimo->tabela, operando1.stringVal)).valor);
            }
            else{
                strcpy(op2_string, operando1.stringVal);
            }
        default:
            break;
    }


    if (strcmp(operador, "+") == 0){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_INT;
            result.intVal = op1_int + op2_int;
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_FLOAT;
            result.intVal = op1_float + op2_float;
        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.intVal = op1_double + op2_double;
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
            result.intVal = op1_int - op2_int;
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_FLOAT;
            result.intVal = op1_float - op2_float;
        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.intVal = op1_double - op2_double;
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
    else if (strcmp(operador, "*")){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_INT;
            result.intVal = op1_int * op2_int;
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_FLOAT;
            result.intVal = op1_float * op2_float;
        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.intVal = op1_double * op2_double;
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
    else if (strcmp(operador, "/")){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_INT;
            result.intVal = op1_int / op2_int;
        }
        else if(operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_FLOAT;
            result.intVal = op1_float / op2_float;
        }
        else if(operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_DOUBLE;
            result.intVal = op1_double / op2_double;
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
    else if (strcmp(operador, "%")){
        if (operando1.tipoExpr == T_INT && operando2.tipoExpr == T_INT){
            result.tipoExpr = T_INT;
            result.intVal = op1_int % op2_int;
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
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float != op2_float)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double != op2_double)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            result.tipoExpr = T_BOOL;
            if (op1_bool != op2_bool)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            result.tipoExpr = T_BOOL;
            if (strcmp(op1_string, op2_string) != 0)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            result.tipoExpr = T_BOOL;
            if (strcmp(op1_char, op2_char) != 0)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
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
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float == op2_float)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double == op2_double)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_BOOL && operando2.tipoExpr == T_BOOL){
            result.tipoExpr = T_BOOL;
            if (op1_bool == op2_bool)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_STRING && operando2.tipoExpr == T_STRING){
            result.tipoExpr = T_BOOL;
            if (strcmp(op1_string, op2_string) == 0)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_CHAR && operando2.tipoExpr == T_CHAR){
            result.tipoExpr = T_BOOL;
            if (strcmp(op1_char, op2_char) == 0)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
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
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float < op2_float)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double < op2_double)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
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
            if (op1_int > op2_int)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float > op2_float)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double > op2_double)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
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
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float <= op2_float)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double <= op2_double)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
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
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_FLOAT && operando2.tipoExpr == T_FLOAT){
            result.tipoExpr = T_BOOL;
            if (op1_float >= op2_float)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
        }
        else if (operando1.tipoExpr == T_DOUBLE && operando2.tipoExpr == T_DOUBLE){
            result.tipoExpr = T_BOOL;
            if (op1_double >= op2_double)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
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
    else if (strcmp(opeorador, "&&")){
        if (operando1.tipoExpr == T_BOOL && operando1.tipoExpr == T_BOOL){
            result.tipoExpr = T_BOOL;
            if (op1_bool == 1 && op2_bool == 1)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
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
    else if (strcmp(opeorador, "||")){
        if (operando1.tipoExpr == T_BOOL && operando1.tipoExpr == T_BOOL){
            result.tipoExpr = T_BOOL;
            if (op1_bool == 1 || op2_bool == 1)
                strcpy(result.boolVal, "Acesa");
            else
                strcpy(result.boolVal, "Apagada");
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
    //printf("Ultimo Token Num: %d \n", ultimo_token);
    exit(1);
}