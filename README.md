# mach-regex

Regular expressions for Mach with RE2's syntax and semantics.

- **Linear time.** A search takes time proportional to the length of the
  pattern times the length of the text, whatever the pattern and whatever the
  text. There is no backtracking, so no pattern can make a search run away, and
  a pattern from an untrusted source is safe to compile and run.
- **RE2 syntax.** Patterns mean what they mean in RE2 and Go's `regexp`,
  leftmost-first by default and leftmost-longest on request. The library is held
  to RE2's own search tests.
- **Pure Mach.** It is written in Mach on the standard library alone, with no C
  and no libc, for linux, windows and darwin on x86_64, and linux and darwin on
  aarch64.
- **No allocation per search.** Compiling allocates, through the allocator you
  pass. Searching runs in a `Cache` you make once per compiled pattern and reuse,
  so a search allocates nothing.

When every match must begin with the same literal bytes, as `hello` in
`hello\s+world`, a search with no match in progress skips ahead to the next
place those bytes occur, scanning the text 16 bytes at a time.

## Using it

Add the dependency to a project:

```sh
mach dep add . regex --git https://github.com/briar-systems/mach-regex --version ^0.1
```

and import it with `use regex;`. Everything below is reached through that one
module.

## Examples

Every example here is a program in [`demo/readme`](demo/readme), a project that
depends on this library by path. Build and run them with:

```sh
mach dep pull .
mach dep pull demo/readme
mach build demo/readme
demo/readme/out/linux-x86_64/debug/bin/search
```

### Compiling and searching

[`search.mach`](demo/readme/src/bin/search.mach) compiles a pattern, makes its
cache and searches a text:

```mach
# compile a pattern, make a cache for it and search a text

use std.allocator;
use std.allocator.page;
use std.print;
use std.runtime;
use std.types.option.opt;
use std.types.result.res;
use std.types.string.str;
use std.types.string.str_len;
use std.types.view.View;
use std.types.view.view;

use regex;

fun text(s: str) View {
    ret view(s, str_len(s));
}

#[symbol("main")]
fun main(argc: i64, argv: **u8) i64 {
    var a: allocator.Allocator;
    page.make(?a);

    var re: res[regex.Regex, regex.Error] = regex.compile(?a, text("[a-z]+@[a-z]+\\.com"));
    if (sel re.err) { ret 1; }
    fin { regex.dnit(?re.ok); }

    # the scratch a search runs in, made once and reused for every search
    var c: res[regex.Cache, regex.Error] = regex.cache(?a, ?re.ok);
    if (sel c.err) { ret 1; }
    fin { regex.cache_dnit(?c.ok); }

    val hay: View = text("write to ada@example.com today");
    if (regex.is_match(?re.ok, ?c.ok, hay)) { print.println("it matches"); }

    val m: opt[regex.Match] = regex.find(?re.ok, ?c.ok, hay, 0);
    if (sel m.some) { print.printlnf("found at {}..{}", m.some.start, m.some.end); }
    ret 0;
}
```

It prints `it matches` and `found at 9..24`. The page allocator keeps the
example short, and any `std.allocator.Allocator` serves.

Patterns and texts are `View`s of UTF-8 bytes, and every position is a byte
offset into the text. `compile` returns the `Regex` or the first `Error` in the
pattern, and `dnit` releases it. `cache` makes the scratch a search runs in,
sized for that one `Regex`, and `cache_dnit` releases it. A cache serves only
the `Regex` it was made for, and one search at a time.

`is_match` says whether the pattern matches anywhere. `find` gives the leftmost
match at or after an offset as a `Match`, its `start` and the `end` just past
it. A search from an offset inside a code point starts at the next code point
boundary, and `^` and `\A` still mean the start of the whole text.

### Captures and named groups

[`captures.mach`](demo/readme/src/bin/captures.mach) reads every group of
`(?P<year>\d{4})-(?P<month>\d{2})-(\d{2})` by number and one by name. It
compiles and makes its cache as above, and `show` writes a `View` to stdout:

