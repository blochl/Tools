/*** For demo ***/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/****************/
#include <stdint.h>

/* A fast approximation of the exponential function.
 * Reference [1]: https://schraudolph.org/pubs/Schraudolph99.pdf
 * Reference [2]: http://dx.doi.org/10.1162/089976600300015033
 * Additional improvements by Leonid Bloch. */

/* use just EXP_A = 1512775 for integer version, to avoid FP calculations */
#define EXP_A (1512775.3951951856938)  /* 2^20/ln2 */
/* For min. RMS error */
#define EXP_BC 1072632447              /* 1023*2^20 - 60801 */
/* For min. max. relative error */
/* #define EXP_BC 1072647449 */        /* 1023*2^20 - 45799 */
/* For min. mean relative error */
/* #define EXP_BC 1072625005 */        /* 1023*2^20 - 68243 */

static inline double fast_exp (double y)
{
    union
    {
        double d;
        struct { int32_t i, j; } n;
        uint8_t t[8];
    } _eco = { .n.i = 1 };

    switch(_eco.t[0]) {
        case 1:
            /* Little endian */
            _eco.n.j = (int32_t)(EXP_A*(y)) + EXP_BC;
            _eco.n.i = 0;
            break;
        case 0:
            /* Big endian */
            _eco.n.i = (int32_t)(EXP_A*(y)) + EXP_BC;
            _eco.n.j = 0;
            break;
    }

    return _eco.d;
}

/*** For demo ***/

int main(int argc, char **argv)
{
    double i = atof(argv[1]);
    double mexp = exp(i);
    double sexp = fast_exp(i);
    double diff = mexp - sexp;
    /* double reldiff = diff / mexp; */
    printf("%f %f %f %f\n", i, mexp, sexp, diff);
}
