%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "table_symbole.h"
#include "y.tab.h"
%}

D                       [0-9]
L                       [a-zA-Z_]

%%
"break"                 { return BREAK; }
"case"                  { return CASE; }
"default"               { return DEFAULT; }
"else"                  { return ELSE; }
"extern"                { return EXTERN; }
"for"                   { return FOR; }
"if"                    { return IF; }
"int"                   { return INT; }
"return"                { return RETURN; }
"switch"                { return SWITCH; }
"void"                  { return VOID; }
"while"                 { return WHILE; }

{L}({L}|{D})*           { yylval.id = strdup(yytext); return IDENTIFICATEUR; }
{D}+                    { yylval.id = strdup(yytext); return CONSTANTE; }

"="                     { return yytext[0]; }

">"                     { return GT; }
"<"                     { return LT; }
"<="                    { return LEQ; }
">="                    { return GEQ; }
"=="                    { return EQ; }
"!="                    { return NEQ; }

"+"                     { return PLUS; }
"-"                     { return MOINS; }
"*"                     { return MUL; }
"/"                     { return DIV; }

"&"                     { return BAND; }
"|"                     { return BOR; }
">>"                    { return RSHIFT; }
"<<"                    { return LSHIFT; }
"&&"                    { return LAND; }
"||"                    { return LOR; }
"!"                     { return NOT; }

","                     { return yytext[0]; }
";"                     { return yytext[0]; }
":"                     { return yytext[0]; }

"{"                     { return yytext[0]; }
"}"                     { return yytext[0]; }
"["                     { return yytext[0]; }
"]"                     { return yytext[0]; }
"("                     { return yytext[0]; }
")"                     { return yytext[0]; }

\/\/.*                  { /* Ignore single-line comments */ }
\/\*(.|\n)*?\*\/        { /* Ignore multi-line comments */ }

\n                      { yylineno++; }
[ \t\v\f]              { /* Ignore whitespace */ }

.                       { printf("Caractère inattendu line: %d\n", yylineno); exit(1); }
%%

int yywrap() {
    return 1;
}
