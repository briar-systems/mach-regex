# regex.unicode.lookup

## rec Range

```mach
pub rec Range;
```

an inclusive range of code points

lo: first code point
hi: last code point, at least lo

## rec Table

```mach
pub rec Table;
```

a borrowed view of a static range table, sorted and non-overlapping

ranges: the first range
len: number of ranges

## fun class

```mach
pub fun class(name: View) opt[Table];
```

the table of a class name as RE2 accepts it: a general category, a script or Any

name: the class name, case-sensitive
ret: the class's table, or none for an unknown name

## fun simple_fold

```mach
pub fun simple_fold(cp: u32) u32;
```

the next code point in cp's simple case folding orbit, as go's unicode.SimpleFold

cp: a code point
ret: the smallest code point in the orbit greater than cp, else the smallest in the
     orbit, or cp itself when it has no fold

