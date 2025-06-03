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
%token ABRE_CHAVE FECHA_CHAVE
%token FUNCAO PROCEDIMENTO
%token VETOR ENUM
%token <intVal> DIGITO_POSITIVO DIGITO_NEGATIVO 
%token <floatVal> DECIMAL
%token <stringVal>  STRING_LITERAL PALAVRA
%token <charVal> CHAR_LITERAL
%token  TK_TRUE TK_FALSE
%token SOMA SUBTRACAO MULTIPLICACAO DIVISAO MOD
%token INCREMENTO DECREMENTO MAIS_IGUAL MENOS_IGUAL MULTIPLICADOR_IGUAL
%token IGUAL DIFERENTE MENOR MAIOR MENOR_IGUAL MAIOR_IGUAL
%token AND OR RECEBE
%token ABRE_PARENTESES FECHA_PARENTESES
// Definição de tipos
%token INTEIRO FLOAT BOOL DOUBLE STRING CHAR
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

inventario : escopo ABRE_CHAVE declaracoesVar FECHA_CHAVE

// novo
declaracoesVar : declaraVarTipo
               | declaraVarVetorTipo
               | definicaoEnum
               ;

defFuncao : '(' assinaturas ')' ABRE_CHAVE listaComandos FECHA_CHAVE
          ;

//novo
assinaturas : assinaturaFuncao
            | assinaturaProced
            ;


assinaturaFuncao : tipo FUNCAO IDENTIFICADOR '(' argumentos ')'
                 ;
assinaturaProced : VOID PROCEDIMENTO IDENTIFICADOR '(' argumentos ')'
                 ;

chamadaFuncao : FUNCAO IDENTIFICADOR '(' parametros ')' ';'
              ;
chamadaProcedimento : PROCEDIMENTO IDENTIFICADOR '(' parametros ')' ';'
                    ;

declaraVarTipo : tipo IDENTIFICADOR atribuicao
               | tipo IDENTIFICADOR ';'
               ;
  
declaraVarTipoVetor : tipo VETOR IDENTIFICADOR '[' inteiro ']' ';'
                    ;

variavel : IDENTIFICADOR
         | VETOR
         ;

atribuiVar : variavel atribuicao
           ;


atribuicao : '=' listaExpressoess ';'
           ;

argumentos : argumento argOpicionais
           ;

//novo
argOpicionais : ',' argumento argOpicionais
              | /* vazio */
              ;

argumento : tipo variavel
          ;

parametros : parametro parmOpicionais
           ;

//novo
parmOpicionais : ',' parametro parmOpicionais
               | /* vazio */
               ;
               
parametro: expr
         ;
         

/*EXPRESSOES*/

listaExpressoes : expr
                | expr ',' listaExpressoes
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
               
fator : '(' expr ')'
      | chamadaFuncao
      | DOUBLE
      | INTEIRO
      | BOOL
      | TK_NULL
      | STRING 
      | CHAR
      | FLOAT 
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
        | ComRegenerar
        | ComVeneno
        | ComCreeper
        | ComBloco
        | chamadaProcedimento
        | ComImprimir
        ;

ComRepetidor : FOR '(' decRepet ';' exprRepet ';' exprRepet ')' ABRE_CHAVE listaComandos FECHA_CHAVE
decRepet : declaraVarTipo
         | /*vazio*/
         ;
exprRepet : listaExpressoes
          | /*vazio*/
          ;

ComObervador : IF '(' listaExpressoes ')' ABRE_CHAVE listaComandos FECHA_CHAVE ComElse
             ;
ComElse : ELSE exprElse ABRE_CHAVE listaComandos FECHA_CHAVE
        | /*vazio*/
        ;
exprElse : listaExpressoes
         | /*vazio*/
         ;

ComComparador : WHILE '(' listaExpressoes ')' ABRE_CHAVE listaComandos FECHA_CHAVE
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

