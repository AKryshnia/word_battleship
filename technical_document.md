# Word Battleship

A solo Battleship game with a word-association twist, built with Flutter.  
Each cell on the board holds a Russian adjective–noun phrase. When a cell is tapped, the full phrase is revealed in the event strip above the board—making every shot a vocabulary moment.

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
  - [Theme System](#theme-system)
  - [Utilities](#utilities)
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
4. A **hit** means a ship occupies that cell; a **miss** means open water.
5. The shot result and the cell's word phrase appear in the event strip above the board.
6. The move log at the bottom records every shot as a chip (hit / miss).
7. The game ends when all ships are sunk.
8. Press **Новая игра** at any time to generate a fresh board.

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
| Fonts              | google_fonts (Manrope, Poppins, Space Mono, Nunito, Rajdhani) | ^8.0.2 |
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
│   └── words.dart             # Board sizing helpers
├── models/
│   ├── models.dart            # Barrel export
│   ├── board_position.dart    # BoardPosition value object (row, col)
│   ├── cell.dart              # Cell value object
│   ├── cell_status.dart       # CellStatus enum
│   ├── game_state.dart        # SoloGameState value object
│   ├── move_log_entry.dart    # MoveLogEntry value object
│   ├── ship.dart              # Ship + ShipCell value objects
│   └── word_entry.dart        # Dictionary entry models + generation mode
├── providers/
│   └── game_provider.dart     # GameProvider + derived providers
├── services/
│   ├── board_service.dart     # Board creation & ship placement
│   ├── storage_service.dart   # JSON serialization / SharedPreferences
│   └── word_pair_service.dart # Local word-pair generation
├── theme/
│   ├── app_theme.dart         # AppTheme (light/dark/fluffy) + barrel exports
│   ├── app_theme_dark.dart    # buildDarkTheme()
│   ├── app_theme_fluffy.dart  # buildFluffyTheme()
│   ├── app_theme_light.dart   # buildLightTheme()
│   ├── board_style.dart       # BoardVisualStyle, CellVisual, BoardStyleConfig
│   ├── board_style_presets.dart # BoardStylePresets (modernInk, graphiteInk, fluffy, navalRetro, gridScan)
│   ├── cell_painters.dart     # Custom painters for cell icons
│   ├── theme_foundation.dart  # AppColors, AppDimensions, AppTextStyles
│   ├── theme_tokens.dart      # WordBattleThemeTokens (ThemeExtension) + wbTokens extension
│   └── theme_variant.dart     # WordBattleThemeVariant enum (paper, graphite, fluffy)
├── utils/
│   ├── plural_ru.dart         # pluralRu() — Russian plural forms
│   └── split_ru_label_parts.dart # splitRuLabelParts(), splitRuLabel()
├── screens/
│   └── game_screen.dart       # Root screen widget
└── widgets/
    ├── board_axis_headers.dart # Column (nouns) and row (adjectives) axis headers
    ├── board_cell_widget.dart  # Single cell widget
    ├── event_strip.dart        # Fixed 56 px event zone (hit/miss/sunk/victory)
    ├── game_board.dart         # Grid + axis headers assembly
    ├── game_hud_bar.dart       # Compact 54 px top bar (brand · status · stats · picker · button)
    ├── game_shell.dart         # Main card container (shell)
    ├── hud_stats.dart          # HudStatsRow + HudStatItem
    ├── hud_style_picker.dart   # Board style popup menu
    ├── move_log_bar.dart       # Scrollable bottom bar with move chips
    ├── new_game_button.dart    # "Новая игра" button
    └── word_battle_logo.dart   # WordBattle brand logo
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
   │  mutates (new SoloGameState via copyWith)
   ▼
SoloGameState (immutable)
   │  triggers rebuild of
   ▼
GameScreen → GameShell → GameHudBar + EventStrip + GameBoard + MoveLogBar
```

`GameScreen` also holds `BoardVisualStyle` in local state. Switching themes does not touch the provider and triggers no game state rebuild.

### Data Flow

1. `BoardService.createNewGameBoard()` generates the initial board, ship list, column nouns, and row adjectives.
2. `GameProvider` holds `SoloGameState` via Riverpod `NotifierProvider`.
3. `GameScreen` watches `gameProvider` and passes the full state to `GameShell`.
4. `GameShell` distributes slices to `GameHudBar`, `EventStrip`, `GameBoard`, and `MoveLogBar`.
5. Cell taps bubble up through `onCellClick` callbacks into `GameProvider`.

### State Management

`GameProvider` extends `Notifier<SoloGameState>` (Riverpod). All state mutations produce a new `SoloGameState` via `copyWith`—there is no mutable state outside the notifier.

Three derived read-only providers expose computed values:

| Provider | Returns |
|---|---|
| `totalShipsProvider` | Total ship count |
| `shipsLeftProvider` | Unsunk ship count |
| `sunkShipsCountProvider` | Sunk ship count |

> **Note:** `GameHudBar` computes stats directly from `gameState.ships` rather than consuming the derived providers.

---

## Layer Reference

### Entry Point

**`lib/main.dart`**  
Wraps the app in `ProviderScope` (required by Riverpod). Configures `MaterialApp` with Material 3, `AppTheme.light()` / `AppTheme.dark()`, and `ThemeMode` resolved from the `WB_THEME_MODE` compile-time define (`light` / `dark` / `system`).

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
| `boardSize` | `10` — default grid dimension |
| `mobileBoardSize` | `6` — small grid dimension |
| `computeBoardSize(profile)` | Returns board size for the given `LayoutProfile` |

**`lib/constants/word_dictionary.dart`**

Generated local dictionary derived from OpenRussian Russian Dictionary Data. Contains filtered `NounEntry` and `AdjectiveEntry` lists for runtime word-pair generation. The full source CSV files are not bundled.

---

### Models

All models are **immutable value objects** with `==`, `hashCode`, and `toString`.

**`CellStatus` enum** (`cell_status.dart`)

| Value | Meaning | Visual |
|---|---|---|
| `defaultValue` | Untouched | Themed default tile |
| `hit` | Ship occupies cell, shot fired | Themed hit tile + hit icon |
| `miss` | Empty cell, shot fired | Themed miss tile + miss icon |
| `blocked` | Adjacent blocking (reserved) | Themed blocked tile with hatch overlay |

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

**`BoardPosition`** (`board_position.dart`)

| Field | Type | Description |
|---|---|---|
| `row` | `int` | 0-indexed row |
| `col` | `int` | 0-indexed column |

Used to identify cells of interest (e.g. hover highlights, adjacency markers).

**`MoveLogEntry`** (`move_log_entry.dart`)

| Field | Type | Description |
|---|---|---|
| `phrase` | `String` | The word phrase shown on the chip |
| `isHit` | `bool` | Whether this move was a hit |

Stored in `SoloGameState.lastMoves` (up to `moveLogLimit = 10`).

**`SoloGameState`** (`game_state.dart`)

| Field | Type | Description |
|---|---|---|
| `board` | `List<List<Cell>>` | 2-D grid |
| `ships` | `List<Ship>` | Full fleet |
| `movesCount` | `int` | Total shots fired |
| `hitsCount` | `int` | Shots that were hits |
| `isFinished` | `bool` | All ships sunk |
| `lastMoveMessage` | `String?` | Raw message for the last shot |
| `lastSunkMessage` | `String?` | Message shown when a ship is sunk |
| `victorySummary` | `String?` | Set when the game is won |
| `columnNouns` | `List<NounEntry>` | Nouns for column axis labels |
| `rowAdjectives` | `List<AdjectiveEntry>` | Adjectives for row axis labels |
| `lastMoves` | `List<MoveLogEntry>` | Recent move history (capped at 10) |
| `interestCells` | `Set<BoardPosition>` | Cells to highlight (e.g. hovered column/row) |
| `currentMode` | `WordPairMode` | Word-pair generation mode |
| `layoutProfile` | `LayoutProfile` | Board size profile (compact / medium / wide) |

`clearLastSunkMessage` and `clearVictorySummary` are convenience flags on `copyWith` to nullify those fields explicitly.

**`LayoutProfile` enum** (`game_state.dart`)

| Value | Board size | When used |
|---|---|---|
| `compact` | 6×6 | viewport width < 420 px |
| `medium` | 6×6 | 420–699 px |
| `wide` | 10×10 | ≥ 700 px |

**`WordGender` enum** (`word_entry.dart`)

| Value | Meaning |
|---|---|
| `masculine` | Masculine Russian noun |
| `feminine` | Feminine Russian noun |
| `neuter` | Neuter Russian noun |

**`WordPairMode` enum** (`word_entry.dart`)

| Value | Meaning |
|---|---|
| `classic` | Prefers semantically closer adjective-noun pairs |
| `random` | Same grammar agreement but intentionally stranger tag combinations |

**`NounEntry` / `AdjectiveEntry`** (`word_entry.dart`)

Local dictionary entries. `AdjectiveEntry` stores masculine, feminine, and neuter nominative forms so generated phrases agree with noun gender.

---

### Services

**`BoardService`** (`board_service.dart`)  
Pure static utility — no state, no side effects.

| Method | Description |
|---|---|
| `createEmptyBoard([size])` | Builds an N×N grid of blank `Cell`s with words assigned |
| `createNewGameBoard([size])` | Calls `createEmptyBoard`, places all ships, returns `GameBoardResult` |
| `_placeShip(board, size)` | Randomly places one ship (see [Ship Placement](#ship-placement)) |
| `_canPlaceShip(...)` | Validates bounds + adjacency before placement |
| `_hasShipsAround(board, row, col)` | Checks all 8 neighbours for existing ships |

`GameBoardResult` bundles `board`, `ships`, `columnNouns`, and `rowAdjectives` after generation.

---

**`WordPairService`** (`word_pair_service.dart`)

Generates unique Russian adjective-noun phrases from the local dictionary.

| Method | Description |
|---|---|
| `generatePairs(count, mode, seed)` | Returns up to `count` unique phrases. A `seed` makes generation reproducible. |

`classic` mode selects a noun and an adjective, agrees the adjective with noun gender, and prefers shared semantic tags when available.

`random` mode preserves grammatical agreement but prefers adjectives with different tags to create stranger combinations ("Режим Рандом"). The UI does not expose this mode yet; board generation is fixed to `WordPairMode.classic`.

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
| `resetGame([profile])` | Generates a brand-new board for the given `LayoutProfile` |

---

### Theme System

The theme system is split into several complementary layers.

#### `theme_foundation.dart` — static constants

**`AppColors`** — warm paper-white palette with a teal (`#3FB6B0`) accent. Used by non-tokenised UI (button backgrounds, cell states in presets, etc.).

**`AppDimensions`** — all layout constants in one place.

| Group | Constants |
|---|---|
| Cell sizes | `cellSize` (46), `cellSizeMd` (30), `cellGap` (2) |
| Axis sizes | `adjAxisWidth` (112), `nounAxisH` (118), `adjAxisWidthMd` (76), `nounAxisHMd` (76) |
| Axis font sizes | `axisFs` (11), `axisFsMd` (9) |
| Shell sections | `hudHeight` (54), `eventStripH` (56), `moveLogBarH` (103) |
| Border radii | `radiusShell` (18), `radiusCell` (6), `radiusButton` (8), `radiusChip` (5) |
| Shell padding | `shellPadH` (22), `shellPadV` (22) |

**`AppTextStyles`** — all text styles using Manrope (via `google_fonts`). Named by role: `hudBrand`, `hudStatus`, `hudStatNum`, `hudStatLabel`, `axisLabel`, `axisLabelActive`, `eventTag`, `eventMessage`, `chipLabel`, `moveLogLabel`, `newGameButton`.

#### `theme_tokens.dart` — dynamic tokens

**`WordBattleThemeTokens`** extends `ThemeExtension<WordBattleThemeTokens>`. It carries ~40 semantic color tokens that change between themes (surfaces, text, accent states, event strip colors, move log chip colors, etc.).

Access in widgets via the `BuildContext.wbTokens` extension:
```dart
final tokens = context.wbTokens;
Container(color: tokens.surface)
```

Three static token presets: `light`, `dark`, `fluffy`.

#### `theme_variant.dart` — variant enum

**`WordBattleThemeVariant`** — `paper`, `graphite`, `fluffy`. Each variant exposes:
- `label` / `shortLabel` — display strings
- `boardStyle` — the linked `BoardStyleConfig`
- `isDark` — whether `Brightness.dark` applies

#### `app_theme.dart` + split builders

**`AppTheme`** provides three static `ThemeData` factories: `light()`, `dark()`, `fluffy()`. Each injects the corresponding `WordBattleThemeTokens` as a `ThemeExtension`. The three builder functions live in `app_theme_light.dart`, `app_theme_dark.dart`, and `app_theme_fluffy.dart` respectively.

#### `board_style.dart` — board visual style

**`BoardVisualStyle`** enum — four visual presets for the board:

| Value | Label |
|---|---|
| `modernInk` | Modern — Ink on Paper |
| `navalRetro` | Retro — Naval Chart |
| `candyFluffy` | Fluffy — Candy Tiles |
| `gridScan` | Futuristic — Grid Scan |

**`CellVisual`** — colors, border, shadows, and optional `hatchColor` (diagonal stripe overlay) for a single cell state.

**`CellIconKind`** — discriminator for the custom painter used inside a revealed cell: `inkX`, `ring`, `burst8`, `wave`, `sparkle`, `teardrop`, `radarBlip`, `miniDiamond`.

**`BoardStyleConfig`** — everything the board UI needs per style: board background, optional scanline overlay, seven `CellVisual` states (`default`, `path`, `hover`, `interest`, `hit`, `sunk`, `miss`, `blocked`), icon kind + color, axis label `TextStyle`, font scale, and uppercase flag.

#### `board_style_presets.dart` — preset configs

**`BoardStylePresets`** provides five ready-made `BoardStyleConfig` instances:

| Preset | Description |
|---|---|
| `modernInk` | Ink-on-Paper light look (default) |
| `graphiteInk` | Dark board for the Graphite app theme |
| `fluffy` | Candy-pink board |
| `_retro` | Naval chart (dark navy + orange hits) |
| `_future` | Futuristic grid scan (black + neon green) |

`BoardStylePresets.of(style)` dispatches to the correct config by `BoardVisualStyle`.

`GameScreen` holds `_boardStyle` in local state. When the app theme is dark (`Brightness.dark`), `GameShell` always resolves `graphiteInk` regardless of `_boardStyle`.

#### `cell_painters.dart` — custom icon painters

Each `CellIconKind` maps to a `CustomPainter` that renders the icon inside a revealed cell. Painters keep cell widgets free of style-aware conditional branches.

---

### Utilities

**`lib/utils/plural_ru.dart`**

`pluralRu(n, one, few, many)` — returns the correct Russian plural form based on the standard mod-10 / mod-100 rules. Used in `HudStatsRow` and `EventStrip`.

**`lib/utils/split_ru_label_parts.dart`**

`splitRuLabelParts(word)` — splits a Russian word into two display lines at the best syllable boundary. Returns a single-element list for short words. Used by axis header widgets.

`splitRuLabel(word)` — convenience wrapper that joins the result with `\n`.

---

### Widgets

**`GameShell`** (`game_shell.dart`)  
Main card container — mirrors the HTML `.shell` element. Holds `GameHudBar`, `EventStrip`, the board area, and `MoveLogBar` in a vertical `Column`. Resolves `BoardStyleConfig` from the active style and whether the app theme is dark.

Desktop layout:
```
GameHudBar (54 px)
EventStrip (56 px)
Expanded → board area (themed mat + GameBoard)
MoveLogBar (103 px collapsed)
```

Mobile layout (< 480 px): board area and `MoveLogBar` are stacked in a custom height-budget layout to prevent `RenderFlex` overflow.

---

**`GameHudBar`** (`game_hud_bar.dart`)  
Compact top bar inside the shell.

Desktop (≥ 480 px): single 54 px row — brand · pipe · status | stats · style picker · new-game button.  
Mobile (< 480 px): two-row layout — row 1 (42 px): brand · status · picker · button; row 2 (26 px): stats strip on `surface2`.

---

**`HudStatsRow`** / **`HudStatItem`** (`hud_stats.dart`)  
Stateless. Renders three stat items (moves / hits / ships left) with Russian plural forms.

---

**`NewGameButton`** (`new_game_button.dart`)  
Stateless. Theme-aware "Новая игра" `TextButton`. Light: teal-tinted fill; dark: translucent teal overlay with press/hover states.

---

**`HudStylePicker`** (`hud_style_picker.dart`)  
Palette icon button that opens a `PopupMenuButton` listing all four `BoardVisualStyle` options. Current selection shown with a checkmark. Tapping applies the style immediately.

---

**`WordBattleLogo`** (`word_battle_logo.dart`)  
Stateless. Brand mark + "WordBattle" text, sizing controlled by `markSize`.

---

**`EventStrip`** (`event_strip.dart`)  
Fixed 56 px zone below the HUD bar. Always occupies layout space (board never jumps). Shows the result of the last action:

| Event | Tag | Message |
|---|---|---|
| Miss | ПРОМАХ | word phrase · flavor text |
| Hit | ПОПАДАНИЕ | word phrase |
| Sunk | ПОТОПЛЕН | ship's word phrases |
| Won | ПОБЕДА | total moves count |

Priority: victory > sunk > hit > miss. Empty before the first move.

---

**`GameBoard`** (`game_board.dart`)  
Stateless. Assembles `board_axis_headers.dart` and the cell grid. Receives `columnNouns`, `rowAdjectives`, and `interestCells` for axis label highlighting.

---

**`board_axis_headers.dart`**  
Renders the column header row (vertical noun labels) and the row header column (horizontal adjective labels). Active axis labels (matching the hovered row/column) are highlighted using `axisLabelActive` from `BoardStyleConfig`.

---

**`board_cell_widget.dart`** (private `_CellWidget`)  
Renders a single cell. Color, border, shadow, icon, and hatch overlay are all derived from `BoardStyleConfig` + `CellStatus`. Taps are disabled on already-revealed cells.

---

**`MoveLogBar`** (`move_log_bar.dart`)  
Fixed-height bottom zone (103 px collapsed). Shows a "ХОДЫ" header and move chips in a `Wrap`. When chips overflow, a chevron appears in the header for scrolling (one chip-row per tap, or mouse-wheel on desktop). Mobile variant caps at `maxHeight` and shrinks to content.

Chip styles: hits use a teal-tinted chip with a `●` marker; misses use a neutral chip with a `×` marker.

---

### Screens

**`GameScreen`** (`game_screen.dart`)  
`ConsumerStatefulWidget`. Holds `_boardStyle` (`BoardVisualStyle`) in local state — theme changes stay out of the provider. On first frame, reads viewport width and calls `resetGame(profile)` if the resolved `LayoutProfile` differs from the stored one.

Outer layout: `Scaffold` with a warm background → `SafeArea` → responsive `EdgeInsets` padding → `ConstrainedBox(maxWidth: 980)` → `GameShell`.

---

## Key Algorithms

### Board Generation

```
createNewGameBoard(size)
  └─ createEmptyBoard(size)         — fills N×N with blank Cells + Russian words
  └─ for each size in shipSizes:
       _placeShip(board, size)      — randomly places ship, mutates board in-place
  └─ returns GameBoardResult(board, ships, columnNouns, rowAdjectives)
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
| 1 | `game_provider.dart` | `StorageService` not integrated — game progress is lost on app restart. |
| 2 | `game_board.dart` | `flutter_screenutil` is imported but `ScreenUtilInit` is never called in `main.dart`, so `.w` / `.h` extensions would return uncalibrated values if used. |
| 3 | `game_provider.dart` | Derived providers (`totalShipsProvider`, `shipsLeftProvider`, `sunkShipsCountProvider`) are defined but `GameHudBar` recomputes the same values from raw `gameState.ships`. |
| 4 | `cell_status.dart` | `CellStatus.blocked` has rendering logic in `board_cell_widget.dart` but is never set by `GameProvider` (intended for adjacency blocking feature). |
| 5 | `word_pair_service.dart` | `WordPairMode.random` ("Режим Рандом") is implemented but not exposed in the UI — `GameProvider` always resets with `WordPairMode.classic`. |

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
