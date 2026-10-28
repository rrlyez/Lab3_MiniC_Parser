
#include "../include/visualizer.h"

#include <fstream>
#include <stdexcept>
#include <string>

namespace {

std::string escape_dot(const std::string& text) {
    std::string result;

    for (char c : text) {
        if (c == '\\' || c == '"') {
            result += '\\';
        }

        if (c == '\n') {
            result += "\\n";
        } else {
            result += c;
        }
    }

    return result;
}

std::string node_color(NodeType type) {
    switch (type) {
        case NodeType::Program:
            return "#2563EB";

        case NodeType::Block:
            return "#64748B";

        case NodeType::Number:
            return "#16A34A";

        case NodeType::Variable:
            return "#0D9488";

        case NodeType::BinaryOp:
        case NodeType::UnaryOp:
            return "#9333EA";

        case NodeType::Declaration:
        case NodeType::Assignment:
            return "#EA580C";

        case NodeType::If:
        case NodeType::While:
            return "#DC2626";

        case NodeType::Return:
        case NodeType::Print:
            return "#CA8A04";
    }

    return "#475569";
}

std::string node_label(const ASTNode& node) {
    std::string label = node_type_to_string(node.type);

    if (!node.value.empty()) {
        label += "\\n" + escape_dot(node.value);
    }

    return label;
}

int write_node(
    const ASTNode& node,
    std::ofstream& out,
    int& next_id
) {
    int current_id = next_id++;

    out << "  node" << current_id
        << " [label=\"" << node_label(node)
        << "\", fillcolor=\"" << node_color(node.type)
        << "\"];\n";

    for (const auto& child : node.children) {
        int child_id = write_node(*child, out, next_id);

        out << "  node" << current_id
            << " -> node" << child_id << ";\n";
    }

    return current_id;
}

} // namespace

void export_ast_dot(
    const ASTNode& root,
    const std::string& filename
) {
    std::ofstream out(filename);

    if (!out) {
        throw std::runtime_error(
            "Cannot create DOT file: " + filename
        );
    }

    out << "digraph AST {\n";
    out << "  graph [rankdir=TB, bgcolor=\"white\", "
           "nodesep=0.4, ranksep=0.6];\n";

    out << "  node [shape=box, style=\"rounded,filled\", "
           "fontname=\"Arial\", fontsize=11, "
           "fontcolor=\"white\", margin=0.15];\n";

    out << "  edge [color=\"#94A3B8\", "
           "arrowsize=0.7];\n\n";

    int next_id = 0;
    write_node(root, out, next_id);

    out << "}\n";

    if (!out) {
        throw std::runtime_error("Failed to write DOT file");
    }
}
