# Matching

How a compiled pattern matches a text: which match a search picks, where
positions fall, and what a search costs.

## Which match

A search finds the leftmost match: the one that starts earliest in the text.
When several matches start there, the matching mode picks between them.

- **Leftmost-first**, the default, as in Perl, RE2 and Go: the match the pattern
  prefers, taking the first alternative that works and repeating greedily
  unless told otherwise. `a|ab` against `ab` matches `a`.
- **Leftmost-longest**, with `longest` set in `Options`, as in POSIX: the longest
  of them. `a|ab` against `ab` matches `ab`.

Captures follow the mode. Under leftmost-longest the spans of the groups are
those RE2 reports for the same match.

## Positions and UTF-8

Patterns and texts are UTF-8, and every position is a byte offset into the text.
`.`, classes and case folding work on code points, and a match starts and ends
only at code point boundaries, so a span never splits a character.

- `.` and every class match only valid UTF-8. A byte that is not part of a valid
  sequence is never matched as a character, though a search passes over it.
- A search from an offset inside a code point starts at the next boundary.
- `^` and `\A` mean the start of the whole text, not of the search, and `$` and
  `\z` its end. Without `(?m)`, `$` matches only at the very end, not before a
  final newline as in Perl.
- `\b` and `\B` are ASCII: a word boundary lies between an ASCII word byte,
  `[0-9A-Za-z_]`, and anything else or an end of the text.

## Empty matches and iteration

A pattern such as `a*` can match the empty string. `find` reports an empty match
like any other, with `start` equal to `end`. Walking every match with `iter`
and `next` follows Go's `FindAll`: matches never overlap, an empty match directly
after the previous match is skipped, and after an empty match the walk moves on
by one code point. So `a*` against `baaa` gives the empty match at 0, then `1..4`,
and nothing more.

## Cost

Every search takes time proportional to the size of the compiled pattern times
the length of the text searched, whatever the pattern and whatever the text.
The engine runs every way the pattern could match in step, keeping at most one
thread per instruction, and never backtracks, so no pattern can make a search
run away: `(a*)*b` against a long run of `a` fails in one pass. This is what
rules out the syntax RE2 leaves out, as the [syntax](syntax.md) guide explains.

A pattern whose every match begins with the same literal bytes, as `hello` in
`hello\s+world`, is searched faster: while no match is in progress, the search
skips to the next place those bytes occur, scanning sixteen bytes at a time.

Compiling allocates through the allocator it is given. A search runs entirely
in its `Cache` and allocates nothing.

## Conformance

These semantics are RE2's, and the library is held to them by RE2's own search
tests, `re2-search.txt` from Go's `regexp/testdata`: every pattern against every
text in full and partial match under both modes, comparing the bounds of the
match and of every group. All 7232 checks pass. The few patterns using `\C` are
skipped, as Go's own test skips them.
