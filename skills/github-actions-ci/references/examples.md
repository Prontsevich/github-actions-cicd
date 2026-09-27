# Example workflows

These show the expected shape of a finished minimal CI and of its explanation. They are not templates: every runtime version, install command, script name, and branch must come from the user's repository. Action tags were verified on 2026-09-28; check them again before use.

## Node.js project with npm, pull requests into `main`

Facts this example depends on, each proven by the repository:
- `.nvmrc` contains `24`.
- `package-lock.json` is committed.
- `package.json` defines `test` and `build` scripts.
- The default branch is `main`, and work goes through pull requests.

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  check:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - name: Check out code
        uses: actions/checkout@v7

      - name: Set up Node.js from .nvmrc
        uses: actions/setup-node@v7
        with:
          node-version-file: .nvmrc

      - name: Install dependencies from package-lock.json
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build
```

Explanation shape (write it in the user's language):

| Step | What it does | Proven by |
|---|---|---|
| `on: pull_request` | Checks every pull request into `main` before merge | The user works through pull requests |
| `on: push` | Checks the merged result on `main` | Default branch is `main` |
| `permissions: contents: read` | The job can read the code but cannot push or change anything | No step needs write access |
| `timeout-minutes: 15` | Stops a hung run instead of letting it run for hours | Initial limit; adjust after the first runs |
| `setup-node` with `node-version-file` | Uses the same Node.js version as local development | `.nvmrc` |
| `npm ci` | Installs exactly the lockfile versions and fails if the lockfile and `package.json` disagree | `package-lock.json` |
| `npm test`, `npm run build` | The project's own checks | `scripts` in `package.json` |

## Python project with pip, direct pushes to `main`

Facts this example depends on:
- `.python-version` contains `3.12`.
- `requirements.txt` pins exact versions with `==` and includes `pytest`.
- The user pushes directly to `main` without pull requests.

```yaml
name: CI

on:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - name: Check out code
        uses: actions/checkout@v7

      - name: Set up Python from .python-version
        uses: actions/setup-python@v7
        with:
          python-version-file: .python-version

      - name: Install dependencies
        run: python -m pip install -r requirements.txt

      - name: Run tests
        run: python -m pytest
```

Tell the user: with a `push` trigger the result arrives after the code is already on `main`; CI reports a problem but does not block it.

## One package inside a monorepo

Only the part that differs. The frontend lives in `web/` with its own lockfile:

```yaml
jobs:
  web:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    defaults:
      run:
        working-directory: web
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version-file: web/.nvmrc
      - run: npm ci
      - run: npm test
```

`defaults.run.working-directory` applies to `run` steps only. Action inputs such as `node-version-file` are resolved from the repository root, so they need the full path. Give each package its own job with its own verified commands.
