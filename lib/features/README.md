# features

One folder per feature, each split into layers, where every layer only uses the
one below it:

- `presentation/`: widgets and screens.
- `application/`: state and use cases (Riverpod).
- `domain/`: pure Dart models and rules, with no Flutter import. Covered at
  85 % or more by `make coverage`.
- `data/`: repositories, database and file access. Covered at 85 % or more by
  `make coverage`.

See "Architecture and stack" in `docs/SPEC.md`.
