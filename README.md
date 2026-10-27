# NeNe Bolt

> *An AI runner plays a side-scrolling action platformer in your terminal. Forever. Press an arrow key and it's your turn.*

A terminal screensaver in which a hand-written AI runner runs, jumps, shoots, charges up, stomps and climbs through four stages:
a grassland, a crystal cavern of vanishing blocks, sky bridges of moving platforms, and a fortress with a boss at the end.
Title, play, game over (or the ending), and around again. **Press any game key and you are playing**; leave it for 30 seconds and the AI takes over.
Four runners take turns, and each one grumbles, jokes and gloats in its own voice the whole time.

[![release](https://img.shields.io/github/v/release/hideyukiMORI/nene-bolt)](https://github.com/hideyukiMORI/nene-bolt/releases/latest)
![platform](https://img.shields.io/badge/platform-Linux%20x86__64%20%2F%20WSL2-555)
![license](https://img.shields.io/badge/license-MIT-555)

**English** · [日本語](README.ja.md)

It is a sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit) (chess), [NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi),
[NeNe Igo](https://github.com/hideyukiMORI/nene-igo) (Go), [NeNe Poker](https://github.com/hideyukiMORI/nene-poker) and [NeNe Swarm](https://github.com/hideyukiMORI/nene-swarm) (a fixed shooter).

🧪 **Beta.** [v0.1.0](https://github.com/hideyukiMORI/nene-bolt/releases/tag/v0.1.0) is out as a beta: it has not yet been checked by eye in Windows Terminal, and screenshots will follow.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-bolt/main/install.sh | bash
```

This downloads the latest release, verifies it against `SHA256SUMS`, and only then installs it as `~/.local/bin/nene-bolt`.
If the checksum doesn't match, nothing is installed. The whole script is [install.sh](install.sh), about 45 lines.

- Requirements: Linux on x86_64 with glibc 2.35 or newer (Ubuntu 22.04+). Made for Ubuntu under WSL2 with Windows Terminal
- No Swift needed. It is a single file with the Swift standard library linked statically; the only dynamic dependencies are libc, libm, libstdc++ and libgcc_s
- To uninstall: `rm ~/.local/bin/nene-bolt` (and `~/.local/state/nene-bolt` for the high scores)

**From PowerShell** (Windows, with WSL):

```powershell
irm https://raw.githubusercontent.com/hideyukiMORI/nene-bolt/main/install.ps1 | iex
```

It runs the same installer inside your default WSL distribution, then puts a small `nene-bolt.cmd` in `%LOCALAPPDATA%\nene-bolt\bin` and adds that folder to your user PATH.
Set `NENE_BOLT_DISTRO` to use another distribution.

From a clone instead: `swift build -c release && .build/release/nene-bolt` (Swift 6.4.1).

## How to watch, and how to play

```bash
nene-bolt
```

| Key | |
| --- | --- |
| Arrows | Move; up and down climb ladders. Any game key takes over from the AI |
| `Z` or Space | Jump (hold it to jump higher) |
| `X` | Fire (hold it to charge, let go for a charged shot that goes through what it kills) |
| `q` | Quit (Ctrl+C works too; however it ends, your terminal is restored) |
| `t` | Next color theme (12 in total) |
| `d` | Next difficulty: `EASY`, `NORMAL`, `HARD`. It applies at once, to the enemies only; the runner's skill never changes |

Ordinary terminals never tell a program that a key was **released**. In Windows Terminal, NeNe Bolt asks for its *win32-input-mode*, which sends both
presses and releases, so holding an arrow keeps you running and letting go stops you. Other terminals fall back to key repeat (you keep going for a moment after letting go).
The HUD says which one you got: `KEYS PRESS/RELEASE` or `KEYS REPEAT`. Thirty seconds without a key and the AI quietly takes over again.

| Option | |
| --- | --- |
| `--theme NAME` | `NEON` `PHOSPHOR` `AMBER` `SYNTHWAVE` `GLACIER` `BLOODMOON` `VAPOR` `MONO` `TOXIC` `GILDED` `ABYSS` `PAPER` |
| `--difficulty NAME` | `easy`, `normal` (default) or `hard` |
| `--seed N` | Same seed, same games, **same lines** (as long as you press no keys) |
| `--tick-rate N` | Game steps per second, 10 to 60 (default 30) |
| `--title-pause SEC` / `--game-over-pause SEC` | How long the title and game over screens stay up (default 5 s and 4 s) |
| `--hand-back SEC` | Seconds without a key before the AI takes over again (default 30) |
| `--version` | Print the version and exit |

The terminal needs at least **80×24**. At **100×26 or larger** the view gets wider and the last two lines of COMMS show under the HUD.

An auto-played NORMAL game lasts **about four and a half minutes** on average, reaches the fortress most of the time and beats the boss now and then.

### What happens on screen

- **Four stages**: a grassland; a **crystal cavern** in blue and cyan with slippery ice, ladders and a shaft climbed on vanishing blocks;
  **sky bridges** of moving platforms over bottomless pits; and a **fortress** of conveyor belts and spikes, with a door that shuts behind you and a boss
- **Vanishing blocks** appear and disappear in a fixed order (1, 2, 3, 4) on a fixed rhythm: learn it and cross. They blink before they go and leave a faint trace
- **The boss** leaps, fans out shots, dashes wall to wall and flashes the whole screen. A `WARNING` banner comes first
- **Coins** (a hundred for a life), health, 1UPs and **power-ups** (stronger shots; you drop one level when hit)
- **Effects**: two layers of scrolling backdrop, floating scores, a glowing charged shot, big-letter banners (`STAGE 2`, `CLEAR!`, `VICTORY`, `GAME OVER`, `ALL CLEAR`)
- **High scores**: the top five (score, runner or `PLAYER`, stage, difficulty) on the title screen and in the HUD, kept in `$XDG_STATE_HOME/nene-bolt/`
  (or `~/.local/state/nene-bolt/`). If the file can't be read or written, it carries on in memory and says so on the title screen

## The runners

At the title screen one of four is drawn at random for the next game. They read ahead differently, take different risks, and are rude differently.

| | How they run | In their words |
| --- | --- | --- |
| **DASH.EXE** `(>o>)` | Only looks forward. Ignores coins, sprays shots, hates restarts | *"I'll see the stage on the replay."* |
| **HOARD.ZIP** `($_$)` | Detours for every coin and power-up. Values its wallet above its life | *"Tell my coins I loved them. Count them first."* |
| **PATIENT.LOG** `(-.-)` | Reads furthest ahead, guards its health, charges its shots. Logs everything | *"Entry: life lost. Cause of loss: the floor's absence."* |
| **GLITCH.DAT** `(@_@)` | Misreads the most and doesn't mind getting hurt. Its speech is slightly corrupted | *"Blue screen. Wait, that's the sky. Never mind, I'm dead."* |

Each has 50 lines for thirteen moments: the title screen, a stage starting and ending, a kill streak, a power-up, getting hit, losing a life,
the last life, the hurry-up, the boss appearing and falling, game over and a new record. The other 196 are yours to collect.

## Twelve themes

Cycle with `t`: `NEON` (default), `PHOSPHOR`, `AMBER`, `SYNTHWAVE`, `GLACIER`, `BLOODMOON`, `VAPOR`, `MONO`, `TOXIC`, `GILDED`, `ABYSS`, and `PAPER` (the only light theme).
Each stage mixes its own hues into the theme. In every theme and every stage the terrain, the runner, the enemies, the shots and the pickups are at least 3:1
against the background, and every letter and digit on screen is at least 4.5:1. Tests compute this from the cells they actually render.

---

## Under the hood

NeNe Bolt wears the face of a retro screensaver, but it is also **an experiment in having machines enforce the rules**.
Every number below is in the repository's records (ADRs, tests, gate proofs).

### 1. The game never reads the clock, and you and the AI press the same buttons

The game is one pure function: state plus the buttons held plus a seeded random source gives the next state, one step at a time.
Your keys and the AI's decisions become **the same set of buttons** and go through the same function; there is no shortcut for either.
The game and the runners **cannot read** the time, random numbers or environment variables; if they try, a home-grown conformance check fails the build.
Positions are integers (one cell is 16 units) and everything moves in pieces of 4 units or less, so even a fall at full speed never sinks into a floor
([ADR 0005](docs/adr/0005-fixed-point-maps-and-tick-step.md)).

### 2. Six hundred games, then a hundred more with the real runners

A platformer has no published numbers to check against. So every `make check` plays **600 games to the end**, starting from each of the four stages, and checks every step:
the same seed replays the same game, the runner is never buried in solid ground, the score only grows by the points of what happened,
lives only change on a loss or a 1UP, and every game ends. Then the four real runners play **96 more**, and harder difficulties must get them less far
([ADR 0006](docs/adr/0006-invariant-tests-and-measured-runs.md), [ADR 0008](docs/adr/0008-runners-cast-and-game-length.md)).

### 3. The runners found the level designer's mistakes

A runner tries 25 moves, runs **the game's own step function** for each in two stages (the move, then the best of a few follow-ups),
and picks one that reaches further along a route map of where it can actually stand. Measuring the first version, **every runner timed out in the crystal cavern**.
Chasing each stall down found a ledge too far to reach from slippery ice, a wall with a turret standing on its only foothold, a chain of vanishing blocks ten cells from the last solid ground,
and an unreachable gap between sky platforms. Every one was too hard for a human, too, so the maps were fixed, not the runners ([ADR 0008](docs/adr/0008-runners-cast-and-game-length.md)).

### 4. Rules aren't written down, they're enforced

The repository has 72 rules, each with an ID and a status saying whether a machine enforces it.
Right now **51 are active** (break one and `make check` fails). The rest are honestly labeled "not yet checked by a machine" or "cannot be blocked by a machine" ([quality gates](docs/QUALITY_GATES.md)).
Swift 6.4.1 was measured in 82 cases before any product code was written ([phase0-results.json](docs/quality/phase0-results.json)), and no check is trusted until it has been seen to fail:
**65 planted violations**, each caught by the intended rule, are recorded in the [gate proofs](docs/quality/gate-proofs.md).
Even the names of the games it pays homage to are planted violations: write one anywhere in the repository and the build fails.

### 5. The terminal always comes back

Whether it ends with `q`, Ctrl+C (sent as a key event in win32-input-mode) or SIGTERM, **or even crashes with SIGSEGV**, it switches the key mode back and restores the terminal before it dies.
The real binary is run inside a pseudo-terminal on every `make check`, including plain arrow keys and win32-input-mode press and release sequences.

---

## Development

```bash
make bootstrap           # once after cloning (commit hook and a static SwiftLint binary)
make check               # the one definition of done, identical locally and on CI
make release TAG=v<ver>  # build the release artifacts (only if they pass the checks)
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product. About 6,000 lines of source and 1,700 lines of tests
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). Design decisions are in 11 [ADRs](docs/adr/README.md); requirements and the owner's decisions are in [REQUIREMENTS.md](docs/REQUIREMENTS.md) (both in Japanese)
- Humans and AI write under the same rules and the same gates. The code here was written by Claude Code; the project owner set the requirements and the decisions

## License

MIT ([LICENSE](LICENSE))
