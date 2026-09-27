# Options, errors and literal text

[`src/bin/options.mach`](src/bin/options.mach) compiles with
`case_insensitive` set, reports the error in the pattern `a(b`, and uses `quote`
to match the text `1.5+2` literally.

```sh
mach dep pull demo/options
mach build demo/options
mach run demo/options
```

It prints:

```text
case insensitive: 1
error at byte 1: missing closing )
quoted: 1
quoted: 0
```

A `bool` prints as 1 or 0. The error gives the byte offset in the pattern where
the problem begins, and `error_text` words it as RE2 does. `quote` escapes every
metacharacter, so the quoted `1.5+2` matches the text `1.5+2` in
`is 1.5+2 = 3.5` and nothing in `is 105 + 2`.
