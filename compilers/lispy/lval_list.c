/*
 * lval_list.c
 * Copyright (C) 2016 sabertazimi <sabertazimi@avalon>
 *
 * Distributed under terms of the MIT license.
 */

#include "lispy.h"

void lval_del(lval *v) {
    switch(v->type) {
        case LVAL_NUM:
            break;
        case LVAL_ERR:
            free(v->err);
            break;
        case LVAL_SYM:
            free(v->sym);
            break;

        /* If Sepxr of Qexpr, then delete all elements inside */
        case LVAL_SEXPR:
        case LVAL_QEXPR:
            for (int i = 0; i < v->count; i++) {
                lval_del(v->cell[i]);
            }

            free(v->cell);
            break;
    }

    free(v);
}

lval *lval_add(lval *v, lval *x) {
    v->count++;
    v->cell = (lval **)realloc(v->cell, sizeof(lval *) * v->count);
    v->cell[v->count - 1] = x;
    return v;
}

lval *lval_pop(lval *v, int i) {
    lval *x = v->cell[i];
    memmove(&v->cell[i], &v->cell[i + 1],
        sizeof(lval *) * (v->count - i - 1));
    v->count--;
    v->cell = (lval **)realloc(v->cell, sizeof(lval *) * v->count);
    return x;
}

lval *lval_join(lval *x, lval *y) {
    while (y->count) {
        x = lval_add(x, lval_pop(y, 0));
    }

    lval_del(y);
    return x;
}

lval *lval_take(lval *v, int i) {
    lval *x = lval_pop(v, i);
    lval_del(v);
    return x;
}

