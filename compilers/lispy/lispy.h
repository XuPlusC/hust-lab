/*
 * lispy.h
 * Copyright (C) 2016 sabertazimi <sabertazimi@avalon>
 *
 * Distributed under terms of the MIT license.
 */

#ifndef LISPY_H
#define LISPY_H

#include "mpc.h"

#define LASSERT(args, cond, err)    \
    do {                            \
        if (!(cond)) {              \
            lval_del(args);         \
            return lval_err(err);   \
        }                           \
    } while (0)                     \

enum {
    LVAL_ERR,
    LVAL_NUM,
    LVAL_SYM,
    LVAL_SEXPR,
    LVAL_QEXPR
};

typedef struct lval {
    int type;

    long num;
    char *err;
    char *sym;

    int count;
    struct lval **cell;
} lval;

/* Contruct new lval node */
lval *lval_num(long x);
lval *lval_err(char *m);
lval *lval_sym(char *s);
lval *lval_sexpr(void);
lval *lval_qexpr(void);

/* Basic operator for lval list */
void lval_del(lval *v);
lval *lval_add(lval *v, lval *x);
lval *lval_pop(lval *v, int i);
lval *lval_join(lval *x, lval *y);
lval *lval_take(lval *v, int i);

/* Screen display functions */
void lval_print(lval *v);
void lval_expr_print(lval *v, char open, char close);
void lval_print(lval *v);
void lval_println(lval *v);

#endif /* !LISPY_H */