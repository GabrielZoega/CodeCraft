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

    for (int i = 0; i < vetor->tamanho; i++) {
        free(vetor->quadrupla[i].op);
        free(vetor->quadrupla[i].arg1);
        free(vetor->quadrupla[i].arg2);
        free(vetor->quadrupla[i].result);
    }

    free(vetor->quadrupla);
    vetor->quadrupla = NULL;
    vetor->tamanho = 0;
    vetor->capacidade = 0;
}