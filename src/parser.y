
%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *message);
%}

%token INT IF RETURN IDENTIFIER NUMBER EQ

%left '+' '-'
%left '*' '/'

%start program

%%

program:
    INT IDENTIFIER '(' ')' block
    {
        printf("Parsing successful!\n");
    }
    ;

block:
    '{' statements '}'
    ;

statements:
      %empty
    | statements statement
    ;

statement:
      INT IDENTIFIER '=' expression ';'
    | IDENTIFIER '=' expression ';'
    | IF '(' condition ')' block
    | RETURN expression ';'
    | block
    ;

condition:
      expression '>' expression
    | expression '<' expression
    | expression EQ expression
    ;

expression:
      NUMBER
    | IDENTIFIER
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | '(' expression ')'
    ;

%%

void yyerror(const char *message) {
    fprintf(stderr, "Syntax error: %s\n", message);
}

int main(void) {
    return yyparse() == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
