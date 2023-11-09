%{
#include <stdio.h> 
#include <stdlib.h>
#include <string.h>
#include  "table_symbole.h"

extern int yylineno;
void yyerror (char *s);
void table_reset();
%}

%union{
	char* id;
	struct _tree *tree;
	struct _symbole *symb;
}
 
%token <id> IDENTIFICATEUR CONSTANTE  
%token <id> VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token <id> BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT BAND BOR LAND LOR LT GT 
%token <id> GEQ LEQ EQ NEQ NOT EXTERN

%left MUL DIV 
%left PLUS MOINS 
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left REL 

%start programme

%type <symb> liste_declarations declaration declarateur liste_declarateurs dl
%type <tree> saut selection instruction variable expression condition affectation bloc liste_instructions  liste_expressions expr_liste_creator appel
%type<tree> iteration parm vr  programme liste_fonctions fonction br
%type <tree> liste_parms 
%type <id> binary_rel type 

%%
programme	:	
	liste_declarations liste_fonctions  {$$=creerArbre("PROGRAM",$2,0); $$->ts = genererTS("programme","");$$->ts->fils=$1; insertSuivantSymbole($$->ts->fils,$2->ts); 
											pereRecusif($$->ts);
											verifieDef($$,0);
											ecritDot($2);
											
										}
;
liste_declarations	:	
		liste_declarations declaration  {$$=$1; insertSuivantSymbole($$,$2);}
	|				{$$=genererTS("#empty","");}
;
liste_fonctions	:	
		liste_fonctions fonction      {$$ = $1; insertSuivant($1,$2); insertSuivantSymbole($1->ts,$2->ts);} 
 |               fonction			{$$=$1;}
;
declaration	:	
		type liste_declarateurs ';' {if(0==strcmp($1,"int")){
										$$ = $2 ; addTypeSymbole($$,$1);
										
									} else{
										yyerror("Typecheck");
									}}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur {$$ = $1; insertSuivantSymbole($1,$3);}
	|	declarateur  {$$ = $1;}
;
declarateur	:	
		IDENTIFICATEUR   {$$  = genererTS($1,"undef");}

	|	IDENTIFICATEUR dl  {   $$=genererTS("TAB","int"); 
	                            $$->fils=genererTS($1,"undef");insertSuivantSymbole($$->fils,$2);
								$$->dimension = sizeFilsSymbole($$->fils)-1; 
								$$->tailles = (int *) malloc(($$->dimension) * sizeof(int));
								initialiseTAB($$->tailles,$$->fils->suivants,0);
								$$->type=TYPE_TAB;
								} 
;

dl :  '[' CONSTANTE ']' {$$=genererTS($2,"int");}
     | dl '[' CONSTANTE ']'{ $$=$1; insertSuivantSymbole($$,genererTS($3,"int"));}
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' bloc {	char * name;
																		name = (char * ) malloc(15 * sizeof(char));
																		sprintf(name,"%s , %s",$2,$1);
																		$$=creerArbre(name,$4,yylineno);insertSuivant($$->fils,$6);
																		$$->typeNode=FONCTION;

																		$$->ts = genererTS($2,$1);

																		if(strcmp($1,"int") == 0 ){
																			
																			$$->typeVar = TYPE_INT;
																			
																		} else if (strcmp($1,"void") == 0){
																			$$->typeVar = TYPE_VOID;
																			
																		}else{$$->typeVar = NULE;
																		}
																		if(sizeFils($4) > 0 ){
																			$$->ts->nbParam=sizeFils($4)-1;
																		}
																		$$->ts->fils = $4->ts;
																		insertSuivantSymbole($4->ts,$6->ts);}						
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {$$=creerArbre("extern",creerArbre($2,NULL,yylineno),yylineno);
															$$->ts = genererTS($3,$2);
															$$->ts->nbParam=sizeFils($5);
															
															$$->ts->fils = $5->ts;

														 	$$->fils->suivants=creerArbre($3,NULL,yylineno);
															$$->fils->suivants->fils=$5;
															$$->typeNode=EXTER;
																if(strcmp($2,"int") == 0 ){
																			$$->typeVar = TYPE_INT;
																		}else if (strcmp($2,"void") == 0)
																		{$$->typeVar = TYPE_VOID;}
																		else{$$->typeVar = NULE;}
																		}
;
type	:	
		VOID {$$="void";}
	|	INT {$$ = "int";}
;

