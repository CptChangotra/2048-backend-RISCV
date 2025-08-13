# 2048 in RISC‑V Assembly (Programming 2 — SS 2025)

This repository contains my implementation of the classic sliding-tile game 2048 in RISC‑V assembly, following the Programming 2 (SS 2025) Project 1 specification.

References:
- [2048 (original game)](http://gabrielecirulli.github.io/2048/)
- [Wikipedia: 2048](https://en.wikipedia.org/wiki/2048_(video_game))


## Overview

2048 is played on an m × n board (m, n ≥ 2). Tiles hold positive integer values. Each move:
- Shifts all tiles in the chosen direction (left/right/up/down) as far as possible, closing gaps.
- Merges adjacent equal tiles encountered in the movement direction (producing a tile with the summed value).
- Spawns a new tile (2 or 4) at a random free position.

Goal: create a tile with value 2048.  
Defeat: no move in any direction changes the board.

In this project, you implement the core subroutines in RISC‑V. Direction handling is pre-implemented via rotating the board; you only implement the “move left” logic and helpers.


## Data Representation (as per spec)

- Tile: unsigned halfword (16-bit). 0 means empty; non-zero is the tile’s value (e.g., 2048 = 0b0000100000000000).
- Board: array of unsigned halfwords in row-major order. Base address b points to the first element. Index i corresponds to memory address b + 2*i.
- Rows/Columns for subroutines: passed as arrays of addresses (not values), enumerated left→right or top→bottom. Your routines operate on these sequences.

Movement directions other than left are handled by pre-implemented rotation. You implement only the “left” behavior.


## Tasks to Implement

Implement only the following subroutines; do not modify pre-provided files such as main.s, buffer.s, utils.s. Unless explicitly stated, assume arbitrary board sizes (m × n), and validate neither parameter ranges nor invariants beyond what the task demands.

1) check_victory.s (1 point)
- Input:
  - a0: base address of the playing field array
  - a1: number of elements (array length)
- Output:
  - a0 = 1 if any tile has value 2048, else 0
- Must not modify the board.

2) place.s (1 point)
- Input:
  - a0: base address of the playing field array
  - a1: number of elements
  - a2: index in the array (0-based)
  - a3: value to place (e.g., 2 or 4)
- Output:
  - a0 = 0 if tile was placed (target cell was empty), else 1
- If the cell is occupied, do nothing.

3) move_check.s (1 point)
- Input:
  - a0: base address of an array of addresses representing a row
  - a1: number of elements in that row
- Output:
  - a0 = 1 if a left move would change the row (a gap to the left of a tile or two adjacent equal tiles), else 0
- Must not modify the board.

4) move_one.s (part of 5 points for section 4.4)
- Shift all tiles in a given row one position to the left simultaneously, if possible.
- Input:
  - a0: base of array of addresses (row)
  - a1: number of elements
- Output:
  - a0 = 1 if any tile moved, else 0

5) move_left.s
- Shift all tiles in the row as far left as possible (repeatedly use move_one.s).
- Input: same as move_one.s
- Output: none

6) merge.s
- Merge adjacent equal tiles toward the left. Process strictly left to right:
  - Replace the left tile with the sum
  - Clear the right tile (to 0)
- Input: same as move_one.s
- Output: none

7) complete_move.s
- Execute a full turn on a single row (left direction only):
  - move_left
  - merge
  - move_left
- Input: same as move_one.s
- Output: none
- Note: Tiles may only be merged once per turn. The required sequence above enforces this.

8) Scoring extension (1 point)
- Extend merge.s to return:
  - a0 = total number of merges in that merge pass
  - a1 = total summed worth of merges (sum of newly created tile values)
- Extend complete_move.s to return analogous totals for the full row move (accumulating across its single merge pass).
- Scoring for a single move on a row:
  - Base score = sum of created tile values
  - Combo factor = 2^(v − 1), where v = number of merges in that row move
  - Final row score = combo factor × base score
  - The integration/accumulation of row scores to a game score is handled by the caller.


## Calling Convention

- Follow the standard RISC‑V calling convention throughout.
- Your subroutines must be callable by arbitrary correct code following the convention.
- You can run Venus with “-cc –retToAllA” to check calling-convention adherence (conservative; might miss some violations).


## Development Workflow

- Do not change pre-supplied control/utility code (e.g., main.s, buffer.s, utils.s).
- Use .import to reference other files as needed. Do not import a file more than once.
- Start Venus from the file containing your main code (the project already organizes entry points in tests and GUI runners).

