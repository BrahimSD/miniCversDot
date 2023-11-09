#ifndef _TABLE_H
#define _TABLE_H
typedef enum {FONCTION,AFFECTATION,APPEL,NUL,VAR,RET,EXTER,COMP} type_t;
typedef enum {TYPE_INT, TYPE_VOID, TYPE_TAB,NULE} type_var;

typedef struct _symbole { 
    char *nom;
    int nbParam;
    type_var type;
    char *node_name;
    int dimension;
    int *tailles;
    struct _symbole *suivants;
    struct _symbole *fils;
    struct _symbole *pere;
} symbole;

typedef struct _tree {
    char *nom; 
    struct _symbole *ts;
    char *node_name;
    type_t typeNode;
    type_var typeVar;
    struct _tree *fils;
    struct _tree *suivants;
    int nbLine;
} tree;

typedef struct _bloc{
    struct _tree *pere;
    struct _symbol *table;

} bloc;

tree *creerArbre(char* name, tree *fils,int line);
symbole * genererTS(char * nom, char* type);
void ecritDot(tree *t);
int sizeFils(tree * t );
void insertSuivant(tree * t1, tree * t2);
void addType(tree * tree, char* type);
void addTypeSymbole(symbole * symb, char* type);
void insertSuivantSymbole(symbole* s1, symbole* s2);
void pereRecusif(symbole * node);
void verifieDef(tree * t, int n);
int sizeFilsSymbole(symbole * t );
void initialiseTAB(int* p,symbole * f,int index);
#endif