# cluster-rbac

Source of truth for who can access the Talos cluster and what they can do.
Two things happen from the same `users` list:

- **Here**: a `ClusterRoleBinding` per user, binding their OIDC identity to a
  built-in `ClusterRole` (`cluster-admin`, `edit`, or `view`).
- **In [`../cluster-auth`](../cluster-auth)**: an Authentik account is
  created for each username (read via `terraform_remote_state` against this
  repo's state), and a one-time link to set a password is emitted as a Tofu
  output.

## Why this only works with the apiserver OIDC patch

RBAC subjects here reference `oidc:<username>` because that's what the
Talos apiserver will present once it trusts Authentik as an OIDC issuer ,
see [`../proxmox-tofu/talos-oidc-patch.yaml`](../proxmox-tofu/talos-oidc-patch.yaml)
and its README section. Until that patch is applied to the control-plane
node, the apiserver doesn't authenticate OIDC tokens at all, so logging in
via Headlamp will fail with 401s rather than land you in an
under-permissioned account , these bindings just have nothing to attach to
yet.

`oidc_username_prefix` here must match `--oidc-username-prefix` in that
patch exactly, or the bound identity string won't match what the apiserver
presents.

## Usage

All `.tf` files live under `tofu/`, not the repo root:

```bash
cd tofu
cp terraform.tfvars.example terraform.tfvars   # edit the users list
tofu init
tofu plan
tofu apply
```

Requires `cluster-config` already applied (nothing here depends on it
directly, but the cluster needs to exist first via `proxmox-tofu`).

## Roles

- `admin` → `cluster-admin`
- `edit` → built-in `edit` ClusterRole (read/write most objects, no RBAC
  changes)
- `view` → built-in `view` ClusterRole (read-only)

Custom ClusterRoles aren't supported by `role` yet , add one here and
extend `rbac.tf`'s `role_ref` mapping if you need finer-grained access.
