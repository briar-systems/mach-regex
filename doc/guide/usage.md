# Using mach-regex

Everything is reached through `use regex;`. The [demos](../../demo) are complete
programs for each part of this guide, and the [API reference](../README.md) has
every declaration.

## Compiling

`compile` turns a pattern into a `Regex`, or gives the first `Error` in it.
`compile_with` takes `Options` as well, and `dnit` releases a `Regex`.

```mach
var re: res[regex.Regex, regex.Error] = regex.compile(?a, text("[a-z]+@[a-z]+\\.com"));
if (sel re.err) { ret 1; }
fin { regex.dnit(?re.ok); }
```

An `Error` is the `Kind` of the problem and the byte `offset` in the pattern
where it begins, and `error_text` words it as RE2 does: `a(b` gives offset 1,
`missing closing )`.

`Options` starts all false, which is what `compile` uses:

| field | effect |
| --- | --- |
| `case_insensitive` | letters match in any case, as `(?i)` |
| `multi_line` | `^` and `$` match at line boundaries, as `(?m)` |
| `dot_all` | `.` matches `\n`, as `(?s)` |
| `ungreedy` | repetition prefers fewer, as `(?U)` |
| `longest` | leftmost-longest matching rather than leftmost-first |
| `literal` | the whole pattern is literal text, with no operators |

`quote` escapes every metacharacter in a text, appending to a `Vector[u8]`, so
the result compiles to a pattern that matches exactly that text.

## The cache

A search needs scratch space sized for the compiled pattern. `cache` makes it
once, and every search with that `Regex` then runs in it and allocates nothing.
A cache serves only the `Regex` it was made for, and one search at a time.
`cache_dnit` releases it.

```mach
var c: res[regex.Cache, regex.Error] = regex.cache(?a, ?re.ok);
if (sel c.err) { ret 1; }
fin { regex.cache_dnit(?c.ok); }
```

## Searching

Texts are `View`s of UTF-8 bytes, and positions are byte offsets into them.

- `is_match` says whether the pattern matches anywhere in a text.
- `find` gives the leftmost match at or after an offset as a `Match`, its
  `start` and the `end` just past it, or none.

[search](../../demo/search) shows both.

## Captures

`captures` fills `slot_count(re)` offsets in memory the caller provides: slots
`2n` and `2n+1` are group `n`'s start and end, group 0 being the whole match. A
group that took no part in the match has `NONE` in both slots, as the optional
group of `(a)(b)?` does against `a`.

Groups are numbered from 1 in the order their `(` appears. `group_count` is how
many there are, `group_name` gives a group's name, empty for an unnamed group,
and `group_index` finds a group by its name. [captures](../../demo/captures)
reads a date's groups both ways.

## Every match

`iter` starts a walk from the start of a text, and `next` gives each match in
turn until there are none. [iterate](../../demo/iterate) walks every number in a
sentence. The rules for empty matches are in [matching](matching.md).
