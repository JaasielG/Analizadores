/*
	*File: parser.y
	*Autores: Alvarez González Ian Arturo y López López Ulysses
	*Creado: 22/05/2020
	*Editado y terminado: 23/05/2020
	*Ultima revisión: 24/05/2020
	*Este programa lleva a cabo la generación del analizador sintáctico
%{
#include <stdio.h>
#include <string.h>
#include "intermediate_code.h"
#include "tablaSimbol.h"
#include "tablaTipo.h"
#include "pilaTablaSimbol.h"
#include "pilaTablaTipo.h"

int max(int a, int b);
int min(int a, int b);
void ampliar(char* res,char* dir,int a, int b);
void reducir(char* res,char* dir,int a, int b);
void yyerror(char *s);
extern int yylex();
void nuevaEtiqueta(char *dire);
int temp, temp2; 
char temp_E[32];
char tipos[32];
pilaTipos *ptt;
pilaSimbolos *pts;
int tipoGlobal, baseGlobal,dirGlobal;

%}

%union
{
    char dir[64];
    int base;
    int line;
    struct 
    {
        int tipo;
        int ival;
        float fval;
        float dval;
    } num;

    struct 
    {
        char sval[10];
        int tipo;
    } car;

    struct
    {
        char dir[24];
        int tipo;
    }variaexp;
}

%token PYC
%token REGISTRO
%token INICIO
%token FIN
%token ESTRUCTURA
%token DEF
%token SI
%token ENTONCES
%token MIENTRAS
%token HACER
%token SEGUN
%token ESCRIBIR
%token DEVOLVER
%token LEER
%token TERMINAR
%token CASO
%token PRED
%token DOSP
%token FALSO
%token VERDADERO

%token<base> ENT
%token<base> CAR
%token<base> DREAL
%token<base> REAL
%token<base> SIN
%token<dir> ID 
%token<car> CARACTER
%token<dir> CADENA
%token<num> NUM

%token COMA
%right ASIG
%left O
%left Y
%left<car> SMT
%left<car> GRT
%left<car> GREQ
%left<car> SMEQ
%left<car> DIF
%left<car> EQEQ 
%left<dir> SUM
%left<dir> RES
%left<dir> MUL
%left<dir> DIV
%left<dir> MOD 
%right NO
%nonassoc PT 
%nonassoc LCOR
%nonassoc RCOR
%nonassoc LPAR RPAR
%nonassoc SINO
%type<dir> programa declaraciones tipo_registro lista_var arreglo funciones argumentos lista_arg arg tipo_arg param_arr sentencias sentencia casos predeterminado e_bool relacional dato_est_sim parametros lista_param variable_comp A/*No terminales*/
%type<base> base tipo tipo_arreglo
%type<variaexp> expresion variable
%start programa         /*Inicio*/

%%

programa : {
    ptt = crearPilaTipos();
    pts = crearPilaSimbolos();
    dirGlobal=0;
    insertarTablaTipo(ptt,crearTablaTipo());
    insertarTipo(getTipoCima(ptt),crearTipo("car", 1, -1, 1,false,NULL));
    insertarTipo(getTipoCima(ptt),crearTipo("ent", 4, -1, 1,false,NULL));
    insertarTipo(getTipoCima(ptt),crearTipo("real", 4, -1, 1,false,NULL));
    insertarTipo(getTipoCima(ptt),crearTipo("dreal", 8, -1, 1,false,NULL));
    insertarTablaSimbolo(pts, crearTablaSimbolo());

} declaraciones funciones {  printf("No hay errores, la gramática acepto el programa\n");
printTablaTipo(getTipoCima(ptt)); 
printTablaSimbolos(getSimboloCima(pts));};

declaraciones : tipo {tipoGlobal = $1;} lista_var PYC declaraciones {}
| tipo_registro lista_var PYC declaraciones {}
| {};

tipo_registro : ESTRUCTURA INICIO declaraciones FIN {};

tipo : base {baseGlobal = $1;} tipo_arreglo {$$ = $3;};

base : ENT {$$=1;}
| REAL {$$=2;}
| DREAL {$$=3;}
| SIN {$$=-1;}
| CAR {$$=0;};

