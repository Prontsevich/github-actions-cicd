#!/usr/bin/env bash
set -euo pipefail
cat > package.json <<'EOF'
{
  "name": "landing-page",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "build": "node scripts/build.js"
  }
}
EOF
cat > package-lock.json <<'EOF'
{
  "name": "landing-page",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "landing-page",
      "version": "1.0.0"
    }
  }
}
EOF
echo "24" > .nvmrc
mkdir -p scripts src
cat > scripts/build.js <<'EOF'
const fs = require("node:fs");
fs.mkdirSync("dist", { recursive: true });
fs.copyFileSync("src/index.html", "dist/index.html");
console.log("Built dist/index.html");
EOF
echo '<!doctype html><title>Landing</title><h1>Hello</h1>' > src/index.html
printf 'node_modules/\ndist/\n' > .gitignore
git init -q -b master
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial commit"
