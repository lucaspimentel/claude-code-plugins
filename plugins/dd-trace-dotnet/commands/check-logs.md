---
description: Check and analyze tracer logs
---

Check and analyze Datadog .NET tracer logs for debugging.

Log locations:
- **Windows**: `%ProgramData%\Datadog .NET Tracer\logs\`
- **Linux**: `/var/log/datadog/dotnet/`
- **Application logs**: Look for logs in the application directory

Log files:
- **dotnet-tracer-managed-{ProcessName}-{PID}.log** - Managed tracer logs
- **dotnet-tracer-native-{ProcessName}-{PID}.log** - Native loader logs
- **dotnet-profiler-{ProcessName}-{PID}.log** - Native profiler logs

Log levels:
- ERROR - Errors that prevent functionality
- WARN - Potential issues or degraded functionality
- INFO - Normal operation information
- DEBUG - Detailed debugging information

Common log patterns to check:
1. **Initialization**: "Datadog.Trace.ClrProfiler.Managed.Loader" messages
2. **Configuration**: "Configuration" or "Settings" messages
3. **Instrumentation**: "Instrumentation" or "CallTarget" messages
4. **Errors**: "Error" or "Exception" messages
5. **Performance**: Timing or "elapsed" messages

When analyzing logs:
1. Check for initialization errors first
2. Verify configuration is loaded correctly
3. Look for integration-specific messages
4. Identify any errors or warnings
5. Check for performance issues (slow initialization, etc.)

Suggest solutions based on common patterns:
- Missing dependencies
- Configuration issues
- Version mismatches
- Permission problems
