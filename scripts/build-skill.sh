#!/bin/sh
# Rebuild the Claude skill release zip from claude-skill/.
# Run from anywhere; resolves the repository root itself.
set -e
cd "$(dirname "$0")/.."
rm -f nx-menu-import-skill.zip
cd claude-skill
zip -qr ../nx-menu-import-skill.zip nx-menu-import -x '*.DS_Store'
cd ..
echo "Built nx-menu-import-skill.zip"
unzip -l nx-menu-import-skill.zip
