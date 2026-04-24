# Word Battleship

Word Battleship — прототип игры "Морской бой" на Flutter, где вместо цифр и букв используются русские словосочетания. В дальнейшем будут добавляться другие языки, если проект будет развиваться.

Каждая клетка содержит фразу из прилагательного и существительного. Когда игрок
нажимает на клетку, игра определяет попадание или промах и показывает полную
фразу над полем.

---

Word Battleship is a Flutter prototype that combines solo Battleship gameplay with Russian word-association practice.

Each cell contains a Russian adjective-noun phrase. When the player taps a cell, the game resolves the shot as a hit or miss and reveals the full phrase above the board.

## Features

- 10x10 Battleship board.
- Classic fleet layout: 1 four-cell ship, 2 three-cell ships, 3 two-cell ships, and 4 one-cell ships.
- Ships are placed randomly and never touch, including diagonally.
- Riverpod-based game state.
- Material 3 Flutter UI.
- SharedPreferences serialization service prepared for save/load integration.

## Tech Stack

- Flutter / Dart
- flutter_riverpod
- shared_preferences
- google_fonts
- uuid

## Getting Started

```bash
fvm install
fvm flutter pub get
fvm flutter run
```

Run checks:

```bash
fvm flutter analyze
fvm flutter test
```

## Documentation

Detailed architecture notes, project structure, data flow, model references, and implementation details are available in [technical_document.md](technical_document.md).
