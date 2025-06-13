%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char const *mensagem);
extern int yylex();
extern int num_linha;
extern char *yytext;       // Texto do token atual (fornecido pelo Flex)
extern int ultimo_token;

extern char linha_atual[1024];
extern int pos_na_linha;


%}
%define parse.lac full
%define parse.error verbose
 
%union{
    // aqui fica os atributos possíveis
    char *stringVal; // de string
    char *charVal;
    void* nulo;
    int intVal;
    float floatVal;
}

// aqui coloca os tokens
//%token <tipodotoken> nometoken
%token FUNC_MAIN
//%token ABRE_CHAVE FECHA_CHAVE
%token FUNCAO PROCEDIMENTO
%token VETOR ENUM
%token <intVal> DIGITO_POSITIVO DIGITO_NEGATIVO 
%token <floatVal> DECIMAL
%token <stringVal>  STRING_LITERAL PALAVRA IDENTIFICADOR
%token <charVal> CHAR_LITERAL
%token BLOCO
%token TK_TRUE TK_FALSE
%token SOMA SUBTRACAO MULTIPLICACAO DIVISAO MOD
%token INCREMENTO DECREMENTO MAIS_IGUAL MENOS_IGUAL MULTIPLICADOR_IGUAL
%token IGUAL DIFERENTE MENOR MAIOR MENOR_IGUAL MAIOR_IGUAL
%token AND OR RECEBE
%token ABRE_PARENTESES FECHA_PARENTESES
// Definição de tipos
%token INTEIRO FLOAT BOOL DOUBLE STRING CHAR POCAO
%token ABRE_BLOCO FECHA_BLOCO ABRE_COLCHETE FECHA_COLCHETE VIRGULA
%token ESCOPO IF ELSE WHILE DO FOR SWITCH CASE DEFAULT TK_NULL
%token BREAK CONTINUE RETURN IMPORT TYPECAST VOID PRINT 
%token FIM_DE_LINHA


%%
// aqui começa a colocar a gramática
topLevel : topLevelElem topLevel {printf("\nReduziu topLevel\n\n");}
         | /* vazio */
         ;

topLevelElem : inventario       {printf("\nReduziu topLevelElem\n\n");}
             | defFuncao        {printf("\nReduziu topLevelElem\n\n");}
             ;

inventario : ESCOPO ABRE_BLOCO declaracoesVar FECHA_BLOCO       {printf("\nReduziu inventario \n\n");}

// novo
declaracoesVar : declaraVarTipo declaracoesVar          {printf("\nReduziu declaracoesVar\n\n");}
               | declaraVarTipoVetor declaracoesVar     {printf("\nReduziu declaracoesVar\n\n");}
               | definicaoEnum declaracoesVar           {printf("\nReduziu declaracoesVar\n\n");}
               | /*vazio*/
               ;

defFuncao : assinaturas ABRE_BLOCO listaComandos FECHA_BLOCO    {printf("\nReduziu defFuncao\n\n");}
          ;

//novo
assinaturas : assinaturaFuncao  {printf("\nReduziu assinaturas\n\n");}
            | assinaturaProced  {printf("\nReduziu assinaturas\n\n");}
            ;


assinaturaFuncao : tipo FUNCAO IDENTIFICADOR ABRE_PARENTESES argumentos FECHA_PARENTESES        {printf("\nReduziu assinaturaFuncao\n\n");}
                 ;
assinaturaProced : VOID PROCEDIMENTO IDENTIFICADOR ABRE_PARENTESES argumentos FECHA_PARENTESES  {printf("\nReduziu assinaturaProced\n\n");}
                 ;

chamadaFuncaoExpr : FUNCAO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES   {printf("\nReduziu chamadaFuncaoExpr\n\n");  printf("Teste: %s", $2);}
              ;
chamadaFuncao : FUNCAO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES FIM_DE_LINHA   {printf("\nReduziu chamadaFuncao\n\n");}
              ;

chamadaProcedimento : PROCEDIMENTO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES FIM_DE_LINHA       {printf("\nReduziu chamadaProcedimento\n\n");}
                    ;

declaraVarTipo : tipo IDENTIFICADOR atribuicao          {printf("\nReduziu declaraVarTipo\n\n");}
               | tipo IDENTIFICADOR FIM_DE_LINHA        {printf("\nReduziu declaraVarTipo\n\n");}
               ;
  
