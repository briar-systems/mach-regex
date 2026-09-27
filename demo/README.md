# Demos

Each demo is a project of its own that depends on this checkout of mach-regex by
path. From the repository root, pull the library's dependencies once, then pull,
build and run a demo:

```sh
mach dep pull .
mach dep pull demo/search
mach build demo/search
mach run demo/search
```

| demo | shows |
| --- | --- |
| [search](search) | compiling a pattern, making its cache, `is_match` and `find` |
| [captures](captures) | reading capture groups by number and by name |
| [iterate](iterate) | walking every match with `iter` and `next` |
| [options](options) | compile options, a compile error, and `quote` |

The [usage guide](../doc/guide/usage.md) explains the API the demos use.
