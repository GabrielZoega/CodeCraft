%{ 
    int num_linha = 1;
    int ultimo_token = 0;
    #include <stdio.h>
    #include "y.tab.h" // Inclue os tokens definidos no YACC
    extern YYSTYPE yylval;
%}

%option noyywrap 

/*Para ignorar tabulação, quebra de linha e espaço em branco*/
delim		        [ \t]
ws		            {delim}+ 

/* identificação */
digito              [0-9]
caractere           [a-zA-Z]
digitoPositivo      \+?{digito}+
digitoNegativo      \-{digito}+
decimal             ({digitoNegativo}|{digitoPositivo})\.{digitoPositivo}

true                Acesa
false               Apagada

identificador            {caractere}({caractere}|{digito})*

/* Aritméticos e lógicos -> lembrar de adicinar and e or*/

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
abreParenteses      "("
fecharParenteses    ")"
abreColchete        \[
fechaColchete       \] 
virgula             \,
/*abreChave           "{", se der ruim volta isso*/
/*fechaChave          "}"*/

/* Tipos Primitivos */
inteiro             "hp"
float               "xp"
bool                "tocha"
string              "livro"
char                "fragmento"
double              "bussola"
/*tiposPrimitivos     {inteiro}|{float}|{bool}|{string}|{char}|{double}*/


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


/*tipos compostos*/
vetor               bau
enum                pocao

/*Funcoes*/
funcao              "crafting_table"
procedimento        "enchanting_table"

funcaoMain          main
fimDeLinha          ";"
comentario          "🪶🪶".*"\n"

/*Identificar Numero de Linhas*/
quebraLinha         (\r\n)|\r|\n       



%% 

{ws}		         {/* nenhuma ação e nenhum retorno */}

{funcaoMain}         { return FUNC_MAIN; }

{funcao}             { printf("Lido: %s\n", yytext); ultimo_token = FUNCAO; printf("Token Num FUNCAO: %d \n", FUNCAO); return FUNCAO; }
{procedimento}       { return PROCEDIMENTO; }

{vetor}              { return VETOR; }
{enum}               { return ENUM; }

{digitoPositivo}     { yylval.intVal = atoi(yytext);  return DIGITO_POSITIVO; }
{digitoNegativo}     { yylval.intVal = atoi(yytext);  return DIGITO_NEGATIVO; }
{decimal}            { yylval.floatVal = atof(yytext);  return DECIMAL; }
{true}               { return TK_TRUE; }
{false}              { return TK_FALSE; }

{soma}               { return SOMA; }
{subtracao}          { return SUBTRACAO; }
{multiplicacao}      { return MULTIPLICACAO; }
{divisao}            { return DIVISAO; }
{mod}                { return MOD; }
{incremento}         { return INCREMENTO; }
{decremento}         { return DECREMENTO; }
{maisIgual}          { return MAIS_IGUAL; }
{menosIgual}         { return MENOS_IGUAL; }
{multiplicadorIgual} { return MULTIPLICADOR_IGUAL; }
{igual}              { return IGUAL; }
{diferente}          { return DIFERENTE; }
{menor}              { return MENOR; }
{maior}              { return MAIOR; }
{menorIgual}         { return MENOR_IGUAL; }
{maiorIgual}         { return MAIOR_IGUAL; }
{and}                { return AND; }
{or}                 { return OR; }
{recebe}             { printf("Lido: %s\n", yytext); ultimo_token = RECEBE; printf("Token Num RECEBE: %d \n", RECEBE); return RECEBE; }
{abreParenteses}     { printf("Lido: %s\n", yytext); ultimo_token = ABRE_PARENTESES; printf("Token Num ABRE_PARENTESES: %d \n", ABRE_PARENTESES); return ABRE_PARENTESES; }
{fecharParenteses}   { printf("Lido: %s\n", yytext); ultimo_token = FECHA_PARENTESES; printf("Token Num FECHA_PARENTESES: %d \n", FECHA_PARENTESES); return FECHA_PARENTESES; }
{inteiro}            { printf("Lido: %s\n", yytext); ultimo_token = INTEIRO; printf("Token Num INTEIRO: %d \n", INTEIRO); return INTEIRO; }
{float}              { return FLOAT; }
{bool}               { return BOOL; }
{string}             { return STRING; }
{char}               { return CHAR; }
{double}             { return DOUBLE; }
{abreBloco}          { printf("Lido: %s\n", yytext); ultimo_token = ABRE_BLOCO; printf("Token Num ABRE_BLOCO: %d \n", ABRE_BLOCO); return ABRE_BLOCO; }
{fechaBloco}         { printf("Lido: %s\n", yytext); ultimo_token = FECHA_BLOCO; printf("Token Num FECHA_BLOCO: %d \n", FECHA_BLOCO); return FECHA_BLOCO; }
{abreColchete}       { return ABRE_COLCHETE; }
{fechaColchete}      { return FECHA_COLCHETE; }
{virgula}            { return VIRGULA; }

{escopo}             { printf("Lido: %s\n", yytext); ultimo_token = ESCOPO; printf("Token Num ESCOPO: %d \n", ESCOPO); return ESCOPO; }
{null}               { return TK_NULL; }
{if}                 { return IF; }
{else}               { return ELSE; }
{while}              { return WHILE; }
{do}                 { return DO; }
{for}                { return FOR; }
{switch}             { return SWITCH; }
{case}               { return CASE; }
{default}            { return DEFAULT; }
{break}              { return BREAK; }
{continue}           { return CONTINUE; }
{return}             { return RETURN; }
{import}             { return IMPORT; }
{typecast}           { return TYPECAST; }
{void}               { return VOID; }
{print}              { return PRINT; }

{stringLiteral}      { 
                        // substitui a última aspa por '\0'
                        yytext[strlen(yytext) - 1] = '\0';  
                        // copia a string a partir da segunda posição (pulando a primeira aspa)
                        yylval.stringVal = strdup(yytext + 1);
                        // retorna ao inves de "string" o valor literal string sem as aspas

                        printf("String sem aspas: %s\n", yylval.stringVal);
                        return STRING_LITERAL; 
                     }

{charLiteral}        { 
                       yylval.charVal = yytext[1];  /* pega o caractere entre aspas simples */
                       printf("Char sem aspas: %c\n", yylval.charVal);
                       return CHAR_LITERAL; 
                     }
{bloco}              {return BLOCO;}

{fimDeLinha}         { return FIM_DE_LINHA; }
{comentario}         {;}

{identificador}      { printf("Lido: %s\n", yytext); ultimo_token = IDENTIFICADOR; printf("Token Num IDENTIFICADOR: %d \n", IDENTIFICADOR); return IDENTIFICADOR; }

{quebraLinha}        { num_linha++; }


%%