tipo_arreglo : LCOR NUM RCOR tipo_arreglo { 
    if($2.tipo == 1)
    {
        if($2.ival > 0)
        {
            $$ = insertarTipo(getTipoCima(ptt),crearTipo("array", getTamanio(getTipoCima(ptt),$4),$4,$2.ival,false,NULL));
        }
        else
        {
            yyerror("El tamaño del arreglo no es válido\n");
        }
    }
    else
    {
        yyerror("El tamaño del arreglo no es un entero\n");
    }
}
| {$$ = baseGlobal;}; 

lista_var : ID A {
    if(buscar(getSimboloCima(pts), $1) == -1)
    {
        insertar(getSimboloCima(pts),crearSimbolo($1, tipoGlobal, dirGlobal, "var"));
        dirGlobal = dirGlobal + getTamanio(getTipoCima(ptt),tipoGlobal);
    }
    else
    {
        yyerror("El identificador ya fue declarado\n"); 
    }
};

A : COMA ID A { 
    if(buscar(getSimboloCima(pts), $2) == -1)
    {
        insertar(getSimboloCima(pts),crearSimbolo($2, tipoGlobal, dirGlobal, "var"));
        dirGlobal = dirGlobal + getTamanio(getTipoCima(ptt),tipoGlobal);
    }
    else
    {
        yyerror("El identificador ya fue declarado\n"); 
    }
} 
|  {};

funciones : DEF tipo ID LPAR argumentos RPAR INICIO declaraciones sentencias FIN funciones {}
| {};

argumentos : lista_arg {}
| SIN {};

lista_arg : lista_arg COMA arg {}
| arg {};

arg : tipo_arg ID {};

tipo_arg : base param_arr {};

param_arr : LCOR RCOR param_arr {}
| {};

sentencias : sentencias sentencia {}
| {};

sentencia : SI e_bool ENTONCES sentencias FIN {}
| SI e_bool ENTONCES sentencias SINO sentencias FIN {}
| MIENTRAS e_bool HACER sentencias FIN {}
| HACER sentencias MIENTRAS e_bool PYC {}
| SEGUN LPAR variable RPAR HACER casos predeterminado FIN {}
| variable ASIG expresion PYC {
    char* resultado = (char*)malloc(sizeof(char)*10);
    reducir(resultado,$3.dir,$3.tipo,$1.tipo); 
    printf("%s = %s\n",$1.dir,resultado);
} 
| ESCRIBIR expresion PYC {}
| LEER variable PYC {}
| DEVOLVER PYC {}
| DEVOLVER expresion PYC {}
| TERMINAR PYC {}
| INICIO sentencias FIN {};

casos : CASO NUM DOSP sentencias casos {}
| CASO NUM DOSP sentencias {};

predeterminado : PRED DOSP sentencias {}
| {};

e_bool : e_bool O e_bool {}
| e_bool Y e_bool {}
| NO e_bool {}
| relacional {}
| VERDADERO {}
| FALSO {}

relacional : relacional SMT relacional {}
|relacional GRT relacional {} 
|relacional GREQ relacional {}
|relacional SMEQ relacional {}
|relacional DIF relacional {}
|relacional EQEQ relacional {}
| expresion {};

