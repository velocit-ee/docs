# `velocitee.yml` reference

The single config file every engine reads. Per-engine blocks live under
their engine slug.

```yaml
velocitee:
  provisioner: "velocitee-native"

vne:
  …       # see VNE configuration reference
```

## Top-level

| Key                    | Type   | Required | Notes |
|------------------------|--------|----------|-------|
| `velocitee.provisioner`| string | yes      | Name of a registered renderer backend. See [provisioners](../vne/provisioners.md). |

Other engines' blocks (e.g. `vse:`, `vle:`) may be present; engines ignore
blocks they don't own. Unknown keys *inside* an engine's own block fail
validation — typos there should not be silent.

## Per-engine blocks

| Block        | Owner | Reference |
|--------------|-------|-----------|
| `vne:`       | VNE   | [VNE configuration](../vne/configuration.md) |
| `vse:`       | VSE   | (not yet defined — VSE is planned) |
| `vle:`       | VLE   | (not yet defined — VLE is planned) |

VME has its own config file (`vme-config.yml`) rather than a block here, for
historical reasons. A future release may consolidate.

## Secrets and credentials

**Never put secrets in `velocitee.yml`.** API tokens, passwords, and
private keys belong in environment variables. VNE pre-flight checks all
required environment variables and reports any missing in one error before
running.

See [environment variables](environment.md) for the full inventory by
backend.
