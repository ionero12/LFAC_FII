%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdlib.h>
#include"header.h"

extern FILE* yyin;
extern char* yytext;
extern int yylineno;


struct variabila_info table_of_variables[100];
struct functie_info table_of_functons[100];
int var_counter = 0;
int func_counter = 0;
char error_msg[100];

void print_error()
{
     printf("Eroare: %s\n", error_msg);
}

char *trim(char *content)
{
     while (isspace((unsigned char)*content))
          content++;
     char *finish;
     if (*content == 0)
          return 0;
     finish = content + strlen(content) - 1;
     while (finish > content && isspace((unsigned char)*finish))
          finish--;
     finish[1] = '\0';
     return content;
}

int check_id(char *nume)
{
     int i;
     for (i = 0; i < var_counter; i++)
          if (strcmp(table_of_variables[i].name, nume) == 0)
               return 1;
     return 0;
}

int check_if_vars_exist(char *nume)
{
     if(check_id(nume) == 0 )
     {
          sprintf(error_msg, "Linia %d: Variabila %s nu este declarata!",yylineno, nume);
          print_error();
          exit(0);
     }
}

int check_constant(char *nume)
{
     if (check_id(nume)==0)
     {
          sprintf(error_msg, "Linia %d: Variabila %s nu exista pentru a verifica daca e constanta sau nu.", yylineno, nume);
          print_error();
          exit(0);
     }
     int i;
     for (i = 0; i < var_counter; i++)
          if (strcmp(table_of_variables[i].name, nume) == 0)
               if (table_of_variables[i].if_const == 1)
                    return 1;
     return 0; 
}

char *get_id_type(char *nume)
{
     int i;
     for (i = 0; i < var_counter; i++)
          if (strcmp(table_of_variables[i].name, nume) == 0)
               return table_of_variables[i].type;
     return (char *)"no type";
}

int check_if_identifier_exists(char* str1, char* str2)
{
     strcpy(str1, get_id_type(str2));
     if( strcmp( trim(str1), "no type" ) == 0 )  
     { 
          sprintf(error_msg, "Linia %d: Eroare identificator %s inexistent.\n", yylineno, str2);
          print_error(); 
          exit(0); 
     }
     return 1;
}

int identifier_help_function(char * str1, char *str2)
{
     strcat(str1,","); 
     strcat(str1, get_id_type(str2)); 
     if( strstr( str1 , "no type" ) != NULL ) 
     { 
          sprintf(error_msg,"Linia %d: Eroare identificator %s inexistent!\n", yylineno, str2);
          print_error(); 
          exit(0); 
     }
}

int assign_value_if_null()
{
     table_of_variables[var_counter].val = 0;
     strcpy(table_of_variables[var_counter].str_val, "NULL");
     return 0;
}

int declarare_char(char *id, char *contents, int scope)
{
     if (check_id(id)!=0)
     {
          sprintf(error_msg, "Linia %d: Variabila %s a fost deja declarta anterior.", yylineno, id);
          print_error();
          exit(0);
     }
     strcpy(table_of_variables[var_counter].name, trim(id));
     table_of_variables[var_counter].scope = 1; 
     table_of_variables[var_counter].if_const = 0;
     if ((table_of_variables[var_counter].if_const == 1) && (strcmp(trim(contents), "empty") == 0))
     {
          sprintf(error_msg, "Linia %d: Constanta %s a fost declarata fara valoare.\n", yylineno, id);
          print_error();
          exit(0);
     }
     strcpy(table_of_variables[var_counter].type, "char");
     table_of_variables[var_counter].val = 1; 
     sprintf(table_of_variables[var_counter].str_val, "%s", contents);
     if (strcmp(trim(contents), "empty") == 0)
     {
          table_of_variables[var_counter].val = 0; 
     }
     var_counter++;
     return 0;
}

