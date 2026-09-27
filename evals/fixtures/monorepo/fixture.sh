#!/usr/bin/env bash
set -euo pipefail
mkdir -p web/src web/test api/tests
cat > web/package.json <<'EOF'
{
  "name": "web",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "test": "node --test",
    "build": "node -e \"require('node:fs').mkdirSync('dist',{recursive:true})\""
  }
}
EOF
cat > web/package-lock.json <<'EOF'
{
  "name": "web",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "web",
      "version": "1.0.0"
    }
  }
}
EOF
echo "24" > web/.nvmrc
cat > web/src/sum.js <<'EOF'
exports.sum = (a, b) => a + b;
EOF
cat > web/test/sum.test.js <<'EOF'
const test = require("node:test");
const assert = require("node:assert");
const { sum } = require("../src/sum");

test("sum adds two numbers", () => {
  assert.strictEqual(sum(2, 2), 4);
});
EOF
printf 'pytest==8.3.3\n' > api/requirements.txt
echo "3.12" > api/.python-version
cat > api/app.py <<'EOF'
def health():
    return {"status": "ok"}
EOF
cat > api/tests/test_app.py <<'EOF'
from app import health


def test_health():
    assert health() == {"status": "ok"}
EOF
cat > README.md <<'EOF'
# Shop

- `web/` — frontend: `npm test`, `npm run build`
- `api/` — backend: `python -m pytest`
EOF
printf 'node_modules/\ndist/\n__pycache__/\n' > .gitignore
git init -q -b main
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial commit"
