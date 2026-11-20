#!/usr/bin/env python3
"""Validate known prime counts and identical C/Python outputs."""
import subprocess
import sys

EXPECTED = {
    0: (0, 0),
    1: (0, 0),
    2: (1, 2),
    10: (4, 7),
    100: (25, 97),
    1000: (168, 997),
    1000000: (78498, 999983),
}

COMMANDS = [
    ["./findprimes_O0"],
    ["./findprimes_O2"],
    [sys.executable, "findprimes.py"],
]


def main() -> None:
    for limit, (count, last) in EXPECTED.items():
        expected = f"count={count} last={last}\n"
        for command in COMMANDS:
            output = subprocess.check_output([*command, str(limit)], text=True)
            assert output == expected, (
                f"{command} {limit}: expected {expected!r}, got {output!r}"
            )
    print(f"PASS: {len(COMMANDS)} programs x {len(EXPECTED)} limits")


if __name__ == "__main__":
    main()
