# Go Coding Standards for go-qtools

## General Principles

1. **Use constants from `internal/constants`** - Never hardcode usernames, groups, paths, ports, or service names. Import and use `internal/constants` package.
2. **Error handling** - Always handle errors explicitly. Use `fmt.Errorf` with `%w` for error wrapping when appropriate.
3. **Package organization** - Keep packages focused and cohesive. Use `internal/` for private packages.

## Constants and Configuration

### Use Constants Package

**❌ BAD:**
```go
user := "quilibrium"
path := "/home/quilibrium/qtools"
serviceName := "ceremonyclient"
```

**✅ GOOD:**
```go
import "github.com/tjsturos/qtools/go-qtools/internal/constants"

user := constants.DefaultUser
path := constants.DefaultQtoolsPath
serviceName := constants.GetServiceName(cfg)
```

### Config-Based Overrides

Always check config first, then fall back to constants:
```go
func GetUser(cfg *config.Config) string {
    if cfg != nil && cfg.Service != nil && cfg.Service.DefaultUser != "" {
        return cfg.Service.DefaultUser
    }
    return constants.DefaultUser
}
```

## Error Handling

### Error Wrapping

Use `fmt.Errorf` with `%w` to wrap errors for context:
```go
if err != nil {
    return fmt.Errorf("failed to load config: %w", err)
}
```

### Error Types

Define custom error types when needed:
```go
type ConfigError struct {
    Path string
    Err  error
}

func (e *ConfigError) Error() string {
    return fmt.Sprintf("config error at %s: %v", e.Path, e.Err)
}

func (e *ConfigError) Unwrap() error {
    return e.Err
}
```

## Service Management

### Platform Detection

Always use platform detection before service operations:
```go
import "github.com/tjsturos/qtools/go-qtools/internal/service"

backend := service.GetServiceBackend()
if backend == nil {
    return fmt.Errorf("unsupported platform: %s", runtime.GOOS)
}
```

### Service Names

Use `constants.GetServiceName(cfg)` instead of hardcoding:
```go
serviceName := constants.GetServiceName(cfg)
err := backend.StartService(serviceName)
```

## Node Config Management

### Use NodeConfigManager

Always use `NodeConfigManager` for node config operations:
```go
import "github.com/tjsturos/qtools/go-qtools/internal/node"

manager, err := node.NewNodeConfigManager(configPath)
if err != nil {
    return err
}

value, err := manager.GetValue("p2p.listenMultiaddr")
```

### Path-Based Access

Use dot-separated paths for config access:
- `"p2p.listenMultiaddr"` - P2P listen address
- `"grpc.listenMultiaddr"` - gRPC endpoint
- `"engine.dataWorkerMultiaddrs"` - Data worker addresses

## Testing

### Test Structure

Follow Go testing conventions:
- Test files: `*_test.go`
- Test functions: `TestXxx(t *testing.T)`
- Table-driven tests for multiple cases

### Mocking

Use interfaces for testability:
```go
type ServiceBackend interface {
    StartService(name string) error
    StopService(name string) error
}
```

## File Permissions

### Ownership

All qtools/node files should be owned by `quilibrium:qtools`:
```go
import "github.com/tjsturos/qtools/go-qtools/internal/constants"

user := constants.DefaultUser
group := constants.DefaultGroup
cmd := exec.Command("chown", fmt.Sprintf("%s:%s", user, group), path)
```

### Permissions

Use constants for file permissions:
- Directories: `constants.DefaultDirPerm` (0755)
- Files: `constants.DefaultFilePerm` (0644)
- Group permissions: `constants.DefaultGroupPerm` ("g+rwx")

## CLI Commands

### Cobra Structure

Use Cobra for CLI commands:
```go
var nodeCmd = &cobra.Command{
    Use:   "node",
    Short: "Node management commands",
}

var nodeSetupCmd = &cobra.Command{
    Use:   "setup",
    Short: "Setup node",
    RunE: func(cmd *cobra.Command, args []string) error {
        // Implementation
    },
}
```

### Flag Parsing

Use Cobra's flag system:
```go
nodeSetupCmd.Flags().Bool("automatic", false, "Use automatic mode")
nodeSetupCmd.Flags().Int("workers", 0, "Number of workers (0 = auto)")
```

## TUI Components

### Bubble Tea Models

Follow Bubble Tea patterns:
```go
type Model struct {
    // State fields
}

func (m Model) Init() tea.Cmd {
    return nil
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    // Handle messages
}

func (m Model) View() string {
    // Render UI
}
```

### Component Reusability

Create reusable components in `internal/tui/components/`:
- `core_input.go` - Core number input component
- `menu.go` - Navigation menu
- `status_bar.go` - Status bar

## Logging

### Use Structured Logging

Consider using structured logging (log/slog or similar):
```go
import "log/slog"

slog.Info("service started", "name", serviceName, "user", user)
```

### Log File Paths

Use constants for log paths:
```go
logPath := filepath.Join(constants.DefaultLogsPath, constants.MasterLogFile)
```

## Migration Strategy

When migrating bash scripts to Go:

1. **Identify constants** - Extract hardcoded values to `internal/constants`
2. **Create interfaces** - Define interfaces for platform-specific code
3. **Implement platform backends** - Create systemd/launchd implementations
4. **Add tests** - Write tests for new functionality
5. **Update documentation** - Keep README and docs up to date

## References

- Main plan: `.cursor/plans/go_tools_rewrite_with_tui.plan.md` (in parent repo)
- Constants: `internal/constants/constants.go`
- Config: `internal/config/`
- Service: `internal/service/`
- Node: `internal/node/`
