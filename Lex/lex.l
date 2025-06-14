%{ 
    int num_linha = 1;                            // guarda a linha atual do programa fonte sendo lida
    int ultimo_token = 0;                         // guarda o último token a ser lido
    int pos_na_linha = 0;                         // guarda a posição da linha atual sendo lida
    char linha_atual[1024] = "";                  // guarda a linha atual do código de entrada para exibição de erros.
    #include <stdio.h>
    #include "translate.tab.h"                    // Inclue os tokens definidos no YACC.
    extern YYSTYPE yylval;
%}

%option noyywrap 

/*Para ignorar tabulação, quebra de linha e espaço em branco*/
delim		        [ \t]
ws		            {delim}+ 

/* identificação */
digito              [0-9]
caractere           [a-zA-Z_]
digitoPositivo      {digito}+
digitoNegativo      \-{digito}+
decimal             ({digitoNegativo}|{digitoPositivo})\.{digitoPositivo}

true                Acesa
false               Apagada

identificador            {caractere}({caractere}|{digito})*

/* Aritméticos e lógicos */

soma                "⚒️"|\+
subtracao           "⚔️"|\-
multiplicacao       "💣"|\*
divisao             "🪣"|\/
mod                 "🪵"|%
incremento          minerar
decremento          colocar_bloco
maisIgual           regenerar
menosIgual          veneno
multiplicadorIgual  creeper
igual               "🧱🧱"|"=="
diferente           "🧱⬜"|"!="
menor               "🔽🪜"|"<"
maior               "🔼🪜"|">"
menorIgual          "🧱🔽"|"<="
maiorIgual          "🧱🔼"|">="
and                 "E"|"📦"
or                  "OU"|"🪨"
recebe              "="
doisPontos          ":"
abreParenteses      "("
fecharParenteses    ")"
abreColchete        \[
fechaColchete       \] 
virgula             \,
concatenar          "\+\+"


/* Tipos Primitivos */
inteiro             "hp"
float               "xp"
bool                "tocha"
string              "livro"
char                "fragmento"
double              "bussola"


/*blocos*/
abreBloco           "⛏️"|"{"
fechaBloco          "⬛"|"}"


/* Palavras reservadas */
escopo              inventario
null                nether
if                  observador
else                liberador
while               comparador 
do                  redstone
for                 repetidor
switch              carrinho
case                trilho
default             cacto 
break               end 
continue            pular
return              overworld
import              portal 
typecast            villager
void                vazio
print               imprimir
stringLiteral       \".*\"
charLiteral         \'{caractere}\'
bloco               bloco
delFloat            \\f
delDouble           \\d

/*tipos compostos*/
vetor               bau
enum                pocao

/*Funcoes*/
funcao              "crafting_table"
procedimento        "enchanting_table"

funcaoMain          main
fimDeLinha          ";"
comentario          "🪶🪶"[^\n]*

/*Identificar Numero de Linhas*/
quebraLinha         (\r\n)|\r|\n       



%% 

{ws}		         { strcat(linha_atual, yytext);}

{funcaoMain}         { yylval.stringVal = strdup(yytext); strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = FUNC_MAIN; printf("Token Num FUNC_MAIN: %d \n", FUNC_MAIN);*/ return FUNC_MAIN; }

{funcao}             { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = FUNCAO; printf("Token Num FUNCAO: %d \n", FUNCAO);*/ return FUNCAO; }
{procedimento}       { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = PROCEDIMENTO; printf("Token Num PROCEDIMENTO: %d \n", PROCEDIMENTO);*/return PROCEDIMENTO; }

{vetor}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = VETOR; printf("Token Num VETOR: %d \n", VETOR);*/ return VETOR; }
{enum}               { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = ENUM; printf("Token Num ENUM: %d \n", ENUM);*/ return ENUM; }

{digitoPositivo}     { yylval.intVal = atoi(yytext); strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DIGITO_POSITIVO; printf("Token Num DIGITO_POSITIVO: %d \n", DIGITO_POSITIVO); yylval.intVal = atoi(yytext);*/  return DIGITO_POSITIVO; }
{digitoNegativo}     { yylval.intVal = atoi(yytext); strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DIGITO_NEGATIVO; printf("Token Num DIGITO_NEGATIVO: %d \n", DIGITO_NEGATIVO); yylval.intVal = atoi(yytext);*/  return DIGITO_NEGATIVO; }
{decimal}            { yylval.floatVal = atof(yytext); strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DECIMAL; printf("Token Num DECIMAL: %d \n", DECIMAL); yylval.floatVal = atof(yytext);*/  return DECIMAL; }
{true}               { yylval.booleano = strdup(yytext); strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = TK_TRUE; printf("Token Num TK_TRUE: %d \n", TK_TRUE);*/ return TK_TRUE; }
{false}              { yylval.booleano = strdup(yytext); strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = TK_FALSE; printf("Token Num TK_FALSE: %d \n", TK_FALSE);*/ return TK_FALSE; }

