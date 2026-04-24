# Dictionary Data License

This project includes a filtered local Russian word dictionary derived from:

- Source: OpenRussian Russian Dictionary Data
- URL: https://github.com/Badestrand/russian-dictionary
- Website: https://en.openrussian.org
- License: Creative Commons Attribution-ShareAlike 4.0 International
- License URL: https://creativecommons.org/licenses/by-sa/4.0/

The generated local dictionary is stored in:

- `lib/constants/word_dictionary.dart`

The source CSV files are not bundled with the Flutter application. They are used
only during dictionary preparation by `tooling/build_word_dictionary.dart`.

Because the source data is licensed under CC-BY-SA-4.0, derived dictionary data
in this project is distributed under the same license terms. This notice covers
the dictionary data only, not necessarily the whole application source code.
