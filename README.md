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

# todos
- [ ] How to properly define user groups per machine?
- [ ] How to properly define the ssh keys per machine?
