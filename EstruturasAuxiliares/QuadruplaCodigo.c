#include "QuadruplaCodigo.h"
#include <stdio.h>
#include <stdlib.h>

void inicializarVetor(vetorQuadruplas *vetor, int capacidadeInicial){
    vetor->quadrupla = (QuadruplaCodigo *)malloc(capacidadeInicial * sizeof(QuadruplaCodigo));
    vetor->tamanho = 0;
    vetor->capacidade = capacidadeInicial;
}

void inserirVetor(vetorQuadruplas *vetor, QuadruplaCodigo quadruplaCodigo){
    if (vetor->tamanho == vetor->capacidade){
        vetor->capacidade *= 2;
        vetor->quadrupla = (QuadruplaCodigo *)realloc(vetor->quadrupla, vetor->capacidade * sizeof(QuadruplaCodigo));
    }
    vetor->quadrupla[vetor->tamanho] = quadruplaCodigo;
    vetor->tamanho++;
}

void liberarVetor(vetorQuadruplas *vetor){
    free(vetor->quadrupla);
    vetor->quadrupla = NULL;
    vetor->tamanho = 0;
    vetor->capacidade = 0;
}