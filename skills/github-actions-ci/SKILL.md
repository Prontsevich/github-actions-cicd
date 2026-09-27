---
name: github-actions-ci
description: >-
  Use when someone wants to add, explain, or fix a GitHub Actions CI workflow in .github/workflows: running tests, lint, or a build on push or pull request, the CI part of a CI/CD request, or finding out why an Actions run failed. Not for deployment, release publication, or rollback (use github-actions-cd), and not for GitLab CI, Jenkins, or CircleCI.
---

# GitHub Actions CI

Help the user add the smallest useful CI for the project they actually have. Explain each step in plain language matching the user's language. Never assume a stack or command before inspecting the repository.

CI here only verifies code. If the user also wants deployment, release publication, or rollback, finish the CI part first, then continue with `$github-actions-cd`; do not improvise delivery steps from this skill.

## Inspect the project

Read the repository guidance (`AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `README`), project manifests, lockfiles, and `.github/workflows/`. Identify:

- The runtime and version from project files such as `.nvmrc`, `.python-version`, `pyproject.toml`, `go.mod`, `.ruby-version`, or `rust-toolchain.toml`.
- The package manager and committed lockfile.
- Existing test, lint, and build commands, including the files that define them.
- The default branch, from `git symbolic-ref refs/remotes/origin/HEAD` or `gh repo view --json defaultBranchRef`. Do not assume `main`.
- Whether changes are pushed directly or sent through pull requests.
- The working directory and commands for each package in a monorepo.

Summarize the evidence before editing. Separate facts from assumptions. Ask a focused question if the change flow, runtime, or command cannot be established. Do not invent scripts, versions, lockfiles, or output paths.

## Create a minimal CI workflow

Run existing tests and production build when available. Add lint only if the project already has a real lint command.

Choose the trigger from the user's change flow:

- **Pull requests:** `pull_request` into the default branch, plus `push` to the default branch so the merged result is checked too. These do not duplicate each other.
- **Direct pushes:** `push` to the default branch. Explain that CI reports after the push and does not block a commit already pushed.

Create or update one clear workflow under `.github/workflows/`; if one already exists, fix it instead of adding a second. Use a linear job: a GitHub-hosted runner, check out the code, set up the runtime, install dependencies from the lockfile, then run the verified commands as named steps.

- **Runtime:** read the version from the project's file through the setup action's file input (`node-version-file`, `python-version-file`, `go-version-file`) instead of copying the number into the workflow.
- **Permissions:** set `permissions: contents: read` unless a step needs more.
- **Timeout:** set `timeout-minutes` on the job. Base it on known check duration; if unknown, start around 10-15 minutes for a small project and say it can be adjusted after the first runs.
- **Monorepo:** give each package its own job with `defaults.run.working-directory`. Action inputs such as `node-version-file` still resolve from the repository root.
- **Actions:** a current major tag is acceptable for first-party `actions/*` actions; pin any third-party action to a verified full commit SHA with a version comment. Never invent a version or SHA. Avoid matrices, caching, extra actions, and release automation unless the project needs them.

Do not add credentials or secrets to ordinary test/build CI, and never put secret values in workflow files, logs, or chat. Never use `pull_request_target` to build or run proposed code.

For the expected shape of a finished workflow and its explanation, see [references/examples.md](references/examples.md). Adapt it to the verified facts; never copy a command the project does not have.

## Handle common gaps

Name the gap, explain its consequence, and offer the smallest fix; never paper over it silently.

- **No tests:** run a real build if one exists, and say that CI checks the build but does not test behavior. Never invent a placeholder test or weaken checks just to get a green run.
- **No test or build command:** do not create an empty or `echo`-only workflow. Explain that CI needs a real command and offer to add one to the project first.
- **No committed lockfile:** explain that dependency versions may change between runs and recommend committing the lockfile. If the user declines, use the install command that works without it (for example `npm install` instead of `npm ci`) and state that runs are not reproducible.
- **Checks need environment variables or a database:** find out what they actually need. Use non-secret test values in `env:`, or a service container for a database. If a real secret or paid external service is required, explain the dependency and ask before wiring it in. Secrets are not available to pull requests from forks.
- **Runtime version not declared:** ask the user to choose, or offer to add a version file, before configuring CI. Do not silently pick a version.
- **No network access:** if action versions cannot be checked online, use the current major tag of a first-party action only when confident it exists, say it was not verified, and give the user `gh api repos/actions/<name>/releases/latest --jq .tag_name` to check it.

## Explain and verify

Explain what each step does, why it is present, and which project file proves the runtime or command. Clarify that a green run confirms only the checks configured in the workflow.

Check the trigger and branch filter, action references, permissions, timeout, working directory, runtime, install command, and every referenced script. Run `actionlint` on the workflow when it is installed; otherwise check the YAML structure by reading it.

Run the same install and check commands locally when the environment allows, and report what passed. If install fails because the sandbox has no network access, that is an environment limit, not a project failure: ask for approval to run it with network access, or list the commands for the user to run. Do not claim a remote run succeeded unless it actually ran.

## Fix a failing run

Find the first failed step, in the Actions tab, in the pull request's Checks, or with `gh run list` and `gh run view <run-id> --log-failed` when the GitHub CLI is available. Reproduce that command locally when possible, then fix the cause in the workflow or the project. Do not fix a red workflow by deleting tests, weakening assertions, or skipping steps.

## Report

Finish with the files changed, verified project facts, checks performed and their results, and the user's next action. Keep code and workflow comments in English; explain in the user's language.

## Official references

- [GitHub Actions workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [Building and testing code with GitHub Actions](https://docs.github.com/en/actions/tutorials/build-and-test-code)
- [Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub Actions secrets](https://docs.github.com/en/actions/reference/security/secrets)
