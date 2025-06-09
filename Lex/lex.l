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
comentario          "🪶🪶"[^\n]*

/*Identificar Numero de Linhas*/
quebraLinha         (\r\n)|\r|\n       



%% 

{ws}		         {/* nenhuma ação e nenhum retorno */}

{funcaoMain}         { printf("Lido: %s\n", yytext); ultimo_token = FUNC_MAIN; printf("Token Num FUNC_MAIN: %d \n", FUNC_MAIN); return FUNC_MAIN; }

{funcao}             { printf("Lido: %s\n", yytext); ultimo_token = FUNCAO; printf("Token Num FUNCAO: %d \n", FUNCAO); return FUNCAO; }
{procedimento}       { printf("Lido: %s\n", yytext); ultimo_token = PROCEDIMENTO; printf("Token Num PROCEDIMENTO: %d \n", PROCEDIMENTO);return PROCEDIMENTO; }

{vetor}              { printf("Lido: %s\n", yytext); ultimo_token = VETOR; printf("Token Num VETOR: %d \n", VETOR); return VETOR; }
{enum}               { printf("Lido: %s\n", yytext); ultimo_token = ENUM; printf("Token Num ENUM: %d \n", ENUM); return ENUM; }

{digitoPositivo}     { printf("Lido: %s\n", yytext); ultimo_token = DIGITO_POSITIVO; printf("Token Num DIGITO_POSITIVO: %d \n", DIGITO_POSITIVO); yylval.intVal = atoi(yytext);  return DIGITO_POSITIVO; }
{digitoNegativo}     { printf("Lido: %s\n", yytext); ultimo_token = DIGITO_NEGATIVO; printf("Token Num DIGITO_NEGATIVO: %d \n", DIGITO_NEGATIVO); yylval.intVal = atoi(yytext);  return DIGITO_NEGATIVO; }
{decimal}            { printf("Lido: %s\n", yytext); ultimo_token = DECIMAL; printf("Token Num DECIMAL: %d \n", DECIMAL); yylval.floatVal = atof(yytext);  return DECIMAL; }
{true}               { printf("Lido: %s\n", yytext); ultimo_token = TK_TRUE; printf("Token Num TK_TRUE: %d \n", TK_TRUE); return TK_TRUE; }
{false}              { printf("Lido: %s\n", yytext); ultimo_token = TK_FALSE; printf("Token Num TK_FALSE: %d \n", TK_FALSE); return TK_FALSE; }

