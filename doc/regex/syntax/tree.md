# regex.syntax.tree

## val UNBOUNDED

```mach
pub val UNBOUNDED: u32 = 0xFFFFFFFF
```

the most a repetition may take, standing for no upper bound

## rec Flags

```mach
pub rec Flags;
```

the flags in force where a node was parsed

fold: letters match in any case, (?i)
multiline: ^ and $ match at line boundaries, (?m)
dotnl: . matches a newline, (?s)
ungreedy: repetition prefers fewer, (?U)

## rec Range

```mach
pub rec Range;
```

a range of code points, both ends included

lo: the first code point
hi: the last code point

## rec Span

```mach
pub rec Span;
```

a run of entries in one of the Ast's vectors

start: index of the first entry
len: number of entries

## rec Literal

```mach
pub rec Literal;
```

one code point to match

cp: the code point
fold: it matches in any case

## rec Unicode

```mach
pub rec Unicode;
```

a unicode class named by \p or \P, resolved when the pattern is compiled

name: the class name as written, borrowed from the pattern
negated: it matches every code point outside the class
offset: where the escape begins in the pattern, for an unknown name

## rec Set

```mach
pub rec Set;
```

a set of code point ranges within a class

ranges: span of the Ast's ranges
negated: it stands for every code point outside its ranges

## tag Item

```mach
pub tag Item: u8 {
    set:     Set;
    unicode: Unicode;
}
```

one member of a character class

a negated member is folded before it is negated, as RE2 does, so (?i)\W
excludes every case variant of a word character.

set: ranges given literally or by a perl or posix class
unicode: a unicode class

## rec Class

```mach
pub rec Class;
```

a character class

it matches the union of its items, folded when fold is set, then
complemented when negated is set.

items: span of the Ast's items
negated: it matches every code point outside the union
fold: letters match in any case

## rec Capture

```mach
pub rec Capture;
```

a capturing group

index: its number, counting open parentheses from 1
name: its name, empty for an unnamed group
sub: the node it captures

## rec Repeat

```mach
pub rec Repeat;
```

a repetition

sub: the node repeated
min: the fewest repetitions
max: the most repetitions, UNBOUNDED for no limit
greedy: it prefers more repetitions to fewer

## tag Node

```mach
pub tag Node: u8 {
    empty;
    literal: Literal;
    class:   usize;
    any;
    any_but_newline;
    begin_line;
    end_line;
    begin_text;
    end_text;
    word_boundary;
    not_word_boundary;
    capture:   Capture;
    repeat:    Repeat;
    concat:    Span;
    alternate: Span;
}
```

one node of a parsed pattern

empty: matches the empty string
literal: one code point
class: a character class, by index into the Ast's classes
any: any code point, a newline included
any_but_newline: any code point but a newline
begin_line: the start of the text or of a line, ^ under (?m)
end_line: the end of the text or of a line, $ under (?m)
begin_text: the start of the text, ^ or \A
end_text: the end of the text, $ or \z
word_boundary: an ascii word boundary, \b
not_word_boundary: not an ascii word boundary, \B
capture: a capturing group
repeat: a repetition
concat: its children in sequence, a span of the Ast's kids
alternate: any one of its children, preferring earlier ones

## rec Ast

```mach
pub rec Ast;
```

a parsed pattern

nodes: every node, the root among them
kids: the children of concatenations and alternations
classes: every character class
items: the members of every class
ranges: the ranges of every set
names: each group's name by index, empty for unnamed and for index 0
root: the index of the root node

## fun init

```mach
pub fun init(a: *A.Allocator) Ast;
```

an empty Ast drawing on an allocator

a: the allocator its vectors grow in
ret: the Ast, owning nothing until it grows

## fun dnit

```mach
pub fun dnit(ast: *Ast);
```

release everything an Ast holds

ast: the Ast to release

## fun groups

```mach
pub fun groups(ast: *Ast) usize;
```

the number of capturing groups, not counting the whole match

ast: the parsed pattern
ret: how many groups it captures