{soma}               { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = SOMA; printf("Token Num SOMA: %d \n", SOMA);*/ return SOMA; }
{subtracao}          { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = SUBTRACAO; printf("Token Num SUBTRACAO: %d \n", SUBTRACAO);*/ return SUBTRACAO; }
{multiplicacao}      { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MULTIPLICACAO; printf("Token Num MULTIPLICACAO: %d \n", MULTIPLICACAO);*/ return MULTIPLICACAO; }
{divisao}            { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DIVISAO; printf("Token Num DIVISAO: %d \n", DIVISAO);*/ return DIVISAO; }
{mod}                { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MOD; printf("Token Num MOD: %d \n", MOD);*/ return MOD; }
{incremento}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = INCREMENTO; printf("Token Num INCREMENTO: %d \n", INCREMENTO);*/ return INCREMENTO; }
{decremento}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DECREMENTO; printf("Token Num DECREMENTO: %d \n", DECREMENTO);*/ return DECREMENTO; }
{maisIgual}          { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MAIS_IGUAL; printf("Token Num MAIS_IGUAL: %d \n", MAIS_IGUAL);*/ return MAIS_IGUAL; }
{menosIgual}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MENOS_IGUAL; printf("Token Num MENOS_IGUAL: %d \n", MENOS_IGUAL);*/ return MENOS_IGUAL; }
{multiplicadorIgual} { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MULTIPLICADOR_IGUAL; printf("Token Num MULTIPLICADOR_IGUAL: %d \n", MULTIPLICADOR_IGUAL);*/ return MULTIPLICADOR_IGUAL; }
{igual}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = IGUAL; printf("Token Num IGUAL: %d \n", IGUAL);*/ return IGUAL; }
{doisPontos}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DOIS_PONTOS; printf("Token Num DOIS_PONTOS: %d \n", DOIS_PONTOS);*/ return DOIS_PONTOS; }
{diferente}          { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DIFERENTE; printf("Token Num DIFERENTE: %d \n", DIFERENTE);*/ return DIFERENTE; }
{menor}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MENOR; printf("Token Num MENOR: %d \n", MENOR);*/ return MENOR; }
{maior}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MAIOR; printf("Token Num MAIOR: %d \n", MAIOR);*/ return MAIOR; }
{menorIgual}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MENOR_IGUAL; printf("Token Num MENOR_IGUAL: %d \n", MENOR_IGUAL);*/ return MENOR_IGUAL; }
{maiorIgual}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = MAIOR_IGUAL; printf("Token Num MAIOR_IGUAL: %d \n", MAIOR_IGUAL);*/ return MAIOR_IGUAL; }
{and}                { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = AND; printf("Token Num AND: %d \n", AND);*/ return AND; }
{or}                 { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = OR; printf("Token Num OR: %d \n", OR);*/ return OR; }
{recebe}             { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = RECEBE; printf("Token Num RECEBE: %d \n", RECEBE);*/ return RECEBE; }
{abreParenteses}     { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = ABRE_PARENTESES; printf("Token Num ABRE_PARENTESES: %d \n", ABRE_PARENTESES);*/ return ABRE_PARENTESES; }
{fecharParenteses}   { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = FECHA_PARENTESES; printf("Token Num FECHA_PARENTESES: %d \n", FECHA_PARENTESES);*/ return FECHA_PARENTESES; }
{inteiro}            { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = INTEIRO; printf("Token Num INTEIRO: %d \n", INTEIRO);*/ return INTEIRO; }
{float}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = FLOAT; printf("Token Num FLOAT: %d \n", FLOAT);*/ return FLOAT; }
{bool}               { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = BOOL; printf("Token Num BOOL: %d \n", BOOL);*/ return BOOL; }
{string}             { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = STRING; printf("Token Num STRING: %d \n", STRING);*/ return STRING; }
{char}               { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = CHAR; printf("Token Num CHAR: %d \n", CHAR);*/ return CHAR; }
{double}             { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DOUBLE; printf("Token Num DOUBLE: %d \n", DOUBLE);*/ return DOUBLE; }
{abreBloco}          { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = ABRE_BLOCO; printf("Token Num ABRE_BLOCO: %d \n", ABRE_BLOCO);*/ return ABRE_BLOCO; }
{fechaBloco}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = FECHA_BLOCO; printf("Token Num FECHA_BLOCO: %d \n", FECHA_BLOCO);*/ return FECHA_BLOCO; }
{abreColchete}       { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = ABRE_COLCHETE; printf("Token Num ABRE_COLCHETE: %d \n", ABRE_COLCHETE);*/ return ABRE_COLCHETE; }
{fechaColchete}      { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = FECHA_COLCHETE; printf("Token Num FECHA_COLCHETE: %d \n", FECHA_COLCHETE);*/ return FECHA_COLCHETE; }
{virgula}            { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = VIRGULA; printf("Token Num VIRGULA: %d \n", VIRGULA);*/ return VIRGULA; }
{concatenar}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = CONCATENAR; printf("Token Num CONCATENAR: %d \n", CONCATENAR);*/ return CONCATENAR; }