{soma}               { printf("Lido: %s\n", yytext); ultimo_token = SOMA; printf("Token Num SOMA: %d \n", SOMA); return SOMA; }
{subtracao}          { printf("Lido: %s\n", yytext); ultimo_token = SUBTRACAO; printf("Token Num SUBTRACAO: %d \n", SUBTRACAO);return SUBTRACAO; }
{multiplicacao}      { printf("Lido: %s\n", yytext); ultimo_token = MULTIPLICACAO; printf("Token Num MULTIPLICACAO: %d \n", MULTIPLICACAO); return MULTIPLICACAO; }
{divisao}            { printf("Lido: %s\n", yytext); ultimo_token = DIVISAO; printf("Token Num DIVISAO: %d \n", DIVISAO); return DIVISAO; }
{mod}                { printf("Lido: %s\n", yytext); ultimo_token = MOD; printf("Token Num MOD: %d \n", MOD); return MOD; }
{incremento}         { printf("Lido: %s\n", yytext); ultimo_token = INCREMENTO; printf("Token Num INCREMENTO: %d \n", INCREMENTO); return INCREMENTO; }
{decremento}         { printf("Lido: %s\n", yytext); ultimo_token = DECREMENTO; printf("Token Num DECREMENTO: %d \n", DECREMENTO); return DECREMENTO; }
{maisIgual}          { printf("Lido: %s\n", yytext); ultimo_token = MAIS_IGUAL; printf("Token Num MAIS_IGUAL: %d \n", MAIS_IGUAL); return MAIS_IGUAL; }
{menosIgual}         { printf("Lido: %s\n", yytext); ultimo_token = MENOS_IGUAL; printf("Token Num MENOS_IGUAL: %d \n", MENOS_IGUAL); return MENOS_IGUAL; }
{multiplicadorIgual} { printf("Lido: %s\n", yytext); ultimo_token = MULTIPLICADOR_IGUAL; printf("Token Num MULTIPLICADOR_IGUAL: %d \n", MULTIPLICADOR_IGUAL); return MULTIPLICADOR_IGUAL; }
{igual}              { printf("Lido: %s\n", yytext); ultimo_token = IGUAL; printf("Token Num IGUAL: %d \n", IGUAL); return IGUAL; }
{diferente}          { printf("Lido: %s\n", yytext); ultimo_token = DIFERENTE; printf("Token Num DIFERENTE: %d \n", DIFERENTE); return DIFERENTE; }
{menor}              { printf("Lido: %s\n", yytext); ultimo_token = MENOR; printf("Token Num MENOR: %d \n", MENOR); return MENOR; }
{maior}              { printf("Lido: %s\n", yytext); ultimo_token = MAIOR; printf("Token Num MAIOR: %d \n", MAIOR); return MAIOR; }
{menorIgual}         { printf("Lido: %s\n", yytext); ultimo_token = MENOR_IGUAL; printf("Token Num MENOR_IGUAL: %d \n", MENOR_IGUAL); return MENOR_IGUAL; }
{maiorIgual}         { printf("Lido: %s\n", yytext); ultimo_token = MAIOR_IGUAL; printf("Token Num MAIOR_IGUAL: %d \n", MAIOR_IGUAL); return MAIOR_IGUAL; }
{and}                { printf("Lido: %s\n", yytext); ultimo_token = AND; printf("Token Num AND: %d \n", AND); return AND; }
{or}                 { printf("Lido: %s\n", yytext); ultimo_token = OR; printf("Token Num OR: %d \n", OR); return OR; }
{recebe}             { printf("Lido: %s\n", yytext); ultimo_token = RECEBE; printf("Token Num RECEBE: %d \n", RECEBE); return RECEBE; }
{abreParenteses}     { printf("Lido: %s\n", yytext); ultimo_token = ABRE_PARENTESES; printf("Token Num ABRE_PARENTESES: %d \n", ABRE_PARENTESES); return ABRE_PARENTESES; }
{fecharParenteses}   { printf("Lido: %s\n", yytext); ultimo_token = FECHA_PARENTESES; printf("Token Num FECHA_PARENTESES: %d \n", FECHA_PARENTESES); return FECHA_PARENTESES; }
{inteiro}            { printf("Lido: %s\n", yytext); ultimo_token = INTEIRO; printf("Token Num INTEIRO: %d \n", INTEIRO); return INTEIRO; }
{float}              { printf("Lido: %s\n", yytext); ultimo_token = FLOAT; printf("Token Num FLOAT: %d \n", FLOAT); return FLOAT; }
{bool}               { printf("Lido: %s\n", yytext); ultimo_token = BOOL; printf("Token Num BOOL: %d \n", BOOL); return BOOL; }
{string}             { printf("Lido: %s\n", yytext); ultimo_token = STRING; printf("Token Num STRING: %d \n", STRING); return STRING; }
{char}               { printf("Lido: %s\n", yytext); ultimo_token = CHAR; printf("Token Num CHAR: %d \n", CHAR); return CHAR; }
{double}             { printf("Lido: %s\n", yytext); ultimo_token = DOUBLE; printf("Token Num DOUBLE: %d \n", DOUBLE); return DOUBLE; }
{abreBloco}          { printf("Lido: %s\n", yytext); ultimo_token = ABRE_BLOCO; printf("Token Num ABRE_BLOCO: %d \n", ABRE_BLOCO); return ABRE_BLOCO; }
{fechaBloco}         { printf("Lido: %s\n", yytext); ultimo_token = FECHA_BLOCO; printf("Token Num FECHA_BLOCO: %d \n", FECHA_BLOCO); return FECHA_BLOCO; }
{abreColchete}       { printf("Lido: %s\n", yytext); ultimo_token = ABRE_COLCHETE; printf("Token Num ABRE_COLCHETE: %d \n", ABRE_COLCHETE); return ABRE_COLCHETE; }
{fechaColchete}      { printf("Lido: %s\n", yytext); ultimo_token = FECHA_COLCHETE; printf("Token Num FECHA_COLCHETE: %d \n", FECHA_COLCHETE); return FECHA_COLCHETE; }
{virgula}            { printf("Lido: %s\n", yytext); ultimo_token = VIRGULA; printf("Token Num VIRGULA: %d \n", VIRGULA); return VIRGULA; }

