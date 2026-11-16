# cluster-rbac

**Retired.** Cluster access now comes from auth-api groups, bound to Kubernetes roles in `cluster-auth`. This repo is kept for history and shouldn't be applied.

It used to keep a list of people and give each of them a ClusterRoleBinding against their Authentik login. When Authentik was replaced by auth-api, those per-person bindings were destroyed before the Kubernetes API started trusting auth-api, so nobody could register a matching username and pick up someone else's access.

To give someone cluster access now, use the Cluster access setting in admin-ui.
