---
description: Deploy and test with Azure resources
---

Deploy and test the .NET tracer with Azure resources.

Available Azure resources (resource group: lucas.pimentel):
- Function apps starting with prefix: `lucasp-*`

Common tasks:

1. **List Function Apps**:
   ```bash
   az functionapp list --resource-group lucas.pimentel --output table
   ```

2. **Get Function App Details**:
   ```bash
   az functionapp show --name <app-name> --resource-group lucas.pimentel
   ```

3. **List Functions in App**:
   ```bash
   az functionapp function list --name <app-name> --resource-group lucas.pimentel
   ```

4. **Check App Settings**:
   ```bash
   az functionapp config appsettings list --name <app-name> --resource-group lucas.pimentel
   ```

5. **Download Logs**:
   ```bash
   az webapp log download --name <app-name> --resource-group lucas.pimentel --log-file logs.zip
   ```

Deployment scenarios:
- **Site Extension** (Windows): Deploy via Azure portal or ARM template
- **NuGet Package** (Linux/Container): Build with `/azure-functions-nuget` and deploy with package reference

Before deploying:
- Build the tracer or NuGet package
- Verify Azure CLI is authenticated: `az account show`
- Confirm target function app exists

After deploying:
- Check application logs for tracer initialization
- Verify traces are being sent to Datadog
- Test instrumented functionality