int declarare_global_integers(char *type_var, char *id, int check_const, int actual_value)
{
     if (check_id(id)!=0)
     {
          sprintf(error_msg, "Linia %d: Variabila %s a fost deja declarta anterior.",yylineno, id);
          print_error();
          exit(0);
     }
     if ((actual_value == 9999999))
     {
          sprintf(error_msg, "Linia %d: Constanta %s a fost declarata fara valoare.", yylineno, id);
          print_error();
          exit(0);
     }
     strcpy(table_of_variables[var_counter].name, trim(id));
     table_of_variables[var_counter].scope = 0; 
     table_of_variables[var_counter].if_const = check_const;
     if (strcmp(trim(type_var), "int") == 0)
     {
          strcpy(table_of_variables[var_counter].type, trim(type_var)); 
     }
     else
          if (strcmp(trim(type_var), "float") == 0)
          {
               strcpy(table_of_variables[var_counter].type, trim(type_var)); 
          }
          else
          {
               sprintf(error_msg, "Linia %d: Nu poti asigna un tip non-int intr-o \"declarare_int\" functie %s.", yylineno, id);
               print_error();
               exit(0);
          }
     table_of_variables[var_counter].val = actual_value;
     sprintf(table_of_variables[var_counter].str_val, "%d", actual_value);
     var_counter++;
     return 0;
}

int declarare_main(char *type_var, char *id, int check_const, int actual_value)
{
     if (check_id(id)==1)
     {
          sprintf(error_msg, "Variabila %s a fost deja declarta anterior. Linia %d", id, yylineno);
          print_error();
          exit(0);
     }
     if ((actual_value == 9999999))
     {
          sprintf(error_msg, "Constanta %s a fost declarata fara valoare la linia %d", id, yylineno);
          print_error();
          exit(0);
     }
     strcpy(table_of_variables[var_counter].name, trim(id));
     table_of_variables[var_counter].scope = 1;
     table_of_variables[var_counter].if_const = check_const;
     strcpy(table_of_variables[var_counter].type, trim(type_var));
     table_of_variables[var_counter].val = actual_value;
     sprintf(table_of_variables[var_counter].str_val, "%d", actual_value);
     if (actual_value == -9999999)
     {
          assign_value_if_null();
     }
     var_counter++;
     return 0;
}

int check_function(char *nume_functie, char *type, char *lista_argumente)
{
     for (int i = 0; i < func_counter; i++)
          if (strcmp(table_of_functons[i].func_name, nume_functie) == 0)
               if ((strcmp(table_of_functons[i].func_return_type, trim(type)) == 0) &&
                    (strcmp(table_of_functons[i].list_of_types, trim(lista_argumente)) == 0))
                         return 1;
     return 0;
}

int check_run_function(char *nume_functie, char *lista_argumente)
{
     int i;
     for (i = 0; i < func_counter; i++)
          if (strcmp(table_of_functons[i].func_name, nume_functie) == 0)
          {
               if ((strcmp(table_of_functons[i].list_of_types, lista_argumente) == 0))
                    return 0;
               sprintf(error_msg, "Linia %d: Functia %s are alti parametrii.\n", yylineno, nume_functie);
               print_error();
               exit(0);
          }
     sprintf(error_msg, "Linia %d: Functia %s nu exista.\n", yylineno, nume_functie);
     print_error();
     exit(0);
}

int declarare_functie(char *name, char *return_type, char *lista_param)
{
     if(check_function(name, return_type, lista_param))
     {
          sprintf(error_msg, "Linia %d: Functia %s deja exista.", yylineno, name);
          print_error();
          exit(0);
     }
     strcpy(table_of_functons[func_counter].func_name, name);
     strcpy(table_of_functons[func_counter].func_return_type, return_type);
     char *lista_tipuri;
     strcpy(lista_tipuri,lista_param);
     int count_int=0, count_float=0, count_char=0;
     char *t=strtok(lista_tipuri, " "); 
     while(t!=NULL)
     {
          if(strcmp(t,"int")==0)
               count_int++;
          if(strcmp(t,"float")==0)
               count_float++;
          if(strcmp(t,"char")==0)
               count_char++;
          t=strtok(NULL," ");
     }
     if(strcmp(return_type,"int")==0)
          if(count_char!=0 || count_float!=0)
          {     
               sprintf(error_msg, "Linia %d: Parametrii functiei difera de tipul functiei.", yylineno);
               print_error();
               exit(0);
          }
     if(strcmp(return_type,"float")==0)
          if(count_char!=0 || count_int!=0)
          {     
               sprintf(error_msg, "Linia %d: Parametrii functiei difera de tipul functiei.", yylineno);
               print_error();
               exit(0);
          }
     if(strcmp(return_type,"char")==0)
          if(count_int!=0 || count_float!=0)
          {     
               sprintf(error_msg, "Linia %d: Parametrii functiei difera de tipul functiei.", yylineno);
               print_error();
               exit(0);
          }
     strcpy(table_of_functons[func_counter].list_of_types,lista_param);
     func_counter++;
}

