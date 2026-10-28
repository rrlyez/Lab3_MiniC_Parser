
#include "../include/ast.h"

#include <iostream>
#include <string>

std::string node_type_to_string(NodeType type) {
    switch (type) {
        case NodeType::Program:     return "Program";
        case NodeType::Block:       return "Block";
        case NodeType::Number:      return "Number";
        case NodeType::Variable:    return "Variable";
        case NodeType::BinaryOp:    return "BinaryOp";
        case NodeType::UnaryOp:     return "UnaryOp";
        case NodeType::Declaration: return "Declaration";
        case NodeType::Assignment:  return "Assignment";
        case NodeType::If:          return "If";
        case NodeType::While:       return "While";
        case NodeType::Return:      return "Return";
        case NodeType::Print:       return "Print";
    }

    return "Unknown";
}

void print_ast(const ASTNode& node, int depth) {
    std::string indent(depth * 2, ' ');

    std::cout << indent << node_type_to_string(node.type);

    if (!node.value.empty()) {
        std::cout << ": " << node.value;
    }

    std::cout << '\n';

    for (const auto& child : node.children) {
        print_ast(*child, depth + 1);
    }
}
