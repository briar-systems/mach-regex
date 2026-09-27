# regex.compile.utf8

## rec Seq

```mach
pub rec Seq;
```

a sequence of byte ranges, one per encoded byte

len: how many bytes, 1 to 4
lo: the first byte at each position
hi: the last byte at each position

## fun encode

```mach
pub fun encode(cp: u32, out: *u8) u32;
```

encode a code point into out, which holds 4 bytes, giving its length

cp: a code point, not a surrogate
out: the first of 4 bytes to write
ret: how many bytes it takes

## fun sequences

```mach
pub fun sequences(lo: u32, hi: u32, out: *Vector[Seq]) bool;
```

append the sequences of a code point range, in order

lo: the first code point
hi: the last code point
out: where the sequences go
ret: false when the allocator refuses