int get_id_value(char *nume)
{
     int i;
     for (i = 0; i < var_counter; i++)
          if (strcmp(table_of_variables[i].name, nume) == 0)
          {
               if( strcmp( table_of_variables[i].str_val , "array" ) == 0 )
               {
                    sprintf(error_msg, "Linia %d: Vector %s folosit incorect, specificati o pozitie.\n", yylineno ,nume);
                    print_error();
                    exit(0);
               }
               if( strcmp( table_of_variables[i].str_val , "NULL") != 0 )
                    return table_of_variables[i].val;
          }
     return 9999999;
}

int assign_expression(char *name, int value)
{
     if (check_constant(name))
     {
          sprintf(error_msg, "Linia %d: Imposibil de asignat o valoarea unei constante: %s.\n",yylineno, name);
          print_error();
          exit(0);
     }
     int i;
     for (i = 0; i < var_counter; i++)
          if (strcmp(table_of_variables[i].name, name) == 0)
          {
               if (table_of_variables[i].if_const != 1)
               {
                    sprintf(table_of_variables[i].str_val , "%d", value);
                    table_of_variables[i].val = value;
                    return 1;
               }
               return 0;
          }
     return 0;
}

char* return_type_function( char *nume_functie, char *lista_argumente )
{
     int i;
     for (i = 0; i < func_counter; i++)
          if (strcmp(table_of_functons[i].func_name, nume_functie) == 0)
               if ((strcmp(table_of_functons[i].list_of_types, lista_argumente) == 0))
                    return table_of_functons[i].func_return_type;
     sprintf(error_msg, "Functia %s nu exista. Linia %d", nume_functie, yylineno);
     print_error();
     exit(0);
}

int declarare_vector(char *tip, char *nume, int dimensiune_maxima, int scope)
{
     if (check_id(nume))
     {
          sprintf(error_msg, "Linia %d: O variabila cu acelasi nume %s a fost deja declarta anterior.",yylineno, nume);
          print_error();
          exit(0);
     }
     strcpy(table_of_variables[var_counter].name, trim(nume));
     table_of_variables[var_counter].has_elements = 0;
     table_of_variables[var_counter].array_size = dimensiune_maxima;
     if (strcmp(trim(tip), "int") == 0)
     {
          table_of_variables[var_counter].array = (int*)malloc(dimensiune_maxima * sizeof(int));
          int j;
          for (j = 0; j < dimensiune_maxima; j++)
               table_of_variables[var_counter].array[j] = 0;
          strcpy(table_of_variables[var_counter].str_val,"array");
     }
     else if (strcmp(trim(tip), "float") == 0)
     {
          sprintf(error_msg, "Linia %d: Imposibila crearea unui vector de %s, folositi int.\n", yylineno, tip);
          print_error();
          exit(0);
     }
     else if (strcmp(trim(tip), "char") == 0)
     {
          sprintf(error_msg, "Linia %d: Imposibila crearea unui vector de %s, folositi int.\n", yylineno, tip);
          print_error();
          exit(0);
     }
     strcpy(table_of_variables[var_counter].type, "int");
     table_of_variables[var_counter].scope = scope;
     table_of_variables[var_counter].if_const = 0;
     var_counter++;
}

int get_array_value( char* nume_array , int poz )
{
     int i;
     for (i = 0; i < var_counter; i++)
     {
          if (strcmp(table_of_variables[i].name, nume_array) == 0)
               if( table_of_variables[i].array_size > poz  )
               {
                    return table_of_variables[i].array[poz];
               }
               else
               {
                    sprintf(error_msg, "Linia %d: Pozitie inexistenta in array.\n", yylineno);
                    print_error();
                    exit(0);
               }
     }
     sprintf(error_msg, "Linia %d: Array inexistent.\n", yylineno);
     print_error();
     exit(0);
}

