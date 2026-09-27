#!/usr/bin/env bash
# one-time setup for a repository made from mach-template. run it once from a
# fresh clone, and it deletes itself.
#
# usage: ./setup.sh [project-id]
#   project-id  defaults to the repository name without a leading "mach-",
#               with dashes turned into underscores
#
# it configures the github repository (main and dev branches with dev as
# default, merge commits only, the label set, and rulesets protecting main, dev
# and v* tags), then renames the project, strips the template notes from
# README.md, and commits and pushes that with this script removed. if it fails
# before that commit, fix the cause and run it again. needs git and gh, with
# admin rights on the repo.
set -euo pipefail
cd "$(dirname "$0")"

repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
name=${repo#*/}
id=${1:-$(sed -e 's/^mach-//' -e 's/-/_/g' <<< "$name")}
[[ "$id" =~ ^[a-z][a-z0-9_]*$ ]] || { echo "error: project id '$id' must match [a-z][a-z0-9_]*, pass one explicitly" >&2; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "error: commit or stash your changes first" >&2; exit 1; }
echo "setting up $repo as project '$id'"

head=$(gh api "repos/$repo" --jq .default_branch)
sha=$(gh api "repos/$repo/git/ref/heads/$head" --jq .object.sha)
for branch in main dev; do
    if ! gh api "repos/$repo/git/ref/heads/$branch" > /dev/null 2>&1; then
        gh api --method POST "repos/$repo/git/refs" -f ref="refs/heads/$branch" -f sha="$sha" > /dev/null
        echo "created $branch"
    fi
done

gh api --method PATCH "repos/$repo" --input - > /dev/null <<'EOF'
{
  "default_branch": "dev",
  "has_wiki": false,
  "allow_merge_commit": true,
  "allow_squash_merge": false,
  "allow_rebase_merge": false,
  "allow_update_branch": true,
  "delete_branch_on_merge": true,
  "merge_commit_title": "PR_TITLE",
  "merge_commit_message": "PR_BODY"
}
EOF
echo "dev is the default branch, merge commits only"

while IFS='|' read -r label color description; do
    gh label create "$label" -R "$repo" --force --color "$color" --description "$description" > /dev/null
done <<'EOF'
major|2e1065|Breaking change requiring consumer updates
minor|8250df|Backwards-compatible new feature or capability
patch|d2a8ff|Backwards-compatible bug fix or maintenance update
feature|2da44e|New capability or feature addition
fix|d4a72c|Bug fix or defect resolution
removal|db6d28|Feature deprecation or code pruning
chore|6e7781|Maintenance, refactor, or non-functional code change
performance|e85aad|Optimization, latency, or resource efficiency
testing|04264e|Test suites, harness, benchmarks, or mocks
tooling|0969da|Build systems, workflows, CI/CD, and developer tooling
doc|54aeff|Documentation, guides, specifications, and comments
critical|cf222e|Urgent blocker requiring immediate resolution
blocked|d93f0b|Work is waiting on an external dependency or upstream issue
security|82071e|Vulnerability or cryptographic security concern
discussion|d4c5f9|Design proposal, RFC, or open debate
EOF
for label in bug documentation duplicate enhancement "good first issue" "help wanted" invalid question wontfix; do
    gh label delete "$label" -R "$repo" --yes > /dev/null 2>&1 || true
done
echo "labels set"

# create or update a ruleset by name, so a rerun converges
ruleset() {
    local body id
    body=$(cat)
    id=$(gh api "repos/$repo/rulesets" --jq ".[] | select(.name == \"$1\") | .id")
    if [ -n "$id" ]; then
        gh api --method PUT "repos/$repo/rulesets/$id" --input - > /dev/null <<< "$body"
    else
        gh api --method POST "repos/$repo/rulesets" --input - > /dev/null <<< "$body"
    fi
}

# repository admins bypass both rulesets, which is how releases are cut
ruleset branches <<'EOF'
{
  "name": "branches",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [{ "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" }],
  "conditions": { "ref_name": { "include": ["refs/heads/main", "refs/heads/dev"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "allowed_merge_methods": ["merge"],
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false } },
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [{ "context": "gate", "integration_id": 15368 }] } }
  ]
}
EOF
ruleset "release tags" <<'EOF'
{
  "name": "release tags",
  "target": "tag",
  "enforcement": "active",
  "bypass_actors": [{ "actor_id": 5, "actor_type": "RepositoryRole", "bypass_mode": "always" }],
  "conditions": { "ref_name": { "include": ["refs/tags/v*"], "exclude": [] } },
  "rules": [{ "type": "deletion" }, { "type": "update" }]
}
EOF
echo "rulesets set"

# the github side is done, so the one step that cannot be rerun goes last
old=$(sed -n -E 's/^id[[:space:]]*=[[:space:]]*"(.*)"/\1/p' mach.toml)
sed -i.bak -E \
    -e "s/^(id[[:space:]]*=[[:space:]]*)\"$old\"/\1\"$id\"/" \
    -e "s/^\[artifact\.$old\]/[artifact.$id]/" \
    -e "s|^(out[[:space:]]*=[[:space:]]*\"[^\"]*/)$old|\1$id|" \
    mach.toml
sed -i.bak -e "s/^# mach-template\$/# $name/" -e '/<!-- template -->/,/<!-- \/template -->/d' README.md
cat -s README.md > README.md.bak && mv README.md.bak README.md
rm -f mach.toml.bak
git rm -q setup.sh
git add mach.toml README.md
git commit -q -m "chore: set up $name"
git push -q
echo "committed and pushed the setup"

echo "done. work happens on branches off dev"
