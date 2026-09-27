# regex.compile.compiler

## val MAX_INSTS

```mach
pub val MAX_INSTS: usize = 1048576
```

the most instructions a program may hold

## fun compile

```mach
pub fun compile(a: *A.Allocator, tree: *syntax.Ast) res[Prog, syntax.Error];
```

compile an Ast to a program

a: the allocator the program grows in
tree: the Ast, whose unicode class names are resolved here
ret: the program, or the first error

## fun reverse

```mach
pub fun reverse(a: *A.Allocator, tree: *syntax.Ast) res[Prog, syntax.Error];
```

compile an Ast to a program that reads the text right to left

it accepts a text reversed exactly when the forward program accepts the text,
so run backward from where a match ends, it finds where the match can begin.
it records no captures and has no prefix.

a: the allocator the program grows in
tree: the Ast, whose unicode class names are resolved here
ret: the program, or the first error