/*
topLevel            ::= {topLevelElem}

topLevelElem        ::= inventario | defFuncao

inventario          ::= PC-inventario '⛏️' { (declaraVarTipo | declaraVarVetorTipo | definicaoEnum) } '⬛'

defFuncao           ::= (assinaturaFuncao | assinaturaProced) '⛏️' listaComandos '⬛'

assinaturaFuncao    ::= tipo PC-craftingTable identificador '(' argumentos ')'
assinaturaProced    ::= PC-vazio PC-enchantingTable identificador '(' argumentos ')'

chamadaFuncao       ::= PC-craftingTable identificador '(' parametros ')' ';'
chamadaProcedimento ::= PC-enchantingTable identificador '(' parametros ')' ';'

declaraVarTipo      ::= tipo identificador ([atribuicao] | ';')

declaraVarVetorTipo ::= tipo PC-bau identificador '[' inteiro ']' ';'

variavel            ::= (identificador | vetor)

atribuiVar          ::= variavel atribuicao

atribuicao          ::= '=' listaExpressoes ';'

argumentos          ::= argumento {',' argumento} (* argumentos da declaração de funções *)
argumento           ::= tipo variavel

parametros          ::= parametro {',' parametro} (* parametros a serem passados para funções *)
parametro           ::= expr



(* EXPRESSOES *)

listaExpressoes     ::= expr {',' expr}

expr                ::= exprLogico
exprLogico          ::= exprRelacional {opLogico exprRelacional}
exprRelacional      ::= exprAritmetico {opRelacional exprAritmetico}
exprAritmetico      ::= fator {opAritmetico fator}

fator               ::= '(' expr ')'
                    | chamadaFuncao
                    | double
                    | inteiro
                    | booleano
                    | null
                    | string
                    | char
                    | float

opAritmetico        ::= '+' | '⚒️' 
                    | '-' | '⚔️'
                    | '*' | '💣'
                    | '/' | '🪣'
                    | '%' | '🪵'

opRelacional        ::= '==' | '🧱🧱'
                    | '!=' | '🧱⬜'
                    | '<' | '🔽🪜'
                    | '>' | '🔼🪜'
                    | '<=' | '🧱🔽'
                    | '>=' | '🧱🔼'

opLogico            ::= 'E' | '📦'
                    | 'OU' | '🪨'

(* COMANDOS *)

listaComandos       ::= {comando}

comando             ::= Com-repetidor  (* for *)
                    | Com-observador   (* if *)
                    | Com-comparador   (* while *)
                    | Com-redstone     (* do-while *)
                    | Com-end          (* break *)
                    | Com-pular        (* continue *)
                    | Com-overworld    (* return *)
                    | Com-villager     (* typecast *)
                    | Com-carrinho     (* switch *)
                    | Com-atribuicao
                    | Com-minerar      (* ++ *)
                    | Com-colocarBloco (* -- *)
                    | Com-regenerar    (* += *)
                    | Com-veneno       (* -= *)
                    | Com-creeper      (* *= *)
                    | Com-bloco        (* Comando especial *)
                    | chamadaProcedimento
                    | Com-imprimir

Com-repetidor       ::= PC-repetidor '(' [declaraVarTipo] ';' listaExpressoes ';' listaExpressoes ')' '⛏️' listaComandos '⬛'

Com-observador      ::= PC-observador '(' listaExpressoes ')' '⛏️' listaComandos '⬛' { PC-liberador ['(' listaExpressoes ')'] '⛏️' listaComandos '⬛' }

Com-comparador      ::= PC-comparador '(' listaExpressoes ')' '⛏️' listaComandos '⬛'

Com-redstone        ::= PC-redstone '⛏️' listaComandos '⬛' PC-comparador '(' listaExpressoes ')'

Com-end             ::= PC-end ';'

Com-pular           ::= PC-pular ';'

Com-overworld       ::= PC-overworld expr ';'

Com-villager        ::= PC-villager '(' variavel ',' tipo')'    (* acho que teremos tipos aqui *)

trilhos             ::= PC-trilho expr '⛏️' listaComandos '⬛'
Com-carrinho        ::= PC-carrinho '⛏️' trilhos {trilhos} PC-cacto '⛏️' listaComandos '⬛'

Com-atribuicao      ::= atribuiVar

Com-minerar         ::= PC-minerar '(' variavel ')' ';'

Com-colocarBloco    ::= PC-colocarBloco '(' variavel ')' ';'

Com-regenerar       ::= PC-regenerar '(' variavel ',' numero ')' ';'

Com-veneno          ::= PC-veneno '(' variavel ',' numero ')' ';'

Com-creeper         ::= PC-creeper '(' variavel ',' numero ')' ';'

Com-bloco           ::= PC-bloco '{' parametros '}' opAritmetico numero ';'

Com-imprimir        ::= PC-imprimir '(' (expr | listaComandos) ')' ';'

(* PALAVRAS CHAVE *)

PC-repetidor        ::= "repetidor"
PC-observador       ::= "observador"
PC-comparador       ::= "comparador"
PC-liberador        ::= "liberador"
PC-redstone         ::= "redstone"
PC-end              ::= "end"
PC-pular            ::= "pular"
PC-overworld        ::= "overworld"
PC-villager         ::= "villager"
PC-carrinho         ::= "carrinho"
PC-trilho           ::= "trilho"
PC-cacto            ::= "cacto"
PC-craftingTable    ::= "crafting_table"
PC-enchantingTable  ::= "enchanting_table"
PC-vazio            ::= "vazio"
PC-minerar          ::= "minerar"
PC-colocarBloco     ::= "colocar_bloco"
PC-regenerar        ::= "regenerar"
PC-veneno           ::= "veneno"
PC-creeper          ::= "creeper"
PC-inventario       ::= "inventario"
PC-nether           ::= "nether"
PC-imprimir         ::= "imprimir"
PC-bau              ::= "bau"


(* TIPOS *)

tipo                ::= Type-hp
                    | Type-xp 
                    | Type-tocha 
                    | Type-livro 
                    | Type-fragmento
                    | Type-bussola
                    | Type-enum



Type-hp             ::= "hp"            (* int *)
Type-xp             ::= "xp"            (* float *)
Type-tocha          ::= "tocha"         (* boolean *) 
Type-livro          ::= "livro"         (* string *)
Type-fragmento      ::= "fragmento"     (* char *)
Type-bussola        ::= "bussola"       (* double *)
Type-enum           ::= "pocao"         (* enum *)

definicaoEnum       ::= Type-enum identificador '⛏️' enumerations '⬛'

enumerations        ::= enumeration {enumeration}

enumeration         ::= identificador ':' (inteiro | string) ';'



(* LITERAIS *)

null                ::= PC-nether

digito              ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

lowerChar           ::= a | b | c | d | e | f | g | h | i | j | k | l | m | n | o | p | q | r | s | t | u | v | w | x | y | z

upperChar           ::= A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S | T | U | V | W | X | Y | Z

charEspecial        ::=  ',' | '.' | '?' | '/' | '~' | '`'| '!' | '@' | '#' | '*' | '(' | ')' | '-' | '_' | '+' | '=' | '{' | '$' | '%' | '^' | '&' | '}' | '[' | ']' | '|' | '\' | ':' | ';' | "'" | '<' | '>'

inteiro             ::= digito {digito}

float               ::= inteiro '.' inteiro 'f'

double              ::= inteiro '.' inteiro 'd'

numero              ::= inteiro | float | double

letra               ::= lowerChar | upperChar

caractere           ::= digito | letra | charEspecial

string              ::= '"' {caractere} '"'

char                ::= "'" caractere "'"

identificador       ::= letra {letra | digito | '_'}

vetor               ::= identificador '[' expr ']'

true                ::= "Acesa"

false               ::= "Apagada"

booleano            ::= true | false

*/