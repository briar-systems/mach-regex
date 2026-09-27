# regex.syntax.parse

## fun parse

```mach
pub fun parse(a: *A.Allocator, pattern: View, flags: Flags, literal: bool) res[Ast, Error];
```

parse a pattern

names and unicode class names in the Ast borrow the pattern's bytes.

a: the allocator the Ast grows in
pattern: the pattern's utf-8
flags: the flags in force at the start
literal: the whole pattern is literal text, with no operators
ret: the Ast, or the first error

