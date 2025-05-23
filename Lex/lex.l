%%{ 

%} 

%option noyywrap 

/*Para ignorar tabulação, quebra de linha e espaço em branco*/
delim		 [ \t\n\r] 
ws		   {delim}+ 

/* identificação */ 
digito [0-9]
caractere [a-zA-Z]
digitoPositivo \+?{digito}+
digitoNegativo \-{digito}+
decimal ({digneg}|{digpos})\.{digpos}
palavra [{caractere}]+

true Acesa
false Apagada
void vazio
break end
continue pular

variavel {caractere}({caractere}|{digito})*

/* Aritméticos e lógicos */

soma ⚒️|+
subtracao ⚔️|-
multiplicacao 💣|*
divisao 🪣|/
mod 🪵| %
incremento minerar({variavel})
decremento colocar_bloco({variavel})
maisIgual regenerar({variavel}, {digito}) 
menosIgual veneno({variavel}, {digito})
multiplicadorIgual creeper({variavel}, {digito})
igual 🧱🧱 | ==
diferente 🧱⬜ | !=
menor 🔽🪜 | <
maior 🔼🪜 | >
menorIgual 🧱🔽 | <=
maiorIgual 🧱🔼 | >=


/* Tipos Primitivos */
inteiro hp
float xp
bool tocha
string livro
char fragmento
double bussola
void vazia 
/* ver se deixa aqui ou lá */ 


/* Palavras reservadas */
escopo inventario
null nether
if observador
else liberador
while comparador 
do redstone
for repetidor
switch carrinho
case trilho
defalt cacto 
break end // ver tbm
continue pular // ver tbm 
return overwold
import portal 
typecast villager



%% 

{ws}		{/*nenhuma acao e nenhum retorno*/} 
{digitoPositivo}    { printf("Foi encontrado um numero inteiro positivo. LEXEMA: %s\n", yytext); }
{digitoNegativo}    { printf("Foi encontrado um numero inteiro negativo. LEXEMA: %s\n", yytext); }
{decimal}   { printf("Foi encontrado um numero com parte decimal. LEXEMA: %s\n", yytext); }


%% 

/*codigo em C. Foi criado o main, mas podem ser criadas outras funcoes aqui.*/ 

int main(void) 
{ 
    /* Call the lexer, then quit. */ 
    yylex(); 
    return 0; 
}