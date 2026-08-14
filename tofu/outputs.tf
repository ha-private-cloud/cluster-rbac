output "usernames" {
  description = "Usernames to be created as Authentik accounts by cluster-auth (read via terraform_remote_state)."
  value       = [for u in var.users : u.username]
}
