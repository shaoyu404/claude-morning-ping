# claude-morning-ping

A Windows Task Scheduler script that pings `claude.exe` at fixed times (e.g.
right before work starts, and again at lunch) to pin Claude Code's usage
session reset to your own schedule, so a full session window lines up with
your actual working hours instead of resetting mid-work and wasting part of
the window.

## How it works

`morning_claude.bat`:
- Reads the prompt text from `prompt.txt` and calls `claude.exe -p "..."`
- Retries up to 5 times (60s apart) if the call fails, e.g. a brief WiFi drop
- Only needs one successful call per slot (AM / PM) per day — once it
  succeeds it writes a `.session_ping_<date>_<AM|PM>.flag` marker so a
  repeated trigger from the scheduler won't waste another call

## Why the prompt lives in a separate prompt.txt

`cmd.exe` has a nasty, unreliable bug where a batch file containing embedded
multi-byte UTF-8 characters (e.g. Chinese text) can have its parsing
corrupted if a character happens to land on an internal read-buffer
boundary — and whether that happens depends on file length/offset, so it's
inconsistent and hard to predict. To avoid this entirely, all non-ASCII
content was moved out of the script into `prompt.txt`, loaded into a
variable at runtime via `set /p`. `morning_claude.bat` itself is pure ASCII,
which sidesteps the bug at the source.

## Setup

1. Put the folder anywhere you like — `morning_claude.bat` uses `%~dp0` to
   find its own location, so the folder can be moved freely.
2. Edit the `CLAUDE` variable in `morning_claude.bat` to point to your own
   `claude.exe` path.
3. In Windows Task Scheduler, create daily triggers (e.g. 07:00, 12:00)
   pointing to `morning_claude.bat`.
4. On the task's Settings tab, enable "Run task as soon as possible after a
   scheduled start is missed" (`StartWhenAvailable`) so a run isn't lost if
   the machine happens to be rebooting/updating at trigger time.

## Files

| File | Purpose |
| --- | --- |
| `morning_claude.bat` | Main entry script |
| `prompt.txt` | Prompt text sent to claude |

Running the script creates `morning.log` (run history) and
`.session_ping_*.flag` (today's success markers) in the same folder — both
are local, machine-specific state and are excluded via `.gitignore`.
