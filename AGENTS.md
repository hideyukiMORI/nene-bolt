# NeNe Bolt — Agent Guide

Short English entry point. The authoritative handbook is [CLAUDE.md](CLAUDE.md) (Japanese);
the normative documents live in [docs/](docs/).

## Project identity

- Product: NeNe Bolt — a Swift terminal screensaver where a hand-written AI runner plays a side-scrolling action platformer forever (four stages, a boss at the end); any game key hands control to a human
- Language / UI: Swift 6 / terminal (ANSI escapes, no ncurses)
- Package: `NeNeBolt` (SwiftPM, Swift 6.4.1 pinned in `.swift-version`, zero external dependencies)
- Governing principle: **one meaning, one canonical implementation path, enforced by machines**

## Required reading before changing production code

1. `docs/ARCHITECTURE_CONSTITUTION.md`
2. `docs/PROJECT_LAYOUT.md`
3. `docs/CODING_RULES.md`
4. `docs/QUALITY_GATES.md`
5. `docs/DEVELOPMENT_WORKFLOW.md`
6. `docs/COMMIT_CONVENTIONS.md`
7. `docs/GLOSSARY.md`
8. `docs/REQUIREMENTS.md` (the owner's decisions)

Then the active issue, the relevant accepted ADRs, and any active waivers.

## Agent rules

- Do not invent a second implementation path because it is locally convenient.
- Do not weaken a gate to make a change pass. Fix the code instead.
- Do not mark a rule `active` in `docs/QUALITY_GATES.md` before its enforcement exists.
- Do not read the current time, randomness, locale, or environment outside the `nene-bolt` executable target (the composition root).
- Do not write a catch-all in a `switch`: `default:`, `@unknown default`, `case _:`, `case let x:`, `case (let x):`, `case .a, _:` or `case (_, _):`. They disable exhaustiveness checking.
- Do not write `init` in an `extension`; it can bypass a `private init` from another file of the same target.
- Do not use `async`, `await`, `Task`, `actor`, threads, Dispatch, or `@preconcurrency`.
- Do not add a SwiftPM target without `.treatAllWarnings(as: .error)` and `ExistentialAny`; the manifest beats command-line flags.
- Do not add external packages, and never a game engine or physics library (owner's decision).
- Core and Engine never know the clock: the game is a pure step function, state plus input to the next state, one tick at a time. Only the composition root reads the clock and runs the ticks.
- Keep positions and velocities as integers (fixed point). `Double.squareRoot()` and friends call libm and do not link without importing it (ADR 0001, X-i and X-j).
- Keep one path each for collisions, stage clear and game over in Core. The runner AI reads Core's state and returns only an input; it never mutates Core's state.
- The AI and the human produce the same input type through the same path; never add a second way to drive the runner.
- Never write a trademarked game, character, stage or company name anywhere: product, README, code, comments or runner lines (CNF-023). Say "side-scrolling platformer". Draw new sprites; never copy an existing game's art or music.
- Do not add sound, drop a decided requirement, or change the play keys substantially without asking the owner first.
- Do not override the owner's decisions in `docs/REQUIREMENTS.md` or add features they did not ask for; ask first.
- Do not add suppressions, lint baselines, or tool exclusions without an active waiver (or at all, where the language forbids them).
- Do not claim a command passed unless it was actually executed.
- Prefer the smallest change that fully follows the canonical path.

## The only definition of done

```bash
make bootstrap   # once after clone
make check
```

Local and CI run exactly this. Use narrow checks while iterating; run the full gate before
moving the PR from Draft to Ready.

## Required completion report

Issue and rule IDs, files and behavior changed, verification commands and results,
documentation or schema changes, active waiver IDs (or `none`), remaining risks.

Investigation-only requests do not authorize editing, committing, pushing, or opening PRs.
