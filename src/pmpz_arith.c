/* pmpz_arith -- mpz arithmetic functions
 *
 * Copyright (C) 2011 Daniele Varrazzo
 *
 * This file is part of the PostgreSQL GMP Module
 *
 * The PostgreSQL GMP Module is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 3 of the License,
 * or (at your option) any later version.
 *
 * The PostgreSQL GMP Module is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
 * General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with the PostgreSQL GMP Module.  If not, see
 * http://www.gnu.org/licenses/.
 */

#include "pmpz.h"
#include "pgmp-impl.h"

#include "fmgr.h"


/*
 * Unary minus, plus
 */

PGMP_PG_FUNCTION(pmpz_uminus)
{
    const mpz_t     z1;
    mpz_t           zf;
    pmpz            *res;

    mpz_from_pmpz(z1, PG_GETARG_PMPZ(0));

    mpz_init_set(zf, z1);
    mpz_neg(zf, zf);

    res = pmpz_from_mpz(zf);
    PG_RETURN_POINTER(res);
}

PGMP_PG_FUNCTION(pmpz_uplus)
{
    const pmpz      *pz1;
    pmpz            *res;

    pz1 = PG_GETARG_PMPZ(0);

	res = (pmpz *)palloc(VARSIZE(pz1));
	memcpy(res, pz1, VARSIZE(pz1));

    PG_RETURN_POINTER(res);
}


/*
 * Binary operators
 */

/* Template to generate regular binary operators */

#define PMPZ_OP(op) \
 \
PGMP_PG_FUNCTION(pmpz_ ## op) \
{ \
    const mpz_t     z1; \
    const mpz_t     z2; \
    mpz_t           zf; \
    pmpz            *res; \
 \
    mpz_from_pmpz(z1, PG_GETARG_PMPZ(0)); \
    mpz_from_pmpz(z2, PG_GETARG_PMPZ(1)); \
 \
    mpz_init(zf); \
    mpz_ ## op (zf, z1, z2); \
 \
    res = pmpz_from_mpz(zf); \
    PG_RETURN_POINTER(res); \
}

PMPZ_OP(add)
PMPZ_OP(sub)
PMPZ_OP(mul)


/* Template to generate binary operators that may divide by zero */

#define PMPZ_OP_DIV(op) \
 \
PGMP_PG_FUNCTION(pmpz_ ## op) \
{ \
    const mpz_t     z1; \
    const mpz_t     z2; \
    mpz_t           zf; \
    pmpz            *res; \
 \
    mpz_from_pmpz(z2, PG_GETARG_PMPZ(1)); \
    if (UNLIKELY(MPZ_IS_ZERO(z2))) \
    { \
        ereport(ERROR, ( \
            errcode(ERRCODE_DIVISION_BY_ZERO), \
            errmsg("division by zero"))); \
    } \
 \
    mpz_from_pmpz(z1, PG_GETARG_PMPZ(0)); \
 \
    mpz_init(zf); \
    mpz_ ## op (zf, z1, z2); \
 \
    res = pmpz_from_mpz(zf); \
    PG_RETURN_POINTER(res); \
}

PMPZ_OP_DIV(tdiv_q)
PMPZ_OP_DIV(tdiv_r)
PMPZ_OP_DIV(cdiv_q)
PMPZ_OP_DIV(cdiv_r)
PMPZ_OP_DIV(fdiv_q)
PMPZ_OP_DIV(fdiv_r)


/* Functions defined on bit count */

#define PMPZ_BIT(op) \
 \
PGMP_PG_FUNCTION(pmpz_ ## op) \
{ \
    const mpz_t     z; \
    long            b; \
    mpz_t           zf; \
    pmpz            *res; \
 \
    mpz_from_pmpz(z, PG_GETARG_PMPZ(0)); \
    b = PG_GETARG_INT32(1); \
 \
    if (UNLIKELY(b < 0)) { \
        ereport(ERROR, ( \
            errcode(ERRCODE_INVALID_PARAMETER_VALUE), \
            errmsg("op2 can't be negative") )); \
    } \
 \
    mpz_init(zf); \
    mpz_ ## op (zf, z, (unsigned long)b); \
 \
    res = pmpz_from_mpz(zf); \
    PG_RETURN_POINTER(res); \
}

PMPZ_BIT(mul_2exp)


/*
 * Comparison operators
 */

PG_FUNCTION_INFO_V1(pmpz_cmp);

Datum       pmpz_cmp(PG_FUNCTION_ARGS);

Datum
pmpz_cmp(PG_FUNCTION_ARGS)
{
    const mpz_t     z1;
    const mpz_t     z2;

    mpz_from_pmpz(z1, PG_GETARG_PMPZ(0));
    mpz_from_pmpz(z2, PG_GETARG_PMPZ(1));

    PG_RETURN_INT32(mpz_cmp(z1, z2));
}


#define PMPZ_CMP(op, rel) \
 \
PGMP_PG_FUNCTION(pmpz_ ## op) \
{ \
    const mpz_t     z1; \
    const mpz_t     z2; \
 \
    mpz_from_pmpz(z1, PG_GETARG_PMPZ(0)); \
    mpz_from_pmpz(z2, PG_GETARG_PMPZ(1)); \
 \
    PG_RETURN_BOOL(mpz_cmp(z1, z2) rel 0); \
}

PMPZ_CMP(eq, ==)
PMPZ_CMP(ne, !=)
PMPZ_CMP(gt, >)
PMPZ_CMP(ge, >=)
PMPZ_CMP(lt, <)
PMPZ_CMP(le, <=)

