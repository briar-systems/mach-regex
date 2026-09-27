# regex.exec.pikevm

## val NONE

```mach
pub val NONE: usize = 0xFFFFFFFFFFFFFFFF
```

a capture slot no thread has set

## rec Cache

```mach
pub rec Cache;
```

the scratch of a search, sized for one program

cur: the threads at this position
nxt: the threads at the next position
stack: the closure's pending frames
depth: how many frames are pending
thread: the slots of the thread being followed
best: the slots of the best match so far
width: the slots per thread
size: the program's instruction count it was sized for
steps: how many positions the last search stepped threads through

## fun init

```mach
pub fun init(a: *A.Allocator, p: *Prog, c: *Cache) bool;
```

make the scratch for searching a program

a: the allocator the scratch lives in
p: the program
c: the cache to fill
ret: false when the allocator refuses, leaving nothing held

## fun dnit

```mach
pub fun dnit(c: *Cache);
```

release a cache's scratch

c: the cache

## fun holds

```mach
pub fun holds(a: Assert, text: View, at: usize) bool;
```

whether an assertion holds at a position of the text

a: the assertion
text: the text
at: the position
ret: whether it holds there

## fun boundary

```mach
pub fun boundary(text: View, at: usize) bool;
```

whether a position does not split a utf-8 sequence

text: the text
at: the position
ret: whether a code point may begin there

## fun search

```mach
pub fun search(p: *Prog, c: *Cache, text: View, start: usize, anchored: bool, longest: bool, active: usize, out: *usize) bool;
```

search a text for the program's match

the best match's slots are left in out, the first active of them, with
NONE for a group that took no part.

p: the program
c: scratch sized for the program
text: the text
start: where the search begins, a code point boundary
anchored: a match must begin at start
longest: leftmost-longest rather than leftmost-first
active: how many slots to record, at least 2 and at most the program's
out: where the slots of the match go, active of them
ret: whether there is a match

## fun search_within

```mach
pub fun search_within(p: *Prog, c: *Cache, text: View, start: usize, limit: usize, anchored: bool, longest: bool, active: usize, out: *usize) bool;
```

search a text for the program's match, reading no byte at or past limit

assertions still see the whole text, so a match known to end by limit is
found with the same groups, as when the lazy dfas have found its bounds.

p: the program
c: scratch sized for the program
text: the text
start: where the search begins, a code point boundary
limit: where reading stops, at most the text's length
anchored: a match must begin at start
longest: leftmost-longest rather than leftmost-first
active: how many slots to record, at least 2 and at most the program's
out: where the slots of the match go, active of them
ret: whether there is a match

