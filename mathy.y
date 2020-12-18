%{
  #include <iostream>
  #include <sstream>

  extern int yylex();

  extern FILE* yyin;

  #include <stdio.h>
  #include <string.h>
  #include <map>
  #include <fstream>
  #include <string>

  using namespace std;

  int line = 1;
  int stringNumber = 0;
  int count1 = 0;
  int countForS =0;
  int countFort =0;
  int countFora =0;
  int countForv =0;
  int countForLoop = 1;
  int countForIF = 1;
  int countForEndIF = 1;

  map<string, string> table;
  map<string, string> env;
  map<string, string> variables;

  char typecheck[100];

  string output = "\n";

  /*......................................
  STRUCTURE OF THE ABSTRACT SYNTAX TREE NODE
  ........................................*/
  typedef struct tnode {
    char value[100];
	char value2[100];
	char value3[100];
	char value4[100];
    char token[100];
	char token2[100];
	char token3[100];
	char token4[100];
	bool displayFlag;
	bool lastchild;
	struct tnode *child;
    struct tnode *ptr;
  } tnode;

	tnode* CreateTnode();
	tnode* AppendNode(tnode* push, tnode* t);
	tnode* AppendNode(string value, string token, tnode* t);

    // FUNCTIONS FOR ERROR REPORT
    void yyerror(const char* message);
	void yyerror(int code);
	void yyerror(int code, string variable);
    bool errorFlag = false; // If there is error, no tree printing or code generating

	void printtree(tnode *s);

    int gcd(int a, int b);

	tnode *START_NODE = NULL;

%}

%union {
    int intVal;
	char chVal;
    char* string;
    float numVal;
	struct tnode *node;
}

/* --------------------------- DATA TYPE -------------------------*/
%token <string> TOKEN_NUMBER TOKEN_POLY TOKEN_FRACTION;
/* --------------------------- RESERVE KEYWORDS ------------------*/
%token <string> TOKEN_ID TOKEN_PRINT TOKEN_IF TOKEN_ELSE;
%token <string> TOKEN_SIN TOKEN_TAN TOKEN_FUNCTION TOKEN_LOOP;
/* --------------------------- MATHEMATICAL OPERATORS ------------*/
%token <string> TOKEN_PLUS TOKEN_MINUS TOKEN_DIV TOKEN_MUL;
%token <string> TOKEN_FRAC TOKEN_POWER;
/* --------------------------- LOGICAL OPERATORS -----------------*/
%token <string> TOKEN_LOGIC_OPERATOR TOKEN_LOGIC_OPERATOR_NOT;
/* --------------------------- RELATIONAL OPERATORS --------------*/
%token <string> TOKEN_RELATION_OPERATOR TOKEN_ASSIGN;
/* --------------------------- MISC TOKENS -----------------------*/
%token <string> TOKEN_LEFTPAREN TOKEN_RIGHTPAREN TOKEN_LCB TOKEN_RCB;
%token <string> TOKEN_SEMICOLON TOKEN_COMMA TOKEN_UNTIL TOKEN_LB TOKEN_RB;
%token <string> TOKEN_INTCONST TOKEN_NUMCONST TOKEN_STRINGCONST;

/*---------------------------- NODES IN LANGUAGE GRAMMAR -------------*/
%type <node> PROGRAM
%type <node> STMTS  STMT LOOP  CONDITION PRINTFUNC;
%type <node> TYPE EXP ELSECON STMT_DECLARE;
%type <node> IDS STMT_ASSIGN;

%left TOKEN_RELATION_OPERATOR
%right TOKEN_ASSIGN
%left TOKEN_LOGIC_OPERATOR
%right TOKEN_LOGIC_OPERATOR_NOT
%left TOKEN_PLUS TOKEN_MINUS
%left TOKEN_MUL TOKEN_DIV 
%left TOKEN_POWER TOKEN_FRAC
%left TOKEN_RIGHTPAREN TOKEN_RB