int assign_expression_to_array_el( char* nume_array , int poz , int value )
{
     if(check_id(nume_array)!=0)
          for( int i = 0 ; i < var_counter ; i++ )
               if( strcmp(table_of_variables[i].name, nume_array) == 0 )
               {    
                    if( poz < table_of_variables[i].array_size )
                    {
                         table_of_variables[i].array[poz] = value;
                         return 1;
                    }
                    sprintf(error_msg, "Pozitie introdusa la array inexistenta, linia %d", yylineno);
                    print_error();
                    exit(0);
               }
     sprintf(error_msg, "Linia %d: Array inexistent.\n", yylineno);
     print_error();
     exit(0);
}

struct AST* buildAST( char* nume , struct AST* left , struct AST* right, enum nodetype type )
{
     struct AST* newnode = (struct AST*)malloc(sizeof(struct AST));
     newnode->name = strdup(nume);
     newnode->left = left;
     newnode->right = right;
     newnode->node_type = type;
     return newnode;
} 

int evalAST( struct AST* tree )
{
     if( tree->left == NULL && tree->right == NULL ) // leaf
     {
          if( tree->node_type == 2 ) // id
          {
               int val = get_id_value( tree->name );

               char tip[10];
               bzero( tip , 10 );
               strcpy( tip , get_id_type( tree->name ) );

               if( strcmp( tip , "char" ) == 0 )
               {
                    return 0;
               }
               
               if( strcmp( tip, "float") == 0 )
               {
                    return 0;
               }

               if( val == 9999999 )
               {
                    sprintf(error_msg, "Variabila %s nu are valoare.", tree->name);
                    print_error();
                    exit(0);
               }
               else
               {
                    return val;
               }
          }
          else if( tree->node_type == 3 ) // nr
          {
               int val = atoi(tree->name);
               return val;
          }
          else 
          {
               return 0;
          }
     }
     else
     {
          int rezultat_stanga = evalAST( tree->left );
          int rezultat_dreapta = evalAST( tree->right );

          if( strcmp( tree->name , "+" ) == 0 )
               return rezultat_dreapta + rezultat_stanga;
          else 
               if( strcmp( tree->name , "-" ) == 0 ) 
                    return rezultat_stanga - rezultat_dreapta;
               else 
                    if( strcmp( tree->name , "*" ) == 0 ) 
                         return rezultat_stanga * rezultat_dreapta;
                    else 
                         if( strcmp( tree->name , "/" ) == 0 ) 
                         {
                              if( rezultat_dreapta != 0 ) 
                                   return rezultat_stanga - rezultat_dreapta;
                              else
                              {
                                   sprintf(error_msg, "NU se poate face impartire la 0!");
                                   print_error();
                                   exit(0);
                              }
                         }
     }
}

char *typeofff(char *nume)
{
     int i;
     for (i = 0; i < var_counter; i++)
          if (strcmp(table_of_variables[i].name, nume) == 0)
               return table_of_variables[i].type;
     return (char *)"no type";
}
%}


%union
{
     char* str;
     int intnr;
     struct AST* tree;
}

%token CONST ARRAY EVAL TYPEOF
%token FCT EFCT CLASS ENDCLASS 
%token IF ELSEIF ENDIF WHILE ENDWHILE FOR ENDFOR TO DO
%token BGNGLO ENDGLO BGNFCT ENDFCT BGNCL ENDCL MAIN ENDMAIN 
%token LESS_EQ GREAT_EQ NOT_EQ EQ
%token AND OR

%token <str> ID TIP STRING CHAR
%token <intnr> NR
%type  <str> lista_tip_parametrii lista_tip_parametrii_clasa parametrii parametrii_clasa lista_apel
%type  <tree> expresie

%left OR
%left AND
%left NOT_EQ EQ
%left LESS_EQ GREAT_EQ '<' '>'
%left '-' '+'
%left '/' '*'

%start progr
%%
progr: bloc1 bloc2 bloc3 bloc4 {printf("\nProgram corect din punct de vedere sintactic!\n\n");}
     ;

bloc1 : BGNGLO declaratii_globale ENDGLO
     | 
     ;

declaratii_globale 
     : declaratie 
     | declaratii_globale declaratie 
     ;