declaraVarTipoVetor : VETOR tipo IDENTIFICADOR ABRE_COLCHETE inteiro FECHA_COLCHETE FIM_DE_LINHA  {printf("\nReduziu declaraVarTipoVetor\n\n");}
                    ;

/*declaraVarTipoVetor : VETOR IDENTIFICADOR RECEBE inteiro tipo FIM_DE_LINHA
                    ;
*/
variavel : IDENTIFICADOR        {printf("\nReduziu variavel\n\n");}
         | vetor                {printf("\nReduziu variavel\n\n");}
         ;

atribuiVar : variavel atribuicao        {printf("\nReduziu atribuiVar\n\n");}
           ;

atribuicao : RECEBE listaExpressoes FIM_DE_LINHA        {printf("\nReduziu atribuicao\n\n");}
           ;

argumentos : argumento argumentos       {printf("\nReduziu argumentos\n\n");}
           | VIRGULA argumento          {printf("\nReduziu argumentos\n\n");}
           | /*vazio*/                  {printf("\nReduziu argumentos\n\n");}
           ;

argumento : tipo variavel               {printf("\nReduziu argumento\n\n");}
          ;

parametros : parametro parmOpicionais   {printf("\nReduziu parametros\n\n");}
           ;

//novo
parmOpicionais : VIRGULA parametro parmOpicionais       {printf("\nReduziu parmOpicionais\n\n");}
               | /* vazio */
               ;
               
parametro: expr         {printf("\nReduziu parametro\n\n");}
         ;
         

/*EXPRESSOES*/

listaExpressoes : expr                                  {printf("\nReduziu listaExpressoes\n\n");}
                | expr VIRGULA listaExpressoes          {printf("\nReduziu listaExpressoes\n\n");}
                ;

expr : exprLogico                                       {printf("\nReduziu expr\n\n");}
     ;

exprLogico : exprRelacional                             {printf("\nReduziu exprLogico\n\n");}
           | exprLogico opLogico exprRelacional     {printf("\nReduziu exprLogico\n\n");}
           ;

exprRelacional : exprAritmetico                                 {printf("\nReduziu exprRelacional\n\n");}
               | exprAritmetico opRelacional exprAritmetico     {printf("\nReduziu exprRelacional\n\n");}
               ;
                         
exprAritmetico : exprAritmetico opAritmetico fator              {printf("\nReduziu exprAritmetico\n\n");}
               | fator                                          {printf("\nReduziu exprAritmetico\n\n");}
               ;
               
fator : ABRE_PARENTESES expr FECHA_PARENTESES                   {printf("\nReduziu fator\n\n");}
      | chamadaFuncaoExpr                                       {printf("\nReduziu fator\n\n");}
      | numero                                                  {printf("\nReduziu fator\n\n");}
      | booleano                                                {printf("\nReduziu fator\n\n");}
      | TK_NULL                                                 {printf("\nReduziu fator\n\n");}
      | STRING_LITERAL                                          {printf("\nReduziu fator\n\n");}
      | CHAR_LITERAL                                            {printf("\nReduziu fator\n\n");}
      | IDENTIFICADOR                                           {printf("\nReduziu fator\n\n");}
      ;




opAritmetico : SOMA                     {printf("\nReduziu opAritmetico\n\n");}
             | SUBTRACAO                {printf("\nReduziu opAritmetico\n\n");}
             | MULTIPLICACAO            {printf("\nReduziu opAritmetico\n\n");}
             | DIVISAO                  {printf("\nReduziu opAritmetico\n\n");}
             | MOD                      {printf("\nReduziu opAritmetico\n\n");}
             ;
            
opRelacional : IGUAL                    {printf("\nReduziu opRelacional\n\n");}
             | DIFERENTE                {printf("\nReduziu opRelacional\n\n");}
             | MENOR                    {printf("\nReduziu opRelacional\n\n");}
             | MAIOR                    {printf("\nReduziu opRelacional\n\n");}
             | MENOR_IGUAL              {printf("\nReduziu opRelacional\n\n");}
             | MAIOR_IGUAL              {printf("\nReduziu opRelacional\n\n");}
             ;

opLogico : AND                          {printf("\nReduziu opLogico\n\n");}
         | OR                           {printf("\nReduziu opLogico\n\n");}
         ;
      