%%
/* --------------- PROGRAM START: func main() { stmts } ------------------ */
PROGRAM:        TOKEN_FUNCTION TOKEN_ID TOKEN_LEFTPAREN TOKEN_RIGHTPAREN TOKEN_LCB STMTS TOKEN_RCB 
                {
                    if (strcmp($2, "main") != 0) {
                        yyerror(2);
                    } 
                    else {
                        START_NODE = CreateTnode();
                        strcpy(START_NODE->token, "PROGRAM");
                        START_NODE = AppendNode($1, "TOKEN_FUNCTION", START_NODE);
                        START_NODE = AppendNode($2, "TOKEN_ID", START_NODE);
                        START_NODE = AppendNode($3, "TOKEN_LEFTPAREN", START_NODE);
                        START_NODE = AppendNode($4, "TOKEN_RIGHTPAREN", START_NODE);
                        START_NODE = AppendNode($5, "TOKEN_LCB", START_NODE);
                        START_NODE = AppendNode($6, START_NODE);
                        START_NODE = AppendNode($7, "TOKEN_RCB", START_NODE);
                     
                    }
                };

/*------------------------ BODY OF MAIN FUNCTION: contain a list of statements ----------------*/
STMTS :		    STMT TOKEN_SEMICOLON STMTS
                {
					tnode *a = CreateTnode();
                    strcpy(a->token, "STMTS");
                    a = AppendNode($1, a);
                    a = AppendNode($2, "TOKEN_SEMICOLON", a);
                    a = AppendNode($3, a);
                    $$ = a;
                }
                | CONDITION STMTS
                {
					tnode *b = CreateTnode();
                    strcpy(b->token, "STMTS");
                    b = AppendNode($1, b);
                    b = AppendNode($2, b);
                    $$ = b;
                }
                | LOOP STMTS
                {
					tnode *c = CreateTnode();
                    strcpy(c->token, "STMTS");
                    c = AppendNode($1, c);
                    c = AppendNode($2, c);
                    $$ = c;
                }
                |
                { 
                    tnode *d = CreateTnode();
                    strcpy(d->token, "STMTS");
					d->displayFlag = 0;
                    $$ = d;
                };
/*--------------------------- SINGLE STATEMENTS ---------------------*/
STMT:           STMT_DECLARE
                {
					tnode *a = CreateTnode();
                    strcpy(a->token, "STMT");
                    a = AppendNode($1, a);
                    $$ = a;
                }
                | STMT_ASSIGN
                {
					tnode *b = CreateTnode();
                    strcpy(b->token, "STMT");
                    b = AppendNode($1, b);
                    $$ = b;
                }
                | EXP
                {
					tnode *c = CreateTnode();
                    strcpy(c->token, "STMT");
                    c = AppendNode($1, c);
                    $$ = c;
                }
                | PRINTFUNC
                {
					tnode *d = CreateTnode();
                    strcpy(d->token, "STMT");
                    d = AppendNode($1, d);
                    $$ = d;
                }
                | 
                {
					tnode *e = CreateTnode();
                    strcpy(e->token, "STMT");
					e->displayFlag = 0;
                    $$ = e;
                };
/*----------------- SYNTAX FOR PRINT FUNCTION ------------------*/
PRINTFUNC :		TOKEN_PRINT TOKEN_LEFTPAREN EXP TOKEN_RIGHTPAREN
                {
					tnode *a = CreateTnode();
                    strcpy(a->token, "PRINTFUNC");
                    a = AppendNode($1, "TOKEN_PRFUNC", a);
                    a = AppendNode($2, "TOKEN_LEFTPAREN", a);
                    a = AppendNode($3, a);
                    a = AppendNode($4, "TOKEN_RIGHTPAREN", a);
                    $$ = a;

                    // SIMPLY DISPLAY ALL VALUES OF EXP
					cout << $3->value << " " << $3->value2 << " " << $3->value3 << " "  << $3->value4 << endl;

                };

/*---------------------------- SYNTAX FOR EXPRESSIONS ------------------*/
                /*............Relation operations..........*/
