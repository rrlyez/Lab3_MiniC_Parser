
#ifndef AST_H
#define AST_H

#include <memory>
#include <string>
#include <vector>

enum class NodeType {
    Program,
    Block,
    Number,
    Variable,
    BinaryOp,
    UnaryOp,
    Declaration,
    Assignment,
    If,
    While,
    Return,
    Print
};

struct ASTNode {
    NodeType type;
    std::string value;
    std::vector<std::unique_ptr<ASTNode>> children;

    ASTNode(NodeType node_type, const std::string& node_value = "")
        : type(node_type), value(node_value) {}

    void add_child(std::unique_ptr<ASTNode> child) {
        children.push_back(std::move(child));
    }
};

std::string node_type_to_string(NodeType type);
void print_ast(const ASTNode& node, int depth = 0);

#endif
