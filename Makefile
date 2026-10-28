
CXX = g++
CXXFLAGS = -std=c++20 -Wall -Wextra -Iinclude

BISON = bison
FLEX = flex

TARGET = output/minic.exe

PARSER = output/parser.tab.c
PARSER_HEADER = output/parser.tab.h
LEXER = output/lex.yy.c

SOURCES = src/ast.cpp src/interpreter.cpp src/codegen.cpp src/visualizer.cpp src/json_exporter.cpp

.PHONY: all clean test visualize

all: $(TARGET)

$(PARSER) $(PARSER_HEADER) &: src/parser.y include/ast.h
	@mkdir -p output
	$(BISON) -Wall -Wcounterexamples -v -d -o $(PARSER) src/parser.y

$(LEXER): src/lexer.l $(PARSER_HEADER)
	$(FLEX) -o $(LEXER) src/lexer.l

$(TARGET): $(PARSER) $(LEXER) $(SOURCES) include/interpreter.h include/codegen.h include/visualizer.h include/json_exporter.h
	$(CXX) $(CXXFLAGS) $(PARSER) $(LEXER) $(SOURCES) -o $(TARGET)

test: all
	./$(TARGET) < tests/interpreter_test.c

visualize: all
	./$(TARGET) < tests/codegen_test.c
	dot -Tsvg output/ast.dot -o output/ast.svg
	@echo "AST visualization saved to output/ast.svg"

clean:
	rm -f output/*.exe output/*.o
	rm -f output/lex.yy.c
	rm -f output/parser.tab.c
	rm -f output/parser.tab.h
	rm -f output/parser.output