EXP:		    EXP TOKEN_RELATION_OPERATOR EXP
                {
                    tnode *a = CreateTnode();
                    strcpy(a->token, "EXP");
                    a = AppendNode($1, a);
                    a = AppendNode($2, "TOKEN_RELATION_OPERATOR", a);
                    a = AppendNode($3, a);
                    if(strcmp($1->token2, $3->token2) != 0)
                        yyerror(1);

                    strcpy(a->token2, $1->token2);
                    $$ = a;
                }
                /*.............Addition Operation.........*/
                | EXP TOKEN_PLUS EXP 
                {
					tnode *d = CreateTnode();
                    strcpy(d->token, "EXP");
                    d = AppendNode($1, d);
                    d = AppendNode($2, "TOKEN_PLUS",d);
                    d = AppendNode($3, d);
                    if(strcmp($1->token2, $3->token2) != 0)
                      yyerror(4);

                    strcpy(d->token2, $1->token2);
                    $$ = d;

					if (strcmp($1->token2, "num") == 0)
						sprintf($$->value2,"%f", atof($1->value2) + atof($3->value2));
					else if (strcmp($1->token2, "frac") == 0) {
                        int a1 = atoi($1->value2);
                        int b1 = atoi($1->value4);

                        int a2 = atoi($3->value2);
                        int b2 = atoi($3->value4);

                        int numerator = a1 * b2 + a2 * b1;
                        int denominator = b1 * b2;

                        int x = gcd(numerator, denominator);

                        string numS = to_string(numerator / x);
                        string denS = to_string(denominator / x);

                        string result = numS + " // " + denS;

                        sprintf($$->value2, "%s", result.c_str());
                    }
                    else {
                        yyerror("expression is not supported by + operator.");
                    }

					countFort++;
                }
                /*............Substraction Operation.......*/
                | EXP TOKEN_MINUS EXP
                {
					tnode *b = CreateTnode();
                    strcpy(b->token, "EXP");
                    b = AppendNode($1, b);
                    b = AppendNode($2, "TOKEN_MINUS", b);
                    b = AppendNode($3, b);
                    if(strcmp($1->token2, $3->token2) != 0)
                      yyerror(4);

                    strcpy(b->token2, $1->token2);
                    $$ = b;

                    if (strcmp($1->token2, "num") == 0)
						sprintf($$->value2,"%f", atof($1->value2) - atof($3->value2));
					else if (strcmp($1->token2, "frac") == 0) {
                        int a1 = atoi($1->value2);
                        int b1 = atoi($1->value4);

                        int a2 = atoi($3->value2);
                        int b2 = atoi($3->value4);

                        int numerator = a1 * b2 - a2 * b1;
                        int denominator = b1 * b2;

                        int x = gcd(numerator, denominator);

                        string numS = to_string(numerator / x);
                        string denS = to_string(denominator / x);

                        string result = numS + " // " + denS;

                        sprintf($$->value2,"%s", result.c_str());
                    }
                    else {
                        yyerror("expression is not supported by - operator.");
                    }

					countFort++;
                }
                /*..............Division Operation........*/
                | EXP TOKEN_DIV EXP
                {
					tnode *c = CreateTnode();
                    strcpy(c->token, "EXP");
                    c = AppendNode($1, c);
                    c = AppendNode($2, "TOKEN_DIV", c);
                    c = AppendNode($3, c);
                    if(strcmp($1->token2, $3->token2) != 0)
                      yyerror(4);

                    strcpy(c->token2, $1->token2);
                    $$ = c;

					if (strcmp($1->token2,"num") == 0)
						sprintf($$->value2,"%f", atof($1->value2) / atof($3->value2));
					else if (strcmp($1->token2, "frac") == 0) {
                        int a1 = atoi($1->value2);
                        int b1 = atoi($1->value4);

                        int a2 = atoi($3->value2);
                        int b2 = atoi($3->value4);

                        int numerator = a1 * b2;
                        int denominator = b1 * a2;

                        int x = gcd(numerator, denominator);

                        string numS = to_string(numerator / x);
                        string denS = to_string(denominator / x);

                        string result = numS + " // " + denS;

                        sprintf($$->value2,"%s", result.c_str());
                    }
                    else {
                        yyerror("expression is not supported by / operator.");
                    }

					countFort++;
                }
                /*.............Multiplication Operation.........*/
                | EXP TOKEN_MUL EXP 
                {
					tnode *e = CreateTnode();
                    strcpy(e->token,"EXP");
                    e = AppendNode($1, e);
                    e = AppendNode($2, "TOKEN_MUL", e);
                    e = AppendNode($3, e);
                    if(strcmp($1->token2, $3->token2) != 0)
                      yyerror(4);

                    strcpy(e->token2, $1->token2);
                    $$ = e;

					if (strcmp($1->token2,"num") == 0)
						sprintf($$->value2,"%f", atof($1->value2) * atof($3->value2));
					else if (strcmp($1->token2, "frac") == 0) {
                        int a1 = atoi($1->value2);
                        int b1 = atoi($1->value3);

                        int a2 = atoi($3->value2);
                        int b2 = atoi($3->value3);

                        int numerator = a1 * a2;
                        int denominator = b1 * b2;

                        int x = gcd(numerator, denominator);

                        string numS = to_string(numerator / x);
                        string denS = to_string(denominator / x);

                        string result = numS + " // " + denS;

                        sprintf($$->value2, "%s", result.c_str());
                    }
                    else {
                        yyerror("expression is not supported by * operator.");
                    }

					countFort++;
                }
                /*.............Power Operation.........*/
                | EXP TOKEN_POWER TOKEN_INTCONST
                {
					tnode *f = CreateTnode();
                    strcpy(f->token, "EXP");

                    f = AppendNode($1, f);
                    f = AppendNode($2, "TOKEN_POWER", f);
                    f = AppendNode($3, "TOKEN_INTCONST", f);

                    if(strcmp($1->token2, "num") != 0)
					  yyerror("value on the left must be a number.");

                    strcpy(f->token2, $1->token2);

                    $$ = f;

                    float base = atof($1->value2);
                    int power = atoi($1->value2);
                    float result = 1;

                    for (int i = 0; i < power; i++)
                        result *= base;

                    sprintf($$->value2, "%f", result);
                }
                /*.............Logical Operations....... */
                | EXP TOKEN_LOGIC_OPERATOR EXP
                {
					tnode *g = CreateTnode();
                    strcpy(g->token, "EXP");
                    g = AppendNode($1, g);
                    g = AppendNode($2, "TOKEN_LOGIC_OPERATOR", g);
                    g = AppendNode($3, g);
                    if(strcmp($1->token2, $3->token2) != 0)
					  yyerror(3);

                    strcpy(g->token2, $1->token2);
                    $$ = g;
                }

                | TOKEN_LOGIC_OPERATOR_NOT EXP
                {
					tnode *h = CreateTnode();
                    strcpy(h->token, "EXP");
                    h = AppendNode($1, "TOKEN_LOGIC_OPERATOR_NOT", h);
                    h = AppendNode($2, h);
                    if(strcmp($2->token2, "poly") == 0)
					    yyerror("cannot use not operator for poly type");
                    else if (strcmp($2->token2, "frac") == 0)
                        yyerror("cannot use not operator for fraction");

                    strcpy(h->token2, $2->token2);
                    $$ = h;
                }
                /*...............( expressions )................*/
                | TOKEN_LEFTPAREN EXP TOKEN_RIGHTPAREN
                {
					tnode *i = CreateTnode();
                    strcpy(i->token, "EXP");
                    i = AppendNode($1, "TOKEN_LEFTPAREN", i);
                    i = AppendNode($2, i);
                    i = AppendNode($3, "TOKEN_RIGHTPAREN", i);
                    strcpy(i->token2, $2->token2);
                    $$ = i;
                }
                /*............... variable ................*/
                | TOKEN_ID
                {
					tnode *j = CreateTnode();
                    strcpy(j->token, "EXP");
                    j = AppendNode($1, "TOKEN_ID", j);
                    if(table[$1] == "")
					  yyerror(2, $1);
                    else
                      strcpy(j->token2, table[$1].c_str());

                    $$ = j;
					strcpy($$->value2, env[$1].c_str());
					strcpy($$->token3, $1);
                }
                /*............... number ....................*/
                | TOKEN_NUMCONST
                { 
                    tnode *r = CreateTnode();
                    strcpy(r->token, "EXP");
                    r = AppendNode($1, "TOKEN_NUMCONST", r);
                    strcpy(r->token2, "num");
                    $$ = r;
					strcpy($$->value2, $1);
                }
                /*............... Fraction Expression ........*/
                | TOKEN_INTCONST TOKEN_FRAC TOKEN_INTCONST
                {
					tnode *k = CreateTnode();
                    strcpy(k->token, "EXP");
                    k = AppendNode($1, "TOKEN_INTCONST", k);
                    k = AppendNode($2, "TOKEN_FRAC", k);
                    k = AppendNode($3, "TOKEN_INTCONST", k);
                    
                    strcpy(k->token2, "frac");

                    $$ = k;
                    
                    strcpy($$->value2, $1);
                    strcpy($$->value3, $2);
                    strcpy($$->value4, $3);
                
                    
                    //sprintf($$->value2,"%s", result);
                }
                /*...............sin cos tan................*/
                | TOKEN_SIN EXP
                {
					tnode *l = CreateTnode();
                    strcpy(l->token, "EXP");
                    l = AppendNode($1, "TOKEN_SIN", l);
                    l = AppendNode($2, l);
                    
                    if(strcmp($2->token2, "num") != 0)
					  yyerror("expression in sine must be a number.");

                    strcpy(l->token2, "num");
                    $$ = l;

                    float temp = atof($2->value2);
                    float sine_temp = temp - temp * temp * temp / 6 + temp * temp * temp * temp * temp / 120 ;
                    string result = to_string(sine_temp);

                    strcpy($$->value2, result.c_str());

                }
                | TOKEN_TAN EXP
                {
					tnode *m = CreateTnode();
                    strcpy(m->token, "EXP");
                    m = AppendNode($1, "TOKEN_TAN", m);
                    m = AppendNode($2, m);

                    if(strcmp($2->token2, "num") != 0)
					  yyerror("expression in tan must be a number.");

                    strcpy(m->token2, "num");
                    $$ = m;
                }
                /*...............polynomial expression................*/
                | TOKEN_NUMBER TOKEN_COMMA TOKEN_INTCONST
                {
                    tnode *n = CreateTnode();
                    strcpy(n->token, "EXP");
                    n = AppendNode($1, "TOKEN_NUMBER", n);
                    n = AppendNode($2, "TOKEN_COMMA", n);
                    n = AppendNode($3, "TOKEN_INTCONST", n);
                    strcpy(n->token2, "poly");
                    $$ = n;
                }
                /*.............. String ..................*/
                | TOKEN_STRINGCONST
                {
                    tnode *o = CreateTnode();
                    strcpy(o->token, "EXP");
                    o = AppendNode($1, "TOKEN_STRINGCONST", o);
                    strcpy(o->token2, "string");
                    
                    $$ = o;

                    strcpy($$->value2, $1);

                };
