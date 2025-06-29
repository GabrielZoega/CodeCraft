#ifndef LISTA_EXPRESSOES_H
#define LISTA_EXPRESSOES_H

typedef enum {T_INT, T_FLOAT, T_BOOL, T_STRING, T_CHAR, T_NULO, T_DOUBLE} TipoSimples;

typedef struct ListaExpressoes {
    TipoSimples tipoExpr;
    int flagId;
    union {
        int intVal;
        float floatVal;
        double doubleVal;
        char *stringVal;
        char *charVal;
        char *boolVal;
        char *nuloVal;
    } valor;
    char *temp;
} ListaExpressoes;

#endif