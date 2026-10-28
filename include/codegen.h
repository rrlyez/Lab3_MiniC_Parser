
#ifndef CODEGEN_H
#define CODEGEN_H

#include "ast.h"
#include <string>

void generate_python(
    const ASTNode& root,
    const std::string& filename
);

#endif