/*------------------------------- POLY TERM ---------------------------- */
/* POLY_TERM:      TOKEN_PLUS POLY_TERM
                {
                    tnode *a = CreateTnode();
                    strcpy(a->token, "POLY_TERM");
                    a = AppendNode($1, "TOKEN_PLUS", a);
                    a = AppendNode($2, a);
                    strcpy(a->token2, $2->token2);
                    $$ = a;
                }
                | TOKEN_MINUS POLY_TERM
                {
                    tnode *b = CreateTnode();
                    strcpy(b->token, "POLY_TERM");
                    b = AppendNode($1, "TOKEN_MINUS", b);
                    b = AppendNode($2, b);
                    strcpy(b->token2, $2->token2);
                    $$ = b;
                }
                | TOKEN_LB TOKEN_NUMBER TOKEN_COMMA TOKEN_INTCONST TOKEN_RB
                {
                    tnode *c = CreateTnode();
                    strcpy(c->token, "POLY_TERM");
                    c = AppendNode($1, "TOKEN_LB", c);
                    c = AppendNode($2, "TOKEN_NUMBER", c);
                    c = AppendNode($3, "TOKEN_COMMA", c);
                    c = AppendNode($4, "TOKEN_INTCONST", c);
                    c = AppendNode($5, "TOKEN_RB", c);
                    strcpy(c->token2, "poly");
                    $$ = c;
                }
                | 
                {
                    tnode *d = CreateTnode();
                    strcpy(d->token, "POLY_TERM");
					d->displayFlag = 0;
                    $$ = d;
                };*/
