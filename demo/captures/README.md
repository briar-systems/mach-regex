# Captures and named groups

[`src/bin/captures.mach`](src/bin/captures.mach) matches
`(?P<year>\d{4})-(?P<month>\d{2})-(\d{2})` against `released on 2026-09-26` and
reads every group by number, then finds one by name.

```sh
mach dep pull demo/captures
mach build demo/captures
mach run demo/captures
```

It prints:

```text
group 1 year at 12..16: 2026
group 2 month at 17..19: 09
group 3 at 20..22: 26
month is group 2
```

`captures` fills `slot_count(re)` offsets in memory the caller owns, here 8: a
start and an end for each of the three groups and for the whole match.
`group_name` gives a group's name, empty for the unnamed third group, and
`group_index` finds a group by its name.
