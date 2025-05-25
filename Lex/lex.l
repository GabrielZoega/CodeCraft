%{ 

%} 

%option noyywrap 

/*Para ignorar tabulação, quebra de linha e espaço em branco*/
delim		        [ \t\n\r]
ws		            {delim}+ 

/* identificação */ 
digito              [0-9]
caractere           [a-zA-Z]
digitoPositivo      \+?{digito}+
digitoNegativo      \-{digito}+
decimal             ({digitoNegativo}|{digitoPositivo})\.{digitoPositivo}
palavra             [{caractere}]+

true                Acesa
false               Apagada

variavel            {caractere}({caractere}|{digito})*

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
abreChave           "{"
fechaChave          "}"

/* Tipos Primitivos */
inteiro             "hp"
float               "xp"
bool                "tocha"
string              "livro"
char                "fragmento"
double              "bussola"
tiposPrimitivos     {inteiro}|{float}|{bool}|{string}|{char}|{double}


/*blocos*/
abreBloco           "⛏️"
fechaBloco          "⬛"


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


/*tipos compostos*/
vetor               bau
enum                pocao

/*Funcoes*/
funcao              "crafting_table"
procedimento        "enchanting_table"

funcaoMain          main
fimDeLinha          ";"
comentario          "🪶🪶".*"\n"



%% 

{ws}		         {/*nenhuma acao e nenhum retorno*/} 

{funcaoMain}         { printf("funcaoMain. LEXEMA: %s\n", yytext); }
{abreChave}          { printf("abreChave. LEXEMA: %s\n", yytext); }
{fechaChave}         { printf("fechaChave. LEXEMA: %s\n", yytext);}

{funcao}             { printf("funcao. LEXEMA: %s\n", yytext); }
{procedimento}       { printf("procedimento. LEXEMA: %s\n", yytext); }

{vetor}              { printf("vetor. LEXEMA: %s\n", yytext); }
{enum}               { printf("enum. LEXEMA: %s\n", yytext); }

{digitoPositivo}     { printf("Digito positivo. LEXEMA: %s\n", yytext); }
{digitoNegativo}     { printf("Digito negativo. LEXEMA: %s\n", yytext); }
{decimal}            { printf("Numero com parte decimal. LEXEMA: %s\n", yytext); }
{palavra}            { printf("Palavra. LEXEMA: %s\n", yytext); }
{true}               { printf("True. LEXEMA: %s\n", yytext); }
{false}              { printf("False. LEXEMA: %s\n", yytext); }


{soma}               { printf("Soma. LEXEMA: %s\n", yytext); }
{subtracao}          { printf("subtracao. LEXEMA: %s\n", yytext); }
{multiplicacao}      { printf("multiplicacao. LEXEMA: %s\n", yytext); }
{divisao}            { printf("divisao. LEXEMA: %s\n", yytext); }
{mod}                { printf("mod. LEXEMA: %s\n", yytext); }
{incremento}         { printf("incremento. LEXEMA: %s\n", yytext); }
{decremento}         { printf("decremento. LEXEMA: %s\n", yytext); }
{maisIgual}          { printf("maisIgual. LEXEMA: %s\n", yytext); }
{menosIgual}         { printf("menosIgual. LEXEMA: %s\n", yytext); }
{multiplicadorIgual} { printf("multiplicacao. LEXEMA: %s\n", yytext); }
{igual}              { printf("igual. LEXEMA: %s\n", yytext); }
{diferente}          { printf("diferente. LEXEMA: %s\n", yytext); }
{menor}              { printf("menor. LEXEMA: %s\n", yytext); }
{maior}              { printf("maior. LEXEMA: %s\n", yytext); }
{menorIgual}         { printf("menorIgual. LEXEMA: %s\n", yytext); }
{maiorIgual}         { printf("maiorIgual. LEXEMA: %s\n", yytext); }
{and}                { printf("and. LEXEMA: %s\n", yytext); }
{or}                 { printf("or. LEXEMA: %s\n", yytext); }
{recebe}             { printf("recebe. LEXEMA: %s\n", yytext);}
{abreParenteses}     { printf("abreParenteses. LEXEMA: %s\n", yytext);}
{fecharParenteses}   { printf("fecharParenteses. LEXEMA: %s\n", yytext);}
{inteiro}            { printf("inteiro. LEXEMA: %s\n", yytext); }
{float}              { printf("float. LEXEMA: %s\n", yytext); }
{bool}               { printf("bool. LEXEMA: %s\n", yytext); }
{string}             { printf("string. LEXEMA: %s\n", yytext); }
{char}               { printf("char. LEXEMA: %s\n", yytext); }
{double}             { printf("double. LEXEMA: %s\n", yytext); }
{abreBloco}          { printf("abreBloco. LEXEMA: %s\n", yytext); }
{fechaBloco}         { printf("fechaBloco. LEXEMA: %s\n", yytext); }
{abreColchete}       { printf("abreColchete. LEXEMA: %s\n", yytext); }
{fechaColchete}      { printf("fechaColchete. LEXEMA: %s\n", yytext);}
{virgula}            { printf("virgula. LEXEMA: %s\n", yytext);}

{escopo}             { printf("escopo. LEXEMA: %s\n", yytext); }
{null}               { printf("null. LEXEMA: %s\n", yytext); }
{if}                 { printf("if. LEXEMA: %s\n", yytext); }
{else}               { printf("else. LEXEMA: %s\n", yytext); }
{while}              { printf("while. LEXEMA: %s\n", yytext); }
{do}                 { printf("do. LEXEMA: %s\n", yytext); }
{for}                { printf("for. LEXEMA: %s\n", yytext); }
{switch}             { printf("switch. LEXEMA: %s\n", yytext); }
{case}               { printf("case. LEXEMA: %s\n", yytext); }
{default}            { printf("default. LEXEMA: %s\n", yytext); }
{break}              { printf("break. LEXEMA: %s\n", yytext); }
{continue}           { printf("continue. LEXEMA: %s\n", yytext); }
{return}             { printf("return. LEXEMA: %s\n", yytext); }
{import}             { printf("import. LEXEMA: %s\n", yytext); }
{typecast}           { printf("typecast. LEXEMA: %s\n", yytext); }
{void}               { printf("void. LEXEMA: %s\n", yytext); }
{print}              { printf("print. LEXEMA: %s\n", yytext); }
{stringLiteral}      { printf("stringLiteral. LEXEMA: %s\n", yytext); }
{fimDeLinha}         { printf("fimDeLinha. LEXEMA: %s\n", yytext); }
{comentario}         { printf("comentario. LEXEMA: %s\n", yytext); }


{variavel}           { printf("variavel. LEXEMA: %s\n", yytext); }

%% 

/*codigo em C. Foi criado o main, mas podem ser criadas outras funcoes aqui.*/ 

int main(void) 
{ 
    /* Call the lexer, then quit. */ 
    yylex(); 
    return 0; 
}