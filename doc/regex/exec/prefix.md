# regex.exec.prefix

## fun candidate

```mach
pub fun candidate(p: *Prog, text: View, from: usize, at: *usize) bool;
```

find the first position at or after from where the program's prefix begins

p: a program with a required prefix
text: the text
from: where to look from
at: where the prefix begins, when it is found
ret: whether the prefix occurs at or after from

