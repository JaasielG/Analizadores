/*
* Autores: Dominguez Cisneros Alexis Saul y Garcia Oviedo Jaasiel Osmar
 * Creado 22/05/2020 by Dominguez Cisneros Alexis Saul
 * Editado y terminado: 23/05/2020 by Garcia Oviedo Jaasiel Osmar
 *ultima revision: 24/05/2020 by Dominguez Cisneros Alexis Saul y Garcia Oviedo Jaasiel Osmar
 *ESTE PROGRAMA LLEVA A CABO LA GENERACION DEL ANALAIZADOR LEXICO
*/

%{
	#include <stdio.h>
	#include <stdlib.h>
	int num_char=0;
	int num_linea=0;
	char linea[20];
	char cadena[20];
	FILE *e;
	int token;
%}

%option noyywrap
%option yylineno
/*
************************************EXPRESIONES REGULARES************************************
*/
letra [a-zA-Z]
digito [0-9]
letra_ ({letra}|_)+
id ({letra_}|{letra_}({letra_}|{digito})+)
tipo $(int|float|double|char|void|struct)
res #(do|for|double|char|void|struct|false|func|printf)
opesp [(|)|{|}]
termina [;]
espacio [ \n\t]
cadena ["]({letra}*|{digito}*)+["]
numero ({digito}*.{digito}+|({digito})+)
coment [/][*]({letra}|{digito})*[\n]({letra}|{digito})*[*][/]
opera  [+|-|*|/|%]
condi  [|| | && | ! ]
rela   [<|>|<=|>=|!=|==|=]


%%

 /*ACCIONES LEXICAS*/
 /*	Se especifican las acciones que se llevaran a 	cabo cuando se identifiquen cada uno de los  		tokens acpetados por la gramática propuesta. 		Igualmente se retorna la clase lexica, la cual 	 recibira el analizador sintactico para llevar a 		cabo su tarea*/
{id} {num_char=num_char+yyleng;
		fputs("\n<id\t,\t",yyout);
		fputs(yytext,yyout);
		fputs(">",yyout);		
		yylex();
		printf("\n<(1)id,%s>\n",yytext);
	}
 /*Para los casos: res, opesp, opera, condi y rela se retorna una 		clase lexica por cada uno de los elementos
	que los conforman y asi estos puedan ser diferenciados e 		identificados de forma individual por el 
	analizador sintactico.*/
{tipo} {num_char=num_char+yyleng;
		fputs("\n<tipo\t,\t",yyout);
		fputs(yytext,yyout);
		fputs(">",yyout);
		yylex();
		printf("\n<(2)tipo,%s>\n",yytext);
	}

{res} {num_char=num_char+yyleng;
	  fputs("\n<res\t,\t",yyout);
	  fputs(yytext,yyout);
	  fputs(">",yyout);
	  yylex();
	  printf("\n<(3)res,%s>\n",yytext);
	}

{opesp} {num_char=num_char+yyleng;
		fputs("\n<opesp\t,\t",yyout);
		fputs(yytext,yyout);
		fputs(">",yyout);
		yylex();
		printf("\n<(4)opesp,%s>\n",yytext);
	}

 /*los espacios los ignorados*/
{espacio} {num_char=num_char+yyleng;}

{cadena} {num_char=num_char+yyleng;
		 fputs("\n<cadena\t,\t",yyout);
		 fputs(yytext,yyout);
		 fputs(">",yyout);
		 yylex();
		 printf("\n<(6)cadena,%s>\n",yytext);
		}

{numero} {num_char=num_char+yyleng;
		fputs("\n<numero\t,\t",yyout);
		fputs(yytext,yyout);
		fputs(">",yyout);
		yylex();
		printf("\n<(7)numero,%s>\n",yytext);
	}

{opera} {num_char=num_char+yyleng;
		fputs("\n<opera\t,\t",yyout);
		fputs(yytext,yyout);
		fputs(">",yyout);
		yylex();
		printf("\n<(8)opera,%s>\n",yytext);
	}

{coment} {num_char=num_char+yyleng;
		fputs("\n<coment\t,\t",yyout);
		fputs(yytext,yyout);
		fputs(">",yyout);
		yylex();
		printf("\n<(9)coment,%s>\n",yytext);
	}

{condi} {num_char=num_char+yyleng;
			fputs("\n<condicional\t,\t",yyout);
			fputs(yytext,yyout);
			fputs(">",yyout);
			yylex();
			printf("\n<(10)condi,%s>\n",yytext);
		}

{rela} {num_char=num_char+yyleng;
			fputs("\n<relacional\t,\t",yyout);
			fputs(yytext,yyout);
			fputs(">",yyout);
			yylex();
			printf("\n<(11)rela,%s>\n",yytext);
		}

{termina} {num_char=num_char+yyleng;	
		fputs("\n<termina\t,\t",yyout);
		fputs(yytext,yyout);
		fputs(">",yyout);		
		printf("\n<(12)End_Linea,%s>\n",yytext);
	}

[ \n\t]+ {}
 /*Si se encuentra algun error, son agregados a un archivo en el 	cual se muestra tanto la linea 
	como la columna donde se produjo el error lexico.*/
. {printf("Error lexico: %s\n", yytext);	
			num_char=num_char+yyleng;
			num_linea=yylineno;
			sprintf(linea, "%i", num_linea);
			sprintf(cadena, "%i", num_char);
			fputs("\n<error\t,\t", e);
			fputs(linea,e);
			fputs(":", e);
			fputs(cadena,e);			
	}	

%%
/**********************************Main C*************************************************/

/*En esta parte se lleva a cabo el procedimiento para abrir/crear  y cerrar los archivos utilizados por el analizador 
lexico. En total se hace uso de dos archivos: Tokens y Erroes.*/
int main(int argc, char **argv){
	FILE *f, *t;
	f=fopen(argv[1], "r");
	yyin=f;
	t=fopen("Tokens.txt", "w");
	e=fopen("Errores.txt", "w");
	yyout=t;
	if(yyin==NULL||yyout==NULL){
		printf("Error\n");
	}else{
		yylex();
	}
	fclose(yyin);
	fclose(yyout);
	fclose(e);
}
