---
description: Build the Datadog .NET tracer
---

Build the Datadog .NET tracer using the Nuke build system.

Before building:
1. Check the current working directory - you should be in the dd-trace-dotnet repository root
2. Verify the build will succeed by checking for any obvious issues

Build options:
- Quick build for testing: `dotnet build tracer/src/Datadog.Trace/ -c Release -f net6.0`
- Full tracer home build: `.\build.cmd BuildTracerHome` (Windows) or `./build.sh BuildTracerHome` (Linux/macOS)
- Clean and build: `.\build.cmd Clean BuildTracerHome`

After building:
- Report the build result (success/failure)
- If there are errors, analyze them and suggest fixes
- Show the output location if successful
