
#include "../include/interpreter.h"

#include <iostream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

class Interpreter {
private:
    using Scope = std::unordered_map<std::string, long long>;

    std::vector<Scope> scopes;

    struct ReturnSignal {
        long long value;
    };

    long long& find_variable(const std::string& name) {
        for (auto it = scopes.rbegin(); it != scopes.rend(); ++it) {
            auto variable = it->find(name);

            if (variable != it->end()) {
                return variable->second;
            }
        }

        throw std::runtime_error("Undeclared variable: " + name);
    }

    long long evaluate(const ASTNode& node) {
        switch (node.type) {
            case NodeType::Number:
                return std::stoll(node.value);

            case NodeType::Variable:
                return find_variable(node.value);

            case NodeType::UnaryOp: {
                long long value = evaluate(*node.children[0]);

                if (node.value == "-") return -value;
                if (node.value == "!") return !value;

                break;
            }

            case NodeType::BinaryOp: {
                const auto& left_node = *node.children[0];
                const auto& right_node = *node.children[1];
                const std::string& op = node.value;

                long long left = evaluate(left_node);

                if (op == "&&") {
                    return left && evaluate(right_node);
                }

                if (op == "||") {
                    return left || evaluate(right_node);
                }

                long long right = evaluate(right_node);

                if (op == "+") return left + right;
                if (op == "-") return left - right;
                if (op == "*") return left * right;

                if (op == "/" || op == "%") {
                    if (right == 0) {
                        throw std::runtime_error("Division by zero");
                    }

                    if (op == "/") return left / right;
                    return left % right;
                }

                if (op == "<")  return left < right;
                if (op == ">")  return left > right;
                if (op == "<=") return left <= right;
                if (op == ">=") return left >= right;
                if (op == "==") return left == right;
                if (op == "!=") return left != right;

                break;
            }

            default:
                break;
        }

        throw std::runtime_error("Invalid expression");
    }

    void execute(const ASTNode& node) {
        switch (node.type) {
            case NodeType::Program:
                execute(*node.children[0]);
                break;

            case NodeType::Block:
                scopes.emplace_back();

                try {
                    for (const auto& child : node.children) {
                        execute(*child);
                    }
                } catch (...) {
                    scopes.pop_back();
                    throw;
                }

                scopes.pop_back();
                break;

            case NodeType::Declaration: {
                long long value = 0;

                if (!node.children.empty()) {
                    value = evaluate(*node.children[0]);
                }

                if (scopes.back().count(node.value) > 0) {
                    throw std::runtime_error(
                        "Variable already declared: " + node.value
                    );
                }

                scopes.back()[node.value] = value;
                break;
            }

            case NodeType::Assignment:
                find_variable(node.value) =
                    evaluate(*node.children[0]);
                break;

            case NodeType::If:
                if (evaluate(*node.children[0])) {
                    execute(*node.children[1]);
                } else if (node.children.size() == 3) {
                    execute(*node.children[2]);
                }
                break;

            case NodeType::While:
                while (evaluate(*node.children[0])) {
                    execute(*node.children[1]);
                }
                break;

            case NodeType::Print:
                std::cout << evaluate(*node.children[0]) << '\n';
                break;

            case NodeType::Return:
                throw ReturnSignal{evaluate(*node.children[0])};

            default:
                throw std::runtime_error("Invalid statement");
        }
    }

public:
    void run(const ASTNode& root) {
        scopes.emplace_back();

        try {
            execute(root);
        } catch (const ReturnSignal&) {
            // Normal termination after return.
        }
    }
};

void execute_program(const ASTNode& root) {
    Interpreter interpreter;
    interpreter.run(root);
}
