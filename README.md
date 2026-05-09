# dotfiles

Quick setup my environment.  
WARN: Use it ONLY for initial server configuration.

# Usage
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/nornad/dotfiles/main/setup.sh)"

curl -fsSL https://raw.githubusercontent.com/nornad/dotfiles/main/setup.sh | bash -s -- nornad [ssh-config-type]

ssh config types:
- (no value, default) - No root login, No password authentication allowed, No TCP tunneling allowed
- 3x-ui - No root login, No password authentication allowed
- amnezia - No root login, No TCP tunneling allowed

Example for 3X-UI type
curl -fsSL https://raw.githubusercontent.com/nornad/dotfiles/main/setup.sh | bash -s -- nornad 3x-ui
```
