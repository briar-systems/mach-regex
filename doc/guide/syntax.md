# Syntax

mach-regex accepts RE2's syntax, as RE2's
[syntax page](https://github.com/google/re2/wiki/Syntax) gives it for what RE2
supports, and rejects what RE2 rejects. A pattern that uses anything outside it
is a compile error at the byte where the construct begins, never a silent change
of meaning. How a pattern then matches is in [matching](matching.md).

## Single characters

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

## Composites

| syntax | matches |
| --- | --- |
| `xy` | `x` followed by `y` |
| <code>x&#124;y</code> | `x` or `y`, preferring `x` |

## Repetition

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

## Grouping and flags

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

## Empty strings

| syntax | matches at |
| --- | --- |
| `^` | the start of the text, or of a line with `(?m)` |
| `$` | the end of the text, or of a line with `(?m)` |
| `\A` | the start of the text |
| `\z` | the end of the text |
| `\b` | an ASCII word boundary, `\w` on one side and `\W` or an end on the other |
| `\B` | anywhere but an ASCII word boundary |

## Escapes

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

## Character classes

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

## Unicode classes

`\p` takes the name of a general category, a script, or `Any`, which matches
every code point. Names are case-sensitive. The classes are Unicode 18.0.0's,
generated from the Unicode Character Database, and `regex.unicode.VERSION`
gives the version at run time.

The general categories are the two-letter ones, `Lu`, `Nd`, `Zs` and the rest
but the unassigned `Cn`, and the one-letter unions of them: `C`, `L`, `M`,
`N`, `P`, `S` and `Z`. A one-letter name may drop its braces, as in `\pL`.

The scripts are those of Unicode's `Scripts.txt` by their long names, such as
`Latin`, `Greek`, `Cyrillic`, `Han` and `Arabic`.

## Case folding

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
