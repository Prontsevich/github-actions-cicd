---
name: github-actions-cd
description: >-
  Use when someone asks to deploy, publish a release, or roll back through GitHub Actions: CD, the delivery part of a CI/CD request, preview, staging, or production deployment, package registry or GitHub Release publication, release approval gates, or restoring a known-good version. Not for ordinary test, lint, or build CI (use github-actions-ci).
---

# GitHub Actions CD

CD here means continuous delivery: every verified build can be shipped, and a person decides when it reaches production. Switch to continuous deployment, where every green build ships automatically, only after the user explicitly confirms that tradeoff.

Explain each step in plain language matching the user's language. Never assume a cloud provider, SSH, a static site, or a release layout. Never request or expose credential values.

## Require CI first

Delivery promotes a build that CI has already verified. Inspect `.github/workflows/` before anything else:

- **No CI that runs the project's tests or build:** set that up first with `$github-actions-ci`, then return here. For a combined CI/CD request, do the CI part first.
- **CI exists:** note its workflow file, trigger, job names, and the commands it runs. Delivery jobs will depend on it.

## Establish the release facts

Read `AGENTS.md`, `README`, contributing and release docs, build and signing scripts, and hosting configuration. Before editing, establish:

- The target: preview, staging, package registry, GitHub Release, or production.
- The user's authority to publish there.
- Which ref or event may release.
- What the runner needs to reach the target.
- The existing release procedure, if any.
- What rollback should restore.

Ask for missing operational facts. Summarize the evidence and separate facts from assumptions before editing.

## Map the real release stages

Inspect workflow triggers, branch checks, job dependencies, `environment`, secret scope, build and signing scripts, artifact upload/download, draft creation, publication, hosting configuration, and recovery documentation. Describe each stage separately:

1. **Build and validate:** run tests and produce the candidate artifact from a known commit. If signing, notarization, packaging, or release-specific checks exist, inspect and include those verified steps.
2. **Approval before sensitive work:** determine whether the approval starts a workflow or gates a job. `workflow_dispatch` is an operator starting a workflow. A GitHub Environment with configured protection rules can pause a job before it runs or accesses environment secrets. An agent's command-approval prompt is separate from product-release approval.
3. **Artifact handoff:** distinguish a temporary Actions artifact from a preview/staging deployment and from a GitHub Draft Release. Establish how long the artifact is retained, who can access it, and what the user is being asked to review.
4. **Promotion/publication:** identify the exact human action that makes the build public or production-facing. A Draft Release remains unpublished until someone publishes it.
5. **Post-release check:** verify the deployed version or release assets and perform a project-appropriate smoke check.

Do not assume every project needs all five stages. Keep the existing verified process if it is safe and understandable; add stages only to meet a stated need.

## Design a solo-operator release path

A solo operator can approve their own release; do not require a second reviewer by default. Choose a clear gate, such as a manual promotion workflow or a protected Environment where the operator is an allowed reviewer. Verify whether self-review is disabled and whether the repository plan supports the configured protections. Do not call an Environment protected unless its rules are configured and verified. A manual workflow start is an operator gate, but it is not the same as a second-person review.

Keep production release separate from pull-request CI. Never deploy untrusted pull request code, and never use `pull_request_target` to build or run proposed code. Restrict production jobs to a trusted ref/event, make them depend on successful CI, and use least-privilege token permissions. Scope deployment or signing credentials to the specific job and Environment that needs them. Never print credentials or put their values in workflow YAML, logs, chat, or artifacts.

Promote the exact artifact that passed CI and was reviewed; do not silently rebuild different code after approval. If a separate workflow publishes it, verify that the selected upstream run succeeded and matches the expected repository, workflow, branch/ref, commit SHA, version, and artifact names. `needs` applies only to jobs in one workflow; across workflows, verify the upstream run and artifact identity explicitly. Consider checksums or equivalent integrity validation when handing artifacts between workflows. Serialize deployments to the same target with `concurrency` and do not cancel an in-progress deployment unless the deployment method makes that safe.

If the user requests fully automatic production releases, explain that each release will no longer wait for an operator's approval. Make that change only after the user explicitly confirms that tradeoff.

## Plan and verify rollback

Treat rollback as a separate operation with its own trigger and target. Inspect how releases are versioned, where known-good artifacts are retained, and the documented command or workflow that restores one. Confirm that the selected version is compatible with current data and database schema; restoring app files alone may not reverse a migration or data change.

Require the operator to choose and deliberately start rollback for a specific known-good version. If you are asked to execute it, require an explicit user instruction to perform that production action. Do not automatically roll back after a failed health check unless the user explicitly requests that behavior and the project has a verified safe mechanism. After rollback, check the deployed version and run a smoke test. Do not delete the failed release or its evidence unless explicitly requested and safe.

## Run and report

Preparing workflow files and running production actions are different steps. Pushing, triggering a workflow, publishing a release, or deploying needs network access and an explicit user instruction in the current conversation; if the sandbox blocks it, ask for approval or give the user the exact command instead of working around the block.

Finish by stating which parts were inspected, prepared, and actually run. Never claim that deployment or rollback succeeded unless it ran and the target was checked. Keep code and workflow comments in English; explain in the user's language.

## Official references

- [Deployments and environments](https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
- [Manually running a workflow](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow)
- [Workflow artifacts](https://docs.github.com/en/actions/concepts/workflows-and-actions/workflow-artifacts)
- [Workflow concurrency](https://docs.github.com/en/actions/concepts/workflows-and-actions/concurrency)
- [GitHub Actions secrets](https://docs.github.com/en/actions/reference/security/secrets)
- [Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