declaratie 
     : TIP ID ';'                        { declarare_global_integers( $1, $2 , 0 , 0 );}
     | TIP ID '=' expresie ';'           { int rez = evalAST($4); declarare_global_integers( $1, $2 , 0 , rez );}
     | CONST TIP ID '=' expresie ';'     { int rez = evalAST($5); declarare_global_integers( $2, $3 , 1 , rez ); }
     | CONST TIP ID ';'                  { declarare_global_integers( $2, $3 , 1 , 9999999 );}
     | CHAR ID ';'                       { declarare_char( $2 , "empty", 0);}
     | CHAR ID '=' STRING ';'            { declarare_char( $2 , $4, 0);}        
     | ARRAY TIP ID '[' NR ']' ';'       { declarare_vector( $2 , $3 , $5 , 0 );}
     ;

bloc2 : BGNFCT declarari_bloc_2 ENDFCT
     | 
     ;

declarari_bloc_2
     : declarari_bloc_2 declaratie_functie
     | declaratie_functie
     ;

declaratie_functie : FCT TIP ID lista_tip_parametrii EFCT        { declarare_functie( $3, $2, $4) ;}  
                    | FCT CHAR ID lista_tip_parametrii EFCT      { declarare_functie( $3, $2, $4) ;}
                    ;

lista_tip_parametrii
     : '('  ')'                     { $$ = malloc(5); strcpy( $$ , "null"); }
     | '(' parametrii ')'           { $$ = malloc(100); strcpy( $$ , $2); }
     ;

parametrii
     : TIP ID                           {$$=$1; strcat($$, " "); strcat($$, $2);}
     | parametrii ',' TIP ID          {strcat( $$ , ", " ); strcat( $$ , $3 ); strcat($$, " "); strcat($$, $4);}
     | CHAR ID                            {$$=$1; strcat($$, " "); strcat($$, $2);}
     | parametrii ',' CHAR ID          {strcat( $$ , ", " ); strcat( $$ , $3 ); strcat($$, " "); strcat($$, $4);}
     ;


bloc3: BGNCL declarari_bloc3 ENDCL
    |
    ;

declarari_bloc3
    : declarari_bloc3 declarare_class
    | declarare_class
    ;

declarare_class : CLASS ID bloc_class ENDCLASS

bloc_class     : bloc_class declaratie_metoda
               | declaratie_metoda
               | bloc_class declaratie_class
               | declaratie_class
               ;

declaratie_class
     : TIP ID ';'
     | TIP ID '=' expresie ';'
     | CONST TIP ID '=' expresie ';'
     | CHAR ID ';'
     | CHAR ID '=' STRING ';'
     | ARRAY TIP ID '[' NR ']' ';'
     ;

declaratie_metoda   : FCT TIP ID lista_tip_parametrii_clasa EFCT 
                    | FCT CHAR ID lista_tip_parametrii_clasa EFCT
                    ;

lista_tip_parametrii_clasa
     : '('  ')'                     { $$ = malloc(5); strcpy( $$ , "null"); }
     | '(' parametrii_clasa ')'           { $$ = malloc(50); strcpy( $$ , $2); }
     ;

parametrii_clasa
     : TIP ID                           {$$=$1; strcat($$, " "); strcat($$, $2);}
     | parametrii_clasa ',' TIP ID          {strcat( $$ , ", " ); strcat( $$ , $3 ); strcat($$, " "); strcat($$, $4);}
     | CHAR ID                            {$$=$1; strcat($$, " "); strcat($$, $2);}
     | parametrii_clasa ',' CHAR ID          {strcat( $$ , ", " ); strcat( $$ , $3 ); strcat($$, " "); strcat($$, $4);}
     ;

bloc4 : MAIN list ENDMAIN  
     ;
     

list : statement 
     | list statement 
     | apel_instr_control
     | list apel_instr_control
     | declarari_main
     | list declarari_main
     | eval_function
     | typeof_function
     | list eval_function
     ;

eval_function
     : EVAL '(' expresie ')' ';'      { printf("%d\n", evalAST($3) ); }
     ;

typeof_function
     : TYPEOF '(' ID ')' ';'      { printf("%s\n", typeofff($3) ); }
     ;

declarari_main
     : TIP ID ';'                       { declarare_main($1 , $2 , 0 , -9999999);}
     | TIP ID '=' expresie ';'          { int rez = evalAST($4); declarare_main($1 , $2 , 0 , rez);}
     | CONST TIP ID '=' expresie ';'    { int rez = evalAST($5); declarare_main($2 , $3 , 1 , rez);} 
     | CONST TIP ID ';'                 { declarare_main($2 , $3 , 1 , 9999999); }     
     | CHAR ID ';'                      { declarare_char( $2 , "empty", 1); }
     | CHAR ID '=' STRING ';'           { declarare_char( $2 , $4, 1 ); }         
     | ARRAY TIP ID '[' NR ']' ';'      { declarare_vector( $2 , $3 , $5 , 1 ); }    
     ;


