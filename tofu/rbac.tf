# Binds each user's OIDC identity (as the apiserver will see it: the
# preferred_username claim, prefixed per var.oidc_username_prefix) to a
# built-in ClusterRole. Requires the Talos apiServer OIDC patch (see
# proxmox-tofu/talos-oidc-patch.yaml) to be applied , until then the
# apiserver doesn't trust OIDC tokens at all, so these bindings have
# nothing to attach to.
resource "kubernetes_cluster_role_binding" "user" {
  for_each = { for u in var.users : u.username => u }

  metadata {
    name = "oidc-user-${each.value.username}"
  }

  subject {
    kind      = "User"
    name      = "${var.oidc_username_prefix}${each.value.username}"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = each.value.role == "admin" ? "cluster-admin" : each.value.role
    api_group = "rbac.authorization.k8s.io"
  }
}
