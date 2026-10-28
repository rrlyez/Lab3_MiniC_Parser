
%option noyywrap

%{
#include "parser.tab.h"
%}

DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
NUMBER      {DIGIT}+

%%

"int"       { return INT; }
"if"        { return IF; }
"return"    { return RETURN; }

"=="        { return EQ; }

{NUMBER}    { return NUMBER; }
{IDENTIFIER} { return IDENTIFIER; }

[+\-*/=<>]  { return yytext[0]; }
[(){};]     { return yytext[0]; }

[ \t\r\n]+  { /* Ignore whitespace */ }

.           {
    fprintf(stderr, "Unknown character: %s\n", yytext);
    return YYUNDEF;
}

%%
