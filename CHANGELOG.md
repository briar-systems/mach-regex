# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-09-26

The first release: regular expressions with RE2's syntax and semantics, matched in time linear in the pattern and the text, in pure Mach on std alone.

### Added
- The full RE2 syntax (#2): literals and UTF-8 text, `.`, bracket classes with ranges, negation, POSIX classes and Perl and Unicode members, Perl classes `\d \s \w` and their negations, Unicode classes `\pL`, `\p{Greek}`, `\PL` and `\p{^Greek}`, escapes including octal, `\x{10FFFF}` and `\Q...\E`, the anchors `^ $ \A \z` and ASCII word boundaries `\b \B`, the flags `i m s U` in groups and as `(?flags:...)`, capturing, named and non-capturing groups, greedy and lazy repetition with bounds up to 1000, and alternation. Every error is located at its byte offset.
- Unicode 18.0.0 general categories, scripts and simple case folding, generated from the UCD by `tools/unicode-tables` and checked in CI against a fresh run (#3, #12).
- A compiler to a byte program whose classes are UTF-8 automata with sparse transitions and shared tails, so every code point takes 11 instructions and `\pL` 313 (#4).
- A Pike VM search with captures, leftmost-first by default and leftmost-longest as an option, starting only at code point boundaries, with all scratch in a caller-owned `Cache` so a search makes no allocation (#5).
- The public API through `use regex;`: `compile`, `compile_with` and `Options`, `cache`, `is_match`, `find`, `captures`, `iter` and `next` with Go's FindAll iteration, `group_count`, `group_name`, `group_index`, `error_text` and `quote` (#5).
- RE2's `re2-search.txt` as the conformance suite: all 7232 checks pass in full and partial match under leftmost-first and leftmost-longest (#6).
- A search for a pattern with a required literal prefix scans for it sixteen bytes at a time (#7).
- The README with the syntax reference, the API and examples that compile (#8).