liste_parms	:
    liste_parms ',' parm {$$ = $1; insertSuivant($1,$3); insertSuivantSymbole($$->ts,$3->ts);}
	| parm	{$$ =$1;}
	|				{$$ = creerArbre("#",NULL,yylineno); $$->ts=genererTS("#empty","");}
;
parm	:	 
		INT IDENTIFICATEUR  {$$=creerArbre("int",creerArbre($2,NULL,yylineno),yylineno); $$->typeVar = TYPE_INT; $$->ts=genererTS($$->fils->nom,"int"); }
;
liste_instructions :	
		liste_instructions instruction {$$ = $1; insertSuivant($1,$2);insertSuivantSymbole($1->ts,$2->ts);}
	|				{$$ = creerArbre("#",NULL,yylineno);$$->ts = genererTS("#empty","undef");}
;
instruction	:	
		iteration {$$=$1;}
	|	selection {$$ = $1;}
	|	saut { $$ = $1;}
	|	affectation ';' { $$ = $1;}
	|	bloc {$$=$1;}
	|	appel {$$=$1;}
;

iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction 	{$$=creerArbre("FOR",$3,yylineno); $$->fils->suivants=$5;
																			$$->fils->suivants->suivants=$7;$$->fils->suivants->suivants->suivants=$9; 
																			$$->ts = $9->ts; 
																			insertSuivantSymbole($$->ts,$3->ts);
																			insertSuivantSymbole($$->ts,$5->ts);
																			insertSuivantSymbole($$->ts,$7->ts);}
	|	WHILE '(' condition ')' instruction {$$=creerArbre("WHILE",$3,yylineno); $$->fils->suivants=$5; 
											$$->ts->fils = $5->ts;
											insertSuivantSymbole($$->ts,$3->ts);}
	
;
selection	:	
		IF '(' condition ')' instruction %prec THEN {$$ = creerArbre("IF",$3,yylineno);
													if(strcmp($5->nom,"BLOC")==0){
														$5->nom = "THEN";	
													}
													$$->fils->suivants = $5;
													$$->ts=$5->ts;
													insertSuivantSymbole($$->ts,$3->ts);
													$$->typeNode=COMP;}
	|	IF '(' condition ')' instruction ELSE instruction {$$ = creerArbre("IF",$3,yylineno);
														if(strcmp($5->nom,"BLOC")==0){
															$5->nom = "THEN";	
														}
														$$->fils->suivants = $5;$$->fils->suivants->suivants = creerArbre("ELSE",$7,yylineno);
															$$->ts=$3->ts;
															insertSuivantSymbole($$->ts,$5->ts);
															insertSuivantSymbole($$->ts,$7->ts);
															$$->typeNode=COMP;} 
	|	SWITCH '(' expression ')' instruction {$$ = creerArbre("SWITCH",$3,yylineno); $$->fils->suivants = $5->fils;
												$$->ts=$3->ts;
												insertSuivantSymbole($$->ts,$5->ts);
												$$->typeNode=COMP;}
	|	CASE CONSTANTE ':' instruction br  { symbole *tmp =creerArbre ($2,NULL,yylineno);
		                                             $$ = creerArbre("CASE",tmp,yylineno); 
			                                          insertSuivant (tmp,$4); if (strcmp ($5->nom,"BREAK")==0 ) insertSuivant(tmp,$5) ; 
													  $$->ts=$4->ts;}
	
	|	DEFAULT ':' instruction {$$ = creerArbre("DEFAULT",$3,yylineno);$$->ts = $3->ts;}
;
br   : BREAK  ';'  {$$=creerArbre("BREAK",NULL,yylineno);}
     |          {$$=creerArbre("#",NULL,yylineno);} 
	 ;
saut	:	
		BREAK  ';' {$$=creerArbre("BREAK",NULL,yylineno);}
	|	RETURN ';' {$$ = creerArbre("return",NULL,yylineno);
					$$->typeNode=RET;}
	|	RETURN expression ';' {$$ = creerArbre("RETURN",$2,yylineno); 
								$$->ts=$2->ts;
								$$->typeNode=RET;
								}
;
affectation	:	 
		variable '=' expression  {$$ = creerArbre(":=",$1,yylineno);$$->fils->suivants = $3; 
								 
								$$->ts->fils = $1->ts;
								$$->ts->fils->suivants = $3->ts;
								$$->typeNode=AFFECTATION;} 
