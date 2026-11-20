import sys

import numpy as np


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} SIZE (positive integer)", file=sys.stderr)
        return 2
    try:
        n = int(sys.argv[1])
    except ValueError:
        print("SIZE must be a positive integer", file=sys.stderr)
        return 2
    if n <= 0:
        print("SIZE must be a positive integer", file=sys.stderr)
        return 2

    # Integer-valued float64 inputs, identical to the C implementation.
    i = np.arange(n, dtype=np.int64)[:, None]
    j = np.arange(n, dtype=np.int64)[None, :]
    a = ((i + j) % 7 - 3).astype(np.float64)
    b = ((2 * i + j) % 5 - 2).astype(np.float64)

    c = a @ b  # Delegated to NumPy's optimized native matrix multiplication.
    # Position-weighted checksum, matching the C implementation. Entries of c
    # are exact integers, so summing as int64 is order-independent.
    weights = np.arange(n * n, dtype=np.int64) % 1000 + 1
    checksum = int((c.astype(np.int64).ravel() * weights).sum())
    print(f"checksum={checksum}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