/* instructiune */
statement
     : ID '(' lista_apel ')' ';'                       { check_run_function( $1, $3 ) ; }
     | ID '(' ')' ';'                                  { check_run_function( $1, "null" ) ; }
     | ID '=' expresie ';'                             { 
                                                            char temp[100]; bzero(temp, 100); strcpy(temp,$1);
                                                            if( strcmp("char",get_id_type(temp)) == 0 ) 
                                                            {  
                                                                 sprintf(error_msg, "NU se pot face asignari la variabile de tip char, linia %d.", yylineno);
                                                                 print_error();
                                                                 exit(0);
                                                            }
                                                            int rez = evalAST( $3 );
                                                            if( assign_expression( $1 , rez)  != 1 ) exit(0); 
                                                       }
     | ID '[' NR ']' '=' expresie ';'                  { int rez = evalAST( $6 ); assign_expression_to_array_el( $1 , $3 , rez ); }
     ;

apel_instr_control
     : IF '(' expresie ')' list ENDIF
     | IF '(' expresie ')' list ELSEIF list ENDIF
     | WHILE '(' expresie ')' list ENDWHILE
     | DO list ENDWHILE '(' expresie ')'
     | FOR ID '=' NR TO ID DO list ENDFOR                { 
                                                            check_if_vars_exist($2);
                                                            check_if_vars_exist($6);
                                                       }

     | FOR ID '=' NR TO NR DO list ENDFOR                { 
                                                            check_if_vars_exist($2);
                                                       }
     | FOR ID '=' ID TO ID DO list ENDFOR                { 
                                                            check_if_vars_exist($2);
                                                            check_if_vars_exist($4);
                                                            check_if_vars_exist($6);
                                                       }
     | FOR ID '=' ID TO NR DO list ENDFOR                { 
                                                            check_if_vars_exist($2);
                                                            check_if_vars_exist($4);
                                                       }
     ;

expresie :  expresie '+' expresie                      { $$ = buildAST( "+" , $1 , $3 , OP ); }
          | expresie '-' expresie                      { $$ = buildAST( "-" , $1 , $3 , OP ); }
          | expresie '*' expresie                      { $$ = buildAST( "*" , $1 , $3 , OP ); }
          | expresie '/' expresie                      { $$ = buildAST( "/" , $1 , $3 , OP ); }
          | expresie  '>'  expresie                    { 
                                                            int rez1 = evalAST($1);
                                                            int rez2 = evalAST($3); 
                                                            int calcul = ( rez1 > rez2 );
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , calcul );
                                                            $$ = buildAST( nume , NULL , NULL, OTHERS );
                                                       }
          | expresie  '<' expresie                     { 
                                                            int rez1 = evalAST($1);
                                                            int rez2 = evalAST($3); 
                                                            int calcul = ( rez1 < rez2 );
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , calcul );
                                                            $$ = buildAST( nume , NULL , NULL, OTHERS );
                                                       }
          |  expresie LESS_EQ  expresie                    { 
                                                            int rez1 = evalAST($1);
                                                            int rez2 = evalAST($3); 
                                                            int calcul = ( rez1 <= rez2 );
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , calcul );
                                                            $$ = buildAST( nume , NULL , NULL, OTHERS );
                                                       }
          |  expresie GREAT_EQ  expresie                    { 
                                                            int rez1 = evalAST($1);
                                                            int rez2 = evalAST($3); 
                                                            int calcul = ( rez1 >= rez2 );
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , calcul );
                                                            $$ = buildAST( nume , NULL , NULL, OTHERS );
                                                       }
          |  expresie  NOT_EQ expresie                    { 
                                                            int rez1 = evalAST($1);
                                                            int rez2 = evalAST($3); 
                                                            int calcul = ( rez1 != rez2 );
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , calcul );
                                                            $$ = buildAST( nume , NULL , NULL, OTHERS );
                                                       }
          |  expresie  EQ  expresie                    { 
                                                            int rez1 = evalAST($1);
                                                            int rez2 = evalAST($3); 
                                                            int calcul = ( rez1 == rez2 );
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , calcul );
                                                            $$ = buildAST( nume , NULL , NULL, OTHERS );
                                                       }
          |  expresie  AND  expresie                   { 
                                                            int rez1 = evalAST($1);
                                                            int rez2 = evalAST($3); 
                                                            int calcul = ( rez1 & rez2 );
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , calcul );
                                                            $$ = buildAST( nume , NULL , NULL, OTHERS );
                                                       }
          |  expresie OR expresie                      { 
                                                            int rez1 = evalAST($1);
                                                            int rez2 = evalAST($3); 
                                                            int calcul = ( rez1 || rez2 );
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , calcul );
                                                            $$ = buildAST( nume , NULL , NULL, OTHERS );
                                                       }
          | '(' expresie ')'                           { $$ = $2; }
          | ID                                         { $$ = buildAST( $1 , NULL , NULL , IDENTIF ); }
          | NR                                         { 
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , $1 );
                                                            $$ = buildAST( nume , NULL , NULL , NUMAR ); 
                                                       }
          | ID '[' NR ']'                              { 
                                                            int value = get_array_value($1,$3); 
                                                            char nume[100];
                                                            bzero(nume, 100);
                                                            sprintf( nume , "%d" , value );
                                                            $$ = buildAST( nume , NULL , NULL , NUMAR );
                                                       }
          | ID '(' ')'                                 { check_run_function( $1, "null" ) ; $$ = buildAST( $1 , NULL , NULL , OTHERS ); }
          | ID '(' lista_apel ')'                      { check_run_function( $1, $3 ) ;     $$ = buildAST( $1 , NULL , NULL , OTHERS ); }
          ;

