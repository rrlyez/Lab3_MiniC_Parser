
%code requires {
#include "../include/ast.h"
#include <string>
}

%{
#include "../include/ast.h"
#include <iostream>
#include <memory>
#include <string>

int yylex(void);
void yyerror(const char *message);

std::unique_ptr<ASTNode> root;

ASTNode* make_node(
    NodeType type,
    const std::string& value = "",
    ASTNode* first = nullptr,
    ASTNode* second = nullptr,
    ASTNode* third = nullptr
) {
    ASTNode* result = new ASTNode(type, value);

    if (first)
        result->add_child(std::unique_ptr<ASTNode>(first));

    if (second)
        result->add_child(std::unique_ptr<ASTNode>(second));

    if (third)
        result->add_child(std::unique_ptr<ASTNode>(third));

    return result;
}
%}

%union {
    ASTNode* node;
    std::string* text;
}

%token INT IF ELSE WHILE RETURN PRINT
%token EQ NE LE GE AND OR
%token <text> IDENTIFIER NUMBER

%type <node> program block statements statement expression

%destructor { delete $$; } <node>
%destructor { delete $$; } <text>

%start program

%left OR
%left AND
%nonassoc EQ NE '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'
%precedence '!' UMINUS

%precedence IF_WITHOUT_ELSE
%precedence ELSE

%%

program:
    INT IDENTIFIER '(' ')' block
    {
        root.reset(make_node(NodeType::Program, *$2, $5));
        delete $2;
        $$ = nullptr;
    }
    ;


block:
    '{' statements '}'
    {
        $$ = $2;
    }
    ;

statements:
    %empty
    {
        $$ = make_node(NodeType::Block);
    }
    | statements statement
    {
        $1->add_child(std::unique_ptr<ASTNode>($2));
        $$ = $1;
    }
    ;

statement:
    INT IDENTIFIER ';'
    {
        $$ = make_node(NodeType::Declaration, *$2);
        delete $2;
    }
    | INT IDENTIFIER '=' expression ';'
    {
        $$ = make_node(NodeType::Declaration, *$2, $4);
        delete $2;
    }
    | IDENTIFIER '=' expression ';'
    {
        $$ = make_node(NodeType::Assignment, *$1, $3);
        delete $1;
    }
    | IF '(' expression ')' statement
      %prec IF_WITHOUT_ELSE
    {
        $$ = make_node(NodeType::If, "", $3, $5);
    }
    | IF '(' expression ')' statement ELSE statement
    {
        $$ = make_node(NodeType::If, "", $3, $5, $7);
    }
    | WHILE '(' expression ')' statement
    {
        $$ = make_node(NodeType::While, "", $3, $5);
    }
    | PRINT '(' expression ')' ';'
    {
        $$ = make_node(NodeType::Print, "", $3);
    }
    | RETURN expression ';'
    {
        $$ = make_node(NodeType::Return, "", $2);
    }
    | block
    {
        $$ = $1;
    }
    ;

expression:
    NUMBER
    {
        $$ = make_node(NodeType::Number, *$1);
        delete $1;
    }
    | IDENTIFIER
    {
        $$ = make_node(NodeType::Variable, *$1);
        delete $1;
    }
    | expression '+' expression
    {
        $$ = make_node(NodeType::BinaryOp, "+", $1, $3);
    }
    | expression '-' expression
    {
        $$ = make_node(NodeType::BinaryOp, "-", $1, $3);
    }
    | expression '*' expression
    {
        $$ = make_node(NodeType::BinaryOp, "*", $1, $3);
    }
    | expression '/' expression
    {
        $$ = make_node(NodeType::BinaryOp, "/", $1, $3);
    }
    | expression '%' expression
    {
        $$ = make_node(NodeType::BinaryOp, "%", $1, $3);
    }
    | expression '<' expression
    {
        $$ = make_node(NodeType::BinaryOp, "<", $1, $3);
    }
    | expression '>' expression
    {
        $$ = make_node(NodeType::BinaryOp, ">", $1, $3);
    }
    | expression LE expression
    {
        $$ = make_node(NodeType::BinaryOp, "<=", $1, $3);
    }
    | expression GE expression
    {
        $$ = make_node(NodeType::BinaryOp, ">=", $1, $3);
    }
    | expression EQ expression
    {
        $$ = make_node(NodeType::BinaryOp, "==", $1, $3);
    }
    | expression NE expression
    {
        $$ = make_node(NodeType::BinaryOp, "!=", $1, $3);
    }
    | expression AND expression
    {
        $$ = make_node(NodeType::BinaryOp, "&&", $1, $3);
    }
    | expression OR expression
    {
        $$ = make_node(NodeType::BinaryOp, "||", $1, $3);
    }
    | '!' expression
    {
        $$ = make_node(NodeType::UnaryOp, "!", $2);
    }
    | '-' expression %prec UMINUS
    {
        $$ = make_node(NodeType::UnaryOp, "-", $2);
    }
    | '(' expression ')'
    {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *message) {
    std::cerr << "Syntax error: " << message << '\n';
}

int main() {
    if (yyparse() != 0)
        return 1;

    std::cout << "Parsing successful!\n\n";
    std::cout << "Abstract Syntax Tree:\n";

    if (root)
        print_ast(*root);

    return 0;
}
