# regex.unicode.classes

## val COUNT

```mach
pub val COUNT: u32 = 214
```

number of classes

## val NAMES

```mach
pub val NAMES: [214]str = [214]str;
```

class names, sorted by byte

## val STARTS

```mach
pub val STARTS: [214]u32 = [214]u32;
```

first range of each class in RANGES, in the order of NAMES

## val COUNTS

```mach
pub val COUNTS: [214]u32 = [214]u32;
```

number of ranges of each class, in the order of NAMES

## val RANGES

```mach
pub val RANGES: [12242]u32 = [12242]u32;
```

every class's ranges as lo, hi pairs, both inclusive, sorted and disjoint