/*------------------------------- LOOP OPERATIONS ---------------------------- */
LOOP:		    TOKEN_LOOP TOKEN_LEFTPAREN EXP TOKEN_UNTIL EXP TOKEN_RIGHTPAREN TOKEN_LCB STMTS TOKEN_RCB
                {
					tnode *a = CreateTnode();
                    strcpy(a->token, "LOOP");
                    a = AppendNode($1, "TOKEN_LOOP", a);
                    a = AppendNode($2, "TOKEN_LEFTPAREN", a);
                    a = AppendNode($3, a);
                    a = AppendNode($4, "TOKEN_UNTIL", a);
                    a = AppendNode($5, a);
                    a = AppendNode($6, "TOKEN_RIGHTPAREN", a);
                    a = AppendNode($7, "TOKEN_LCB", a);
                    a = AppendNode($8, a);
                    a = AppendNode($9, "TOKEN_RCB", a);
                    $$ = a;

                    countForLoop++;
                };
/*------------------------------- CONDITION OPERATION  ------------------------*/
CONDITION :	    TOKEN_IF TOKEN_LEFTPAREN EXP TOKEN_RIGHTPAREN TOKEN_LCB STMTS TOKEN_RCB
                {
					tnode *a = CreateTnode();
                    strcpy(a->token, "CONDITION");
                    a = AppendNode($1, "TOKEN_IF", a);
                    a = AppendNode($2, "TOKEN_LEFTPAREN", a);
                    a = AppendNode($3, a);
                    a = AppendNode($4, "TOKEN_RIGHTPAREN", a);
                    a = AppendNode($5, "TOKEN_LCB", a);
                    a = AppendNode($6, a);
                    a = AppendNode($7, "TOKEN_RCB", a);
                    $$ = a;
                    countForIF++;
                }
	            | TOKEN_IF TOKEN_LEFTPAREN EXP TOKEN_RIGHTPAREN TOKEN_LCB STMTS TOKEN_RCB {} ELSECON
                {
				    tnode *b = CreateTnode();
                    strcpy(b->token,"CONDITION");
                    b = AppendNode($1, "TOKEN_IF", b);
                    b = AppendNode($2, "TOKEN_LEFTPAREN", b);
                    b = AppendNode($3, b);
                    b = AppendNode($4, "TOKEN_RIGHTPAREN", b);
                    b = AppendNode($5, "TOKEN_LCB", b);
                    b = AppendNode($6, b);
                    b = AppendNode($7, "TOKEN_RCB", b);
                    b = AppendNode($9, b);
                    $$ = b;
                };

