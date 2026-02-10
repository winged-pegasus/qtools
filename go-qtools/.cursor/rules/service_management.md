# Service Management Guidelines

## Platform Detection

Always detect platform before service operations:

```go
import (
    "github.com/tjsturos/qtools/go-qtools/internal/service"
    "runtime"
)

backend := service.GetServiceBackend()
if backend == nil {
    return fmt.Errorf("unsupported platform: %s", runtime.GOOS)
}
```

## Service Names

Use `constants.GetServiceName(cfg)` instead of hardcoding:

```go
import (
    "github.com/tjsturos/qtools/go-qtools/internal/constants"
    "github.com/tjsturos/qtools/go-qtools/internal/config"
)

serviceName := constants.GetServiceName(cfg)
err := backend.StartService(serviceName)
```

## Service Options

Always use `ServiceOptions` struct for service configuration:

```go
import "github.com/tjsturos/qtools/go-qtools/internal/service"

opts := &service.ServiceOptions{
    Testnet:            false,
    Debug:              false,
    SkipSignatureCheck: false,
    RestartTime:        "60s",
    WorkerRestartTime:  "5s",
    EnableService:      true,
    RestartService:     true,
}

err := service.UpdateServiceFile(serviceName, opts)
```

## Manual Mode (Default)

**Important:** Manual mode is the default and recommended mode. In manual mode:

- Each worker runs as a separate service
- Better isolation and reliability
- Easier monitoring and debugging
- User experience remains automatic (tooling handles complexity)

### Starting Services

```go
// Start all services (master + all workers)
err := service.StartService(service.StartOptions{})

// Start master only
err := service.StartMasterOnly()

// Start specific workers
err := service.StartWorkers([]int{1, 2, 3})
```

### Stopping Services

```go
// Stop all services
err := service.StopService(service.StopOptions{})

// Stop master only
err := service.StopMasterOnly()

// Stop specific workers
err := service.StopWorkers([]int{1, 2, 3})
```

### Worker Core Numbers

Support flexible core number input:
- Single: `"5"` → `[5]`
- Range: `"1-4"` → `[1,2,3,4]`
- Multiple: `"1,3,5"` → `[1,3,5]`
- Combination: `"1-3,5,7-9"` → `[1,2,3,5,7,8,9]`

```go
import "github.com/tjsturos/qtools/go-qtools/internal/service"

cores, err := service.ParseCoreNumbers("1-3,5,7-9")
if err != nil {
    return err
}

err := service.StartWorkers(cores)
```

## Service File Generation

### Systemd (Linux)

Service files should include:
- `User=quilibrium` (from constants)
- `Group=qtools` (from constants)
- `WorkingDirectory=/home/quilibrium/node` (from constants)
- All flags from `ServiceOptions`
- Proper restart policies
- Environment variables (GOGC, GOMEMLIMIT, IPFS_LOGGING)

### Launchd (macOS)

Plist files should include:
- `UserName` = `quilibrium` (from constants)
- `WorkingDirectory` = `/home/quilibrium/node` (from constants)
- All flags from `ServiceOptions`
- Proper restart policies (KeepAlive)
- Environment variables

## Service Status

Always check status before operations:

```go
status, err := service.GetStatus(service.StatusOptions{})
if err != nil {
    return err
}

// Check individual worker status
workerStatus, err := service.GetWorkerStatus(1)
if err != nil {
    return err
}
```

## Error Handling

Handle platform-specific errors:

```go
err := backend.StartService(serviceName)
if err != nil {
    // Check if it's a platform-specific error
    if errors.Is(err, service.ErrUnsupportedPlatform) {
        return fmt.Errorf("service management not supported on %s", runtime.GOOS)
    }
    return fmt.Errorf("failed to start service: %w", err)
}
```

## Testing

Use interfaces for testability:

```go
type ServiceBackend interface {
    StartService(name string) error
    StopService(name string) error
    RestartService(name string) error
    GetStatus(name string) (*ServiceStatus, error)
}
```

Mock the backend in tests:

```go
type mockBackend struct{}

func (m *mockBackend) StartService(name string) error {
    // Mock implementation
    return nil
}
```

## References

- Service manager: `internal/service/manager.go`
- Systemd backend: `internal/service/systemd.go`
- Launchd backend: `internal/service/launchd.go`
- Service options: `internal/service/options.go`
- Worker management: `internal/service/workers.go`
