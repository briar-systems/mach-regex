# regex.exec.dfa

## val NONE

```mach
pub val NONE: usize = 0xFFFFFFFFFFFFFFFF
```

no position

## val BUDGET

```mach
pub val BUDGET: usize = 2097152
```

the most memory one dfa's arena takes

## tag Kind

```mach
pub tag Kind: u8 {
    first;
    longest;
    all;
}
```

how threads are ranked

first: leftmost-first, a match cuts every thread after it
longest: leftmost-longest, a match cuts the threads that started after it
all: every match counts and nothing is cut

## tag Outcome

```mach
pub tag Outcome: u8 {
    none;
    found: usize;
    gave_up;
}
```

what a search found

none: no match
found: the position a match ends at reading forward, or begins at reading backward
gave_up: the arena filled too often, and the search must be made another way

## rec Dfa

```mach
pub rec Dfa;
```

a lazy dfa for one program, and the scratch it searches in

kind: how threads are ranked
backward: the program reads the text right to left
stride: transitions per state, one per byte class and one for the edge of the text
need: the context flags the program's assertions read
cap: the most states the arena holds
count: states in use
trans: each state's row of transitions, tagged, UNKNOWN where not yet computed
lists: where each state's list begins in the pool
lens: each state's list length
flags: each state's flags
hashes: each state's hash
pool: the states' lists
used: pool entries in use
table: states by hash, open addressed, a state's index plus one or 0 for none
starts: the start state for each context, tagged, UNKNOWN until made
q: the closure being taken, every instruction reached in order, with marks
qlen: entries in q
at_q: where each instruction sits in q, meaningful only for members
stack: the closure's pending instructions
out: the list of the state a transition leads to
olen: entries in out
at_out: where each instruction sits in out, meaningful only for members
held: the list of the current state, kept across a clearing
cleared: whether the arena has been cleared in this search
since: where the search was when it last cleared the arena

## fun init

```mach
pub fun init(a: *A.Allocator, p: *Prog, kind: Kind, backward: bool, d: *Dfa) bool;
```

make a lazy dfa for a program

a: the allocator the arena and scratch live in
p: the program
kind: how threads are ranked
backward: the program reads the text right to left
d: the dfa to fill
ret: false when the allocator refuses, leaving nothing held

## fun dnit

```mach
pub fun dnit(d: *Dfa);
```

release a dfa's arena and scratch

d: the dfa

## fun forward

```mach
pub fun forward(d: *Dfa, p: *Prog, text: View, from: usize, earliest: bool) Outcome;
```

search forward for where the leftmost match ends

d: a forward dfa for the program
p: the program
text: the text
from: where matches may begin, a code point boundary
earliest: stop at the first match found, for a search that asks only whether one exists
ret: the end of the leftmost match, none, or gave_up

## fun backward

```mach
pub fun backward(d: *Dfa, p: *Prog, text: View, from: usize, end: usize) Outcome;
```

search backward from where a match ends for the earliest position it can begin

d: a backward dfa for the reverse program
p: the reverse program
text: the text
from: the earliest position a match may begin
end: where the match ends
ret: the earliest start, none, or gave_up