ELSECON:		TOKEN_ELSE TOKEN_LCB STMTS TOKEN_RCB
                {
					tnode *a = CreateTnode();
                    strcpy(a->token, "ELSECON");
                    a = AppendNode($1, "TOKEN_ELSE", a);
                    a = AppendNode($2, "TOKEN_LCB", a);
                    a = AppendNode($3, a);
                    a = AppendNode($4, "TOKEN_RCB", a);
                    $$ = a;
                    countForEndIF++;
                };

/*------------------------------- DECLARATION STATEMENTS  ------------------------*/
STMT_DECLARE :	  TYPE TOKEN_ID IDS
                  {
					tnode *a = CreateTnode();
                    strcpy(a->token, "STMT_DECLARE");
                    a = AppendNode($1, a);
                    a = AppendNode($2, "TOKEN_ID", a);
                    a = AppendNode($3, a);
					if(table[$2] != "")
					  yyerror(3, $2);

                    table[$2] = $1->token2;
                    strcpy(typecheck, $1->token2);

                    $$ = a;

					if (strcmp($3->value2, "") == 0)
						env[$2] = "0";
					else
					    env[$2] = $3->value2;

					variables[$2]= "$s" + std::to_string(countForS);
					countForS++;
                  };

/*--------------------------------- TYPES --------------------------------------------*/
TYPE:           TOKEN_NUMBER
                {
					tnode *a = CreateTnode();
                    strcpy(a->token, "TYPE");
                    a = AppendNode($1, "TOKEN_NUMBER", a);
                    strcpy(a->token2, "num");
                    $$ = a;
                }
                | TOKEN_POLY
                { 
                    tnode *b = CreateTnode();
                    strcpy(b->token, "TYPE");
                    b = AppendNode($1, "TOKEN_POLY", b);
                    strcpy(b->token2, "poly");
                    $$ = b;
                }
                | TOKEN_FRACTION
                { 
                    tnode *c = CreateTnode();
                    strcpy(c->token, "TYPE");
                    c = AppendNode($1, "TOKEN_FRACTION", c);
                    strcpy(c->token2, "frac");
                    $$ = c;
                };

