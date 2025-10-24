---
description: Build Azure Functions NuGet package
---

Build the Datadog Azure Functions NuGet package for testing.

Steps:
1. Run the build script: `tracer/tools/Build-AzureFunctionsNuget.ps1 -CopyTo D:/temp/nuget`
2. The script will:
   - Build the Datadog.AzureFunctions project
   - Create a NuGet package
   - Copy it to the specified directory

Usage in Azure Functions:
- Add local NuGet source in `nuget.config` pointing to `D:/temp/nuget`
- Reference the package in your function app: `<PackageReference Include="Datadog.AzureFunctions" Version="..." />`

After building:
- Report the package version and location
- Show the output directory contents
- Provide instructions for testing in a function app

Related commands:
- Test with Azure Functions: Use `BuildAndRunWindowsAzureFunctionsTests` Nuke target
- Sample apps: `tracer/test/test-applications/azure-functions/`
