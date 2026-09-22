# Ansible node

Ansible role for basic Ubuntu server setup and hardening.

Tested on Ubuntu 24.04 (noble) and 26.04 (resolute) with ansible-core 2.15+.

Requires the `ansible.posix` and `community.general` collections.

## What it does

* **Swap** — creates a swap file when the host has none. Small cloud
  instances ship without any, and a 512MB node cannot get through
  `apt install docker-ce` before the OOM killer intervenes.
* **Packages** — a base set, plus debugging tools, with security-sensitive
  packages held at the newest available version.
* **Admin user** — creates `node_ssh_user`, gives it password-less sudo, and
  copies the authorized keys of the account Ansible connected with. Aborts
  if that account has no keys, rather than locking you out.
* **Locale, shell, journald** — journald gets persistent storage and size
  caps via a drop-in.
* **Unattended upgrades** — security pocket only.
* **ufw** — default deny inbound, with the SSH port always permitted.
* **fail2ban** — sshd jail on the real port, plus an optional `recidive`
  jail that re-bans repeat offenders for longer.
* **SSH hardening** — no root login, keys only, and a port change.

## Two things about SSH on modern Ubuntu

Both of these silently defeat the older approach of editing
`/etc/ssh/sshd_config` with `lineinfile`.

**sshd is socket-activated.** Since Ubuntu 22.10, `ssh.service` is disabled
and `ssh.socket` owns the listening socket, passing the fd to sshd. The
`Port` directive in `sshd_config` is ignored. The role therefore writes
`/etc/systemd/system/ssh.socket.d/override.conf`:

```ini
[Socket]
ListenStream=
ListenStream=0.0.0.0:2345
```

The empty `ListenStream=` matters — without it the new port is *added* to
port 22 rather than replacing it. Set `node_ssh_manage_socket: false` if you
have disabled socket activation.

**Drop-ins outrank the main config.** The shipped `sshd_config` has
`Include /etc/ssh/sshd_config.d/*.conf` near the top, and sshd keeps the
*first* value it sees for an option. Ubuntu cloud images ship
`50-cloud-init.conf` and `60-cloudimg-settings.conf`, so anything appended to
the bottom of the main file loses. The role writes
`10-ansible-hardening.conf`, which sorts ahead of both.

Check the result with `sshd -T`, which shows the effective config rather
than what any one file says.

## Not getting locked out

The role changes the port it is connected over, so ordering is deliberate:

1. The admin user and its keys are created first.
2. ufw is configured next, allowing both `node_ssh_port` **and** the port
   the current run arrived on, so the switchover has a path either way.
3. sshd is reconfigured last, and the drop-in is validated with
   `sshd -t` before anything restarts.
4. Once a later run arrives on the hardened port, the bootstrap port 22
   rule is removed.

`KillMode=process` on `ssh.service` means established sessions survive the
restart, so the run that performs the switch keeps its own connection.

## Variables

See `defaults/main.yml`. The ones you are most likely to change:

| Variable | Default | Purpose |
| --- | --- | --- |
| `node_ssh_user` | `ansible` | Admin account to create |
| `node_ssh_port` | `22` | Port sshd ends up on |
| `node_ssh_groups` | `sudo` | Group granted sudo and `AllowGroups` |
| `node_sshd_options` | see defaults | Merged into the sshd drop-in |
| `node_ufw_setup` | `true` | Enable ufw |
| `node_ufw_allow_ports` | `[80, 443]` | Opened alongside the SSH port |
| `node_fail2ban_setup` | `true` | Enable fail2ban |
| `node_swap_setup` | `true` | Create swap when the host has none |
| `node_swap_size_mb` | 2×RAM, 1–4GB | Swap file size |
| `node_run_system_upgrades` | `false` | `apt dist-upgrade` and reboot |

## Tags

`swap`, `apt`, `packages`, `users`, `bash`, `locale`, `journald`, `logging`,
`security`, `unattended-upgrades`, `firewall`, `fail2ban`, `ssh`, `reboot`.

Tags are pushed into the included task files with `apply`, so
`--tags fail2ban` runs the fail2ban tasks rather than just the include.
