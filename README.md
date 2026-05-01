# real-nixos
Nixos config


## Common commands

- rebuild
```bash
sudo nixos-rebuild switch
```

- rebuild with specific machine name
```bash
sudo nixos-rebuild switch --flake /etc/nixos#<machine-name>
```

## What to do after startup

### Tailscale

To log into tailscale:
```shell
sudo tailscale up
```

To update the tailscale settings:
```shell
sudo systemctl restart tailscaled
```

# todos
- [ ] How to properly define user groups per machine?
- [ ] How to properly define the ssh keys per machine?
