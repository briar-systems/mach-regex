# regex.exec.onepass

## val NONE

```mach
pub val NONE: usize = 0xFFFFFFFFFFFFFFFF
```

a capture slot no thread has set

## val MAX_SLOTS

```mach
pub val MAX_SLOTS: u32 = 64
```

the most capture slots a one-pass program has, one bit each in an Entry

## val MAX_BYTES

```mach
pub val MAX_BYTES: usize = 1 << 20
```

the most bytes a table takes before the program is left to the pike vm

## rec Entry

```mach
pub rec Entry;
```

what a state does on one byte class, or on reaching the match

next: the state after the byte, DEAD for none, or in the match column MATCH
looks: the assertions that must hold before the byte, one bit each
after: the match is preferred to this byte, so leftmost-first stops at it
saves: the capture slots recorded before the byte, one bit each

## rec OnePass

```mach
pub rec OnePass;
```

a program's one-pass table

table: the rows, stride entries each, state 0 first
stride: the program's class count and one more for the match
ready: the program is one-pass and the table is built

## rec Cache

```mach
pub rec Cache;
```

the scratch of a search, sized for one program

thread: the slots of the one thread
best: the slots of the best match so far

## fun init

```mach
pub fun init(a: *A.Allocator) OnePass;
```

an empty table drawing on an allocator

a: the allocator its table grows in
ret: the table, not ready and owning nothing

## fun dnit

```mach
pub fun dnit(op: *OnePass);
```

release a table

op: the table

## fun build

```mach
pub fun build(a: *A.Allocator, p: *Prog, op: *OnePass) res[bool, A.Error];
```

decide whether a program is one-pass and, when it is, build its table

a program with more than MAX_SLOTS slots, or whose table would take more
than MAX_BYTES, is left to the pike vm like one that is not one-pass.

a: the allocator the analysis borrows scratch from
p: the program
op: a table made by init for the program, ready when this gives true
ret: whether the table is built, or the memory error

## fun cache

```mach
pub fun cache(a: *A.Allocator, p: *Prog, c: *Cache) bool;
```

make the scratch for searching a program

a: the allocator the scratch lives in
p: the program
c: the cache to fill
ret: false when the allocator refuses, leaving nothing held

## fun cache_dnit

```mach
pub fun cache_dnit(c: *Cache);
```

release a cache's scratch

c: the cache

## fun search

```mach
pub fun search(p: *Prog, op: *OnePass, c: *Cache, text: View, start: usize, longest: bool, active: usize, out: *usize) bool;
```

search a text for a match beginning exactly at start

gives what pikevm.search gives anchored at start with the same arguments:
the match's slots in out, the first active of them, with NONE for a group
that took no part.

p: the program
op: its table, ready
c: scratch sized for the program
text: the text
start: where the match must begin
longest: leftmost-longest rather than leftmost-first
active: how many slots to record, at least 2 and at most the program's
out: where the slots of the match go, active of them
ret: whether there is a match

