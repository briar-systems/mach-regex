# Compiling and searching

[`src/bin/search.mach`](src/bin/search.mach) compiles `[a-z]+@[a-z]+\.com`,
makes the cache a search runs in, asks whether it matches anywhere and finds
where.

```sh
mach dep pull demo/search
mach build demo/search
mach run demo/search
```

It prints:

```text
it matches
found at 9..24
```

`compile` gives the `Regex` or the first error in the pattern, and `cache` makes
the scratch every search with that `Regex` runs in, so the searches themselves
allocate nothing. `find` gives the leftmost match at or after an offset as byte
offsets into the text, `9..24` being `ada@example.com`. The page allocator keeps
the demo short, and any `std.allocator.Allocator` serves.
