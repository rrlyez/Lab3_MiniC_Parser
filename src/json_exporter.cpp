
#include "../include/json_exporter.h"

#include <fstream>
#include <iomanip>
#include <stdexcept>
#include <string>

namespace {

std::string escape_json(const std::string& text) {
    std::string result;

    for (unsigned char c : text) {
        switch (c) {
            case '"':  result += "\\\""; break;
            case '\\': result += "\\\\"; break;
            case '\n': result += "\\n";  break;
            case '\r': result += "\\r";  break;
            case '\t': result += "\\t";  break;

            default:
                if (c < 0x20) {
                    const char* hex = "0123456789abcdef";
                    result += "\\u00";
                    result += hex[c >> 4];
                    result += hex[c & 15];
                } else {
                    result += static_cast<char>(c);
                }
        }
    }

    return result;
}

void write_json(
    const ASTNode& node,
    std::ofstream& out,
    int depth
) {
    std::string spaces(depth * 2, ' ');

    out << spaces << "{\n";

    out << spaces << "  \"type\": \""
        << escape_json(node_type_to_string(node.type))
        << "\",\n";

    out << spaces << "  \"value\": \""
        << escape_json(node.value)
        << "\",\n";

    out << spaces << "  \"children\": [\n";

    for (size_t i = 0; i < node.children.size(); ++i) {
        write_json(*node.children[i], out, depth + 2);

        if (i + 1 < node.children.size()) {
            out << ",";
        }

        out << "\n";
    }

    out << spaces << "  ]\n";
    out << spaces << "}";
}

} // namespace

void export_ast_json(
    const ASTNode& root,
    const std::string& filename
) {
    std::ofstream out(filename);

    if (!out) {
        throw std::runtime_error(
            "Cannot create JSON file: " + filename
        );
    }

    write_json(root, out, 0);
    out << '\n';

    if (!out) {
        throw std::runtime_error("Failed to write JSON file");
    }
}