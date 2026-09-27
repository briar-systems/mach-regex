# regex.syntax.errors

## tag Kind

```mach
pub tag Kind: u8 {
    missing_bracket;
    missing_paren;
    unexpected_paren;
    trailing_backslash;
    invalid_escape;
    missing_repeat_argument;
    invalid_repeat_op;
    invalid_repeat_size;
    invalid_char_class;
    invalid_char_range;
    invalid_named_capture;
    duplicate_capture_name;
    invalid_perl_op;
    invalid_utf8;
    nesting_depth;
    large;
    memory;
}
```

the kind of a syntax error

missing_bracket: a [ is never closed
missing_paren: a ( is never closed
unexpected_paren: a ) closes no group
trailing_backslash: the pattern ends in a lone backslash
invalid_escape: a backslash escape RE2 does not define
missing_repeat_argument: a repetition operator follows nothing
invalid_repeat_op: a repetition operator follows another
invalid_repeat_size: a bound is over 1000 or the minimum exceeds the maximum
invalid_char_class: a \p escape with no name or an unclosed brace
invalid_char_range: a range whose end precedes its start, or an unknown class name
invalid_named_capture: a group name that is empty or not a word
duplicate_capture_name: two groups share a name
invalid_perl_op: a (? construct RE2 does not define
invalid_utf8: the pattern is not valid utf-8
nesting_depth: groups nest more than 1000 deep
large: the compiled program would be too large
memory: the allocator refused while parsing or compiling

## rec Error

```mach
pub rec Error;
```

a syntax error

kind: what is wrong
offset: the byte offset in the pattern where it begins

## fun text

```mach
pub fun text(k: Kind) str;
```

the message for an error kind

k: the kind
ret: a lowercase description, as RE2 words it

