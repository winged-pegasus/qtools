# Qtools

A comprehensive CLI toolkit for installing, configuring, managing, and monitoring [Quilibrium](https://quilibrium.com) nodes.

## Features

- **One-command installation** — Set up a Quilibrium node from scratch with a single command
- **Service management** — Start, stop, restart, and monitor your node via systemd
- **Cluster support** — Manage multi-server clusters with master/worker architecture
- **Manual mode** — Run each data worker as a separate service for better reliability
- **Auto-updates** — Scheduled updates for both the node binary and qtools itself
- **Backup & restore** — Remote and local backup of peer configs and store data
- **Diagnostics** — Health checks, hardware info, disk/CPU/memory monitoring, and status reports
- **gRPC queries** — Query node info, peer ID, balance, seniority, frame count, and more
- **QClient operations** — Transfer, merge, split tokens and check balances
- **Configuration management** — YAML-based config with CLI helpers for every setting
- **Firewall management** — Automated UFW configuration
- **Statistics & monitoring** — Prometheus, Loki, and Grafana Alloy integration
- **Shell autocomplete** — Tab completion for all commands in bash
- **Testnet support** — Run against testnet with a config toggle

## Quick Start

### Prerequisites

- A Linux server (Ubuntu recommended)
- `git` installed
- A non-root user with sudo access

### Installation

```bash
git clone https://github.com/QuilibriumNetwork/qtools.git
cd qtools
./qtools.sh init
source ~/.bashrc  # enables autocomplete
```

Then install the node:

```bash
qtools complete-install
```

This may prompt for your sudo password. Once finished, the node service is configured and ready to start.

### Running Commands

After initialization, `qtools` is available globally:

```bash
qtools <command> [options]
```

Run `qtools` with no arguments to see all available commands.

## Commands Overview

For the full command reference with parameters and examples, see [docs/Commands.md](docs/Commands.md).

### Service Commands

| Command | Description |
|---------|-------------|
| `start` | Start the node service (`--debug` for debug mode) |
| `stop` | Stop the node service (`--kill` to force, `--wait` to wait for completion) |
| `restart` | Restart the node service (`--wait` to wait for next proof) |
| `status` | Check service status (`--worker <n>` for a specific worker) |

### Node & Network Info (gRPC)

| Command | Description |
|---------|-------------|
| `node-info` | Get node information |
| `peer-id` | Get your node's peer ID |
| `balance` | Get current balance |
| `seniority` | Get node seniority |
| `frame-count` | Get current frame count |
| `network-info` | Get network information |
| `token-info` | Get token information |

### QClient

| Command | Description |
|---------|-------------|
| `coins` | List coins and balances |
| `transfer` | Transfer tokens to an address |
| `split` | Split a token |
| `merge` | Merge tokens (batches of 100) |

### Configuration

| Command | Description |
|---------|-------------|
| `edit-quil-config` | Open the node config file in your editor |
| `edit-qtools-config` | Open the qtools config file in your editor |
| `add-direct-peer` | Add a direct peer to the node config |
| `update-direct-peers` | Update peers from a remote source |
| `set-listen-addr-port` | Set the listening port and protocol |
| `update-bandwidth` | Update bandwidth settings (`--plan low/high/default`) |
| `max-frame` | Set the maximum frame number |
| `toggle-dynamic-proofs` | Enable/disable dynamic proof creation |
| `setup-firewall` | Configure UFW firewall rules |

### Updates

| Command | Description |
|---------|-------------|
| `update-node` | Update to the latest node version (`--force`, `--auto`) |
| `self-update` | Update qtools itself (`--auto`) |
| `update-kernel` | Install the latest Linux kernel |

### Backup & Restore

| Command | Description |
|---------|-------------|
| `backup-peer` | Backup peer config files to a remote location |
| `backup-store` | Backup the store directory |
| `make-local-backup` | Create a local backup |
| `restore-backup` | Restore a complete backup from remote |
| `restore-peer` | Restore peer config files |
| `restore-store` | Restore the store directory |

### Diagnostics

| Command | Description |
|---------|-------------|
| `status-report` | Generate a full status report (`--json` for JSON output) |
| `run-diagnostics` | Run all diagnostic checks |
| `check-node-files` | Verify node file integrity |
| `check-disk-space` | Check disk space |
| `check-cpu-load` | Check CPU load |
| `memory-usage` | Check memory usage |
| `hardware-info` | Display hardware information |
| `view-log` | View node logs |
| `ports-listening` | Show listening ports |

### Shortcuts & Toggles

| Command | Description |
|---------|-------------|
| `consolidate-rewards` | Consolidate rewards to a configured address |
| `toggle-auto-update-node` | Enable/disable automatic node updates |
| `toggle-auto-update-qtools` | Enable/disable automatic qtools updates |
| `toggle-backups` | Enable/disable scheduled backups |
| `toggle-statistics` | Enable/disable statistics collection |
| `toggle-diagnostics` | Enable/disable scheduled diagnostics |
| `public-ip` | Display your server's public IP |

## Cluster Management

Qtools supports multi-server clusters where a master node coordinates multiple workers across servers.

### Setup

1. Enable clustering in your config:
   ```bash
   qtools toggle-cluster-mode
   ```

2. Add servers to the cluster:
   ```bash
   qtools cluster-add-server
   ```

3. Run the cluster setup:
   ```bash
   qtools cluster-setup
   ```

### Cluster Commands

| Command | Description |
|---------|-------------|
| `cluster-start` | Start all cluster services -- same as `start` |
| `cluster-stop` | Stop all cluster services -- same as `stop` |
| `cluster-update` | Update all cluster nodes |
| `cluster-remote-command` | Execute a command on all remote servers |
| `cluster-add-server` | Add a server to the cluster |
| `cluster-remove-server` | Remove a server from the cluster |
| `cluster-provision-server` | Provision a new server |

## Configuration

Qtools uses a YAML configuration file (`config.yml`) that is created from [`config.sample.yml`](config.sample.yml) during initialization.

Key configuration sections:

| Section | Description |
|---------|-------------|
| `service` | Node service settings (name, paths, debug mode, restart time) |
| `service.clustering` | Cluster configuration (ports, servers, SSH keys) |
| `manual` | Manual mode settings (worker count, local-only) |
| `scheduled_tasks` | Automated tasks (backups, updates, diagnostics, statistics) |
| `settings` | General settings (AVX512, listen address, firewall) |
| `ssh` | SSH configuration (port, IP allowlist) |
| `dev` | Development settings (repository, remote builds) |

### Manual Mode

Manual mode runs each data worker as a separate systemd service, providing better isolation and reliability:

```bash
qtools manual-mode --on
```

When enabled, qtools automatically calculates and manages the optimal worker count based on your hardware.

### Scheduled Tasks

Qtools can automate common maintenance tasks via cron:

- **Backups** — Periodic backup of peer configs and store data
- **Node updates** — Automatic updates when new releases are available
- **Qtools updates** — Keep qtools itself up to date
- **Log cleanup** — Rotate and clean old log files
- **Memory checks** — Monitor and restart workers if memory thresholds are exceeded
- **Diagnostics** — Periodic health checks
- **Public IP monitoring** — Detect and handle IP changes

Install scheduled tasks with:

```bash
qtools install-cron
```

## Statistics & Monitoring

Qtools can export node metrics via Grafana Alloy to Prometheus and Loki endpoints:

```bash
qtools toggle-statistics --on
qtools install-grafana-statistics
```

This sets up:
- **Prometheus** metrics export (node stats, hardware metrics)
- **Loki** log aggregation
- **Grafana Alloy** as the collection agent

## Go Rewrite (In Progress)

A Go rewrite of qtools is under active development in the [`go-qtools/`](go-qtools/) directory, adding:

- Cross-platform support (Linux systemd + macOS launchd)
- A Terminal UI (TUI) built with Bubble Tea
- Structured config management with auto-migration
- Shell completion for bash, zsh, fish, and PowerShell

See [go-qtools/README.md](go-qtools/README.md) for build instructions and current status.

## Known Issues

- When running commands via SSH (non-interactive), `yq` commands that read/modify the config file may hang. This is a [known yq bug](https://github.com/mikefarah/yq/issues/2103). Workaround: SSH into the server and run commands directly, or use cron tasks.

## Project Structure

```
qtools/
├── qtools.sh              # Main entry point
├── config.sample.yml      # Configuration template
├── scripts/               # Command scripts organized by category
│   ├── backup/            # Backup and restore
│   ├── cluster/           # Cluster management
│   ├── config/            # Configuration management
│   ├── diagnostics/       # Health checks and monitoring
│   ├── grpc/              # gRPC node queries
│   ├── install/           # Installation scripts
│   ├── node-commands/     # Node-specific commands
│   ├── qclient/           # Token operations
│   ├── service-commands/  # Service control
│   ├── shortcuts/         # Convenience commands and toggles
│   └── update/            # Update operations
├── go-qtools/             # Go rewrite (in progress)
├── utils/                 # Shared utility functions
├── docs/                  # Documentation
├── binaries/              # Bundled binaries (yq)
├── files/                 # Template files (Grafana Alloy config)
└── tests/                 # Test scripts
```