expresion : expresion SUM expresion {
    $$.tipo = max($1.tipo,$3.tipo);
    char* temporal = (char*)malloc(sizeof(char)*10);
    newTemp(temporal);
    char* temporal1 = (char*)malloc(sizeof(char)*10);
    char* temporal2 = (char*)malloc(sizeof(char)*10);
    ampliar(temporal1,$1.dir,$1.tipo,$3.tipo);
    ampliar(temporal2,$3.dir,$3.tipo,$1.tipo);
    printf("%s = %s + %s\n",temporal,temporal1,temporal2);
    strcpy($$.dir,temporal);
}
|expresion RES expresion{
    $$.tipo = max($1.tipo,$3.tipo);
    char* temporal = (char*)malloc(sizeof(char)*10);
    newTemp(temporal);
    char* temporal1 = (char*)malloc(sizeof(char)*10);
    char* temporal2 = (char*)malloc(sizeof(char)*10);
    ampliar(temporal1,$1.dir,$1.tipo,$3.tipo);
    ampliar(temporal2,$3.dir,$3.tipo,$1.tipo);
    printf("%s = %s - %s\n",temporal,temporal1,temporal2);
    strcpy($$.dir,temporal);
}
| expresion MUL expresion {
    $$.tipo = max($1.tipo,$3.tipo);
    char* temporal = (char*)malloc(sizeof(char)*10);
    newTemp(temporal);
    char* temporal1 = (char*)malloc(sizeof(char)*10);
    char* temporal2 = (char*)malloc(sizeof(char)*10);
    ampliar(temporal1,$1.dir,$1.tipo,$3.tipo);
    ampliar(temporal2,$3.dir,$3.tipo,$1.tipo);
    printf("%s = %s * %s\n",temporal,temporal1,temporal2);
    strcpy($$.dir,temporal);
}
| expresion DIV expresion{
    $$.tipo = max($1.tipo,$3.tipo);
    char* temporal = (char*)malloc(sizeof(char)*10);
    newTemp(temporal);
    char* temporal1 = (char*)malloc(sizeof(char)*10);
    char* temporal2 = (char*)malloc(sizeof(char)*10);
    ampliar(temporal1,$1.dir,$1.tipo,$3.tipo);
    ampliar(temporal2,$3.dir,$3.tipo,$1.tipo);
    printf("%s = %s / %s\n",temporal,temporal1,temporal2);
    strcpy($$.dir,temporal);
}
| expresion MOD expresion{
    $$.tipo = max($1.tipo,$3.tipo);
    char* temporal = (char*)malloc(sizeof(char)*10);
    newTemp(temporal);
    char* temporal1 = (char*)malloc(sizeof(char)*10);
    char* temporal2 = (char*)malloc(sizeof(char)*10);
    ampliar(temporal1,$1.dir,$1.tipo,$3.tipo);
    ampliar(temporal2,$3.dir,$3.tipo,$1.tipo);
    printf("%s = %s o/o %s\n",temporal,temporal1,temporal2);
    strcpy($$.dir,temporal);
}
| LPAR expresion RPAR {strcpy($$.dir,$2.dir);
    $$.tipo = $2.tipo;
}
| variable {strcpy($$.dir,$1.dir);
    $$.tipo = $1.tipo;
}
| NUM {sprintf($$.dir,"%d",$1.ival);
    $$.tipo = $1.tipo;

}
| CADENA {}
| CARACTER {};

variable : ID variable_comp {strcpy($$.dir,$1); $$.tipo = 1;};

variable_comp : dato_est_sim {}
| arreglo {}
| LPAR parametros RPAR {};

dato_est_sim : dato_est_sim PT ID {}
| {};

arreglo : LCOR expresion RCOR {}
| LCOR expresion RCOR arreglo {};

parametros : lista_param {}
| {};

lista_param : lista_param COMA expresion {}
| expresion {}; 
%%

void yyerror(char *s){
    printf("Error sintactico. %s\n",s);
}


void nuevaEtiqueta(char *dire){
    char L[32];
    sprintf(L, "L%d", temp2++);
    strcpy (dire,L);
}

int max(int a, int b)
{
    if(a < 3 && b < 3 || a==b)
    {
        if(a > b)
        {
            return a;
        }
        else
        {
            return b;
        }
    } 
    else
    {
        yyerror("Tipos incompatibles\n");
    }
}

int min(int a, int b)
{
    if(a < 3 && b < 3 || a==b)
    {
        if(a < b)
        {
            return a;
        }
        else
        {
            return b;
        }
    } 
    else
    {
        yyerror("Tipos incompatibles\n");
    }
}

void ampliar(char* res,char* dir,int a, int b)
{
    if(a != b)
    {
        int m = max(a,b);
        if(m == a)
        {
            strcpy(res,dir);
        }
        else
        {
            newTemp(res);
            switch(m)
            {
                case 1:
                    printf("%s = (ent)%s\n", res,dir);
                    break;
                case 2:
                    printf("%s = (real)%s\n", res,dir);
                    break;
                case 3:
                    printf("%s = (dreal)%s\n", res,dir);
                    break;
                default:
                    res = NULL; 
            }
        } 
    }
    else
    {
        strcpy(res,dir);
    }
}

void reducir(char* res,char* dir,int a, int b)
{
    if(a != b)
    {
        int m = min(a,b);
        if(m == a)
        {
            strcpy(res,dir);
        }
        else
        {
            newTemp(res);
            switch(m)
            {
                case 1:
                    printf("%s = (ent)%s\n", res,dir);
                    break;
                case 2:
                    printf("%s = (real)%s\n", res,dir);
                    break;
                case 0:
                    printf("%s = (car)%s\n", res,dir);
                    break;
                default:
                    res = NULL; 
            }
        } 
    }
    else
    {
        strcpy(res,dir);
    }
}
