#!/usr/bin/env python
"""A quick python program to unformat json

Why?

Cause I just came accross a stupid web service that requires json to
be unformatted/unpretty.

Usage:

$ cat some.json | unformat-json.py > unformated-some.json
"""
import json
import sys
 
if __name__ == "__main__":
    json.dump(json.load(sys.stdin), sys.stdout)
