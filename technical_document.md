# Word Battleship

A solo Battleship game with a word-association twist, built with Flutter.  
Each cell on the board holds a Russian adjective–noun phrase. When a cell is tapped, the full phrase is revealed in a banner above the board—making every shot a vocabulary moment.

---

## Table of Contents

- [Game Rules](#game-rules)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Architecture Overview](#architecture-overview)
  - [Data Flow](#data-flow)
  - [State Management](#state-management)
- [Layer Reference](#layer-reference)
  - [Entry Point](#entry-point)
  - [Constants](#constants)
  - [Models](#models)
  - [Services](#services)
  - [Providers](#providers)
  - [Widgets](#widgets)
  - [Screens](#screens)
- [Key Algorithms](#key-algorithms)
  - [Board Generation](#board-generation)
  - [Ship Placement](#ship-placement)
  - [Win Condition](#win-condition)
- [Persistence](#persistence)
- [Known Limitations & TODOs](#known-limitations--todos)
- [Getting Started](#getting-started)

---

## Game Rules

1. A 10×10 grid is generated with 10 ships placed randomly.
2. Ships never touch each other (including diagonals).
3. Tap any unrevealed cell to fire a shot.
4. A **hit** (red, crosshair icon) means a ship occupies that cell.
5. A **miss** (grey, ✕ icon) means open water.
6. The selected cell's word phrase is displayed above the board.
7. The game ends when all ships are sunk.
8. Press **Reset** at any time to generate a fresh board.

### Ship Fleet

| Size | Count |
|------|-------|
| 4    | 1     |
| 3    | 2     |
| 2    | 3     |
| 1    | 4     |
| **Total** | **10** |

---

## Tech Stack

| Concern            | Package / Tool                  | Version |
|--------------------|---------------------------------|---------|
| Framework          | Flutter                         | SDK ^3.10.7 |
| Language           | Dart                            | — |
| State management   | flutter_riverpod                | ^3.2.1 |
| Persistence        | shared_preferences              | ^2.5.4 |
| Fonts              | google_fonts (Poppins)          | ^8.0.2 |
| Responsive sizing  | flutter_screenutil              | ^5.9.3 |
| UUID generation    | uuid                            | ^4.5.2 |
| Design system      | Material 3 (`useMaterial3: true`) | — |
| Linting            | flutter_lints                   | ^6.0.0 |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── constants/
│   ├── constants.dart         # Barrel export
│   ├── game_constants.dart    # Ship sizes, storage key
│   ├── word_dictionary.dart   # Generated local noun/adjective dictionary
│   └── words.dart             # Board sizing
├── models/
│   ├── models.dart            # Barrel export
│   ├── cell.dart              # Cell value object
│   ├── cell_status.dart       # CellStatus enum
│   ├── ship.dart              # Ship + ShipCell value objects
│   ├── game_state.dart        # SoloGameState value object
│   └── word_entry.dart        # Dictionary entry models + generation mode
├── providers/
│   └── game_provider.dart     # GameProvider + derived providers
├── services/
│   ├── board_service.dart     # Board creation & ship placement
│   ├── storage_service.dart   # JSON serialization / SharedPreferences
│   └── word_pair_service.dart # Local word-pair generation
├── screens/
│   └── game_screen.dart       # Root screen widget
└── widgets/
    ├── game_board.dart        # Grid + cell rendering
    └── game_header.dart       # Stats dashboard + reset button
```

---

## Architecture Overview

The project follows a layered architecture with immutable value objects and unidirectional data flow.

```
User Tap
   │
   ▼
GameScreen (ConsumerStatefulWidget)
   │  calls
   ▼
GameProvider.handleCellClick(row, col)
   │  mutates
   ▼
SoloGameState (immutable, replaced via copyWith)
   │  triggers rebuild of
   ▼
GameScreen → GameHeader + GameBoard
```

### Data Flow

1. `BoardService.createNewGameBoard()` generates the initial board and ship list.
2. `GameProvider` holds `SoloGameState` via Riverpod `NotifierProvider`.
3. `GameScreen` watches `gameProvider` and passes slices down to `GameHeader` and `GameBoard`.
4. Cell taps bubble up through `onCellClick` callbacks into `GameProvider`.

### State Management

`GameProvider` extends `Notifier<SoloGameState>` (Riverpod). All state mutations produce a new `SoloGameState` via `copyWith`—there is no mutable state outside the notifier.

Three derived read-only providers expose computed values:

| Provider | Returns |
|---|---|
| `totalShipsProvider` | Total ship count |
| `shipsLeftProvider` | Unsunk ship count |
| `sunkShipsCountProvider` | Sunk ship count |

> **Note:** `GameHeader` currently computes these values directly from `gameState` rather than consuming the derived providers.

---

## Layer Reference

### Entry Point

**`lib/main.dart`**  
Wraps the app in `ProviderScope` (required by Riverpod), configures `MaterialApp` with Material 3, a blue seed color, and Poppins as the global text theme. `GameScreen` is the sole route.

---

### Constants

**`lib/constants/game_constants.dart`**

| Constant | Value | Purpose |
|---|---|---|
| `shipSizes` | `[4,3,3,2,2,2,1,1,1,1]` | Defines the fleet |
| `storageKey` | `'word-battleship-solo-v1'` | SharedPreferences key |

**`lib/constants/words.dart`**

| Symbol | Description |
|---|---|
| `boardSize` | `10` — desktop grid dimension |
| `mobileBoardSize` | `6` — mobile grid dimension (see TODOs) |
| `computeBoardSize()` | Currently always returns `boardSize` (TODO: responsive) |

**`lib/constants/word_dictionary.dart`**

Generated local dictionary derived from OpenRussian Russian Dictionary Data.
It currently contains filtered `NounEntry` and `AdjectiveEntry` lists for
runtime word-pair generation. The full source CSV files are not bundled.

---

### Models

All models are **immutable value objects** with `copyWith`, `==`, `hashCode`, and `toString`.

**`CellStatus` enum** (`cell_status.dart`)

| Value | Meaning | Visual |
|---|---|---|
| `defaultValue` | Untouched | Blue tile, noun label |
| `hit` | Ship occupies cell, shot fired | Red tile, crosshair icon |
| `miss` | Empty cell, shot fired | Grey tile, ✕ icon |
| `blocked` | Reserved (adjacent blocking, unused) | Dark grey, block icon |

**`Cell`** (`cell.dart`)

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID v4 |
| `row` | `int` | 0-indexed row |
| `col` | `int` | 0-indexed column |
| `word` | `String` | Russian phrase for this cell |
| `hasShip` | `bool` | Whether a ship occupies this cell |
| `status` | `CellStatus` | Current reveal state |

**`Ship`** (`ship.dart`)

| Field | Type | Description |
|---|---|---|
| `id` | `String` | UUID v4 |
| `cells` | `List<ShipCell>` | Grid positions occupied |
| `sunk` | `bool` | All cells hit |

**`ShipCell`** — `(row, col)` coordinate pair.

**`SoloGameState`** (`game_state.dart`)

| Field | Type | Description |
|---|---|---|
| `board` | `List<List<Cell>>` | 2-D grid |
| `ships` | `List<Ship>` | Full fleet |
| `movesCount` | `int` | Total shots fired |
| `hitsCount` | `int` | Shots that were hits |
| `isFinished` | `bool` | All ships sunk |

**`WordGender` enum** (`word_entry.dart`)

| Value | Meaning |
|---|---|
| `masculine` | Masculine Russian noun |
| `feminine` | Feminine Russian noun |
| `neuter` | Neuter Russian noun |

**`WordPairMode` enum** (`word_entry.dart`)

| Value | Meaning |
|---|---|
| `classic` | Prefers semantically closer adjective-noun pairs when tags allow it |
| `random` | Keeps grammar agreement but intentionally allows stranger tag combinations |

**`NounEntry` / `AdjectiveEntry`** (`word_entry.dart`)

Local dictionary entries. `AdjectiveEntry` stores masculine, feminine, and
neuter nominative forms so generated phrases can agree with noun gender.

---

### Services

**`BoardService`** (`board_service.dart`)  
Pure static utility — no state, no side effects.

| Method | Description |
|---|---|
| `createEmptyBoard([size])` | Builds an N×N grid of blank `Cell`s with words assigned |
| `createNewGameBoard([size])` | Calls `createEmptyBoard`, then places all ships, returns `GameBoardResult` |
| `_placeShip(board, size)` | Randomly places one ship (see [Ship Placement](#ship-placement)) |
| `_canPlaceShip(...)` | Validates bounds + adjacency before placement |
| `_hasShipsAround(board, row, col)` | Checks all 8 neighbours for existing ships |

`GameBoardResult` — simple data class bundling `board` + `ships` after generation.

---

**`WordPairService`** (`word_pair_service.dart`)

Generates unique Russian adjective-noun phrases from the local dictionary.

| Method | Description |
|---|---|
| `generatePairs(count, mode, seed)` | Returns up to `count` unique phrases. A `seed` makes generation reproducible. |

`classic` mode selects a noun and an adjective, agrees the adjective with noun
gender, and prefers shared semantic tags when available.

`random` mode also preserves grammatical agreement but prefers adjectives with
different tags to create stranger combinations for the future "Режим Рандом".
The UI does not expose this mode yet; board generation is currently fixed to
`WordPairMode.classic`.

---

**`StorageService`** (`storage_service.dart`)  
Static async service. Serializes `SoloGameState` to/from JSON and persists it via `SharedPreferences`.

| Method | Description |
|---|---|
| `saveGameState(state)` | Encodes state to JSON string, writes to prefs |
| `loadGameState()` | Reads and decodes; returns `null` on missing/corrupt data |
| `clearGameState()` | Removes the stored key |

> **Note:** `StorageService` is fully implemented but not yet wired into `GameProvider`. Auto-save/restore on launch is a pending integration.

---

### Providers

**`game_provider.dart`**

| Symbol | Type | Description |
|---|---|---|
| `GameProvider` | `Notifier<SoloGameState>` | Core game notifier |
| `gameProvider` | `NotifierProvider` | Main provider |
| `totalShipsProvider` | `Provider<int>` | `ships.length` |
| `shipsLeftProvider` | `Provider<int>` | Unsunk ship count |
| `sunkShipsCountProvider` | `Provider<int>` | Sunk ship count |

`GameProvider` public API:

| Method | Description |
|---|---|
| `handleCellClick(row, col)` | Fires a shot; no-op if game finished or cell already revealed |
| `resetGame()` | Generates a brand-new board |

---

### Widgets

**`GameBoard`** (`game_board.dart`)  
Stateless. Renders the grid as a square `AspectRatio(1.0)` → `GridView.builder`.  
Passes tap events up via `onCellClick(row, col, word)` callback.

**`_CellWidget`** (private, same file)  
Renders a single cell. Color, border, icon, and label are derived from `CellStatus`:

| Status | Background | Content |
|---|---|---|
| `defaultValue` | `blue[50]` | Noun word (desktop only) |
| `hit` | `red[400]` | Crosshair icon |
| `miss` | `grey[300]` | ✕ icon |
| `blocked` | `grey[400]` | Block icon |

Taps are disabled on already-revealed cells.

---

**`GameHeader`** (`game_header.dart`)  
Stateless. Shows:
- Game status label ("Game in Progress" / "Game Finished!")
- Reset button
- 5 stat cards: **Total Ships**, **Ships Left**, **Sunk**, **Moves**, **Hits**

---

### Screens

**`GameScreen`** (`game_screen.dart`)  
`ConsumerStatefulWidget`. Holds `selectedWord` local state to display the last tapped cell's phrase.

Layout (top → bottom):
1. `AppBar` — title
2. `GameHeader` — stats + reset
3. Selected word banner (conditional)
4. `GameBoard` (expanded)
5. Footer label

---

## Key Algorithms

### Board Generation

```
createNewGameBoard()
  └─ createEmptyBoard()           — fills N×N with blank Cells + Russian words
  └─ for each size in shipSizes:
       _placeShip(board, size)    — randomly places ship, mutates board in-place
  └─ returns GameBoardResult(board, ships)
```

### Ship Placement

`_placeShip` runs a retry loop:
1. Pick random orientation (horizontal / vertical) and random `(row, col)`.
2. Call `_canPlaceShip` — checks board bounds and verifies none of the target cells (or their 8-neighbours) already `hasShip`.
3. If invalid, retry. If valid, mark cells `hasShip = true` and record `ShipCell` coordinates.

No placement limit is set on retries; termination is guaranteed in practice because the fleet fits comfortably on a 10×10 grid.

### Win Condition

After every shot in `handleCellClick`:
```dart
final isFinished = updatedShips.every((ship) => ship.sunk);
```
A `Ship` is marked sunk when `_markSunkShips` finds all its `ShipCell` coordinates have `status == CellStatus.hit` in the updated board.

---

## Persistence

`StorageService` serializes `SoloGameState` to JSON:

```
SoloGameState
  ├── board: [[Cell, ...], ...]
  │     └── Cell: { id, row, col, word, hasShip, status (enum name) }
  ├── ships: [Ship, ...]
  │     └── Ship: { id, cells: [{ row, col }, ...], sunk }
  ├── movesCount: int
  ├── hitsCount: int
  └── isFinished: bool
```

Storage key: `word-battleship-solo-v1` (versioned to allow breaking changes).

> Auto-save and restore-on-launch are **not yet connected**. Calling `StorageService.saveGameState` / `loadGameState` from `GameProvider` is the pending integration step.

---

## Known Limitations & TODOs

| # | Location | Description |
|---|---|---|
| 1 | `words.dart` · `computeBoardSize()` | Responsive board sizing not implemented — always returns 10. Mobile 6×6 path is dead code. |
| 2 | `game_provider.dart` | `StorageService` not integrated — game progress is lost on app restart. |
| 3 | `game_board.dart` | `flutter_screenutil` is imported but `ScreenUtilInit` is never called in `main.dart`, so `.w` / `.h` extensions would return uncalibrated values if used. |
| 4 | `game_header.dart` | Derived providers (`totalShipsProvider`, `shipsLeftProvider`, `sunkShipsCountProvider`) are defined but `GameHeader` recomputes the same values from raw `gameState`. |
| 5 | `cell_status.dart` | `CellStatus.blocked` has rendering logic in `_CellWidget` but is never set by `GameProvider` (intended for adjacency blocking feature). |

---

## Getting Started

### Prerequisites

- FVM 4.x
- Flutter SDK 3.38.6, installed through FVM
- Dart SDK ≥ 3.x

### Run

```bash
fvm install
fvm flutter pub get
fvm flutter run
```

### Analyze

```bash
fvm flutter analyze
```

### Test

```bash
fvm flutter test
```

### Build (release)

```bash
# Android
fvm flutter build apk --release

# Web
fvm flutter build web --release
```
