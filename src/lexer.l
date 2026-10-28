
%option noyywrap

%{
#include <stdio.h>
#include "parser.tab.h"
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
NUMBER      {DIGIT}+

%%

"int"       { return INT; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"return"    { return RETURN; }

"=="        { return EQ; }
"!="        { return NE; }
"<="        { return LE; }
">="        { return GE; }
"&&"        { return AND; }
"||"        { return OR; }

{NUMBER}      { return NUMBER; }
{IDENTIFIER}  { return IDENTIFIER; }

[+\-*/%=<>!]  { return yytext[0]; }
[(){};]       { return yytext[0]; }

[ \t\r\n]+    { /* Ignore whitespace */ }

. {
    fprintf(stderr, "Unknown character: %s\n", yytext);
    return YYUNDEF;
}

%%
