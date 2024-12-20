# SECRETS

Secrets will be categorized into two tiers:

1. bootstrap
2. operational

Bootstrap secrets are secrets needed for the core infrastrucure. These should not change often.:

- truenas api token

Tofu will create a `flux-gpg` secret containing the gpg private key
The api token can then be added to a sops encrypted file deployed via flux.

Operational secrets will come from bitwarden secrets manager.
If this turns out to be unacceptable then all secrets will be managed by sops.
