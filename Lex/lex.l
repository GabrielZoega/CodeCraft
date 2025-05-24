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
incremento          minerar({variavel})
decremento          colocar_bloco({variavel})
maisIgual           regenerar"("{variavel}","{digito}+")" 
menosIgual          veneno"("{variavel}","{digito}+")"
multiplicadorIgual  creeper"("{variavel}","{digito}+")"
igual               "🧱🧱"|"=="
diferente           "🧱⬜"|"!="
menor               "🔽🪜"|"<"
maior               "🔼🪜"|">"
menorIgual          "🧱🔽"|"<="
maiorIgual          "🧱🔼"|">="
and                 &&|"📦"
or                  \|\||"🪨"

/* Tipos Primitivos */
inteiro             "hp"
float               "xp"
bool                "tocha"
string              "livro"
char                "fragmento"
double              "bussola"
tiposPrimitivos     {inteiro}|{float}|{bool}|{string}|{char}|{double}


/*blocos*/
abreBloco           "⛏️"|\{
fechaBloco          "⬛"|\}


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
defalt              cacto 
break               end 
continue            pular
return              overworld
import              portal 
typecast            villager
void                vazia 

/*tipos compostos*/
vetor               bau[ ]{variavel}
enum                pocao[ ]{variavel}⛏️[{variavel}:{digito}/+/;]+

/*Funcoes*/
defineFuncao        {tiposPrimitivos}(crafting_table){variavel}\(({tiposPrimitivos}{variavel})*\)
defineProcedimento  {void}(enchanting_table){variavel}\(({tiposPrimitivos}{variavel})*\)

funcaoMain          {inteiro}main\(\){abreBloco}
fimDeLinha          ";"
comentario          "🪶🪶"

%% 

{ws}		        {/*nenhuma acao e nenhum retorno*/} 

{digitoPositivo}     { printf("Inteiro positivo. LEXEMA: %s\n", yytext); }
{digitoNegativo}     { printf("Inteiro negativo. LEXEMA: %s\n", yytext); }
{decimal}            { printf("Numero com parte decimal. LEXEMA: %s\n", yytext); }
{palavra}            { printf("Palavra. LEXEMA: %s\n", yytext); }
{true}               { printf("True. LEXEMA: %s\n", yytext); }
{false}              { printf("False. LEXEMA: %s\n", yytext); }
{variavel}           { printf("variavel. LEXEMA: %s\n", yytext); }
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
{inteiro}            { printf("inteiro. LEXEMA: %s\n", yytext); }
{float}              { printf("float. LEXEMA: %s\n", yytext); }
{bool}               { printf("bool. LEXEMA: %s\n", yytext); }
{string}             { printf("string. LEXEMA: %s\n", yytext); }
{char}               { printf("char. LEXEMA: %s\n", yytext); }
{double}             { printf("double. LEXEMA: %s\n", yytext); }
{abreBloco}          { printf("abreBloco. LEXEMA: %s\n", yytext); }
{fechaBloco}         { printf("fechaBloco. LEXEMA: %s\n", yytext); }
{escopo}             { printf("escopo. LEXEMA: %s\n", yytext); }
{null}               { printf("null. LEXEMA: %s\n", yytext); }
{if}                 { printf("if. LEXEMA: %s\n", yytext); }
{else}               { printf("else. LEXEMA: %s\n", yytext); }
{while}              { printf("while. LEXEMA: %s\n", yytext); }
{do}                 { printf("do. LEXEMA: %s\n", yytext); }
{for}                { printf("for. LEXEMA: %s\n", yytext); }
{switch}             { printf("switch. LEXEMA: %s\n", yytext); }
{case}               { printf("case. LEXEMA: %s\n", yytext); }
{defalt}             { printf("defalt. LEXEMA: %s\n", yytext); }
{break}              { printf("break. LEXEMA: %s\n", yytext); }
{continue}           { printf("continue. LEXEMA: %s\n", yytext); }
{return}             { printf("return. LEXEMA: %s\n", yytext); }
{import}             { printf("import. LEXEMA: %s\n", yytext); }
{typecast}           { printf("typecast. LEXEMA: %s\n", yytext); }
{void}               { printf("void. LEXEMA: %s\n", yytext); }
{vetor}              { printf("vetor. LEXEMA: %s\n", yytext); }
{enum}               { printf("enum. LEXEMA: %s\n", yytext); }
{defineFuncao}       { printf("edefineFuncao. LEXEMA: %s\n", yytext); }
{defineProcedimento} { printf("defineProcedimento. LEXEMA: %s\n", yytext); }
{fimDeLinha}         { printf("fimDeLinha. LEXEMA: %s\n", yytext); }
{comentario}         { printf("comentario. LEXEMA: %s\n", yytext); }
{funcaoMain}         { printf("funcaoMain. LEXEMA: %s\n", yytext); }

%% 

/*codigo em C. Foi criado o main, mas podem ser criadas outras funcoes aqui.*/ 

int main(void) 
{ 
    /* Call the lexer, then quit. */ 
    yylex(); 
    return 0; 
}