```mach
# two slots per group and two for the whole match: 8 for this pattern
var slots: [8]usize;
if (regex.slot_count(?re.ok) != 8) { ret 1; }

val hay: View = text("released on 2026-09-26");
if (!regex.captures(?re.ok, ?c.ok, hay, 0, ?slots[0])) { ret 1; }

var g: usize = 1;
for (g <= regex.group_count(?re.ok)) {
    val name: View = regex.group_name(?re.ok, g);
    print.printf("group {}", g);
    if (name.len > 0) {
        print.print(" ");
        show(name);
    }
    print.printf(" at {}..{}: ", slots[2 * g], slots[2 * g + 1]);
    show(view(?hay.data[slots[2 * g]], slots[2 * g + 1] - slots[2 * g]));
    print.println("");
    g = g + 1;
}

val month: opt[usize] = regex.group_index(?re.ok, text("month"));
if (sel month.some) { print.printlnf("month is group {}", month.some); }
```

It prints:

```text
group 1 year at 12..16: 2026
group 2 month at 17..19: 09
group 3 at 20..22: 26
month is group 2
```

`captures` fills `slot_count(re)` offsets in memory you provide: slots `2n` and
`2n+1` are group `n`'s start and end, group 0 being the whole match. A group that
took no part in the match has `NONE` in both its slots, as the optional group of
`(a)(b)?` does against `a`. Groups are numbered from 1 in the order their `(`
appears. `group_count` is how many there are, `group_name` gives a group's name,
empty for an unnamed group, and `group_index` finds a group by name.

### Every match

[`iterate.mach`](demo/readme/src/bin/iterate.mach) walks every match of `\d+`:

```mach
val hay: View       = text("3 apples, 12 pears and 40 plums");
var it:  regex.Iter = regex.iter();
for {
    val m: opt[regex.Match] = regex.next(?re.ok, ?c.ok, hay, ?it);
    if (sel m.none) { brk; }
    print.printlnf("{}..{}", m.some.start, m.some.end);
}
```

It prints `0..1`, `10..12` and `23..25`. `iter` starts a walk from the start of
the text and `next` gives each match in turn, as Go's `FindAll` does: matches do
not overlap, an empty match directly after the previous match is skipped, and
after an empty match the search moves on by one code point.

### Options, errors and literal text

[`options.mach`](demo/readme/src/bin/options.mach) compiles with options through
a helper, `matches`, that compiles a pattern with `compile_with`, searches one
text and releases both:

```mach
var o: regex.Options;
o.case_insensitive = true;
print.printlnf("case insensitive: {}", matches(?a, text("hello"), o, text("Say HeLLo")));
```

It prints `case insensitive: 1`, as a `bool` prints as 1 or 0.

`Options` starts all false, the defaults `compile` uses:

| field | effect |
| --- | --- |
| `case_insensitive` | letters match in any case, as `(?i)` |
| `multi_line` | `^` and `$` match at line boundaries, as `(?m)` |
| `dot_all` | `.` matches `\n`, as `(?s)` |
| `ungreedy` | repetition prefers fewer, as `(?U)` |
| `longest` | leftmost-longest matching, as POSIX, rather than leftmost-first |
| `literal` | the whole pattern is literal text, with no operators |

A pattern that is not a regular expression is an `Error`, the `Kind` of the
problem and the byte `offset` in the pattern where it begins. `error_text` words
it as RE2 does:

```mach
var bad: res[regex.Regex, regex.Error] = regex.compile(?a, text("a(b"));
if (sel bad.ok) {
    regex.dnit(?bad.ok);
    ret 1;
}
print.printlnf("error at byte {}: {}", bad.err.offset, regex.error_text(bad.err));
```

This prints `error at byte 1: missing closing )`.

`quote` escapes every metacharacter in a text, so the result compiles to a
pattern that matches exactly that text:

```mach
# quote escapes every metacharacter, so the pattern matches the text exactly
var quoted: Vector[u8] = vector.init[u8](?a);
fin { vector.dnit[u8](?quoted); }
if (!regex.quote(text("1.5+2"), ?quoted)) { ret 1; }
var plain: regex.Options;
print.printlnf("quoted: {}", matches(?a, view(quoted.data, quoted.len), plain, text("is 1.5+2 = 3.5")));
print.printlnf("quoted: {}", matches(?a, view(quoted.data, quoted.len), plain, text("is 105 + 2")));
```

The first prints `quoted: 1` and the second `quoted: 0`.

## Matching

By default a search is leftmost-first, as in Perl, RE2 and Go: of the matches
that start leftmost, it takes the one the pattern prefers, the first alternative
and the greedy repetition. So `a|ab` against `ab` matches `a`. With `longest` it
is leftmost-longest, as in POSIX: of the matches that start leftmost, the
longest, so `a|ab` matches `ab`.

