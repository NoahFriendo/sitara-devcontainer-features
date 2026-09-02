#!/bin/bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$repo_root"

generate_docs() {
    if [[ -n "${DEVCONTAINER_CLI:-}" ]]; then
        "$DEVCONTAINER_CLI" features generate-docs "$@"
    else
        npx --yes @devcontainers/cli@0.88.0 features generate-docs "$@"
    fi
}

generate_docs \
    --project-folder src \
    --namespace noahfriendo/sitara-devcontainer-features \
    --github-owner NoahFriendo \
    --github-repo sitara-devcontainer-features

for readme in src/*/README.md; do
    sed 's#/blob/main/#/blob/master/#g' "$readme" > "$readme.tmp"
    mv "$readme.tmp" "$readme"
done