IDS :		      STMT_ASSIGN IDS
                  {
					tnode *a = CreateTnode();
                    strcpy(a->token, "IDS");
                    a = AppendNode($1, a);
                    a = AppendNode($2, a);
                    $$ = a;
					strcpy($$->value2, $1->value2);
                  }
                  | TOKEN_COMMA TOKEN_ID IDS
                  {
					tnode *b = CreateTnode();
                    strcpy(b->token, "IDS");
                    b = AppendNode($1, "TOKEN_COMMA", b);
                    b = AppendNode($2, "TOKEN_ID", b);
                    b = AppendNode($3, b);
                    if(table[$2] != "")
					  yyerror(3,$2);

                    table[$2] = typecheck;
                    $$ = b;
                  }
                  |
                  {
					tnode *c = CreateTnode();
                    strcpy(c->token, "IDS");
					c->displayFlag = 0;
                    $$ = c;
                  };
/*------------------------------- ASSIGNMENT STATEMENTS  ------------------------*/
STMT_ASSIGN :     TOKEN_ID TOKEN_ASSIGN EXP
                  { 
					tnode *a = CreateTnode();
                    strcpy(a->token, "STMT_ASSIGN");
                    a = AppendNode($1, "TOKEN_ID", a);
                    a = AppendNode($2, "TOKEN_ASSIGN", a);
                    a = AppendNode($3, a);

                    if(table[$1] == "")
                        yyerror(2,$1);
                    else if(strcmp(table[$1].c_str(), $3->token2) != 0)
                        yyerror(1);
                
                    $$ = a;


					if (strcmp($3->value2, "") != 0 || strcmp($3->token3, "") != 0)
					{

						if (strcmp($3->token3, "") != 0 )
						{}
						else
						{
							countFort++;
							if (strcmp($3->token3, "") == 0)
							    countFort--;
						}
					}
					else
					{
					    env[$1] = $3->value2;
				        countFort --;
					}

                  }
                  | TOKEN_ASSIGN EXP
                  {
					tnode *b = CreateTnode();
                    strcpy(b->token, "STMT_ASSIGN");
                    b = AppendNode($1, "TOKEN_ASSIGN", b);
                    b = AppendNode($2, b);

                    strcpy(typecheck, $2->token2);
                    
                    $$ = b;
					strcpy($$->value2,$2->value2);
                    strcpy($$->value3,$2->value3);
                    strcpy($$->value4,$2->value4);
                  };
