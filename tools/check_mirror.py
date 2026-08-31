#!/usr/bin/env python3
"""Verify this repo's mirrored engine-status files match the canonical copies.

`velocit-ee/core` owns the engine-status system. Three files plus its test are
copied verbatim into `velocit-ee/docs` and `velocit-ee/.github` so those repos
can render their own status regions without depending on a package:

    engines.json                        the data
    tools/engines_schema.json           its schema
    tools/render_engine_status.py       the renderer
    tools/tests/test_render_engine_status.py

Each repo's CI already runs `render_engine_status.py --check`, which proves the
rendered regions match *that repo's own* `engines.json`. Nothing proved the
copies matched each other — so promoting VME to Beta in core and forgetting to
mirror it left the docs site claiming Alpha with a green build on both sides.
That is exactly the class of drift the whole single-source-of-truth design
exists to prevent, and it was the one hole in it.

This closes it: fetch the canonical copies from core and compare byte for byte.

Usage:
    python tools/check_mirror.py            # verify (exit 1 on drift)
    python tools/check_mirror.py --write    # pull the canonical copies down

Ordering note: the check compares against core's default branch. When a change
originates in core, land it there first — a mirroring repo's CI will correctly
fail until core's `main` carries the new version. Override with CORE_REF to
compare against a branch or tag while a change is in flight:

    CORE_REF=my-branch python tools/check_mirror.py
"""

from __future__ import annotations

import argparse
import difflib
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

MIRRORED = (
    "engines.json",
    "tools/engines_schema.json",
    "tools/render_engine_status.py",
    "tools/tests/test_render_engine_status.py",
)

CORE_REF = os.environ.get("CORE_REF", "main")
CORE_RAW = os.environ.get(
    "CORE_RAW_URL", f"https://raw.githubusercontent.com/velocit-ee/core/{CORE_REF}"
)

TIMEOUT = 20


def fetch(rel: str) -> str:
    url = f"{CORE_RAW}/{rel}"
    try:
        with urllib.request.urlopen(url, timeout=TIMEOUT) as resp:
            return resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        raise SystemExit(
            f"error: {url} returned HTTP {exc.code}.\n"
            f"       If the file was added in core but not yet merged to "
            f"'{CORE_REF}', set CORE_REF to the branch carrying it."
        ) from exc
    except urllib.error.URLError as exc:
        raise SystemExit(
            f"error: could not reach {url}: {exc.reason}\n"
            f"       This check needs network access to raw.githubusercontent.com."
        ) from exc


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--check", action="store_true", default=True,
                       help="report drift and exit non-zero (default)")
    group.add_argument("--write", action="store_true",
                       help="overwrite local copies with the canonical ones")
    parser.add_argument("--root", type=Path, default=Path("."),
                        help="repo root (default: cwd)")
    args = parser.parse_args(argv)

    drifted: list[str] = []

    for rel in MIRRORED:
        local_path = args.root / rel
        canonical = fetch(rel)

        if args.write:
            local_path.parent.mkdir(parents=True, exist_ok=True)
            local_path.write_text(canonical)
            print(f"synced: {rel}")
            continue

        if not local_path.exists():
            print(f"MISSING: {rel} (present in core, absent here)", file=sys.stderr)
            drifted.append(rel)
            continue

        local = local_path.read_text()
        if local == canonical:
            print(f"ok: {rel}")
            continue

        drifted.append(rel)
        print(f"\nDRIFT: {rel}", file=sys.stderr)
        diff = difflib.unified_diff(
            canonical.splitlines(keepends=True),
            local.splitlines(keepends=True),
            fromfile=f"velocit-ee/core@{CORE_REF}/{rel}",
            tofile=f"(this repo)/{rel}",
        )
        sys.stderr.writelines(diff)

    if args.write:
        return 0

    if drifted:
        print(
            f"\n{len(drifted)} file(s) have drifted from velocit-ee/core@{CORE_REF}:\n"
            + "".join(f"  - {f}\n" for f in drifted)
            + "\nFix with:  python tools/check_mirror.py --write\n"
            "If the change should originate here instead, make it in core first.",
            file=sys.stderr,
        )
        return 1

    print(f"\nall {len(MIRRORED)} mirrored files match velocit-ee/core@{CORE_REF}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
