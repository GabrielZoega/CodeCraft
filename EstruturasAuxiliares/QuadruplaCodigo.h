#ifndef QUADRUPLA_CODIGO
#define QUADRUPLA_CODIGO

typedef struct QuadruplaCodigo{
    char *op;
    char *arg1;
    char *arg2;
    char *result;
} QuadruplaCodigo;

typedef struct vetorQuadruplas{
    QuadruplaCodigo *quadrupla;
    int tamanho;
    int capacidade;
}vetorQuadruplas;


// Funções do Vetor
void inicializarVetor(vetorQuadruplas *vetor, int capacidade);
void inserirVetor(vetorQuadruplas *vetor, QuadruplaCodigo QuadruplaCodigo);
void liberarVetor(vetorQuadruplas *vetor);


#endif