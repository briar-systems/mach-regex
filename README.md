# mach-regex

Regular expressions for Mach with RE2's syntax and semantics, matched in time
linear in the pattern and the text, in pure Mach on the standard library alone.
It is being built toward 0.1.0 under the epic, and the syntax reference and API
arrive with it.

## Build

```sh
mach dep pull .
mach build .
mach test . --lib tests
```

## Workflow

`dev` is the default branch. Work branches from it as `feat/<issue>` or
`fix/<issue>` and merges back through a pull request. `main` only takes release
merges from `dev`. A `hotfix/<issue>` branches from `main` and merges into both.

Both branches require a pull request and a passing `gate` check. Neither can be
deleted or force-pushed, and pull requests merge with a merge commit. Repository
admins can bypass these rules to cut a release. Once a `v*` tag is pushed, only
an admin can move or delete it.

Commits follow [Conventional Commits](https://www.conventionalcommits.org), with
the issue number as the scope: `fix(#12): reject a negative length`.

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
and tests on `x86_64-linux`, checks formatting and cross-builds every manifest
target in release. A pull request into `main` runs every leg. To run every leg
on any branch, use `gh workflow run CI --ref <branch> -f heavy=all`.

The last job, `gate`, is the check the branch rules require. The compiler
version is `mach-version` in `ci.yml`. Change it together with the `mach` range
in `mach.toml`.

## Releases

1. Set `version` in `mach.toml` and the release's section in `CHANGELOG.md`, and
   merge that into `dev`.
2. Merge `dev` into `main` through a pull request, which runs every leg.
3. Tag `main` and push the tag: `git tag vX.Y.Z && git push origin vX.Y.Z`.

`.github/workflows/cd.yml` runs the shared release pipeline, which checks the
tag against the manifest and the changelog, runs every CI leg and publishes the
release.

## License

MIT. See [LICENSE](LICENSE).
