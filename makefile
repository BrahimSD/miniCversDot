CC=gcc
YC=yacc
FL=flex

TARGET=a.out

all:
	@$(YC) -d miniC.y 2>/dev/null
	$(FL) miniC.l
	$(CC) -g lex.yy.c y.tab.c table_symbole.c -lfl -o $(TARGET) -w
	./$(TARGET) < Tests/$(TEST).c
	mv DOT.dot ./DOT/$(TEST).dot
	dot -Tpdf ./DOT/$(TEST).dot -o ./PDF/$(TEST).pdf

clean:
	rm $(TARGET)
	rm DOT.dot