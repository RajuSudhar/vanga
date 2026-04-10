#!/usr/bin/env sh

# VSCode Workspace Setup
# Creates .vscode/ settings and installs recommended extensions

echo "VSCode Workspace Setup"
echo "====================="
echo ""

if ! command -v code &> /dev/null; then
  echo "WARNING: VSCode 'code' command not found in PATH"
  echo "Install via: VSCode > Cmd+Shift+P > 'Install code command in PATH'"
  exit 1
fi

echo "This script will:"
echo "  1. Create .vscode/ directory with workspace settings"
echo "  2. Install recommended VSCode extensions:"
echo "     - ESLint (dbaeumer.vscode-eslint)"
echo "     - Prettier (esbenp.prettier-vscode)"
echo "     - Markdownlint (DavidAnson.vscode-markdownlint)"
echo ""
read -p "Proceed? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

mkdir -p .vscode

echo "[1/3] Creating workspace settings..."
cat > .vscode/settings.json << 'EOF'
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.fixAll.markdownlint": "explicit"
  },
  "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
  "eslint.format.enable": false,
  "prettier.requireConfig": true,
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  "[markdown]": {
    "editor.defaultFormatter": "DavidAnson.vscode-markdownlint",
    "editor.formatOnSave": true,
    "editor.wordWrap": "on",
    "files.trimTrailingWhitespace": false
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
EOF

cat > .vscode/extensions.json << 'EOF'
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "DavidAnson.vscode-markdownlint"
  ]
}
EOF

echo "SUCCESS: Workspace settings created"
echo ""

echo "[2/3] Installing VSCode extensions..."
extensions=(
  "dbaeumer.vscode-eslint"
  "esbenp.prettier-vscode"
  "DavidAnson.vscode-markdownlint"
)
for ext in "${extensions[@]}"; do
  echo "Installing $ext..."
  code --install-extension "$ext" --force
done

echo "SUCCESS: Extensions installed"
echo ""

echo "[3/3] Checking .gitignore..."
if ! grep -q "^\.vscode/$" .gitignore 2> /dev/null; then
  echo "" >> .gitignore
  echo ".vscode/" >> .gitignore
  echo "SUCCESS: Added .vscode/ to .gitignore"
else
  echo "INFO: .vscode/ already in .gitignore"
fi

echo ""
echo "Done. Reload VSCode window (Cmd+Shift+P > Reload Window)."