Texts are UTF-8. `.`, classes and case folding work on code points, and a match
starts and ends only at code point boundaries. `.` never matches a byte that is
not part of valid UTF-8.

Without `(?m)`, `$` matches only at the end of the text, not before a final
newline as in Perl.

## Syntax

The syntax is RE2's, as its
[syntax page](https://github.com/google/re2/wiki/Syntax) gives it for what RE2
supports.

### Single characters

| syntax | matches |
| --- | --- |
| `.` | any character but `\n`, or any character with `(?s)` |
| `[xyz]` | a character class |
| `[^xyz]` | a negated character class |
| `\d`, `\D` | an ASCII digit, `[0-9]`, and its complement |
| `\s`, `\S` | ASCII space, `[\t\n\f\r ]`, and its complement |
| `\w`, `\W` | an ASCII word character, `[0-9A-Za-z_]`, and its complement |
| `\pN` | a Unicode class named by one letter |
| `\p{Greek}` | a Unicode class |
| `\PN`, `\P{Greek}` | the complement of a Unicode class |
| `\p{^Greek}`, `\P{^Greek}` | the complement, and the complement of the complement |

### Composites

| syntax | matches |
| --- | --- |
| `xy` | `x` followed by `y` |
| <code>x&#124;y</code> | `x` or `y`, preferring `x` |

### Repetition

| syntax | matches |
| --- | --- |
| `x*` | zero or more `x`, preferring more |
| `x+` | one or more `x`, preferring more |
| `x?` | zero or one `x`, preferring one |
| `x{n,m}` | `n` to `m` of `x`, preferring more |
| `x{n,}` | `n` or more of `x`, preferring more |
| `x{n}` | exactly `n` of `x` |
| `x*?`, `x+?`, `x??` | the same, preferring fewer |
| `x{n,m}?`, `x{n,}?`, `x{n}?` | the same, preferring fewer |

`(?U)` swaps which of each pair is preferred. A bound is at most 1000. A `{` that
does not begin a valid bound is a literal `{`, so `a{,3}` matches the text
`a{,3}`. A repetition of a repetition, such as `a**`, is an error.

### Grouping and flags

| syntax | meaning |
| --- | --- |
| `(re)` | a numbered capturing group |
| `(?P<name>re)`, `(?<name>re)` | a named and numbered capturing group |
| `(?:re)` | a group that does not capture |
| `(?flags)` | set flags for the rest of the enclosing group |
| `(?flags:re)` | set flags for `re` only |

A group name is one or more of `[0-9A-Za-z_]`, and no two groups share a name.
Groups nest at most 1000 deep.

Flags are `i`, `m`, `s` and `U`, and a `-` clears the flags after it, as in
`(?i-s)` or `(?-m:re)`:

| flag | meaning |
| --- | --- |
| `i` | case insensitive |
| `m` | multi-line: `^` and `$` match at line boundaries |
| `s` | `.` matches `\n` |
| `U` | ungreedy: `x*` and `x*?` and the rest swap meanings |

### Empty strings

| syntax | matches at |
| --- | --- |
| `^` | the start of the text, or of a line with `(?m)` |
| `$` | the end of the text, or of a line with `(?m)` |
| `\A` | the start of the text |
| `\z` | the end of the text |
| `\b` | an ASCII word boundary, `\w` on one side and `\W` or an end on the other |
| `\B` | anywhere but an ASCII word boundary |

### Escapes

| syntax | matches |
| --- | --- |
| `\a` | bell, `\x07` |
| `\f` | form feed, `\x0C` |
| `\t` | tab, `\x09` |
| `\n` | newline, `\x0A` |
| `\r` | carriage return, `\x0D` |
| `\v` | vertical tab, `\x0B` |
| `\123` | the octal character code, up to three digits |
| `\x7F` | the hex character code, exactly two digits |
| `\x{10FFFF}` | the hex character code, any number of digits |
| `\*` | a literal `*`, and so for any ASCII character but a letter or digit |
| `\Q...\E` | the text `...` literally, even if it holds punctuation |

A single digit from `\1` to `\7` with no octal digit after it would be a
backreference, which RE2 does not have, so it is an error. `\0` and a digit
followed by more octal digits are octal codes. An escape of a letter or digit
not listed here is an error.

### Character classes

A class `[...]` holds any mix of:

| item | matches |
| --- | --- |
| `x` | the character `x` |
| `A-Z` | a range of characters, inclusive |
| `\d`, `\s`, `\w` and their complements | as outside a class |
| `\pN`, `\p{Greek}` and their complements | as outside a class |
| `[:alpha:]` | an ASCII class |
| `[:^alpha:]` | the complement of an ASCII class |

A `]` first in the class, after any `^`, is a literal `]`, and a `-` first or
last is a literal `-`. Escapes inside a class are the same as outside.

The ASCII classes are:

| name | matches |
| --- | --- |
| `[:alnum:]` | `[0-9A-Za-z]` |
| `[:alpha:]` | `[A-Za-z]` |
| `[:ascii:]` | `[\x00-\x7F]` |
| `[:blank:]` | `[\t ]` |
| `[:cntrl:]` | `[\x00-\x1F\x7F]` |
| `[:digit:]` | `[0-9]` |
| `[:graph:]` | `[!-~]` |
| `[:lower:]` | `[a-z]` |
| `[:print:]` | `[ -~]` |
| `[:punct:]` | ``[!-/:-@[-`{-~]`` |
| `[:space:]` | `[\t\n\v\f\r ]` |
| `[:upper:]` | `[A-Z]` |
| `[:word:]` | `[0-9A-Za-z_]` |
| `[:xdigit:]` | `[0-9A-Fa-f]` |

### Unicode classes

`\p` takes the name of a general category, a script, or `Any`, which matches
every code point. Names are case-sensitive.

The general categories are the two-letter ones, `Lu`, `Nd`, `Zs` and the rest
but the unassigned `Cn`, and the one-letter unions of them: `C`, `L`, `M`, `N`, `P`, `S` and `Z`. A
one-letter name may drop its braces, as in `\pL`.

The scripts are those of Unicode's `Scripts.txt` by their long names, such as
`Latin`, `Greek`, `Cyrillic`, `Han` and `Arabic`.

### Case folding

With `i`, a character matches every character in its simple case folding orbit,
so `(?i)k` matches `k`, `K` and the Kelvin sign `\x{212A}`, and `(?i)[a-z]`
matches them all too. Folding is Unicode's simple case folding, the `C` and `S`
entries of `CaseFolding.txt`, as in RE2 and Go.

## What RE2 leaves out

Some syntax other engines accept is not here, because no linear-time engine can
support it. Each is an error when compiled, never a silent change of meaning.

- **Backreferences**, `\1` and `(?P=name)`. Matching with backreferences is
  NP-complete, so no engine can promise linear time with them.
- **Lookaround**, `(?=re)`, `(?!re)`, `(?<=re)` and `(?<!re)`. A search reads
  the text once, forward, and lookaround asks about text on either side of a
  position, which the engine could only answer by reading it again.
- **`\C`**, any single byte. It can match inside a code point, which breaks the
  guarantee that a match starts and ends on code point boundaries.
- **`\Z`**, the end of the text or before a final newline. Its meaning differs
  between engines, so RE2 leaves it out. Use `\z`, or `\n?\z` to take a final
  newline into the match.
- **Atomic groups, possessive repetition, conditionals, recursion, comments**,
  `(?>re)`, `x*+`, `(?(cond)...)`, `(?R)` and `(?#...)`, and escapes such as
  `\G`, `\K`, `\X`, `\R` and `\h`.

## Unicode

The Unicode classes and case folding are generated from the Unicode Character
Database 18.0.0 by [`tools/unicode-tables`](tools/unicode-tables). The version
is `regex.unicode.VERSION` at run time.

## Conformance

mach-regex is held to RE2's own search tests, `re2-search.txt` from Go's
`regexp/testdata`: every pattern against every text, in each of full and
partial match under leftmost-first and leftmost-longest, compared on the bounds
of the match and of every group. All 7232 checks pass. A pattern using `\C`,
which RE2 in UTF-8 mode does not support either, is skipped, as Go's own test
skips it. The suite runs with the rest of the tests, as
`src/test/conformance.mach`.

## API reference

Every public declaration has a docstring. `mach doc .` renders them as Markdown
under `doc/`, one page per module. The API is `regex.api`, which `use regex;`
forwards together with `Error` and `Kind` from `regex.syntax`.

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
