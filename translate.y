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
    char *booleano;
    int tipoEnum;
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
                                                        }//TODO: Verificar também se o tipo da atribuição é compatível com o tipo da variável
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

argumentos : argumento argumentos       {/*printf("\nReduziu argumentos\n");*/}
           | VIRGULA argumento          {/*printf("\nReduziu argumentos\n");*/}
           | /*vazio*/                  {/*printf("\nReduziu argumentos\n");*/}
           ;

argumento : tipo variavel               {/*printf("\nReduziu argumento\n");*/}
          ; // TODO: acho que vamos ter que colocar esses argumentos na tabela de símbolos (no mesmo escopo da função deles)

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
                         
exprAritmetico : exprAritmetico opAritmetico fator              {/*printf("\nReduziu exprAritmetico\n");*/}
               | fator                                          {/*printf("\nReduziu exprAritmetico\n");*/}
               ;
               
fator : ABRE_PARENTESES expr FECHA_PARENTESES                   {/*printf("\nReduziu fator\n");*/}
      | chamadaFuncaoExpr                                       {/*printf("\nReduziu fator\n");*/}
      | minerarExpr                                             {/*printf("\nReduziu fator\n");*/}
      | colocarBlocoExpr                                        {/*printf("\nReduziu fator\n");*/}
      | numero                                                  {/*printf("\nReduziu fator\n");*/}
      | booleano                                                {/*printf("\nReduziu fator\n");*/}
      | TK_NULL                                                 {/*printf("\nReduziu fator\n");*/}
      | STRING_LITERAL                                          {/*printf("\nReduziu fator\n");*/}
      | CHAR_LITERAL                                            {/*printf("\nReduziu fator\n");*/}
      | variavel                                                {/*printf("\nReduziu fator\n");*/}
      ;




opAritmetico : SOMA                     {/*printf("\nReduziu opAritmetico\n");*/}
             | SUBTRACAO                {/*printf("\nReduziu opAritmetico\n");*/}
             | MULTIPLICACAO            {/*printf("\nReduziu opAritmetico\n");*/}
             | DIVISAO                  {/*printf("\nReduziu opAritmetico\n");*/}
             | MOD                      {/*printf("\nReduziu opAritmetico\n");*/}
             ;
            
opRelacional : IGUAL                    {/*printf("\nReduziu opRelacional\n");*/}
             | DIFERENTE                {/*printf("\nReduziu opRelacional\n");*/}
             | MENOR                    {/*printf("\nReduziu opRelacional\n");*/}
             | MAIOR                    {/*printf("\nReduziu opRelacional\n");*/}
             | MENOR_IGUAL              {/*printf("\nReduziu opRelacional\n");*/}
             | MAIOR_IGUAL              {/*printf("\nReduziu opRelacional\n");*/}
             ;

opLogico : AND                          {/*printf("\nReduziu opLogico\n");*/}
         | OR                           {/*printf("\nReduziu opLogico\n");*/}
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

ComMinerar : INCREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA  {/*printf("\nReduziu ComMinerar\n");*/}
           ;
minerarExpr : INCREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES              {/*printf("\nReduziu ComMinerar\n");*/}
            ;

ComColocarBloco : DECREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA     {/*printf("\nReduziu ComColocarBloco\n");*/}
                ;
colocarBlocoExpr : DECREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES                 {/*printf("\nReduziu ComColocarBloco\n");*/}
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

inteiro : DIGITO_POSITIVO               {/*printf("\nReduziu inteiro\n");*/}
        | DIGITO_NEGATIVO               {/*printf("\nReduziu inteiro\n");*/}
        ;

float : DECIMAL DEL_FLOAT               {/*printf("\nReduziu float\n");*/}
      ;

double : DECIMAL DEL_DOUBLE             {/*printf("\nReduziu double\n");*/}
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
