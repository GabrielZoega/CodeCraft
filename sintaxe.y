%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(char *mensagem);
extern int yylex();
extern int num_linha; // Exporta 

%}
 
%union{
    // aqui fica os atributos possíveis
    char *stringVal; // de string
    char charVal;
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
%token <stringVal>  STRING_LITERAL PALAVRA
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
%token FIM_DE_LINHA COMENTARIO IDENTIFICADOR


%%
// aqui começa a colocar a gramática
topLevel : topLevelElem
         | /* vazio */
         ;

topLevelElem : inventario
             | defFuncao
             ;

inventario : ESCOPO ABRE_BLOCO declaracoesVar FECHA_BLOCO ;

// novo
declaracoesVar : declaraVarTipo
               | declaraVarTipoVetor
               | definicaoEnum
               ;

defFuncao : ABRE_PARENTESES assinaturas FECHA_PARENTESES ABRE_BLOCO listaComandos FECHA_BLOCO
          ;

//novo
assinaturas : assinaturaFuncao
            | assinaturaProced
            ;


assinaturaFuncao : tipo FUNCAO IDENTIFICADOR ABRE_PARENTESES argumentos FECHA_PARENTESES
                 ;
assinaturaProced : VOID PROCEDIMENTO IDENTIFICADOR ABRE_PARENTESES argumentos FECHA_PARENTESES
                 ;

chamadaFuncao : FUNCAO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES FIM_DE_LINHA
              ;
chamadaProcedimento : PROCEDIMENTO IDENTIFICADOR ABRE_PARENTESES parametros FECHA_PARENTESES FIM_DE_LINHA
                    ;

declaraVarTipo : tipo IDENTIFICADOR atribuicao
               | tipo IDENTIFICADOR FIM_DE_LINHA
               ;
  
declaraVarTipoVetor : tipo VETOR IDENTIFICADOR ABRE_COLCHETE inteiro FECHA_COLCHETE FIM_DE_LINHA
                    ;

variavel : IDENTIFICADOR
         | vetor
         ;

atribuiVar : variavel atribuicao
           ;


atribuicao : '=' listaExpressoes FIM_DE_LINHA
           ;

argumentos : argumento argOpicionais
           ;

//novo
argOpicionais : VIRGULA argumento argOpicionais
              | /* vazio */
              ;

argumento : tipo variavel
          ;

parametros : parametro parmOpicionais
           ;

//novo
parmOpicionais : VIRGULA parametro parmOpicionais
               | /* vazio */
               ;
               
parametro: expr
         ;
         

/*EXPRESSOES*/

listaExpressoes : expr
                | expr VIRGULA listaExpressoes
                ;

expr : exprLogico
     ;

exprLogico : exprRelacional
           | exprRelacional opLogico exprRelacional
           ;

exprRelacional : exprAritmetico
               | exprAritmetico opRelacional exprAritmetico
               ;
                         
exprAritmetico : fator
               | fator opAritmetico fator
               ;   
               
fator : ABRE_PARENTESES expr FECHA_PARENTESES
      | chamadaFuncao
      | double
      | INTEIRO
      | booleano
      | TK_NULL
      | STRING 
      | CHAR
      | float 
      ;




opAritmetico : SOMA
             | SUBTRACAO 
             | MULTIPLICACAO 
             | DIVISAO 
             | MOD
             ;
            
opRelacional : IGUAL 
             | DIFERENTE
             | MENOR
             | MAIOR
             | MENOR_IGUAL
             | MAIOR_IGUAL
             ;

opLogico : AND
         | OR
         ;
      
/* COMANDOS */

listaComandos : comando
              | /* vazio */
              ;

comando : ComRepetidor
        | ComObservador
        | ComComparador
        | ComRedstone
        | ComEnd
        | ComPular
        | ComOverworld
        | ComCarrinho
        | ComAtribuicao
        | ComMinerar
        | ComColocarBloco
        | ComVillager
        | ComRegenerar
        | ComVeneno
        | ComCreeper
        | ComBloco
        | chamadaProcedimento
        | ComImprimir
        ;

ComRepetidor : FOR ABRE_PARENTESES decRepet FIM_DE_LINHA exprRepet FIM_DE_LINHA exprRepet FECHA_PARENTESES ABRE_BLOCO listaComandos FECHA_BLOCO
             ;

decRepet : declaraVarTipo
         | /*vazio*/
         ;

exprRepet : listaExpressoes
          | /*vazio*/
          ;

ComObservador : IF ABRE_PARENTESES listaExpressoes FECHA_PARENTESES ABRE_BLOCO listaComandos FECHA_BLOCO ComElse
             ;
ComElse : ELSE exprElse ABRE_BLOCO listaComandos FECHA_BLOCO
        | /*vazio*/
        ;
exprElse : ABRE_PARENTESES listaExpressoes FECHA_PARENTESES
         | /*vazio*/
         ;

ComComparador : WHILE ABRE_PARENTESES listaExpressoes FECHA_PARENTESES ABRE_BLOCO listaComandos FECHA_BLOCO
              ;

ComRedstone : DO ABRE_BLOCO listaComandos FECHA_BLOCO WHILE ABRE_PARENTESES listaExpressoes FECHA_PARENTESES 
            ;

ComEnd : BREAK FIM_DE_LINHA
       ;

ComPular : CONTINUE FIM_DE_LINHA
         ;

ComOverworld :  RETURN expr FIM_DE_LINHA
             ;

ComVillager : TYPECAST ABRE_PARENTESES variavel VIRGULA tipo FECHA_PARENTESES
            ;

trilhos : CASE expr ABRE_BLOCO listaComandos FECHA_BLOCO trilhos
        | /*vazio*/
        ;

ComCarrinho : SWITCH ABRE_BLOCO trilhos DEFAULT ABRE_BLOCO listaComandos FECHA_BLOCO FECHA_BLOCO
            ;

ComAtribuicao : atribuiVar
              ;

ComMinerar : INCREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA
           ;

ComColocarBloco : DECREMENTO ABRE_PARENTESES variavel FECHA_PARENTESES FIM_DE_LINHA
                ;

ComRegenerar : MAIS_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA
             ;

ComVeneno : MENOS_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA
          ;

ComCreeper : MULTIPLICADOR_IGUAL ABRE_PARENTESES variavel VIRGULA numero FECHA_PARENTESES FIM_DE_LINHA
           ;

ComBloco : BLOCO '{' parametros '}' opAritmetico numero FIM_DE_LINHA
         ;

ComImprimir : PRINT ABRE_PARENTESES elementPrint FECHA_PARENTESES FIM_DE_LINHA
            ;
elementPrint : expr
             | listaComandos
             ;

/* TIPO */
//TODO: Talvez adicionar bau (já que vetor é tipo composto)
tipo : INTEIRO
     | FLOAT
     | BOOL
     | STRING
     | CHAR
     | DOUBLE
     ;

definicaoEnum : POCAO IDENTIFICADOR ABRE_BLOCO enumerations FECHA_BLOCO
              ;
enumerations : IDENTIFICADOR ':' enumContent FIM_DE_LINHA
             ;
enumContent : inteiro
            | PALAVRA
            ;

/*LITERAIS*/

inteiro : DIGITO_POSITIVO 
        | DIGITO_NEGATIVO
        ;

float : DECIMAL 'f'
      ;

double : DECIMAL 'd'
       ;

numero : inteiro 
       | float
       | double
       ;

vetor : IDENTIFICADOR ABRE_COLCHETE expr FECHA_COLCHETE
      ;

booleano : TK_TRUE 
         | TK_FALSE
         ;

%%

void yyerror (char *mensagem){
    printf("Erro na linha %d: %s\n", num_linha, mensagem);
    exit(1);
}


int main(){
    yyparse();
    return 0;
}