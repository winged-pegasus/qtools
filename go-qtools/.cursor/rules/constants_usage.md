# Constants Usage Guide

## Rule: Always Use Constants Package

**Problem:** Hardcoding values like `"quilibrium"`, `"qtools"`, `"/home/quilibrium/qtools"` throughout the codebase leads to inconsistency and maintenance issues.

**Solution:** Always import and use `internal/constants` package for all system-level values.

## Required Constants Package

The `internal/constants` package should define:

- User/Group: `DefaultUser`, `DefaultGroup`
- Paths: `DefaultQtoolsPath`, `DefaultNodePath`, `DefaultClientPath`, `DefaultConfigPath`, `DefaultNodeConfigPath`, `DefaultLogsPath`
- Service Names: `DefaultServiceName`
- Binary Paths: `DefaultNodeBinaryPath`, `DefaultQtoolsBinaryPath`
- Ports: `DefaultP2PListenPort`, `DefaultGRPCPort`, `DefaultRESTPort`, etc.
- File Permissions: `DefaultDirPerm`, `DefaultFilePerm`, `DefaultGroupPerm`
- Log Files: `MasterLogFile`, `WorkerLogFilePattern`

## Usage Pattern

### Basic Constants

```go
import "github.com/tjsturos/qtools/go-qtools/internal/constants"

// ✅ GOOD
user := constants.DefaultUser
group := constants.DefaultGroup
path := constants.DefaultQtoolsPath
serviceName := constants.DefaultServiceName
```

### Config-Aware Constants

```go
import (
    "github.com/tjsturos/qtools/go-qtools/internal/constants"
    "github.com/tjsturos/qtools/go-qtools/internal/config"
)

// ✅ GOOD - Check config first, then default
user := constants.GetUser(cfg)
serviceName := constants.GetServiceName(cfg)
```

### File Operations

```go
// ✅ GOOD - Use constants for ownership
cmd := exec.Command("chown", 
    fmt.Sprintf("%s:%s", constants.DefaultUser, constants.DefaultGroup), 
    path)

// ✅ GOOD - Use constants for permissions
os.Chmod(path, constants.DefaultDirPerm)
```

### Service Operations

```go
// ✅ GOOD - Use constants for service names
serviceName := constants.GetServiceName(cfg)
err := backend.StartService(serviceName)
```

## Common Mistakes

### ❌ BAD - Hardcoded Values

```go
// Don't hardcode usernames
user := "quilibrium"
group := "qtools"

// Don't hardcode paths
path := "/home/quilibrium/qtools"
configPath := "/home/quilibrium/qtools/config.yml"

// Don't hardcode service names
serviceName := "ceremonyclient"

// Don't hardcode binary paths
nodePath := "/usr/local/bin/node"
```

### ✅ GOOD - Use Constants

```go
import "github.com/tjsturos/qtools/go-qtools/internal/constants"

user := constants.DefaultUser
group := constants.DefaultGroup
path := constants.DefaultQtoolsPath
configPath := constants.DefaultConfigPath
serviceName := constants.GetServiceName(cfg)
nodePath := constants.DefaultNodeBinaryPath
```

## Migration Checklist

When reviewing code, check for:

- [ ] Hardcoded `"quilibrium"` → Use `constants.DefaultUser`
- [ ] Hardcoded `"qtools"` → Use `constants.DefaultGroup`
- [ ] Hardcoded `"/home/quilibrium/qtools"` → Use `constants.DefaultQtoolsPath`
- [ ] Hardcoded `"/home/quilibrium/node"` → Use `constants.DefaultNodePath`
- [ ] Hardcoded `"ceremonyclient"` → Use `constants.GetServiceName(cfg)`
- [ ] Hardcoded `"/usr/local/bin/node"` → Use `constants.DefaultNodeBinaryPath`
- [ ] Hardcoded ports (8336, 8337, 8338) → Use port constants
- [ ] Hardcoded permissions (0755, 0644) → Use permission constants

## Files That Need Review

Common files that may have hardcoded values:

- `internal/node/install.go` - User/group creation
- `internal/node/update.go` - Binary paths, ownership
- `internal/node/commands.go` - Binary paths
- `internal/service/manager.go` - Service names
- `internal/service/systemd.go` - User/group in templates
- `internal/service/launchd.go` - User in plist generation
- `internal/config/paths.go` - Should use constants package

## Implementation

If `internal/constants` package doesn't exist yet, create it:

```go
package constants

const (
    DefaultUser  = "quilibrium"
    DefaultGroup = "qtools"
    
    DefaultQtoolsPath     = "/home/quilibrium/qtools"
    DefaultNodePath       = "/home/quilibrium/node"
    DefaultClientPath     = "/home/quilibrium/client"
    DefaultConfigPath     = "/home/quilibrium/qtools/config.yml"
    DefaultNodeConfigPath = "/home/quilibrium/node/.config/config.yml"
    DefaultLogsPath       = "/home/quilibrium/node/.logs"
    
    DefaultServiceName = "ceremonyclient"
    
    DefaultNodeBinaryPath   = "/usr/local/bin/node"
    DefaultQtoolsBinaryPath = "/usr/local/bin/qtools"
    
    DefaultP2PListenPort        = 8336
    DefaultStreamPort           = 8340
    DefaultGRPCPort            = 8337
    DefaultRESTPort             = 8338
    DefaultWorkerBaseP2PPort    = 50000
    DefaultWorkerBaseStreamPort = 60000
    
    DefaultDirPerm  = 0755
    DefaultFilePerm = 0644
    DefaultGroupPerm = "g+rwx"
    
    MasterLogFile        = "master.log"
    WorkerLogFilePattern = "worker-%d.log"
)

// Helper functions for config-aware values
func GetUser(cfg *config.Config) string {
    if cfg != nil && cfg.Service != nil && cfg.Service.DefaultUser != "" {
        return cfg.Service.DefaultUser
    }
    return DefaultUser
}

func GetServiceName(cfg *config.Config) string {
    if cfg != nil && cfg.Service != nil && cfg.Service.FileName != "" {
        return cfg.Service.FileName
    }
    return DefaultServiceName
}
```
