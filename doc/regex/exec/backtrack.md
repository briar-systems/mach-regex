# regex.exec.backtrack

## val NONE

```mach
pub val NONE: usize = 0xFFFFFFFFFFFFFFFF
```

a capture slot no path has set

## val CAPACITY

```mach
pub val CAPACITY: usize = 256 * 1024
```

the most states, instructions times positions, a search may cover, as in
RE2's bitstate

## val STACK

```mach
pub val STACK: usize = 16 * 1024
```

the most frames a cache's stack holds, 128 KiB of them

the stack cannot grow during a search, so a search may cover only as many
positions as the worst case of the program's pushing instructions fits.

## rec Cache

```mach
pub rec Cache;
```

the scratch of a search, sized for one program

visited: one bit per state, instruction major
stack: the pending frames
slots: the slots of the path being followed
best: the slots of the longest match so far
size: the program's instruction count it was sized for
positions: the most positions a search may cover, the span plus one

## fun fits

```mach
pub fun fits(c: *Cache, span: usize) bool;
```

whether a search over a span fits the bitset and the stack

c: a cache made for the program
span: the bytes from the search's start to the end of the text
ret: whether the backtracker can search it

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

## fun search

```mach
pub fun search(p: *Prog, c: *Cache, text: View, start: usize, anchored: bool, longest: bool, active: usize, out: *usize) bool;
```

search a text for the program's match, as the pike vm does

the arguments and the result are the pike vm's, and so is the match. the
search must fit: fits(c, text.len - start).

p: the program
c: scratch sized for the program
text: the text
start: where the search begins, a code point boundary
anchored: a match must begin at start
longest: leftmost-longest rather than leftmost-first
active: how many slots to record, at least 2 and at most the program's
out: where the slots of the match go, active of them
ret: whether there is a match