lista_apel
     : NR                               { $$ = malloc(50); strcpy($$,"int");  }
     | lista_apel ',' NR                { strcat($$,",int"); }
     | ID                               { check_if_identifier_exists($$, $1);}
     | lista_apel ',' ID                { identifier_help_function($$, $1); }
     ;

%%

int yyerror(char * s)
{
     printf("eroare: %s la linia:%d\n\n",s,yylineno);
     exit(0);
}

void print_variables()
{
     FILE *f;
     f = fopen("symbol_table.txt", "w");
     if (f == NULL)
     {
          printf("Unable to create file.\n");
          exit(EXIT_FAILURE);
     }
     for (int i = 0; i < var_counter; i++)
     {
          char buffer[500];
          bzero(buffer, 500);
          if( strcmp(table_of_variables[i].str_val,"array") == 0 )
          {
               sprintf(buffer , "Nume vector: %s, nr elemente: %d, scope: %d, cu elementele:\n" , table_of_variables[i].name, table_of_variables[i].array_size,  table_of_variables[i].scope);
               fputs(buffer, f);
               int j;
               for(j = 0 ; j < table_of_variables[i].array_size ; j++)
               {
                    bzero(buffer, 500);
                    sprintf( buffer , "\t %s[%d] = %d ", table_of_variables[i].name , j , table_of_variables[i].array[j] );
                    fputs(buffer, f);
               }
          }
          else
          {
               sprintf(buffer, "Nume: %s, tip: %s, constanta: %d, valoare: %s, scope: %d\n\n",
                         table_of_variables[i].name, table_of_variables[i].type,
                         table_of_variables[i].if_const, table_of_variables[i].str_val, table_of_variables[i].scope);
               fputs(buffer, f);
          }
     }
     fclose(f);
}

void print_functions()
{
     FILE *f;
     f = fopen("symbol_table_functions.txt", "w");
     if (f == NULL)
     {
          printf("Unable to create file.\n");
          exit(EXIT_FAILURE);
     }
     int i;
     for (i = 0; i < func_counter; i++)
     {
          char buffer[500];
          bzero(buffer, 500);
          sprintf(buffer, "Nume: %s, tip: %s, parametrii: %s\n\n",
                    table_of_functons[i].func_name, table_of_functons[i].func_return_type,
                    table_of_functons[i].list_of_types);
          fputs(buffer, f);
     }
     fclose(f);
}

void print_all()
{
     print_variables();
     print_functions();
}

int main(int argc, char** argv)
{
     yyin=fopen(argv[1],"r");
     yyparse();
     print_all();
} 
