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
promise stability across `0.x → 0.y` minor bumps for engines marked
"Active (initial)" — but we do try, and breaking changes go in the
changelog under a `Breaking` heading.

Engines marked **Active** without qualification have a stable contract
within a major version.
