#include <errno.h>
#include <inttypes.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    if (argc != 2 || argv[1][0] == '-') {
        fprintf(stderr, "Usage: %s LIMIT (nonnegative integer)\n", argv[0]);
        return 2;
    }

    errno = 0;
    char *end = NULL;
    uintmax_t parsed = strtoumax(argv[1], &end, 10);
    if (errno != 0 || end == argv[1] || *end != '\0' || parsed > SIZE_MAX - 1) {
        fprintf(stderr, "Invalid limit: %s\n", argv[1]);
        return 2;
    }
    size_t limit = (size_t)parsed;

    if (limit < 2) {
        puts("count=0 last=0");
        return 0;
    }

    /* Each byte stores 0 for composite and 1 for potentially prime. */
    unsigned char *is_prime = malloc(limit + 1);
    if (is_prime == NULL) {
        fprintf(stderr, "Unable to allocate sieve\n");
        return 1;
    }

    for (size_t i = 0; i <= limit; ++i) {
        is_prime[i] = 1;
    }
    is_prime[0] = 0;
    is_prime[1] = 0;

    /* p <= limit / p avoids overflow from p * p in the condition. */
    for (size_t p = 2; p <= limit / p; ++p) {
        if (is_prime[p]) {
            for (size_t multiple = p * p; multiple <= limit;) {
                is_prime[multiple] = 0;
                /* Avoid overflowing size_t when advancing past limit. */
                if (multiple > limit - p) {
                    break;
                }
                multiple += p;
            }
        }
    }

    size_t count = 0;
    size_t last = 0;
    for (size_t n = 2; n <= limit; ++n) {
        if (is_prime[n]) {
            ++count;
            last = n;
        }
    }
    printf("count=%zu last=%zu\n", count, last);
    free(is_prime);
    return 0;
}
