---
description: Check pull request status and CI results
---

Check pull request status, CI results, and review details.

GitHub CLI commands:

1. **List Recent PRs**:
   ```bash
   gh pr list --repo DataDog/dd-trace-dotnet
   ```

2. **View PR Details**:
   ```bash
   gh pr view <pr-number> --repo DataDog/dd-trace-dotnet
   ```

3. **Check PR Status/Checks**:
   ```bash
   gh pr checks <pr-number> --repo DataDog/dd-trace-dotnet
   ```

4. **View PR Diff**:
   ```bash
   gh pr diff <pr-number> --repo DataDog/dd-trace-dotnet
   ```

Azure DevOps commands:

1. **List Pipeline Runs**:
   ```bash
   az pipelines runs list --org https://dev.azure.com/datadoghq --project dd-trace-dotnet
   ```

2. **View Run Details**:
   ```bash
   az pipelines runs show --id <run-id> --org https://dev.azure.com/datadoghq --project dd-trace-dotnet
   ```

What to check:
- **Build status**: All builds passing
- **Test results**: No failing tests
- **Code coverage**: Coverage maintained or improved
- **Integration tests**: All integration tests passing
- **Smoke tests**: Smoke tests successful
- **PR template**: All sections filled out
- **Reviews**: Required reviewers approved

Common issues:
- Flaky tests: Check test history for patterns
- Timeout: Look for long-running tests
- Docker issues: Verify Docker services are healthy
- Dependencies: Check for version conflicts

After checking:
- Report status summary (passed/failed/running)
- Identify any blocking issues
- Suggest fixes for failures
- Provide links to detailed results
