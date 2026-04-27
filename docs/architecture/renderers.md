# The renderer model

velocitee engines never speak provisioner syntax directly. They speak a
shared, provisioner-agnostic schema (`shared/schema.py`) — and one *renderer*
per backend translates that schema into a specific provisioner's API or DSL.

The benefit: one engine, many backends. Adding a new backend is one Python
class.

## Contract

A renderer is a subclass of `shared.renderer.Renderer`:

```python
class Renderer(ABC):
    name: str = ""              # registry key, e.g. "velocitee-native"
    phase: Phase = "both"       # "infra" | "config" | "both"

    def validate(self) -> list[str]: ...
    def execute(self, *, prior_outputs: dict[str, Any] | None = None) -> ProvisioningResult: ...
```

`validate()` is pure — no side effects, no API calls. It returns a list of
human-readable errors. Empty list means "OK to run." This is where renderers
declare their config-time prerequisites: required env vars, installed CLI
tools, reachable endpoints.

`execute()` does the work, idempotently, and returns a `ProvisioningResult`.

The pipeline calls `render()` (the standard entry point), which validates
then executes. Failure in either is recorded; failures in `infra` phase
gate `config` phase.

## Phase tags

| Phase   | Meaning |
|---------|---------|
| `infra` | Creates compute (VMs, storage, networks). |
| `config`| Configures running systems (API calls, file edits). |
| `both`  | Both phases handled in a single `execute()`. |

The pipeline orchestrator runs all `infra` renderers first, then all
`config` renderers. `both` renderers slot between.

If any `infra` renderer fails, `config` renderers in the same pipeline are
skipped, not run. This is enforced by the orchestrator, not by individual
renderers.

## Idempotency expectations

Every renderer is expected to be **safe to re-run**. The two patterns
velocitee uses:

1. **Live probe before action.** "Does this VLAN exist?" before creating it.
   "Is this VM running?" before starting. The live API is the source of
   truth.
2. **Versioned, atomic state files.** `vne/state/vne.state.json` records
   what's done so resume is fast. State and live API are reconciled — if
   they disagree, live wins and state is updated.

Renderers that talk to a stateful provisioner (Terraform, Pulumi) inherit
that provisioner's idempotency. Renderers that talk to APIs directly
(velocitee-native) handle it themselves.

## Composition

Some provisioners are inherently a sequence of two backends. The registry
handles this via tuples:

```python
register("opentofu+ansible", OpenTofuRenderer, AnsibleRenderer)
```

VNE looks up the user's chosen `velocitee.provisioner` and instantiates
*every* class in the tuple. The pipeline runs them in declared order, with
phase tags enforcing the rest.

## Adding a backend

```python
# shared/renderers/my_backend.py
from typing import Any
from ..renderer import Renderer
from ..renderer_registry import register
from ..schema import ProvisioningResult

class MyRenderer(Renderer):
    name = "my-backend"
    phase = "config"

    def validate(self) -> list[str]:
        import shutil, os
        errors = []
        if not shutil.which("my-cli"):
            errors.append("my-cli not in PATH")
        if not os.environ.get("MY_API_TOKEN"):
            errors.append("missing env: MY_API_TOKEN")
        return errors

    def execute(self, *, prior_outputs: dict[str, Any] | None = None) -> ProvisioningResult:
        # Read self.intent (the VNEIntent), do the work idempotently,
        # return a ProvisioningResult with success/error and any outputs
        # downstream renderers should see.
        return ProvisioningResult(
            success=True,
            renderer=self.name,
            phase=self.phase,
            outputs={"some_id": "..."},
        )

register("my-backend", MyRenderer)
```

Then expose the user-facing toggle in `velocitee.yml`:

```yaml
velocitee:
  provisioner: "my-backend"
```

Nothing else changes. The engine logic doesn't know about your backend; the
registry is the only coupling point.

## Stub renderers

VNE registers eleven backends as stubs (`pulumi`, `salt`, `chef`, …). Their
`validate()` returns no errors so `vne deploy --help` lists them; their
`execute()` returns a clean error noting "not yet implemented." This keeps
the registry surface intentional — every reserved name is owned, no
ambiguity about which backends are real.
