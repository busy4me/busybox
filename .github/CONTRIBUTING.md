# Contributing to BusyBox

First off, thanks for taking the time to contribute! 🎉

The following is a set of guidelines for contributing to BusyBox. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Code of Conduct

This project and everyone participating in it is governed by the [BusyBox Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report for BusyBox. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

-   **Use a clear and descriptive title** for the issue to identify the problem.
-   **Describe the exact steps which reproduce the problem** in as many details as possible.
-   **Provide specific examples** to demonstrate the steps.
-   **Include logs and screenshots** which show you the problem.

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion for BusyBox, including completely new features and minor improvements to existing functionality. Following these guidelines helps maintainers and the community understand your suggestion and find related suggestions.

-   **Use a clear and descriptive title** for the issue to identify the suggestion.
-   **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
-   **Provide specific examples** to demonstrate the steps.
-   **Include screenshots and animated GIFs** which show you the enhancement.

## Pull Requests

### Branching Strategy

**IMPORTANT**: We use a strict branching workflow.

*   **Target Branch**: All Pull Requests must target the **`dev`** branch. PRs targeting `main` will be closed (unless they are documentation fixes or critical hotfixes).
*   **Feature Branches**: Create your branch from `dev` (e.g., `feat/login-flow`, `fix/novnc-crash`).
*   **Merge Process**: `feat/...` → `dev` → (test) → `main`.

### Process

1.  Fork the repo and create your branch from `dev`.
2.  If you've added code that should be tested, add tests.
3.  If you've changed APIs, update the documentation.
4.  Ensure the test suite passes.
5.  Make sure your code follows the existing style.
6.  Issue that pull request!

### Commit Messages

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification with emojis.

Format: `emoji type: description`

Examples:
-   `✨ feat: add new login flow`
-   `🐛 fix: resolve crash on startup`
-   `📝 docs: update README`
-   `♻️ refactor: optimize database queries`
-   `🧪 test: add unit tests for user service`

## Styleguides

### Git Commit Messages

-   Use the present tense ("Add feature" not "Added feature").
-   Use the imperative mood ("Move cursor to..." not "Moves cursor to...").
-   Limit the first line to 72 characters or less.
-   Reference issues and pull requests liberally after the first line.

### Documentation

-   Update `README.md` and `docs/` if necessary.
-   Use clear and concise language.
-   Check spelling and grammar.