/* COMANDOS */

listaComandos : comando listaComandos           {printf("\nReduziu listaComandos\n\n");}
              | /* vazio */
              ;

comando : ComRepetidor                          {printf("\nReduziu comando\n\n");}
        | ComObservador                         {printf("\nReduziu comando\n\n");}
        | ComComparador                         {printf("\nReduziu comando\n\n");}
        | ComRedstone                           {printf("\nReduziu comando\n\n");}
        | ComEnd                                {printf("\nReduziu comando\n\n");}
        | ComPular                              {printf("\nReduziu comando\n\n");}
        | ComOverworld                          {printf("\nReduziu comando\n\n");}
        | ComCarrinho                           {printf("\nReduziu comando\n\n");}
        | ComAtribuicao                         {printf("\nReduziu comando\n\n");}
        | ComMinerar                            {printf("\nReduziu comando\n\n");}
        | ComColocarBloco                       {printf("\nReduziu comando\n\n");}
        | ComVillager                           {printf("\nReduziu comando\n\n");}
        | ComRegenerar                          {printf("\nReduziu comando\n\n");}
        | ComVeneno                             {printf("\nReduziu comando\n\n");}
        | ComCreeper                            {printf("\nReduziu comando\n\n");}
        | ComBloco                              {printf("\nReduziu comando\n\n");}
        | chamadaProcedimento                   {printf("\nReduziu comando\n\n");}
        | chamadaFuncao                         {printf("\nReduziu comando\n\n");}
        | ComImprimir                           {printf("\nReduziu comando\n\n");}
        | inventario                            {printf("\nReduziu comando\n\n");}
        | defFuncao                             {printf("\nReduziu comando\n\n");}
        ;

ComRepetidor : FOR ABRE_PARENTESES decRepet FIM_DE_LINHA exprRepet FIM_DE_LINHA exprRepet FECHA_PARENTESES ABRE_BLOCO listaComandos FECHA_BLOCO         {printf("\nReduziu ComRepetidor\n\n");}
             ;

decRepet : declaraVarTipo               {printf("\nReduziu decRepet\n\n");}
         | /*vazio*/                    {printf("\nReduziu decRepet\n\n");}
         ;

exprRepet : listaExpressoes             {printf("\nReduziu exprRepet\n\n");}
          | /*vazio*/                   {printf("\nReduziu exprRepet\n\n");}
          ;

ComObservador : IF ABRE_PARENTESES listaExpressoes FECHA_PARENTESES ABRE_BLOCO listaComandos FECHA_BLOCO ComElse                {printf("\nReduziu ComObservador\n\n");}
             ;
ComElse : ELSE exprElse ABRE_BLOCO listaComandos FECHA_BLOCO                    {printf("\nReduziu ComElse\n\n");}
        | /*vazio*/                                                             {printf("\nReduziu ComElse\n\n");}
        ;
exprElse : ABRE_PARENTESES listaExpressoes FECHA_PARENTESES                     {printf("\nReduziu exprElse\n\n");}
         | /*vazio*/                                                            {printf("\nReduziu exprElse\n\n");}
         ;

ComComparador : WHILE ABRE_PARENTESES listaExpressoes FECHA_PARENTESES ABRE_BLOCO listaComandos FECHA_BLOCO             {printf("\nReduziu ComComparador\n\n");}
              ;

ComRedstone : DO ABRE_BLOCO listaComandos FECHA_BLOCO WHILE ABRE_PARENTESES listaExpressoes FECHA_PARENTESES            {printf("\nReduziu ComRedstone\n\n");}
            ;

ComEnd : BREAK FIM_DE_LINHA             {printf("\nReduziu ComEnd\n\n");}
       ;

ComPular : CONTINUE FIM_DE_LINHA        {printf("\nReduziu ComPular\n\n");}
         ;

ComOverworld :  RETURN expr FIM_DE_LINHA        {printf("\nReduziu ComOverworld\n\n");}
             ;

ComVillager : TYPECAST ABRE_PARENTESES variavel VIRGULA tipo FECHA_PARENTESES   {printf("\nReduziu ComVillager\n\n");}
            ;

trilhos : CASE expr ABRE_BLOCO listaComandos FECHA_BLOCO trilhos        {printf("\nReduziu trilhos\n\n");}
        | /*vazio*/                                                     {printf("\nReduziu trolhos\n\n");}
        ;

