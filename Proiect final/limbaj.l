%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%

"<="                                 {return LESS_EQ;}
">="                                 {return GREAT_EQ;}
"!="                                 {return NOT_EQ;}
"=="                                 {return EQ;}
"&"                                  {return AND;}
"||"                                 {return OR;}

"int"|"float"                        {yylval.str = strdup(yytext); return TIP;}
"char"                               {yylval.str = strdup(yytext); return CHAR;}
"const"                              {return CONST;}
"array"                              {return ARRAY;}
"eval"                              {return EVAL;}
"typeof"                            {return TYPEOF;}

"function"                           {return FCT;}
"end_function"                       {return EFCT;}

"if"                                 {return IF;}
"else"                               {return ELSEIF;}
"end_if"                             {return ENDIF;}

"while"                              {return WHILE;}
"end_while"                          {return ENDWHILE;}

"do"                                 {return DO;}

"for"                                {return FOR;}
"end_for"                            {return ENDFOR;}
"to"                                 {return TO;}
"begin_global"                       {return BGNGLO;}
"end_global"                         {return ENDGLO;}

"begin_fct"                          {return BGNFCT;}
"end_fct"                            {return ENDFCT;}

"begin_class"                       {return BGNCL;}
"end_class"                         {return ENDCL;}

"def_class"                          {return CLASS;}
"end_defclass"                       {return ENDCLASS;}

"main"                               {return MAIN;}
"end_main"                           {return ENDMAIN;}


[_a-zA-Z][_a-zA-Z0-9]*               {yylval.str = strdup(yytext); return ID;}
\"[ _a-zA-Z0-9=:]+\"                  {yylval.str = strdup(yytext); yylval.str++; yylval.str[strlen(yylval.str)-1] = 0; return STRING;}

[-]?[0-9]+[.]?[0-9]?[0-9]?           {yylval.intnr = atoi(yytext); return NR;}
[ \t] ;
\n                                   {yylineno++;}
.                                    {return yytext[0];}
