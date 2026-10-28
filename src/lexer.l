
%option noyywrap nounput noinput

%{
#include <cstdio>
#include <string>
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
"print"     { return PRINT; }

"=="        { return EQ; }
"!="        { return NE; }
"<="        { return LE; }
">="        { return GE; }
"&&"        { return AND; }
"||"        { return OR; }

{NUMBER} {
    yylval.text = new std::string(yytext);
    return NUMBER;
}

{IDENTIFIER} {
    yylval.text = new std::string(yytext);
    return IDENTIFIER;
}

[+\-*/%=<>!]  { return yytext[0]; }
[(){};]       { return yytext[0]; }

[ \t\r\n]+    { /* Ignore whitespace */ }

. {
    fprintf(stderr, "Unknown character: %s\n", yytext);
    return YYUNDEF;
}

%%
