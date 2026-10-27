# NeNe Bolt

A terminal screensaver in which a hand-written AI runner plays a side-scrolling action platformer forever: run, jump, shoot, charge up,
stomp, climb ladders, ride vanishing blocks across a crystal cavern, and take on a boss at the end of the fourth stage.
Title, play, game over (or the ending), and around again until you press `q`. **Press any game key and you are playing**; leave it for 30 seconds and the AI takes over again.
Four runners with their own personalities take turns, and they grumble, joke and gloat in the COMMS panel.
Written in Swift for Ubuntu on WSL2 and Windows Terminal. The game, the collisions and the runners are written from scratch, with no external engine.
It is a sibling of [NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit) (chess), [NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi),
[NeNe Igo](https://github.com/hideyukiMORI/nene-igo) (Go), [NeNe Poker](https://github.com/hideyukiMORI/nene-poker) and [NeNe Swarm](https://github.com/hideyukiMORI/nene-swarm) (a fixed shooter).

🚧 **Nothing is drawn yet.** The game itself is written and tested with no screen: four stages drawn as character maps, running, jumping,
shooting, charged shots, stomping, ladders, ice, conveyors, moving platforms, vanishing blocks on a fixed rhythm, and the boss fight to the ending.
600 games played to the end from each of the four stages keep every invariant (determinism, never sinking into the ground,
never falling through a floor, score and life counts, every game ending). The screen, the human controls and the real runners come next.

## Development

```bash
make bootstrap   # once after cloning (commit hook and a static SwiftLint binary)
make check       # the one definition of done, identical locally and on CI
```

- Swift 6.4.1 (`.swift-version`), SwiftPM only, zero external dependencies in the product
- Entry points: [CLAUDE.md](CLAUDE.md) (Japanese) and [AGENTS.md](AGENTS.md) (English). What the machines enforce right now is in [docs/QUALITY_GATES.md](docs/QUALITY_GATES.md); the owner's decisions are in [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md)

## License

MIT ([LICENSE](LICENSE))