Recommended order:
1) check_victory.s
2) place.s
3) move_check.s
4) move_one.s → move_left.s
5) merge.s
6) complete_move.s
7) Scoring returns (extend 6 and 7)
8) printboard.s (see below)


## CLI Board Printer (printboard.s) — 4 × 4

Implement a printer for a 4×4 board that renders tiles up to four digits each, exactly as specified (fixed widths, alignment, separators, spaces). The output must match precisely, including spaces and trailing newline. See project statement for the expected ASCII layout.


## Running and Debugging

Prerequisites:
- Python 3.x
- Venus (RISC‑V simulator). You can run via the provided Python wrappers or VS Code integration, as described below.

Run public tests:
- From the repository root:
  ```
  ./run_tests.py
  ```
- Run only specific tests:
  ```
  ./run_tests.py -t test_check_win1
  ```
- List all public test names:
  ```
  ./run_tests.py -l
  ```
- Disable colored output if your terminal has issues:
  ```
  ./run_tests.py -nc
  ```

Debugging with Venus:
- You can run a single test file directly:
  ```
  ./venus tests/pub/test_X.s
  ```
- Or open the test file in VS Code and use Run and Debug → Venus.
- Use breakpoints, step execution, inspect:
  - registers
  - call stack
  - disassembled code (resolved pseudos and labels)
  - memory (to inspect the board state)

GUI (optional helper):
- Start the graphical UI:
  ```
  ./run_gui.py
  ```
- Control with arrow keys. Note: The GUI calls your RISC‑V subroutines; the game will only work once your implementations are correct. The GUI is a convenience tool and not required for submission.


## Notes and Constraints

- Generality: Unless specified otherwise, your subroutines must work for arbitrary m × n boards; do not assume fixed lengths.
- Tile values in tests are guaranteed positive but not necessarily powers of two.
- Moves other than “left” are realized by pre-implemented rotations; only implement “left”.
- Test rigor: Spaces and newlines in outputs are significant and compared verbatim.
- Write your own tests under tests/student to supplement provided public tests:
  - test_name.s → test program
  - test_name.ref → expected console output
  - Utilities available: assert_eq_board and print_board_test in tests/test_utils.s


## Git and Submission (course context)

If you did not configure git globally:
```
git config --global user.name "<Givenname Lastname>"
git config --global user.email "<id>@stud.uni-saarland.de"
```

Submission rule (course server): Last commit on main before 06.05.2025 13:59 is considered your submission. Push frequently to trigger daily tests on the server and to keep a backup.

Daily and eval tests run on the course infrastructure; you only have access to public tests locally. Passing public tests is required to receive daily test feedback. Ensure your code assembles locally to avoid delayed daily tests.


## LLM Usage Policy (course)

LLMs are allowed but should be used sparingly. You must fully understand your code and may be asked to reproduce/explain it. Document any LLM usage:
- Create a file LLM.txt in the project root explaining how LLMs were used.
- Commit and push it along with your work.


## Repository Structure (indicative)

- RISC‑V assembly sources:
  - main.s, buffer.s, utils.s (pre-supplied; do not modify)
  - check_victory.s, place.s, move_check.s, move_one.s, move_left.s, merge.s, complete_move.s, printboard.s (to implement)
- Tests and utilities:
  - tests/pub (public tests)
  - tests/student (your own tests)
  - tests/test_utils.s (helpers)
- Tooling:
  - run_tests.py (test harness)
  - run_gui.py (optional GUI runner)
  - venus (runner/integration; or use VS Code Venus extension)
  - LLM.txt (required if you used LLMs)


## Scoring Details (section 4.6)

- Each merge producing a tile of value x yields x points.
- For a single row move, with v merges in total and base score S = sum of produced tile values:
  - Combo factor = 2^(v − 1)
  - Final row score = (2^(v − 1)) × S
- Extend merge.s to return (v, S) in (a0, a1).
- Extend complete_move.s to return (v, S) across its single merge pass for that row. Aggregation across rows and total game score is handled by the caller.


## Tips

- Carefully preserve caller-saved and callee-saved registers per the calling convention.
- When operating on rows/columns passed as arrays of addresses, remember:
  - Load the address from the row array
  - Then load/store the halfword tile value at that address
- Implement move_one.s cleanly; it simplifies move_left.s.
- Enforce left-to-right order in merge.s, and ensure “merge once per turn” by the prescribed move-merge-move sequence in complete_move.s.
- When printing, count spaces meticulously; the grader compares exact output.


## License

This repository is for educational purposes in the context of Programming 2 (SS 2025). See course policies regarding code sharing and collaboration.


---
If you spot discrepancies between this README and the official project statement, the statement is authoritative.
