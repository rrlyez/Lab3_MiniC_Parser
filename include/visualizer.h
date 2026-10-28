
#ifndef VISUALIZER_H
#define VISUALIZER_H

#include "ast.h"
#include <string>

void export_ast_dot(
    const ASTNode& root,
    const std::string& filename
);

#endif
