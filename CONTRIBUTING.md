# Contributing

## Building and testing

The compiler version is `mach-version` in `.github/workflows/ci.yml`, within the
`mach` range in `mach.toml`.

```sh
mach dep pull .
mach build .
mach test .
```

Tests are `test` blocks in the module they test, and the library reaches every
module, so `mach test .` runs them all. The suites that exercise the whole API,
searching and conformance, are in `src/api.mach`. `--filter` narrows a run, as
`mach test . --filter parse`.

Formatting is checked in CI for the library and every demo:

```sh
mach fmt --check .
mach fmt --check demo/search
```

## Layout

| path | holds |
| --- | --- |
| `src/syntax/` | the parser, from pattern text to a syntax tree, and its errors |
| `src/compile/` | the compiler, from a tree to a byte program with UTF-8 automata for classes |
| `src/exec/` | the Pike VM that runs a program over a text |
| `src/api.mach` | the public API, forwarded by `src/lib/regex.mach` |
| `src/unicode/` | the generated Unicode tables and their lookups |
| `src/data/` | the conformance data, embedded by `src/api.mach` |
| `demo/` | one example program per project, built by CI |
| `doc/` | the generated API reference and the hand-written guides in `doc/guide/` |
| `tools/` | generators for committed sources |

A module file must not share its name with a type its module declares, in any
case: on a case-insensitive filesystem `Regex` would resolve to `regex.mach`.

## Documentation

Every public declaration has a docstring. The API reference, `doc/README.md` and
`doc/regex/`, is generated from them and committed. Regenerate it after changing
any docstring or public declaration:

```sh
mach doc .
```

CI fails when the committed reference differs from a fresh run. The guides in
`doc/guide/` are written by hand, and `mach doc` leaves them alone. A change to
behavior updates the guide that describes it, and a new example is a new project
under `demo/` with its own `README.md`, added to the index in `demo/README.md`.

## Unicode tables

`src/unicode/classes.mach` and `src/unicode/folds.mach` are generated from the
Unicode Character Database by `tools/unicode-tables`, which pins the UCD
version and the hash of every file it reads. Never edit them by hand. To
regenerate after changing the tool or its pin:

```sh
tools/unicode-tables
```

It downloads the UCD into `tools/.ucd/`, which is not committed. CI runs
`tools/unicode-tables --check` and fails when the committed tables differ from
what the tool generates.

## Conformance

`src/data/re2-search.txt` is RE2's search test data as Go's
`regexp/testdata` carries it, under the license beside it, and the
`conformance__re2_search` test in `src/api.mach` runs every check in it. The data is marked `-text`
in `.gitattributes` so that no checkout rewrites its line endings. A change
that makes any check fail is a change to RE2's semantics, and needs a reason
that RE2 itself would accept.

## Workflow

`dev` is the default branch. Work branches from it as `feat/<issue>` or
`fix/<issue>` and merges back through a pull request. `main` only takes release
merges from `dev`. A `hotfix/<issue>` branches from `main` and merges into both.

Both branches require a pull request and a passing `gate` check. Neither can be
deleted or force-pushed, and pull requests merge with a merge commit. Repository
admins can bypass these rules to cut a release. Once a `v*` tag is pushed, only
an admin can move or delete it.

Commits follow [Conventional Commits](https://www.conventionalcommits.org), with
the issue number as the scope: `fix(#12): reject a negative length`. A change
that users will notice gets a line under `[Unreleased]` in `CHANGELOG.md`.

Issues are labeled on independent axes:

| axis | labels |
| --- | --- |
| semver magnitude | `patch`, `minor`, `major` |
| kind of work | `feature`, `fix`, `removal`, `chore`, `performance` |
| where, omitted for core code | `testing`, `tooling`, `doc` |
| severity and state | `critical`, `blocked`, `security` |
| discussion | `discussion` |

## CI

`.github/workflows/ci.yml` runs the shared Mach library pipeline,
`mach-lib.yml` from `briar-systems/.github`. A pull request into `dev` builds
and tests on `x86_64-linux`, checks formatting, builds every demo and
cross-builds every manifest target in release. A pull request into `main` runs
every leg. To run every leg on any branch, use
`gh workflow run CI --ref <branch> -f heavy=all`.

`.github/ci/verify.sh` runs the repository's own checks on the primary leg: the
Unicode tables and the API reference against fresh runs.

The last job, `gate`, is the check the branch rules require. Change the
compiler version in `ci.yml` together with the `mach` range in `mach.toml`.

## Releases

1. Set `version` in `mach.toml` and move `[Unreleased]` in `CHANGELOG.md` to the
   release's section, and merge that into `dev`.
2. Merge `dev` into `main` through a pull request, which runs every leg.
3. Tag `main` and push the tag: `git tag vX.Y.Z && git push origin vX.Y.Z`.

`.github/workflows/cd.yml` runs the shared release pipeline, which checks the
tag against the manifest and the changelog, runs every CI leg and publishes the
release.
