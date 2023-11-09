#include <stdio.h>
#include "table_symbole.h" 
#include "y.tab.h"

tree *creerArbre(char* name, tree *fils, int line){
	tree *t = (tree*)malloc(sizeof(tree));
	t->nom = name;
	t->fils = fils;
	t->nbLine=line;
	t->suivants = NULL;
	t->node_name = NULL;
	t->typeNode = NUL;
	t->typeVar=NULE;
	t->ts = genererTS("#","#");
	return t;

}
symbole * genererTS(char * nom, char* type){
	symbole *ts = (symbole*)malloc(sizeof(symbole));
	ts->nom = nom;
	if(strcmp(type,"int") ==0){
		ts->type=TYPE_INT;
	} else if(strcmp(type,"void") ==0){
		ts->type=TYPE_VOID;
	}else{
		ts->type=NULE;
	}
	ts->dimension=0;
	ts->tailles = NULL;
	ts->suivants = NULL;
	ts->fils = NULL;
	ts->pere = NULL;
	ts->node_name=NULL;
	ts->nbParam=0;
	return ts;
}
void ecritNode(FILE *fichier,tree *t, int n){
	t->node_name = (char * ) malloc(50 * sizeof(char));
	sprintf(t->node_name,"node_%d",n);
	if(strcmp("RETURN",t->nom) == 0){
		fprintf(fichier,"%s [label=\"%s\"shape=trapezium color=blue];\n",t->node_name,t->nom);
	}else if(strcmp("IF",t->nom) == 0){
		fprintf(fichier,"%s [label=\"%s\"shape=diamond];\n",t->node_name,t->nom);
	}else if(strcmp("BREAK",t->nom) == 0){
		fprintf(fichier,"%s [label=\"%s\"shape=box];\n",t->node_name,t->nom);
	}else if(APPEL==t->typeNode){
		fprintf(fichier,"%s [label=\"%s\"shape=septagon];\n",t->node_name,t->nom);
	}else if(FONCTION == t->typeNode || EXTER == t->typeNode){
		fprintf(fichier,"%s [label=\"%s\"shape=invtrapezium color=blue];\n",t->node_name,t->nom);
	}
	else if(strcmp("#",t->nom) != 0){
		fprintf(fichier,"%s [label=\"%s\"];\n",t->node_name,t->nom);
		}
}
void relieFils(FILE* fichier, tree* pere, tree* fils) {
    while (fils != NULL) {
        if (strcmp(fils->nom, "#") != 0) {
            fprintf(fichier, "%s -> %s;\n", pere->node_name, fils->node_name);
        }
        fils = fils->suivants;
    }
}
void ecritDot(tree *t){
	FILE *fd =  fopen("DOT.dot","w");
	fprintf(fd,"digraph mon_graphe {\n\n");
	tree *node = t;
	printdot(fd,node,0);
	relieRecusif(fd,node);
	fprintf(fd,"}");
	fclose(fd);
	
}
void relieRecusif(FILE *fd, tree *node) {
	if (node == NULL) {
		return;
	}
	if (strcmp(node->nom, "extern") != 0) {
		relieFils(fd, node, node->fils);
		relieRecusif(fd, node->fils);
	}
	relieRecusif(fd, node->suivants);
}
int printdot(FILE *fd, tree *node, int n) {
	while (node != NULL) {
		if (strcmp(node->nom, "extern") != 0) {
			ecritNode(fd, node, n);
			if (node->fils != NULL) {
				n = printdot(fd, node->fils, n + 1);
			}
		}
		node = node->suivants;
		n++;
	}
	return n;
}
int sizeFilsSymbole(symbole * t ){
	int ret = 0;
	while(t != NULL){
		if(strcmp(t->nom,"#") != 0){
			ret ++ ;}
		t = t->suivants;
	}
	return ret;
}
int sizeFils(tree * t ){
	int ret = 0;
	while(t != NULL){
		if(strcmp(t->nom,"#") != 0){
			ret ++ ;}
		t = t->suivants;
	}
	return ret;
}
void insertSuivant(tree *t1, tree *t2) {
	while (t1->suivants != NULL) {
		t1 = t1->suivants;
	}
	t1->suivants = t2;
}
void addType(tree *tree, char* type) {
	while (tree != NULL) {
		if (strcmp("int", type) == 0) {
			tree->typeVar = TYPE_INT;
		} else if (strcmp("tab", type) == 0) {
			tree->typeVar = TYPE_TAB;
		} else {
			tree->typeVar = TYPE_VOID;
		}
		tree = tree->suivants;
	}
}
void addTypeSymbole(symbole * symb, char* type){
	while (symb != NULL) {
		if (strcmp("int", type) == 0) {
			symb->type = TYPE_INT;
		} else if (strcmp("void", type) == 0) {
			symb->type = TYPE_VOID;
		} else {
			symb->type = NULE;
		}
		symb = symb->suivants;
	}
}
void insertSuivantSymbole(symbole * s1, symbole * s2){
	if(s1->suivants == NULL){
		s1->suivants = s2;
	}
	else {
		insertSuivantSymbole(s1->suivants, s2);
	}
}
int isPresence(char * id, symbole *s,int nbPar){
	if(s->pere==NULL){
		return 0;
	}
	s=s->pere->fils;
	
	if(strcmp(s->nom,id) == 0 && s->nbParam == nbPar ){
			symbole *fils= s->suivants->fils;
			int res=0;
			for(int i = 0; i<=nbPar; i = i+1){
				if(fils!= NULL){
					if(strcmp(fils->nom,"TAB") == 0 ){
						res=res+isPresenceTAB(fils->fils->nom,fils,fils->dimension,fils->tailles);
					}else{
						res=res+verifyType(fils->nom,fils,TYPE_INT);
					}
				fils = fils->suivants;
				}
			}
			return res==nbPar;
		}
	while(s->suivants!=NULL){
		if(strcmp(s->suivants->nom,id) == 0 && s->suivants->nbParam == nbPar ){
			symbole *fils= s->suivants->fils;
			int res=0;
			for(int i = 0; i<=nbPar; i = i+1){
				if(fils!= NULL){
					if(strcmp(fils->nom,"TAB") == 0 ){
						res=res+isPresenceTAB(fils->fils->nom,fils,fils->dimension,fils->tailles);
					}else{
						res=res+verifyType(fils->nom,fils,TYPE_INT);
					}
				fils = fils->suivants;
				}
			}
			return res==nbPar;
		}
		s=s->suivants;
	}
	isPresence(id,s->pere,nbPar);
}
int isPresenceTAB(char * id, symbole *s,int nbPar, int *tailles){
	if(s->pere==NULL){
		return 0;
	}
	s=s->pere->fils;
	if(strcmp(s->nom,"TAB") == 0  && strcmp(s->fils->nom,id) == 0 && s->dimension == nbPar ){
			return verifyTaille(s->tailles,tailles,nbPar);
		}
	while(s->suivants!=NULL){
		if(strcmp(s->suivants->nom,"TAB") == 0   && strcmp(s->suivants->fils->nom,id) == 0 && s->suivants->dimension == nbPar ){
			return verifyTaille(s->suivants->tailles,tailles,nbPar);
		}
		s=s->suivants;
	}
	isPresenceTAB(id,s->pere,nbPar,tailles);	
}
int isPresenceFonc(const char* id, symbole* s, int add) {
    if (s == NULL) {
        return add;
    }
    if (strcmp(s->nom, id) == 0) {
        add++;
    }
    return isPresenceFonc(id, s->pere, add);
}
int verifyTaille(int * tab1,int *tab2,int size){
	for(int i = 0; i < size ; i++ ){
		if( tab2[i] >= tab1[i]){
			return 0;
		}
	}
	return 1;
}
int verifyType(char * id, symbole * s,type_var t){
	if(s->pere==NULL){
		return 0;
	}
	s=s->pere->fils;

	if(strcmp(s->nom,id) == 0){
			if(s->type == t ){
				return 1;
			}
		}

	while(s->suivants!=NULL){
		if(strcmp(s->suivants->nom,id) == 0){
			if(s->suivants->type == t ){
				return 1;
			}
		}
		s=s->suivants;
	}
	
	verifyType(id,s->pere,t);
}
int validateAffectation(tree* t, int b) {
    while (t != NULL) {
        if (t->typeNode == APPEL) {
            int result = verifyType(t->nom, t->ts, TYPE_INT);
            b = (result < b) ? result : b;
        }
        if (t->typeVar == TYPE_TAB) {
            int result = isPresenceTAB(t->fils->nom, t->ts, t->ts->dimension, t->ts->tailles);
            b = (result < b) ? result : b;
        }
        if (t->fils != NULL) {
            int result = validateAffectation(t->fils, b);
            b = (result < b) ? result : b;
        }
        t = t->suivants;
    }
    return b;
}
int verifyRetour(tree* t, type_var type, int b) {
    while (t != NULL) {
        if (t->typeNode == RET) {
            if (t->fils != NULL) {
                int result = validateAffectation(t->fils, 1);
                b = (result < b) ? result : b;
            } else {
                b = (b > 1) ? 1 : b;
            }
        }
        if (t->fils != NULL) {
            int result = verifyRetour(t->fils, type, b);
            b = (result < b) ? result : b;
        }
        t = t->suivants;
    }
    return b;
}
void verifieDef(tree* t, int n) {
    while (t != NULL) {
        switch (t->typeNode) {
            case FONCTION:
                if (isPresenceFonc(t->ts->nom, t->fils->ts, 0) >= 2) {
                    char* s = malloc(300 * sizeof(char));
                    sprintf(s, "redéfinition de la fonction %s", t->ts->nom);
                    afficheErreur(s, t->fils->nbLine);
                    free(s);
                }
                if (t->typeVar == TYPE_INT) {
                    int retourValide = verifyRetour(t->fils, t->ts->type, 2);
                    if (retourValide == 0) {
                        afficheErreur(t->nom, t->fils->nbLine);
                    } else if (retourValide > 1) {
                        retourValide = 0;
                    }
                } else {
                    if (verifyRetour(t->fils, t->ts->type, 2) == 1) {
                        fprintf(stderr, "Warning : return dans une fonction void line: %d\n", t->fils->nbLine);
                    }
                }
                break;
            case VAR:
                if (t->typeVar == TYPE_TAB) {
                    int presenceTab = isPresenceTAB(t->fils->nom, t->ts, t->ts->dimension, t->ts->tailles);
                    if (presenceTab == 0) {
                        afficheErreur(t->fils->nom, t->fils->nbLine);
                    }
                } else {
                    int presenceVar = isPresence(t->nom, t->ts, 0);
                    if (presenceVar == 0) {
                        afficheErreur(t->nom, t->nbLine);
                    }
                }
                break;
            case APPEL:
                if (isPresence(t->nom, t->ts, sizeFils(t->fils)) == 0) {
                    afficheErreur(t->nom, t->nbLine);
                }
                break;
            case AFFECTATION:
            case COMP: {
                int validateAffect = validateAffectation(t->fils->suivants, 1);
                if (validateAffect == 0) {
                    char* nomErreur = strcmp(t->fils->nom, "TAB") == 0 ? t->fils->fils->nom : t->fils->nom;
                    afficheErreur(nomErreur, t->nbLine);
                }
                break;
            }
            default:
                break;
        }
        verifieDef(t->fils, n + 1);
        t = t->suivants;
    }
}
void reliePere(symbole *pere, symbole *fils) {
    while (fils != NULL) {
        fils->pere = pere;
        fils = fils->suivants;
    }
}
void pereRecusif(symbole *node) {
    if (node == NULL) {
        return;
    }
    reliePere(node, node->fils);
    pereRecusif(node->fils);
    pereRecusif(node->suivants);
}
void afficheErreur(char * s,int line){
	fprintf(stderr,"erreur de sémantique %s à la ligne %d\n",s,line);
	exit(1);
}
void initialiseTAB(int* p,symbole * f,int index){
	if(f !=NULL){
		p[index] = atoi(f->nom);
		initialiseTAB(p,f->suivants,index+1);
	}
}