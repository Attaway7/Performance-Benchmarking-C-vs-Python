#!/usr/bin/env python3
import sys


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} LIMIT (nonnegative integer)", file=sys.stderr)
        return 2

    try:
        if sys.argv[1].startswith("-"):
            raise ValueError
        limit = int(sys.argv[1])
        if limit < 0:
            raise ValueError
    except ValueError:
        print(f"Invalid limit: {sys.argv[1]}", file=sys.stderr)
        return 2

    if limit < 2:
        print("count=0 last=0")
        return 0

    # Each byte stores 0 for composite and 1 for potentially prime.
    is_prime = bytearray(limit + 1)
    for i in range(limit + 1):
        is_prime[i] = 1
    is_prime[0] = 0
    is_prime[1] = 0

    for p in range(2, limit + 1):
        if p > limit // p:
            break
        if is_prime[p]:
            multiple = p * p
            while multiple <= limit:
                is_prime[multiple] = 0
                multiple += p

    count = 0
    last = 0
    for n in range(2, limit + 1):
        if is_prime[n]:
            count += 1
            last = n

    print(f"count={count} last={last}")
    return 0


if __name__ == "__main__":
    sys.exit(main())