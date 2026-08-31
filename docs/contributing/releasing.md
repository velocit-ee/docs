# Releasing

Releases follow [Semantic Versioning](https://semver.org/) and
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Cadence

- Engines version independently. VME and VNE each have their own version
  number.
- The shared library (`shared/`) versions independently from the engines.

## Steps

1. Update the engine's `__version__` and `pyproject.toml` `[project]
   version`.
2. Move the `Unreleased` section of the top-level `CHANGELOG.md` under a
   new `## [x.y.z] — YYYY-MM-DD` heading; start a fresh `Unreleased`
   block.
3. Open a PR with the version bump and changelog. Title:
   `release: <engine> <version>`.
4. Merge. Tag the merge commit `<engine>-v<version>` (e.g. `vne-v0.1.0`).
   Push the tag.
5. The release workflow on GitHub Actions builds and publishes the wheel.

## Pre-1.0 stability promise

Every engine starts at `0.x` while its API is still iterating. We don't
promise contract stability across `0.x → 0.y` minor bumps — but we do
try, and breaking changes go in the changelog under a `Breaking`
heading. Once an engine ships its first `1.0` release, the contract is
stable within the major version.

The status badge in the engine status table (driven by
[`engines.json`](https://github.com/velocit-ee/core/blob/main/engines.json))
describes maturity, not contract stability — that comes with `1.0`. The
ladder has four rungs, and an engine does not claim a rung it has not
reached:

| Status      | What it means |
|-------------|---------------|
| **Planned** | No implementation yet. |
| **Alpha**   | Implemented and usable, but the primary execution paths are not yet covered by automated tests, and interfaces may still change. |
| **Beta**    | Feature-complete for its declared scope, with its main paths under test. Interfaces settling. |
| **Stable**  | Interfaces are committed; breaking changes go through deprecation. |

Moving an engine up a rung is a deliberate change to `engines.json`,
reviewed like any other. "It works on my hardware" is evidence for
Alpha, not for Beta — Beta requires the tests to exist.
