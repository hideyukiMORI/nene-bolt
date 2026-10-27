#!/usr/bin/env python3
"""実行ファイルを疑似端末（pty）の中で動かし、描画・キー・終わり方ごとの端末の復元を確かめる（FR-07・FR-08）。

    python3 eng/smoke-terminal.py <nene-bolt の実行ファイル>

見ること:
- alternate screen に入り、24 ビットの色で面の窓と HUD（`GAME 001`）を描く
- `t` で次のテーマ（PHOSPHOR）に、`d` で次の難易度（HARD）に替わる
- 場面が TITLE から PLAY（HUD の `LIVES 04`）へ進む
- 遊びのキーで人の操作に替わり（HUD の `PLAYER`）、キー入力の方式を HUD に出す（文字なら `REPEAT`・win32-input-mode の列なら `PRESS/RELEASE`）
- win32-input-mode の列で届いた `q` と Ctrl+C でも終わる
- 罫線の幅の問い合わせに答えない端末（この疑似端末）では ASCII の枠に落ちる
- `q`・Ctrl+C・SIGTERM のどれで終わっても exit 0 で、出力の最後が端末を戻す列で、termios の lflag が起動前と同じ
- SIGSEGV（異常終了）でも端末を戻してから、そのシグナルで死ぬ
- 端末を小さくすると落ちずに 1 行の文言を出し、戻すと画面を描き直す
- 保存したハイスコアの表を TITLE に出し、読めないファイルでは起動中だけの記録で続ける（置き場は一時ディレクトリ）
- 間違った起動オプションは exit 2、端末の外から起動すると exit 1（どちらも理由を 1 行）

標準ライブラリだけで書く。Windows Terminal での見え方の代わりにはならない（QLT-013）。
移植元: NeNe Swarm eng/smoke-terminal.py（コミット a660f47。元は NeNe Igo の 3bdae35）。
リアルタイムで出力が止まらないので、決まった秒数だけ読んで waitpid せず、終わるまで読み続ける形のまま使う。端末は 80 × 24。
"""

from __future__ import annotations

import fcntl
import os
import pty
import re
import select
import signal
import struct
import subprocess
import sys
import tempfile
import termios
import time

ENTER, LEAVE, SHOW, GAME = "\x1b[?1049h", "\x1b[?1049l", "\x1b[?25h", "GAME 001"


def run(binary: str, keys: list[bytes], send: int | None = None, shrink: bool = False,
        state: str = "", title: float = 0.5) -> tuple[str, int, bool]:
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
    before = termios.tcgetattr(slave)
    pid = os.fork()
    if pid == 0:
        os.setsid()
        fcntl.ioctl(slave, termios.TIOCSCTTY, 0)
        for fd in (0, 1, 2):
            os.dup2(slave, fd)
        # ハイスコアの置き場は一時ディレクトリにする（利用者の ~/.local/state に書かない）
        env = dict(os.environ, COLORTERM="truecolor", XDG_STATE_HOME=state or tempfile.mkdtemp(prefix="bolt-smoke-"))
        os.execve(binary, [binary, "--seed", "1", "--title-pause", str(title)], env)
    chunks: list[bytes] = []

    def pump(seconds: float) -> None:
        end = time.time() + seconds
        while time.time() < end:
            ready, _, _ = select.select([master], [], [], 0.05)
            if ready:
                try:
                    chunks.append(os.read(master, 65536))
                except OSError:
                    return

    def pump_until(marker: bytes, after: int, seconds: float) -> int:
        # 決まった秒数ではなく文言が出るまで読む
        end = time.time() + seconds
        while time.time() < end:
            found = b"".join(chunks).find(marker, after)
            if found >= 0:
                return found
            pump(0.05)
        return -1

    pump(1.5)
    if shrink:
        # 大きさを変えると、端末は前面のプロセスに SIGWINCH を送る
        start = len(b"".join(chunks))
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 10, 40, 0, 0))
        small = pump_until(b"TERMINAL TOO SMALL", start, 5)
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))
        pump_until(GAME.encode(), max(small, start), 5)
    for key in keys:
        os.write(master, key)
        # キーを読んで描き直すまで待つ。短いと次のキーと一緒に読まれ、描き直す前に終わる
        pump(1.5)
    if send is not None:
        os.kill(pid, send)
        pump(0.5)
    # 終わるまで読み続ける。読まずに待つと、毎刻み描く出力で端末のバッファが埋まり、
    # 書き込みで止まった実行ファイルがキーを読めず、両方が待ち合って終わらない。10 秒で終わらなければ止めて失敗にする
    deadline = time.time() + 10
    while True:
        done, status = os.waitpid(pid, os.WNOHANG)
        if done:
            break
        if time.time() > deadline:
            os.kill(pid, signal.SIGKILL)
            _, status = os.waitpid(pid, 0)
            break
        pump(0.05)
    pump(0.2)
    restored = termios.tcgetattr(slave)[3] == before[3]
    os.close(master)
    os.close(slave)
    return b"".join(chunks).decode("utf-8", "replace"), status, restored


def screen(text: str, rows: int = 24, columns: int = 80) -> list[str]:
    """出力を小さな端末として再生した、最後の画面の行（差分で書くので、出力の文字列そのものには画面の文言が続いて現れない）。"""
    grid = [[" "] * columns for _ in range(rows)]
    row = column = 0
    for match in re.finditer(r"\x1b\[([0-9;?]*)([A-Za-z])|(.)", text, re.S):
        params, final, char = match.groups()
        if char is not None:
            if char not in "\r\n" and 0 <= row < rows and 0 <= column < columns:
                grid[row][column] = char
            column += char not in "\r\n"
        elif final == "H":
            parts = (params or "1;1").split(";")
            row, column = int(parts[0]) - 1, int(parts[1]) - 1
        elif final == "J" and params == "2":
            grid = [[" "] * columns for _ in range(rows)]
    return ["".join(line) for line in grid]