ComCarrinho : SWITCH ABRE_BLOCO trilhos DEFAULT ABRE_BLOCO listaComandos FECHA_BLOCO FECHA_BLOCO        {printf("\nReduziu ComCarrinho\n\n");}
            ;

ComAtribuicao : atribuiVar      {printf("\nReduziu ComAtribuicao\n\n");}
              ;

ComMinerar : INCREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA  {printf("\nReduziu ComMinerar\n\n");}
           ;

ComColocarBloco : DECREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA     {printf("\nReduziu ComColocarBloco\n\n");}
                ;

ComRegenerar : MAIS_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA         {printf("\nReduziu ComRegenerar\n\n");}
             ;

ComVeneno : MENOS_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA           {printf("\nReduziu ComVeneno\n\n");}
          ;

ComCreeper : MULTIPLICADOR_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA  {printf("\nReduziu ComCreeper\n\n");}
           ;

ComBloco : BLOCO '{' parametros '}' opAritmetico numero FIM_DE_LINHA    {printf("\nReduziu ComBloco\n\n");}
         ;

ComImprimir : PRINT ABRE_PARENTESES listaExpressoes FECHA_PARENTESES FIM_DE_LINHA       {printf("\nReduziu ComImprimir\n\n");}
            ;

/* TIPO */
//TODO: Talvez adicionar bau (já que vetor é tipo composto)
tipo : INTEIRO                  {printf("\nReduziu tipo\n\n");}
     | FLOAT                    {printf("\nReduziu tipo\n\n");}
     | BOOL                     {printf("\nReduziu tipo\n\n");}
     | STRING                   {printf("\nReduziu tipo\n\n");}
     | CHAR                     {printf("\nReduziu tipo\n\n");}
     | DOUBLE                   {printf("\nReduziu tipo\n\n");}
     ;

definicaoEnum : POCAO IDENTIFICADOR ABRE_BLOCO enumerations FECHA_BLOCO         {printf("\nReduziu definicaoEnum\n\n");}
              ;
enumerations : IDENTIFICADOR ':' enumContent FIM_DE_LINHA                       {printf("\nReduziu enumerations\n\n");}
             ;
enumContent : inteiro                                                           {printf("\nReduziu enumContent\n\n");}
            | STRING_LITERAL                                                    {printf("\nReduziu enumContent\n\n");}
            | CHAR_LITERAL                                                      {printf("\nReduziu enumContent\n\n");}
            ;

/*LITERAIS*/

inteiro : DIGITO_POSITIVO               {printf("\nReduziu inteiro\n\n");}
        | DIGITO_NEGATIVO               {printf("\nReduziu inteiro\n\n");}
        ;

float : DECIMAL 'f'                     {printf("\nReduziu float\n\n");}
      ;

double : DECIMAL 'd'                    {printf("\nReduziu double\n\n");}
       ;

numero : inteiro                        {printf("\nReduziu numero\n\n");}
       | float                          {printf("\nReduziu numero\n\n");}
       | double                         {printf("\nReduziu numero\n\n");}
       ;

vetor : IDENTIFICADOR ABRE_COLCHETE expr FECHA_COLCHETE         {printf("\nReduziu vetor\n\n");}
      ;

booleano : TK_TRUE                      {printf("\nReduziu booleano\n\n");}
         | TK_FALSE                     {printf("\nReduziu booleano\n\n");}
         ;

%%

void limpaLinha(char *str) {
    int i = 0;

    while (str[i] == ' ' || str[i] == '\t') {
        i++;
    }

    if (i > 0) {
        memmove(str, str + i, strlen(str + i) + 1);
    }
}

void yyerror (char const *mensagem){
    fprintf(stderr, "\nErro na linha %d: %s\n", num_linha, mensagem);
    limpaLinha(linha_atual);
    printf("%d - %s\n", num_linha, linha_atual);

    for(int j = 0; j < 5; j++){
        printf(" ");
    }

    for(int i = 0; i < pos_na_linha; i++){
        if(linha_atual[i] == '\t'){
                printf("\t");
                printf("teste");}
        else
                printf(" ");
    }
    printf("\033[31m^\033[0m\n");


    printf("Token inesperado: '%s'\n", yytext);
    //printf("Ultimo Token Num: %d \n", ultimo_token);
    exit(1);
}
