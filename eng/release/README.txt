NeNe Bolt @VERSION@ (Linux x86_64)
==================================

A terminal screensaver in which a hand-written AI runner plays a side-scrolling action platformer forever:
four stages (a grassland, a crystal cavern, sky bridges and a fortress), vanishing blocks, ladders, ice,
conveyor belts, moving platforms, charged shots, stomping, and a boss at the end of the fourth stage.
Title, play, game over (or the ending), and around again until you press q.
Press an arrow key, Z or X and you are playing; leave it for 30 seconds and the AI takes over again.
Four runners (DASH.EXE, HOARD.ZIP, PATIENT.LOG, GLITCH.DAT) take turns and talk in the COMMS line.

Requirements: Linux on x86_64 with glibc 2.35 or newer (Ubuntu 22.04 or later),
for example Ubuntu on WSL2 in Windows Terminal. Swift is not needed (the standard library is linked statically).

Download and verify
-------------------
1. Download these two files from the GitHub Release into one folder:
     nene-bolt-@VERSION@-linux-x86_64.tar.gz
     SHA256SUMS
2. Verify (it must say OK):
     sha256sum --check SHA256SUMS
3. Extract and run:
     tar -xzf nene-bolt-@VERSION@-linux-x86_64.tar.gz
     ./nene-bolt-@VERSION@-linux-x86_64/nene-bolt

Keys
----
  arrows      move (up and down climb ladders); pressing any game key takes over from the AI
  z or space  jump (hold it to jump higher)
  x           fire (hold it to charge, release for a charged shot)
  q           quit
  t           next color theme (12 themes)
  d           next difficulty (EASY, NORMAL, HARD); it applies at once

In Windows Terminal the game asks for key press and release events, so holding a key keeps you running.
Other terminals send only key repeats; the HUD shows which one is in use (KEYS PRESS/RELEASE or KEYS REPEAT).

Options
-------
  --theme NAME            NEON PHOSPHOR AMBER SYNTHWAVE GLACIER BLOODMOON VAPOR MONO TOXIC GILDED ABYSS PAPER
  --difficulty NAME       easy, normal (default) or hard
  --seed N                the same seed gives the same games and the same lines (if you press no keys)
  --tick-rate N           game steps per second, 10 to 60 (default 30)
  --title-pause SEC       time on the title screen (default 5)
  --game-over-pause SEC   time on the game over and ending screens (default 4)
  --hand-back SEC         seconds without a key before the AI takes over again (default 30)
  --version               print the version and exit

The terminal must be at least 80x24. At 100x26 or larger the view is wider and COMMS shows two lines.
High scores are kept in $XDG_STATE_HOME/nene-bolt/highscores.txt (or ~/.local/state/nene-bolt/).

License: MIT (see LICENSE)
Source: https://github.com/hideyukiMORI/nene-bolt
