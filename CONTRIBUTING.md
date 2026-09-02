# Contributing

Thank you for helping improve these Dev Container Features.

## Public repository requirements

This repository must remain suitable for public distribution. Do not submit
proprietary project data, internal hostnames or URLs, credentials, access
tokens, private keys, certificates, or customer-specific configuration. Use
generic examples and public upstream references only.

## Development workflow

1. Create changes from `master`.
2. Keep Feature options backward compatible unless a breaking change is
   required. Each Feature follows semantic versioning independently.
3. Run the option checks and full runtime suite:

   ```bash
   bash test/validate-options.sh
   npx --yes @devcontainers/cli@0.88.0 features test .
   ```

4. Regenerate Feature documentation and commit it with the source change:

   ```bash
   bash scripts/generate-docs.sh
   git diff --exit-code
   ```

The generated `src/*/README.md` files must not be edited by hand. CI validates
the manifests, runs ShellCheck, regenerates documentation, and exercises each
Feature and the composed toolchain before a release can publish packages.

## Versioning

Use patch releases for backward-compatible fixes, minor releases for new
backward-compatible behavior or options, and major releases for breaking
changes. Update `CHANGELOG.md` with the affected Feature versions.
