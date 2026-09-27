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

the most states, instructions times positions, a search may cover

RE2's bitstate uses the same bound. the stack cannot grow during a search,
so it is sized for the worst case, and a larger bitset would cost eight
bytes of stack for every bit.

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

## fun fits

```mach
pub fun fits(p: *Prog, span: usize) bool;
```

whether a search over a span fits the capacity

p: the program
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
search must fit: fits(p, text.len - start).

p: the program
c: scratch sized for the program
text: the text
start: where the search begins, a code point boundary
anchored: a match must begin at start
longest: leftmost-longest rather than leftmost-first
active: how many slots to record, at least 2 and at most the program's
out: where the slots of the match go, active of them
ret: whether there is a match

