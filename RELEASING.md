# Releasing

This checklist prepares `hangul_choseong_search` 0.1.0 for release. Run commands from the package root. Local checks don't write to GitHub or pub.dev.

## 1. Confirm the release identity

```sh
test "$(grep -c '^version: 0.1.0$' pubspec.yaml)" -eq 1
test "$(grep -c '^## 0.1.0$' CHANGELOG.md)" -eq 1
test "$(grep -c '^name: hangul_choseong_search$' pubspec.yaml)" -eq 1
git diff --check
git status --short
```

Review the 0.1.0 changelog against the final diff. Confirm that the working tree contains only intended release changes and that the release commit is the commit being checked.

## 2. Run local quality checks

```sh
fvm dart pub get
fvm dart format --output=none --set-exit-if-changed .
fvm dart analyze
fvm dart test
fvm dart doc
fvm dart run example/main.dart
fvm dart run benchmark/search_benchmark.dart
```

The benchmark is a smoke check only. Its measured times aren't release thresholds.

## 3. Validate and inspect the package archive

```sh
fvm dart pub publish --dry-run
```

The command builds and validates the archive without publishing it. Read the complete package file list in its output. Confirm that it contains the public library, metadata, license, changelog, documentation, and examples. It must not contain `.dart_tool`, generated dartdoc output, local evidence, credentials, editor files, or other private files. Resolve every warning before continuing.

Run the dry run again after any archive or metadata change. The final run must exit successfully with zero warnings.

## 4. External write gates

Each action below changes an external service. Stop before every gate and get explicit maintainer approval for the exact commit and command. Don't combine these commands into an unattended script. Existing authenticated Git and pub.dev sessions must be managed outside the repository.

### Gate A: push the reviewed commit

Confirm the local release commit, get approval, then run:

```sh
git push origin main
```

Verify that GitHub `main` points to the reviewed commit before continuing.

### Gate B: create and push the tag

Get separate approval to create `v0.1.0`, then run:

```sh
git tag -a v0.1.0 -m "hangul_choseong_search 0.1.0"
git push origin v0.1.0
```

If approval isn't given, don't create or push the tag.

### Gate C: publish to pub.dev

Rerun the identity checks, quality checks, and publish dry run from the tagged commit. Inspect the archive list again. Get separate approval to publish, then run the interactive command:

```sh
fvm dart pub publish
```

Read the package name and version shown by the prompt before confirming. Don't use `--force`. Verify that pub.dev reports `hangul_choseong_search` version `0.1.0` before continuing.

### Gate D: create a GitHub Release

Get separate approval after the tag and published package are verified, then run:

```sh
gh release create v0.1.0 \
  --repo beomq/hangul_choseong_search_flutter \
  --title "hangul_choseong_search 0.1.0" \
  --notes-from-tag
```

Confirm that the release targets `v0.1.0` and links to the reviewed source. A tag, GitHub Release, or pub.dev publication is never implied by passing local checks.
