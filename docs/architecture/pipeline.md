# The pipeline

velocitee is a sequential pipeline of independent engines. Each engine does
one thing, writes a structured handoff manifest, and passes it to the next.

```
bare metal ──► VME ──► VNE ──► VSE ──► VLE ──► documented, running stack
              provision  network  services  lifecycle
```

## Why pipeline, not monolith

Three reasons.

**Composability.** Most users only need one or two phases. A homelab
operator who already has working infrastructure can run only VME, or only
VNE on an existing host — without touching the rest. Each engine is
independently useful.

**Bounded blast radius.** A failure in VSE doesn't undo VNE. Manifests are
checkpoints — if a phase fails, the stage *before* it is still valid and
re-runnable. The system never lands in a half-configured state where it's
unclear what's done.

**Phased shipping.** VME shipped first because it's the prerequisite. VNE
shipped next because it's the next prerequisite. Each engine ships when it
is solid, not when the whole stack is finished. That's how a one-person
project ships at all.

## How handoff works

Every engine writes a JSON manifest validated against
[`shared/schema.json`](https://github.com/velocit-ee/core/blob/main/shared/schema.json).
The next engine reads that manifest as its primary input.

The manifest has three top-level keys:

| Key             | Owner | Meaning |
|-----------------|-------|---------|
| `target`        | VME   | The provisioned host — hostname, IP, OS, disk, MAC. |
| `access`        | VME   | How later engines reach it — username, SSH key, port. |
| `engines.<name>`| each engine | Per-engine record of status, version, timing, and engine-specific outputs. |

VME initialises `target` and `access`. Every subsequent engine
*appends* its own record under `engines.<name>` and re-validates. The
manifest never shrinks; previous engines' records remain.

See the [handoff manifest reference](manifest.md) for the schema in detail.

## Phase ordering inside an engine

VNE introduced *renderer phases* — `infra` and `config`. The pipeline
orchestrator enforces the order:

```
all 'infra' renderers ──►  all 'config' renderers
```

If any infra renderer fails, every config renderer in the same pipeline is
*skipped*, not run. This matters most for the `opentofu+ansible` backend:
OpenTofu fails → Ansible never runs (which would otherwise see a missing VM
and produce unhelpful errors).

Renderers tagged `both` cover both phases themselves and slot between
infra and config.

See the [renderer model](renderers.md) for the full contract.

## Re-running is always safe

Every engine is **idempotent**. Re-running a phase against an
already-completed system is a no-op or a fast reconciliation. If state on
disk says "step done" but the live API disagrees (someone deleted the VM by
hand), VNE reconciles to truth — re-creates rather than blindly trusting
state.

Where engines need to remember progress between runs, they version their
state file and refuse to silently load a schema-mismatched one. Loud
failures with recovery instructions, never silent corruption.
