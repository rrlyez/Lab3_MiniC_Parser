
#ifndef JSON_EXPORTER_H
#define JSON_EXPORTER_H

#include "ast.h"
#include <string>

void export_ast_json(
    const ASTNode& root,
    const std::string& filename
);

#endif
