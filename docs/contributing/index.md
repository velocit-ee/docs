# Contributing

velocitee is open source under Apache 2.0. Contributions are welcome — small
fixes, new backends, doc improvements, real-world deployment reports.

## Before you start

- All contributors must sign the
  [Contributor License Agreement](https://github.com/velocit-ee/core/blob/main/CLA.md)
  before a pull request can be merged.
- Read the [code of conduct](code-of-conduct.md).
- For non-trivial changes, open an issue first so we can agree on the shape
  of the change before code is written.

## Development setup

```bash
git clone https://github.com/velocit-ee/core
cd core/vme           # or core/vne, etc.
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt -r requirements-dev.txt
python -m pytest
```

## What to read first

- [Pipeline](../architecture/pipeline.md) — how engines compose.
- [Renderer model](../architecture/renderers.md) — the engine ↔ provisioner
  contract.
- The engine you're working on (VME or VNE README) for engine-local layout.

## Code standards

- Python 3.11+, type hints required, `ruff` clean.
- No comments that restate what the code does. Comments explain *why* —
  hidden constraints, subtle invariants, workarounds for specific quirks.
- No mocks for end-to-end behaviour — real Proxmox/OPNsense for VNE
  integration tests.
- Pin versions of all external tools (Terraform providers, Ansible
  collections). `>= x.y` constraints don't reproduce.

## Adding a provisioner backend

The fastest path to value: implement a stub. Stubs already have registry
entries; pick a stub from `shared/renderers/`, replace `_stub.make_stub()`
with a real `Renderer` subclass.

See [renderer model](../architecture/renderers.md#adding-a-backend) for the
full pattern.

## Releasing

See [releasing](releasing.md).
