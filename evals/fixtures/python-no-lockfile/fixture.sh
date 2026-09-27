#!/usr/bin/env bash
set -euo pipefail
printf 'requests\npytest\n' > requirements.txt
echo "3.12" > .python-version
cat > app.py <<'EOF'
def slugify(title):
    return "-".join(title.lower().split())
EOF
mkdir -p tests
cat > tests/test_app.py <<'EOF'
from app import slugify


def test_slugify():
    assert slugify("Hello World") == "hello-world"
EOF
cat > README.md <<'EOF'
# Slugify

Run tests: `python -m pytest`
EOF
git init -q -b main
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial commit"
