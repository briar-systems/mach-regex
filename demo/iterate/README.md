# Every match

[`src/bin/iterate.mach`](src/bin/iterate.mach) walks every match of `\d+` in
`3 apples, 12 pears and 40 plums`.

```sh
mach dep pull demo/iterate
mach build demo/iterate
mach run demo/iterate
```

It prints:

```text
0..1
10..12
23..25
```

`iter` starts a walk from the start of the text and `next` gives each match in
turn until there are none, the way Go's `FindAll` does: matches never overlap,
and an empty match right after the previous one is skipped.
