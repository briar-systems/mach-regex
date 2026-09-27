# regex.exec.prefix

## fun skips

```mach
pub fun skips(p: *Prog) bool;
```

whether a search can skip ahead while no thread is alive

p: the program
ret: whether it has a required prefix or a small set of first bytes

## fun candidate

```mach
pub fun candidate(p: *Prog, text: View, from: usize, at: *usize) bool;
```

find the next position at or after from where a match could begin

p: a program that skips
text: the text
from: where to look from
at: where a match could begin, when there is such a place
ret: whether there is one

