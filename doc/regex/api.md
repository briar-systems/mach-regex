# regex.api

## val NONE

```mach
pub val NONE: usize = 0xFFFFFFFFFFFFFFFF
```

a capture slot for a group that took no part in the match

## rec Options

```mach
pub rec Options;
```

how a pattern is compiled

case_insensitive: letters match in any case, as (?i)
multi_line: ^ and $ match at line boundaries, as (?m)
dot_all: . matches a newline, as (?s)
ungreedy: repetition prefers fewer, as (?U)
longest: leftmost-longest matching rather than leftmost-first
literal: the pattern is literal text with no operators

## rec Match

```mach
pub rec Match;
```

a match's bounds

start: the offset of its first byte
end: the offset just past its last byte

## rec Regex

```mach
pub rec Regex;
```

a compiled pattern

a: the allocator it lives in
prog: its program
rev: its program read backward, for finding where a match begins
names: the bytes of every group name, one after another
offsets: where each group's name starts in names, one more than the groups
longest: it matches leftmost-longest

## rec Cache

```mach
pub rec Cache;
```

the scratch of searching with one Regex

vm: the pike vm's scratch
fwd: the lazy dfa that finds where a match ends
bwd: the lazy dfa that finds where it begins

## rec Iter

```mach
pub rec Iter;
```

where a search for successive matches has reached

from: where the next search begins
last: where the previous match ended, NONE before the first

## fun compile

```mach
pub fun compile(a: *A.Allocator, pattern: View) res[Regex, Error];
```

compile a pattern with the default options

a: the allocator the Regex lives in
pattern: the pattern's utf-8
ret: the Regex, or the first error in the pattern

## fun compile_with

```mach
pub fun compile_with(a: *A.Allocator, pattern: View, o: Options) res[Regex, Error];
```

compile a pattern with options

a: the allocator the Regex lives in
pattern: the pattern's utf-8
o: how to compile it
ret: the Regex, or the first error in the pattern

## fun dnit

```mach
pub fun dnit(re: *Regex);
```

release a Regex

re: the Regex

## fun error_text

```mach
pub fun error_text(e: Error) str;
```

the message for a compile error

e: the error
ret: a lowercase description, as RE2 words it

## fun cache

```mach
pub fun cache(a: *A.Allocator, re: *Regex) res[Cache, Error];
```

make the scratch for searching with a Regex

a: the allocator the scratch lives in
re: the Regex it serves
ret: the Cache, or the memory error

## fun cache_dnit

```mach
pub fun cache_dnit(c: *Cache);
```

release a Cache

c: the Cache

## fun group_count

```mach
pub fun group_count(re: *Regex) usize;
```

the number of capturing groups, not counting the whole match

re: the Regex
ret: how many groups it captures

## fun slot_count

```mach
pub fun slot_count(re: *Regex) usize;
```

the capture slots a captures call fills, two per group and two for the match

re: the Regex
ret: the number of slots

## fun group_name

```mach
pub fun group_name(re: *Regex, index: usize) View;
```

a group's name

re: the Regex
index: the group, from 1
ret: its name, empty for an unnamed group or an index out of range

## fun group_index

```mach
pub fun group_index(re: *Regex, name: View) opt[usize];
```

the index of a named group

re: the Regex
name: the name
ret: the group's index, or none when no group has that name

## fun is_match

```mach
pub fun is_match(re: *Regex, c: *Cache, text: View) bool;
```

whether the Regex matches anywhere in a text

re: the Regex
c: a Cache made for it
text: the text
ret: whether there is a match

## fun find

```mach
pub fun find(re: *Regex, c: *Cache, text: View, from: usize) opt[Match];
```

the leftmost match at or after an offset

re: the Regex
c: a Cache made for it
text: the text
from: where to begin, moved forward to a code point boundary
ret: the match, or none

## fun captures

```mach
pub fun captures(re: *Regex, c: *Cache, text: View, from: usize, slots: *usize) bool;
```

the leftmost match at or after an offset, with every group's bounds

slots holds slot_count(re) offsets: slot 2n is group n's start and 2n+1 its
end, group 0 being the whole match, and NONE for a group that took no part.

re: the Regex
c: a Cache made for it
text: the text
from: where to begin, moved forward to a code point boundary
slots: where the offsets go, slot_count(re) of them
ret: whether there is a match

## fun iter

```mach
pub fun iter() Iter;
```

a search for successive matches from the start of a text

ret: the Iter

## fun next

```mach
pub fun next(re: *Regex, c: *Cache, text: View, it: *Iter) opt[Match];
```

the next match of a successive search, as Go's FindAll gives them

an empty match directly after the previous match is skipped, and after an
empty match the search moves on by one code point.

re: the Regex
c: a Cache made for it
text: the text
it: where the search has reached
ret: the match, or none when there are no more

## fun quote

```mach
pub fun quote(text: View, out: *Vector[u8]) bool;
```

append a text with every metacharacter escaped, so it compiles to a pattern
that matches exactly that text

text: the text
out: where the escaped text is appended
ret: false when the allocator refuses

