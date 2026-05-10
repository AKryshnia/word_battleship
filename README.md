# Word Battleship

Word Battleship — прототип игры "Морской бой" на Flutter, где вместо цифр и букв используются русские словосочетания. В дальнейшем будут добавляться другие языки, если проект будет развиваться.

Каждая клетка содержит фразу из прилагательного и существительного. Когда игрок нажимает на клетку, игра определяет попадание или промах и показывает результат и фразу в полосе событий над полем.

Игра выложена на RuStore: https://www.rustore.ru/catalog/app/ru.svartha.wordbattle

<img width="909" height="1194" alt="2-1" src="https://github.com/user-attachments/assets/5ce9f766-e315-4581-93a2-cf41e07d25c3" />


---

Word Battleship is a Flutter prototype that combines solo Battleship gameplay with Russian word-association practice.

Each cell contains a Russian adjective-noun phrase. When the player taps a cell, the game resolves the shot as a hit or miss and reveals the phrase in the event strip above the board.

## Features

- 10×10 Battleship board (6×6 on mobile).
- Classic fleet layout: 1 four-cell ship, 2 three-cell ships, 3 two-cell ships, and 4 one-cell ships.
- Ships are placed randomly and never touch, including diagonally.
- Russian adjective and noun labels on board axes — active row/column highlights on hover.
- Event strip showing hit, miss, sunk, and victory messages with the word phrase.
- Scrollable move log with hit/miss chips at the bottom of the board.
- Four board visual styles: Modern (Ink on Paper), Retro (Naval Chart), Fluffy (Candy Tiles), Futuristic (Grid Scan).
- Three app themes: Paper (light), Graphite (dark), Fluffy (pink). Switchable at runtime.
- Responsive layout: adapts to mobile (< 480 px), tablet, and desktop widths.
- Riverpod-based game state with immutable value objects.
- Material 3 Flutter UI with a custom `ThemeExtension` design token system.
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

Detailed architecture notes, project structure, data flow, model references, theme system, and implementation details are available in [technical_document.md](technical_document.md).

## Credits / Dictionary Data

The local Russian noun and adjective dictionary is derived from
[OpenRussian Russian Dictionary Data](https://github.com/Badestrand/russian-dictionary),
licensed under
[Creative Commons Attribution-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/).

See [LICENSE-DATA.md](LICENSE-DATA.md) for attribution and data-license notes.
