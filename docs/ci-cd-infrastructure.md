# CI/CD Infrastructure

## Overview

BusyBox uses **GitHub Actions** for continuous integration and testing. The CI/CD infrastructure is maintained in a separate repository for better organization and separation of concerns.

## Infrastructure Repository

**Repository**: [busy4me/DevOps](https://github.com/busy4me/DevOps)

### Historical Note

⚠️ **Repository Rename (2026-02-10):**
- **Previous Name**: `busy4me/dev`
- **New Name**: `busy4me/DevOps`
- **Reason**: Avoid naming conflicts with "dev" branch name and improve descriptive clarity

GitHub automatically redirects old URLs, but all references in this repository have been updated to use the new name.

## Workflow Integration

BusyBox repository triggers tests in the DevOps infrastructure using GitHub's `repository_dispatch` event:

```yaml
# .github/workflows/trigger-vm-tests.yml
- name: Trigger repository_dispatch
  uses: peter-evans/repository-dispatch@v2
  with:
    token: ${{ secrets.DISPATCH_TOKEN }}
    repository: busy4me/DevOps
    event-type: busybox-install-request
```

## Test Infrastructure

### Self-Hosted Runners

Tests run on self-hosted GitHub Actions runners:

**Location**: lab1 (10.51.1.183)

**Runners**:
- `github-runner1-lab1` - Primary runner
- `github-runner2-lab1` - Secondary runner
- `github-runner3-lab1` - Tertiary runner

**Capacity**: 3 concurrent test executions

### VM Testing

Tests use **VirtualBox** to create clean VM environments:

1. **Clone Template**: Fresh Debian 12 VM from template
2. **SSH Forwarding**: Dynamic port allocation (2201-2222)
3. **Script Execution**: Copy and run `initiv` script
4. **Log Collection**: Monitor installation progress
5. **Artifact Storage**: Save logs and test results

## Monitoring Test Runs

**Via GitHub UI:**
```
https://github.com/busy4me/DevOps/actions
```

**Via gh CLI:**
```bash
# List recent runs
gh run list --repo busy4me/DevOps

# View specific run
gh run view <run-id> --repo busy4me/DevOps --log

# Download artifacts
gh run download <run-id> --repo busy4me/DevOps
```

## Triggering Tests Manually

### From BusyBox Repository

**Automatic (on push):**
```bash
git push origin main    # Triggers main branch test
git push origin dev     # Triggers dev branch test
```

**Manual:**
```bash
gh workflow run trigger-vm-tests.yml --repo busy4me/busybox
```

### Direct DevOps Invocation

```bash
gh workflow run vm-tty1-test.yml --repo busy4me/DevOps \
  -f target_repo=busy4me/busybox \
  -f target_branch=main \
  -f vm_template=deb12 \
  -f test_suite=busybox
```

## Troubleshooting

If tests fail or hang, see:
- [Troubleshooting Guide](https://github.com/busy4me/DevOps/tree/main/docs/troubleshooting)
- [Known Issues](https://github.com/busy4me/DevOps/blob/main/docs/troubleshooting/known-issues.md)
- [Pipeline Analysis](https://github.com/busy4me/DevOps/blob/main/docs/troubleshooting/pipeline-analysis-2026-02-10.md)

## Repository Structure

```
busy4me/DevOps/
├── .github/workflows/     # GitHub Actions workflows
│   ├── vm-tty1-test.yml  # Main VM test workflow
│   └── examples/         # Example workflows
├── scripts/              # Helper scripts
│   ├── monitor-busybox-install.sh
│   └── install-runner.sh
├── docs/                 # Documentation
│   ├── troubleshooting/
│   ├── architecture/
│   └── REPOSITORY-RENAME.md
└── tests/                # Test configurations
```

## Security

### Required Secrets

BusyBox repository requires the following GitHub secret:

- **`DISPATCH_TOKEN`**: Personal Access Token with `repo` scope for triggering DevOps workflows

### Runner Security

- Self-hosted runners operate in isolated network (Zerotier/Headscale)
- VMs are destroyed after each test (no persistent data)
- SSH keys are temporary and test-specific

## Performance

**Typical Test Duration**:
- Clean installation: ~18-22 minutes
- Stage 0: ~3 minutes
- Stage 1: ~12-15 minutes
- Stage 2: ~3-5 minutes

**Concurrent Capacity**: 3 parallel tests

## Future Improvements

- [ ] Add test result dashboard
- [ ] Implement automatic runner registration recovery
- [ ] Add performance regression detection
- [ ] Expand to ARM/Raspberry Pi test runners
- [ ] Add Docker-based testing for faster iteration

---

**Last Updated**: 2026-02-10  
**Author**: Dariusz Porczyński
# Test automatic workflow trigger - 2026-02-11 16:31:46
