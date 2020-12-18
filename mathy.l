/* 
 LEX ANALYZER FOR MATHY PROGRAMMING LANGUAGE
 AUTHOR: Bao Cao
 University of Regina - Department of Computer Science
*/

%{
  #include <iostream>
  using namespace std;
  #include <string.h>
  #include <stdio.h>
  #include "./mathy.hpp"
  extern int line;
  extern int stringNumber;
%}

%option noyywrap

%%

"#".*     {}

\n        {
            ++line;
            stringNumber = 0;
          }

\t        {}

" "       {}

"num"       {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_NUMBER;
					  }

"poly"      {
              yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_POLY;
            }

"frac"      {
              yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_FRACTION;
            }

"main"      {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_ID;
            }

"print"     {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
						  return TOKEN_PRINT;
					  }

"if"        {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_IF;
					  }

"else"      {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_ELSE;
					  }

"sin"       {
              yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_SIN;
            }

"tan"      {
              yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_TAN;
            }

"func"      {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
					    return TOKEN_FUNCTION;
					  }

"foreach"   {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_LOOP;
					  }

"+"         {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_PLUS;
					  }

"-"         {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_MINUS;
					  }

"/"         {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_DIV;
					  }

"*"         {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_MUL;
					  }

"//"        {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_FRAC;
					  } 

"^"         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_POWER;
					  }

"and"       {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_LOGIC_OPERATOR;
					  }

"or"        {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_LOGIC_OPERATOR;
					  }

"not"       {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_LOGIC_OPERATOR_NOT;
					  }

"<="        {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_RELATION_OPERATOR;
					  }

"<"         {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_RELATION_OPERATOR;
					  }

">"         {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_RELATION_OPERATOR;
					  }

"="         {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_ASSIGN;
					  }

">="        {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_RELATION_OPERATOR;
					  }

"=="        {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
					    return TOKEN_RELATION_OPERATOR;
					  }

"!="        {
					    yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_RELATION_OPERATOR;
					  }

"("         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_LEFTPAREN;
					  }

")"         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_RIGHTPAREN;
					  }

"{"         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_LCB;
					  }

"}"         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_RCB;
					  }

";"         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_SEMICOLON;
					  }

","         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_COMMA;
            }

".."        {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_UNTIL;
					  }

"["         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_LB;
					  }

"]"         {
						  yylval.string=strdup(yytext);
              stringNumber += yyleng;
              return TOKEN_RB;
					  }


-?[0-9]*              {
                        long mynumber = atol(yytext);
                        yylval.string = strdup(yytext);
                        stringNumber += yyleng;
                        return TOKEN_INTCONST;
                      }

[a-zA-Z_]+[0-9a-zA-Z_]* {
                          yylval.string = strdup(yytext);
                          stringNumber += yyleng;
                          return TOKEN_ID;
                        }

[0-9]+[0-9a-zA-Z|_]*    {
                            printf("Syntax Error - line %d : variable name cannot start with number\n",line);
                            exit(0);
                        }


-?[0-9]+"."[0-9]+   {
                      yylval.string = strdup(yytext);
                      stringNumber += yyleng;
                      return TOKEN_NUMCONST;
                    }

\"[ a-zA-Z0-9\'`~!@#$%^&\*()_\-=\+\]\[\{\},\.?]*(\\[ntvrfb\\"'a0])*\" {
                      yylval.string=strdup(yytext);
                      stringNumber += yyleng;
                      return TOKEN_STRINGCONST;
                    }
%%