{escopo}             { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = ESCOPO; printf("Token Num ESCOPO: %d \n", ESCOPO);*/ return ESCOPO; }
{null}               { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = TK_NULL; printf("Token Num TK_NULL: %d \n", TK_NULL);*/return TK_NULL; }
{if}                 { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = IF; printf("Token Num IF: %d \n", IF);*/ return IF; }
{else}               { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = ELSE; printf("Token Num ELSE: %d \n", ELSE);*/ return ELSE; }
{while}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = WHILE; printf("Token Num WHILE: %d \n", WHILE);*/ return WHILE; }
{do}                 { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DO; printf("Token Num DO: %d \n", DO);*/ return DO; }
{for}                { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = FOR; printf("Token Num FOR: %d \n", FOR);*/ return FOR; }
{switch}             { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = SWITCH; printf("Token Num SWITCH: %d \n", SWITCH);*/ return SWITCH; }
{case}               { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = CASE; printf("Token Num CASE: %d \n", CASE);*/ return CASE; }
{default}            { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DEFAULT; printf("Token Num DEFAULT: %d \n", DEFAULT);*/ return DEFAULT; }
{break}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = BREAK; printf("Token Num BREAK: %d \n", BREAK);*/ return BREAK; }
{continue}           { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = CONTINUE; printf("Token Num CONTINUE: %d \n", CONTINUE);*/ return CONTINUE; }
{return}             { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = RETURN; printf("Token Num RETURN: %d \n", RETURN);*/ return RETURN; }
{import}             { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = IMPORT; printf("Token Num IMPORT: %d \n", IMPORT);*/ return IMPORT; }
{typecast}           { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = TYPECAST; printf("Token Num TYPECAST: %d \n", TYPECAST);*/ return TYPECAST; }
{void}               { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = VOID; printf("Token Num VOID: %d \n", VOID);*/ return VOID; }
{print}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = PRINT; printf("Token Num PRINT: %d \n", PRINT);*/ return PRINT; }
{delDouble}          { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DEL_DOUBLE; printf("Token Num DEL_DOUBLE: %d \n", DEL_DOUBLE);*/ return DEL_DOUBLE; }
{delFloat}           { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = DEL_FLOAT; printf("Token Num DEL_FLOAT: %d \n", DEL_FLOAT);*/ return DEL_FLOAT; }

{stringLiteral}      { yylval.stringVal = strdup(yytext); strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = STRING_LITERAL; printf("Token Num STRING_LITERAL: %d \n", STRING_LITERAL); yylval.stringVal = yytext;*/ return STRING_LITERAL; }
{charLiteral}        { yylval.stringVal = strdup(yytext); strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = CHAR_LITERAL; printf("Token Num CHAR_LITERAL: %d \n", CHAR_LITERAL); yylval.charVal = yytext;*/ return CHAR_LITERAL; }

{bloco}              { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = BLOCO; printf("Token Num BLOCO: %d \n", BLOCO);*/ return BLOCO;}

{fimDeLinha}         { strcat(linha_atual, yytext); pos_na_linha += yyleng; /*printf("Lido: %s\n", yytext); ultimo_token = FIM_DE_LINHA; printf("Token Num FIM_DE_LINHA: %d \n", FIM_DE_LINHA);*/ return FIM_DE_LINHA; }
{comentario}         {}

{identificador}      { strcat(linha_atual, yytext); pos_na_linha += yyleng; yylval.stringVal=strdup(yytext); /*printf("Lido: %s\n", yytext); ultimo_token = IDENTIFICADOR; printf("Token Num IDENTIFICADOR: %d \n", IDENTIFICADOR);*/ return IDENTIFICADOR; }

{quebraLinha}        { memset(linha_atual, 0, sizeof(linha_atual)); linha_atual[0] = '\0'; num_linha++; pos_na_linha = 0; }


%%