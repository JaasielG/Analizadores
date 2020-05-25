/*
	*File: parser.y
	*Autores: Alvarez González Ian Arturo y López López Ulysses
	*Creado: 22/05/2020
	*Editado y terminado: 23/05/2020
	*Ultima revisión: 24/05/2020
	*Este programa lleva a cabo la generación del analizador sintáctico
*/
%{
#include <stdio.h>
extern int yylex(); 
void yyerror (char *)
%}

/*----DECLARACION DE TOKENS----*/
/*	PYC : Punto Y Coma
	MAS : +
	MEN : -
	POR : *
	DIV : /
	MOD : % 
	MENQUE : <
	MAYQUE : >
	MENIGUAL : <=
	MAYIGUAL : >=
	DIF : !=
	IGUAL : ==
	NEG : !
	PARA : (
	PARC : )
	CORA : [
	CORC : ]	
	LLA : {
	LLC : }
	AND : &&
	OR : || 
	COMA : ,
	DP : :
	PUNTO : .*/

%token ID
%token INT FLOAT DOUBLE CHAR VOID STRUCT
%token DO FOR FALSE FUN PRINTF TRUE IF ELSE WHILE SWITCH RETURN BREAK CASE DEFAULT
%nonassoc PARA PARC LLAA LLAC CORA CORC
%token CADENA
%token CARACTER
%token NUMERO
%right NEG
%left POR DIV MOD
%left MAS MEN
%token MENQUE MAYQUE MENIGUAL MAYIGUAL
%token IGUAL DIF
%left AND
%left OR 
%right ASIGNA
%token COMENT
%token PYC 
%token COMA DP PUNTO


%start prog

%%
/*-----DECLARACION DE LA GRAMATICA-----*/
/* 	A = Arreglo
	ARG = Argumento
	L_A = Lista de Argumentos
	P_A = Parte Arreglo
	P_I = Parte Izquierda
	CAS = Casos 
	PRED= predeterminado
	V_A = var_arreglo 
	PAR = Parámetros
	L_P = lista_parametros
	prog = programa
	decl = declaraciones
	array = arreglo
	arg = argumentos
	pred = predeterminado 
*/

/* P → DF */
prog : decl funcion;

/* D → T L; | Ɛ */
decl : tipo lista PYC | ;

/* T → int | float | double | char | void | struct {D} */
tipo : INT | FLOAT | DOUBLE | CHAR | VOID | STRUCT LLAA decl LLAC;

/* L → L, id A | id A */ 
lista : lista COMA ID array | ID array;

/* A → [ num ] A | Ɛ */
array : CORA NUMERO CORC array | ;

/* F → func T id ( ARG ) { D } F | Ɛ */
funcion : FUN tipo ID PARA arg PARC LLAA decl sent LLAC funcion | ;

/* ARG → L_A |  Ɛ */
arg : lista_arg | ;

/* L_A → L_A , T id P_A | T id P_A */
lista_arg : lista_arg COMA tipo ID parte_array | tipo ID parte_array;

/* P_A → CORA CORC P_A | Ɛ */
parte_array : CORA CORC parte_array | ;

/* S → SS | if ( C ) S | if ( C ) S else S | while ( C ) S | do S while ( C ); | 
	for  ( S ; C ; S ) S | P_I = E ; |  return E; | return; | { S } | 
	switch ( E ) { CAS PRED } | break; | print E; */
sent : sent sent | IF PARA cond PARC sent | IF PARA cond PARC sent ELSE sent | WHILE PARA cond PARC sent |
	DO sent WHILE PARA cond PARC PYC | FOR PARA sent PYC cond PYC sent PARC sent | parte_izq ASIGNA exp PYC |
	RETURN exp PYC | RETURN PYC | LLAA sent LLAC | SWITCH PARA exp PARC LLAA caso pred LLAC | BREAK PYC | PRINTF exp PYC;

/* CAS → case: num S PRED |  Ɛ */
caso : CASE DP NUMERO sent pred | ;

/* PRED → default: S | Ɛ */
pred : DEFAULT DP sent | ;

/* P_I → id | V_A | id.id */
parte_izq : ID | var_arg | ID PUNTO ID;

/* V_A → id [ E ] | V_A [ E ] */
var_arg : ID CORA exp CORC | var_arg CORA exp CORC;

/* E → E + E | E – E | E * E | E / E | E %  E | V_A | cadena | num | caracter | id (PAR) */
exp : exp MAS exp | exp MEN exp | exp POR exp | exp DIV exp | exp MOD exp | var_arg | CADENA | NUMERO | CARACTER | ID PARA param PARC;

/* PAR → Ɛ | L_P */
param : ; | lista_param;

/* L_P = L_P , E | E */
lista_param : lista_param COMA exp | exp;

/* C → C || C | C && C | ! C | ( C )  | E R E | true | false */
cond : cond OR cond | cond AND cond | NEG cond | PARA cond PARC | exp rel exp | TRUE | FALSE;

/* R → < | > | >= | <= | != | == */
rel : MENQUE | MAYQUE | MAYIGUAL | MENIGUAL | DIF | IGUAL ; 

%%

/*DEFINICION FUNCION ERROR*/ 
/*La funcion error lo que va a hacer es una llamada de función en un archivo c que implementa la función error*/																												  

void yyerror (s) char *s {
	printf ("Error: %s\n",s);
}