{escopo}             { printf("Lido: %s\n", yytext); ultimo_token = ESCOPO; printf("Token Num ESCOPO: %d \n", ESCOPO); return ESCOPO; }
{null}               { printf("Lido: %s\n", yytext); ultimo_token = TK_NULL; printf("Token Num TK_NULL: %d \n", TK_NULL);return TK_NULL; }
{if}                 { printf("Lido: %s\n", yytext); ultimo_token = IF; printf("Token Num IF: %d \n", IF); return IF; }
{else}               { printf("Lido: %s\n", yytext); ultimo_token = ELSE; printf("Token Num ELSE: %d \n", ELSE); return ELSE; }
{while}              { printf("Lido: %s\n", yytext); ultimo_token = WHILE; printf("Token Num WHILE: %d \n", WHILE); return WHILE; }
{do}                 { printf("Lido: %s\n", yytext); ultimo_token = DO; printf("Token Num DO: %d \n", DO); return DO; }
{for}                { printf("Lido: %s\n", yytext); ultimo_token = FOR; printf("Token Num FOR: %d \n", FOR); return FOR; }
{switch}             { printf("Lido: %s\n", yytext); ultimo_token = SWITCH; printf("Token Num SWITCH: %d \n", SWITCH); return SWITCH; }
{case}               { printf("Lido: %s\n", yytext); ultimo_token = CASE; printf("Token Num CASE: %d \n", CASE); return CASE; }
{default}            { printf("Lido: %s\n", yytext); ultimo_token = DEFAULT; printf("Token Num DEFAULT: %d \n", DEFAULT); return DEFAULT; }
{break}              { printf("Lido: %s\n", yytext); ultimo_token = BREAK; printf("Token Num BREAK: %d \n", BREAK); return BREAK; }
{continue}           { printf("Lido: %s\n", yytext); ultimo_token = CONTINUE; printf("Token Num CONTINUE: %d \n", CONTINUE); return CONTINUE; }
{return}             { printf("Lido: %s\n", yytext); ultimo_token = RETURN; printf("Token Num RETURN: %d \n", RETURN); return RETURN; }
{import}             { printf("Lido: %s\n", yytext); ultimo_token = IMPORT; printf("Token Num IMPORT: %d \n", IMPORT); return IMPORT; }
{typecast}           { printf("Lido: %s\n", yytext); ultimo_token = TYPECAST; printf("Token Num TYPECAST: %d \n", TYPECAST); return TYPECAST; }
{void}               { printf("Lido: %s\n", yytext); ultimo_token = VOID; printf("Token Num VOID: %d \n", VOID); return VOID; }
{print}              { printf("Lido: %s\n", yytext); ultimo_token = PRINT; printf("Token Num PRINT: %d \n", PRINT); return PRINT; }

{stringLiteral}      { printf("Lido: %s\n", yytext); ultimo_token = STRING_LITERAL; printf("Token Num STRING_LITERAL: %d \n", STRING_LITERAL); yylval.stringVal = yytext; return STRING_LITERAL; }
{charLiteral}        { printf("Lido: %s\n", yytext); ultimo_token = CHAR_LITERAL; printf("Token Num CHAR_LITERAL: %d \n", CHAR_LITERAL); yylval.charVal = yytext; return CHAR_LITERAL; }

{bloco}              { printf("Lido: %s\n", yytext); ultimo_token = BLOCO; printf("Token Num BLOCO: %d \n", BLOCO); return BLOCO;}

{fimDeLinha}         { printf("Lido: %s\n", yytext); ultimo_token = FIM_DE_LINHA; printf("Token Num FIM_DE_LINHA: %d \n", FIM_DE_LINHA); return FIM_DE_LINHA; }
{comentario}         {}

{identificador}      { printf("Lido: %s\n", yytext); ultimo_token = IDENTIFICADOR; printf("Token Num IDENTIFICADOR: %d \n", IDENTIFICADOR); return IDENTIFICADOR; }

{quebraLinha}        { num_linha++; }


%%