;
bloc	:	
		'{' liste_declarations liste_instructions '}' {if (sizeFils($3) <= 1){ $$ = $3;
													}else{		$$ = creerArbre("BLOC",$3,yylineno);}
													insertSuivantSymbole ($2,$3->ts);
													$$->ts= genererTS("BLOC","");
													$$->ts->fils = $2;}
;
appel	:
	IDENTIFICATEUR '(' liste_expressions ')' ';' {$$=creerArbre($1,$3,yylineno);$$->typeNode=APPEL;$$->ts = $3->ts; 
												}
;
variable	:	
		IDENTIFICATEUR  {$$ = creerArbre($1,NULL,yylineno);$$->typeNode=VAR;}  
	    |IDENTIFICATEUR vr     {tree *tmp = creerArbre($1,NULL,yylineno);
	                       insertSuivant(tmp,$2);
	                    $$=creerArbre("TAB",tmp,yylineno);addType($$,"tab");$$->typeNode=VAR;		
							$$->ts=tmp->ts;
							$$->ts->dimension = sizeFilsSymbole($$->fils)-1; 
								$$->ts->tailles = (int *) malloc(($$->ts->dimension) * sizeof(int));
								initialiseTAB($$->ts->tailles,$$->fils->suivants,0);
								$$->typeVar=TYPE_TAB;}
;
 vr : '[' expression ']' {$$=$2;}
 | '[' expression ']' vr {$$=$2;insertSuivant($$,$4);}
 ;
expression	:	
		'(' expression ')'	{$$ = $2;}                       
	
	|	expression PLUS expression	{$$ = creerArbre("+",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;
									}
	|	expression MOINS expression	{$$ = creerArbre("-",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;
									}		
	|	expression DIV expression	{$$ = creerArbre("/",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;
									}				
	|	expression MUL expression 	{$$ = creerArbre("*",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;
									}			
	|	expression RSHIFT expression	{$$ = creerArbre(">>",$1,yylineno); $$->fils->suivants = $3;
										$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}  			
	|	expression LSHIFT expression	{$$ = creerArbre("<<",$1,yylineno); $$->fils->suivants = $3;
										$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}			
	|	expression BAND expression	{$$ = creerArbre("&",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}			
	|	expression BOR expression	{$$ = creerArbre("|",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;} 			
	|	MOINS expression %prec MUL	{$$ = creerArbre("-",$2,yylineno);
									$$->ts = $2->ts;}                                   
	|	CONSTANTE       {$$ = creerArbre($1,NULL,yylineno);$$->typeVar = TYPE_INT;}                                                 							
	|	variable	 {$$ =  $1;}                           
	|	IDENTIFICATEUR '(' liste_expressions ')' {$$ = creerArbre($1,$3,yylineno); $$->typeNode=APPEL;
												$$->ts->fils=$3->ts;
									}                                  
;
liste_expressions :      
    expr_liste_creator {$$ = $1;}
    | 			{$$ = creerArbre("#",NULL,yylineno);$$->ts=genererTS("#empty","");}
;
expr_liste_creator :                         
    expr_liste_creator ',' expression {$$ = $1 ;insertSuivant($$,$3); insertSuivantSymbole($$->ts,$3->ts);} 
    | expression                   {$$=$1;}           
;
condition	:	
		NOT '(' condition ')' {$$ = creerArbre("not",$3,yylineno);}
	|	condition binary_rel condition %prec REL {$$ = creerArbre($2,$1,yylineno); $$->fils->suivants = $3;
													$$->ts->fils=$1->ts;
													$$->ts->fils->suivants=$3->ts;}
	|	'(' condition ')' { $$ = $2;}
	|	expression LT expression {$$ = creerArbre("<",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}
	|	expression GT expression {$$ = creerArbre(">",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}
	|	expression GEQ expression {$$ = creerArbre(">=",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}
	|	expression LEQ expression {$$ = creerArbre("<=",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}
	|	expression EQ expression {$$ = creerArbre("==",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}
	|	expression NEQ expression {$$ = creerArbre("!=",$1,yylineno); $$->fils->suivants = $3;
									$$->ts->fils=$1->ts;
									$$->ts->fils->suivants=$3->ts;}
;
binary_rel	:	
		LAND {$$ = "&&"; } 
	|	LOR	{$$ = "||"; } 
;


%%

void yyerror(char *s){
	 fprintf(stderr, " line %d: %s\n", yylineno, s);
	 exit(1);
}

int main(void) {
	while(yyparse()); 
}