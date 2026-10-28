
%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *message);
%}

%token INT IF ELSE WHILE RETURN
%token IDENTIFIER NUMBER
%token EQ NE LE GE AND OR

%start program

%precedence IF_WITHOUT_ELSE
%precedence ELSE

%left OR
%left AND
%nonassoc EQ NE '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'
%right '!' UMINUS

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
      INT IDENTIFIER ';'
    | INT IDENTIFIER '=' expression ';'
    | IDENTIFIER '=' expression ';'
    | IF '(' expression ')' statement %prec IF_WITHOUT_ELSE
    | IF '(' expression ')' statement ELSE statement
    | WHILE '(' expression ')' statement
    | RETURN expression ';'
    | block
    ;

expression:
      NUMBER
    | IDENTIFIER
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | expression '%' expression
    | expression '<' expression
    | expression '>' expression
    | expression LE expression
    | expression GE expression
    | expression EQ expression
    | expression NE expression
    | expression AND expression
    | expression OR expression
    | '!' expression
    | '-' expression %prec UMINUS
    | '(' expression ')'
    ;

%%

void yyerror(const char *message) {
    fprintf(stderr, "Syntax error: %s\n", message);
}

int main(void) {
    return yyparse() == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
