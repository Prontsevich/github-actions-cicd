#!/usr/bin/env bash
set -euo pipefail
mkdir -p src test .github/workflows
cat > package.json <<'EOF'
{
  "name": "calc",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "test:unit": "node --test"
  }
}
EOF
cat > package-lock.json <<'EOF'
{
  "name": "calc",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "calc",
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
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: 16
      - run: npm ci
      - run: npm test
EOF
git init -q -b main
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial commit"