%%


int main(int argc,char **argv)
{

	FILE *sourceCode = fopen(argv[1], "r");

	if (sourceCode == NULL)
	    perror ("FILE ERROR: File cannot be opened.");
	else
	{
	    yyin = sourceCode;

	    yyparse();

	    if(START_NODE != NULL && !errorFlag)
		    printtree(START_NODE);
	}

    cout << output <<endl;

    return 0;
}

/* ..............................
ERROR REPORT FUNCTION
Report custom message.
................................*/
void yyerror(const char* message)
{
	cout <<"Line: " << line << ", error: " << message << endl;
    errorFlag = true;
}

/* ..............................
ERROR REPORT FUNCTION
Report specific types of errors (most common errors)
base on error codes.
................................*/
void yyerror(int code)
{
    if (code == 1)
	    cout << "Line: " << line << ", semantic error: " << "assign operation - type mismatch" << endl;
    else if (code == 2)
        cout << "Line: " << line << ", syntax error: " << "function name should be main" << endl;
    else if (code == 3)
	    cout << "Line: " << line << ", semantic error: " << "logical operation - type mismatch" << endl;
    else if (code == 4)
	    cout << "Line: " << line << ", semantic error: " << "arithmetic operation - type mismatch" << endl;

    errorFlag = true;
}

/* ..............................
ERROR REPORT FUNCTION
Report errors related to variable definitions
base on error codes.
................................*/
void yyerror(int code, string variable)
{
    if(code == 2)
  	    cout << "Line: " << line << ", semantic error: " << "variable" << variable << "is not declared!" << endl;
    else if(code == 3)
  	    cout << "Line: " << line << ", semantic error: " << "variable" << variable << "has already been declared!" << endl;

    errorFlag = true;
}

/*................................
DISPLAY ABSTRACT SYNTAX TREE
.................................. */
void printtree( tnode *node )
{
    tnode *itr;

	for(int i = 1; i < count1; i++)
	    cout << "\t";

	if(count1)
	    cout << "\\";

	if(node->lastchild)
	{
	    cout << node->token << "-> " << node->value << endl;
	    output.append(node->value);
	    output.append(" ");
	}
	else
	{
	    cout << node->token << "\n";
	    output.append(node->token);
	    output.append(" ");
	    count1++;
	}

    for(itr = node->child; itr != NULL; itr = itr->ptr)
	    printtree(itr);

    if(node->lastchild == 0)
	    count1--;
}

/*..................................
CREATE A NODE
...................................*/
tnode* CreateTnode()
{
    tnode *t = new struct tnode();
    t->ptr = NULL;
    t->child = NULL;
    t->lastchild = 0;
    t->displayFlag = 1;

    strcpy(t->token, "");
    strcpy(t->token2, "");
    strcpy(t->token3, "");
    strcpy(t->token4, "");
    strcpy(t->value, "");
    strcpy(t->value2, "");
    strcpy(t->value3, "");
    strcpy(t->value4, "");

    return(t);
}

/*.....................................
APPEND NODE
- Append (first parameter) to the node t
......................................*/
tnode* AppendNode(tnode* push, tnode* t)
{
	if(t->child == NULL)
		t->child = push;
	else
	{
		tnode *itr;
		for(itr = t->child; itr->ptr != NULL; itr = itr->ptr);
		itr->ptr = push;
	}
	return(t);
}

/*.....................................
APPEND NODE
- Create a node from value and token then
append it to t
......................................*/
tnode* AppendNode(string value, string token, tnode* t)
{
	tnode *push = CreateTnode();
	push->lastchild = 1;
	strcpy(push->value, value.c_str());
	strcpy(push->token, token.c_str());
	t = AppendNode(push,t);
	return (t);
}

/* GCD FUNCTION - USE IN FRACTION CALCULATION */
int gcd(int a, int b) {
   if (b == 0)
   return a;
   return gcd(b, a % b);
}