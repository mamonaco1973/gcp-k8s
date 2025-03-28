#!/usr/bin/python3

import urllib.request
import sys

# Check if the command line argument is provided
if len(sys.argv) != 2:
    print("Usage: python test_candidates.py <base_url>")
    sys.exit(1)

# Get the base URL from the command line argument
base_url = sys.argv[1]

# Ensure the base_url starts with "http:" or "https:"
if not (base_url.startswith("http:") or base_url.startswith("https:")):
    base_url = f"http://{base_url}"

try:
    with urllib.request.urlopen(f'{base_url}/gtg') as gtg:
        if gtg.code == 200:
            print(u'\033[90m\N{check mark}\033[0m good to go passed')
        else:
            raise Exception
except Exception as ex:
    print(u'\033[91m\N{ballot x}\033[0m good to go failed:', getattr(ex, 'reason', str(ex)))

try:
    with urllib.request.urlopen(f'{base_url}/candidate/John%20Smith', data=b'test') as insert:
        if insert.code == 200:
            print(u'\033[90m\N{check mark}\033[0m insert passed')
        else:
            raise Exception
except Exception as ex:
    print(u'\033[91m\N{ballot x}\033[0m insert failed:', getattr(ex, 'reason', str(ex)))

try:
    with urllib.request.urlopen(f'{base_url}/candidate/John%20Smith') as verify:
        if verify.code == 200:
            print(u'\033[90m\N{check mark}\033[0m verification passed')
        else:
            raise Exception(code=verify.code)
except Exception as ex:
    print(u'\033[91m\N{ballot x}\033[0m verification failed:', getattr(ex, 'reason', str(ex)))

try:
    with urllib.request.urlopen(f'{base_url}/candidates') as list:
        if list.code == 200:
            print(u'\033[90m\N{check mark}\033[0m candidate list passed')
        else:
            raise Exception
except Exception as ex:
    print(u'\033[91m\N{ballot x}\033[0m candidate list failed:', getattr(ex, 'reason', str(ex)))
