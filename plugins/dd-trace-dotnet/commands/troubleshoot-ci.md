---
description: Troubleshoot CI/CD pipeline failures
---

Troubleshoot CI/CD pipeline failures in the dd-trace-dotnet repository.

Available CI systems:
1. **Azure DevOps** - Primary CI/CD system (`.azure-pipelines/`)
2. **GitHub Actions** - Secondary workflows (`.github/workflows/`)

Common failure types:
- **Build failures**: Check build logs for compilation errors
- **Test failures**: Analyze test output for specific failures
- **Integration test failures**: Check Docker containers, network issues
- **Timeout issues**: Look for hung tests or long-running operations
- **Flaky tests**: Identify intermittent failures and patterns

Steps to troubleshoot:
1. **Identify the failed stage**: Build, test, or deployment
2. **Review logs**: Look for error messages, stack traces, or warnings
3. **Check for known issues**: Search recent PRs or issues
4. **Reproduce locally**: Try to run the same build/test locally
5. **Use pipeline tools**:
   - Azure DevOps: `az pipelines runs show --id <run-id>`
   - GitHub Actions: `gh run view <run-id>`

Documentation:
- See `docs/development/CI/TroubleshootingCIFailures.md` for detailed guidance
- See `docs/development/CI/RunSmokeTestsLocally.md` for local testing

Common solutions:
- Restart the pipeline if infrastructure issue
- Update test package versions if dependency issue
- Increase timeout for slow tests
- Fix test data or mocks for integration tests
