#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    if (argc != 2 || argv[1][0] == '-') {
        fprintf(stderr, "Usage: %s SIZE (positive integer)\n", argv[0]);
        return 2;
    }
    errno = 0;
    char *end = NULL;
    unsigned long long parsed = strtoull(argv[1], &end, 10);
    if (errno || end == argv[1] || *end != '\0' || parsed == 0 ||
        parsed > SIZE_MAX / sizeof(double) / parsed) {
        fprintf(stderr, "Invalid or too-large matrix size: %s\n", argv[1]);
        return 2;
    }
    size_t n = (size_t)parsed;
    size_t elements = n * n;
    double *a = malloc(elements * sizeof(*a));
    double *b = malloc(elements * sizeof(*b));
    double *c = calloc(elements, sizeof(*c));
    if (!a || !b || !c) {
        fprintf(stderr, "Could not allocate matrices\n");
        free(a); free(b); free(c);
        return 1;
    }

    for (size_t i = 0; i < n; ++i) {
        for (size_t j = 0; j < n; ++j) {
            a[i * n + j] = (double)((int)((i + j) % 7) - 3);
            b[i * n + j] = (double)((int)((2 * i + j) % 5) - 2);
        }
    }

    /* Deliberately straightforward i-j-k triple loop (not cache-blocked).
       This compares naive C with NumPy's optimized native BLAS backend. */
    for (size_t i = 0; i < n; ++i) {
        for (size_t j = 0; j < n; ++j) {
            double total = 0.0;
            for (size_t k = 0; k < n; ++k) {
                total += a[i * n + k] * b[k * n + j];
            }
            c[i * n + j] = total;
        }
    }

    /* Position-weighted checksum. Every entry of c is an exact integer, so
       summing in 64-bit integers gives a result independent of summation
       order, and the weights make transposed or misplaced entries visible. */
    long long checksum = 0;
    for (size_t idx = 0; idx < elements; ++idx) {
        checksum += (long long)c[idx] * (long long)(idx % 1000 + 1);
    }
    printf("checksum=%lld\n", checksum);
    free(a); free(b); free(c);
    return 0;
}