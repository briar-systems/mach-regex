# regex.compile.ranges

## val MAX_CP

```mach
pub val MAX_CP: u32 = 0x10FFFF
```

the largest code point

## fun append

```mach
pub fun append(v: *Vector[Range], lo: u32, hi: u32) bool;
```

append a range, giving false when the allocator refuses

v: the set
lo: the first code point
hi: the last code point
ret: whether it was appended

## fun canonical

```mach
pub fun canonical(v: *Vector[Range]);
```

sort the set and merge ranges that overlap or touch

v: the set

## fun negate

```mach
pub fun negate(v: *Vector[Range], scratch: *Vector[Range]) bool;
```

replace a canonical set with its complement over every code point

v: the set, canonical
scratch: storage the complement is built in, emptied first
ret: false when the allocator refuses

## fun fold

```mach
pub fun fold(v: *Vector[Range]) bool;
```

add every case variant of a set's code points, as RE2 folds a class

only code points case folding reaches are visited, each one's whole simple
folding orbit appended, then the set is made canonical again.

v: the set
ret: false when the allocator refuses

## fun append_table

```mach
pub fun append_table(v: *Vector[Range], t: unicode.Table) bool;
```

append a unicode table's ranges to a set

v: the set
t: the table
ret: false when the allocator refuses

