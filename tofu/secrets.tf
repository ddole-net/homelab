data "bitwarden_secret" "AWS_ACCESS_KEY_ID" {
  key = "AWS_ACCESS_KEY_ID"
}
data "bitwarden_secret" "AWS_SECRET_ACCESS_KEY" {
  key = "AWS_SECRET_ACCESS_KEY"
}
data "bitwarden_secret" "ROUTEROS_USER" {
  key = "ROUTEROS_USER"
}

data "bitwarden_secret" "ROUTEROS_PASSWORD" {
  key = "ROUTEROS_PASSWORD"
}
data "bitwarden_secret" "PVE_USER" {
  key = "PVE_USER"
}
data "bitwarden_secret" "PVE_API_TOKEN" {
  key = "PVE_API_TOKEN"
}
data "bitwarden_secret" "PVE_SSH_PRIVATE_KEY" {
  key = "PVE_SSH_PRIVATE_KEY"
}