def check(name: str, ok: bool, failures: list[str]) -> None:
    print(f"smoke: {'ok ' if ok else 'NG '} {name}")
    if not ok:
        failures.append(name)


def main() -> int:
    binary = sys.argv[1]
    failures: list[str] = []
    for label, keys, send, expect in (
        ("q", [b"t", b"d", b"q"], None, ("exit", 0)),
        ("Ctrl+C", [b"\x03"], None, ("exit", 0)),
        ("SIGTERM", [], signal.SIGTERM, ("exit", 0)),
        ("SIGSEGV", [], signal.SIGSEGV, ("signal", signal.SIGSEGV)),
        ("resize", [b"q"], None, ("exit", 0)),
        ("keys", [b"\x1b[C", b"q"], None, ("exit", 0)),
        ("win32", [b"\x1b[39;77;0;1;0;1_", b"\x1b[39;77;0;0;0;1_", b"\x1b[81;16;113;1;0;1_"], None, ("exit", 0)),
        ("win32 Ctrl+C", [b"\x1b[67;46;3;1;8;1_"], None, ("exit", 0)),
    ):
        text, status, restored = run(binary, keys, send, shrink=label == "resize")
        actual = ("exit", os.WEXITSTATUS(status)) if os.WIFEXITED(status) else ("signal", os.WTERMSIG(status))
        check(f"{label}: 終わり方 {actual}", actual == expect, failures)
        check(f"{label}: alternate screen に入って盤面と HUD を 24 ビットの色で描く",
              ENTER in text and GAME in text and "38;2;" in text, failures)
        check(f"{label}: 最後に端末を戻す（カーソルを出し alternate screen を抜ける）",
              SHOW in text and text.rstrip().endswith(LEAVE), failures)
        check(f"{label}: termios の lflag が起動前と同じ", restored, failures)
        plain = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", text)  # 色とカーソルの CSI 列を除いた、書いた文字だけ
        if label == "q":
            check("t: 次のテーマ（PHOSPHOR）に替わる", "PHOSPHOR" in plain, failures)
            last = "\n".join(screen(text[: text.rfind(LEAVE)]))
            check("d: 次の難易度（HARD）に替わる", "[d] HARD" in last and "LEVEL HARD" in last, failures)
            check("TITLE から PLAY へ進む（HUD に LIVES 04 が出る）", "LIVES 04" in plain, failures)
            check("幅の問い合わせに答えない端末では ASCII の枠に落ちる", "+------" in plain and "┌" not in plain, failures)
            check("キーを押さなければ AI が遊ぶ（HUD に AUTO）", "PILOT AUTO" in last, failures)
        if label == "keys":
            last = "\n".join(screen(text[: text.rfind(LEAVE)]))
            check("keys: 矢印キーで人の操作に替わり、簡易な方式と出す", "PILOT PLAYER" in last and "KEYS REPEAT" in last, failures)
        if label == "win32":
            last = "\n".join(screen(text[: text.rfind(LEAVE)]))
            check("win32: 押す・離すの列で人の操作に替わり、その方式と出す",
                  "PILOT PLAYER" in last and "KEYS PRESS/RELEASE" in last, failures)
        if label == "resize":
            check("resize: 小さくすると 1 行の文言を出し、戻すと画面を描き直す",
                  "TERMINAL TOO SMALL" in text and text.rfind(GAME) > text.find("TERMINAL TOO SMALL"), failures)
    with tempfile.TemporaryDirectory(prefix="bolt-smoke-") as state:
        os.makedirs(os.path.join(state, "nene-bolt"))
        with open(os.path.join(state, "nene-bolt", "highscores.txt"), "w") as saved:
            saved.write("nene-bolt-highscores 1\n54321\t6\thard\tSNIPER.ISO\n")
        text, _, _ = run(binary, [b"q"], state=state, title=5)
        last = "\n".join(screen(text[: text.rfind(LEAVE)]))
        check("保存したハイスコアの表を読んで TITLE に出す", "0054321  SNIPER.ISO" in last and "MEMORY ONLY" not in last, failures)
    with tempfile.TemporaryDirectory(prefix="bolt-smoke-") as state:
        os.makedirs(os.path.join(state, "nene-bolt"))
        with open(os.path.join(state, "nene-bolt", "highscores.txt"), "w") as saved:
            saved.write("not a score file\n")
        text, _, _ = run(binary, [b"q"], state=state, title=5)
        last = "\n".join(screen(text[: text.rfind(LEAVE)]))
        check("読めないハイスコアのファイルでは起動中だけの記録で続け、TITLE にそう出す", "SCORES KEPT IN MEMORY ONLY" in last, failures)
    bad = subprocess.run([binary, "--tick-rate", "500"], capture_output=True, text=True, stdin=subprocess.DEVNULL)
    check("間違った起動オプションは exit 2 で理由を 1 行", bad.returncode == 2 and bad.stderr.count("\n") == 1, failures)
    off = subprocess.run([binary], capture_output=True, text=True, stdin=subprocess.DEVNULL)
    check("端末の外からは exit 1 で理由を 1 行", off.returncode == 1 and off.stderr.count("\n") == 1, failures)
    print(f"smoke: 失敗 {len(failures)} 件")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
