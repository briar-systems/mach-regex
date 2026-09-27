# regex.compile.program

## tag Assert

```mach
pub tag Assert: u8 {
    begin_line;
    end_line;
    begin_text;
    end_text;
    word_boundary;
    not_word_boundary;
}
```

an empty-width assertion

begin_line: at the start of the text or just after a newline
end_line: at the end of the text or just before a newline
begin_text: at the start of the text
end_text: at the end of the text
word_boundary: between an ascii word byte and a byte that is not one
not_word_boundary: not at an ascii word boundary

## rec Trans

```mach
pub rec Trans;
```

a byte range and where a byte in it leads

lo: the first byte
hi: the last byte
next: the instruction after a byte in the range

## rec Split

```mach
pub rec Split;
```

two ways on, the first preferred

x: the preferred successor
y: the alternative

## rec Save

```mach
pub rec Save;
```

record the position in a capture slot

slot: the slot, 2n for group n's start and 2n+1 for its end
next: the instruction after

## rec Look

```mach
pub rec Look;
```

test an empty-width assertion

assert: the assertion
next: the instruction after, when it holds

## rec Sparse

```mach
pub rec Sparse;
```

a run of the program's transitions, sorted and disjoint

start: index of the first transition
len: number of transitions

## tag Inst

```mach
pub tag Inst: u8 {
    fail;
    match;
    range:  Trans;
    sparse: Sparse;
    split:  Split;
    save:   Save;
    look:   Look;
}
```

one instruction

a zeroed instruction is fail, so an unfilled slot never matches.

fail: never matches
match: a match ends here
range: one byte in a range, then its next
sparse: one byte in any of several ranges, each with its own next
split: either successor, the first preferred
save: record the position in a capture slot
look: an empty-width assertion

## val MAX_PREFIX

```mach
pub val MAX_PREFIX: u32 = 16
```

the most bytes of a required prefix a program keeps

## val MAX_FIRSTS

```mach
pub val MAX_FIRSTS: u32 = 16
```

the most first bytes a program keeps

## val RANK

```mach
pub val RANK: [256]u8 = [256]u8;
```

how common each byte is in typical text, higher for more common, from the
memchr crate's default ranking, which is in the public domain

## rec Prog

```mach
pub rec Prog;
```

a compiled program

insts: the instructions
trans: the transitions of every sparse instruction
start: the first instruction
slots: the number of capture slots, two per group and two for the whole match
prefix: bytes every match begins with, the first prefix_len of them
prefix_len: how many bytes of prefix are required, 0 for none
firsts: the bytes every match begins with one of, the first first_count of them
first_count: how many, 1 to 16, or 0 when there are more or a match can begin without a byte
classes: each byte's class. the program never tells two bytes of a class apart
class_count: how many classes there are

## fun init

```mach
pub fun init(a: *A.Allocator) Prog;
```

an empty program drawing on an allocator

a: the allocator its vectors grow in
ret: the program, owning nothing until it grows

## fun dnit

```mach
pub fun dnit(p: *Prog);
```

release everything a program holds

p: the program to release

## fun size

```mach
pub fun size(p: *Prog) usize;
```

the number of instructions

p: the program
ret: how many instructions it holds

## fun step

```mach
pub fun step(p: *Prog, i: Inst, b: u8, next: *u32) bool;
```

where a byte leads from an instruction that reads one

p: the program
i: one of its instructions
b: the byte
next: where the instruction after goes, when the byte is taken
ret: whether the instruction reads the byte, false for any that reads none

