#!/usr/bin/env bash
set -euo pipefail
mkdir -p src test .github/workflows
cat > package.json <<'EOF'
{
  "name": "notes-app",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "test": "node --test",
    "build": "node -e \"require('node:fs').mkdirSync('dist',{recursive:true})\""
  }
}
EOF
cat > package-lock.json <<'EOF'
{
  "name": "notes-app",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "notes-app",
      "version": "1.0.0"
    }
  }
}
EOF
echo "24" > .nvmrc
cat > src/sum.js <<'EOF'
exports.sum = (a, b) => a + b;
EOF
cat > test/sum.test.js <<'EOF'
const test = require("node:test");
const assert = require("node:assert");
const { sum } = require("../src/sum");

test("sum adds two numbers", () => {
  assert.strictEqual(sum(2, 2), 4);
});
EOF
cat > .github/workflows/ci.yml <<'EOF'
name: CI
on:
  pull_request:
    branches: [main]
permissions:
  contents: read
jobs:
  check:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-node@v7
        with:
          node-version-file: .nvmrc
      - run: npm ci
      - run: npm test
      - run: npm run build
EOF
git init -q -b main
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial commit"
