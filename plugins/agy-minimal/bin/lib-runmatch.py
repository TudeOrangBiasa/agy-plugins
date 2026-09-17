"""lib-runmatch.py — shared run_command matching helpers for agy hooks.

Imported by block-bash-bypass.sh and stream-gate.sh via importlib
(spec_from_file_location; the hyphenated filename is not a valid module
name). Every importer MUST fall back to its previous inline logic if this
file is missing or broken — fail-open is preserved (bad payload, missing
file, or import failure allows, never crashes).
"""
import re


def strip_prose(s):
    """Drop heredoc bodies and quoted strings; $(...) is kept as code."""
    s = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n.*?^\1\s*$", " ", s, flags=re.DOTALL | re.MULTILINE)
    s = re.sub(r"'[^']*'", " ", s)
    s = re.sub(r'"(?:[^"\\]|\\.)*"', " ", s)
    return s


def leaves(o):
    """Yield string leaves of nested tool-call args (dicts/lists/strs)."""
    if isinstance(o, str):
        yield o
    elif isinstance(o, dict):
        for v in o.values():
            yield from leaves(v)
    elif isinstance(o, list):
        for v in o:
            yield from leaves(v)


def split_segments(cmd):
    """Split a shell command line into segments for per-part matching."""
    return re.split(r"[;&|\n]+", cmd)


def segment_head(seg):
    """Head word of a segment: sudo-prefixes stripped, basename taken."""
    seg = re.sub(r"^(sudo\s+)+", "", seg.strip())
    if not seg:
        return ""
    return seg.split(None, 1)[0].rsplit("/", 1)[-1]
