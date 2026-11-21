# Zadrya

Zadrya is a harm reduction journal for iOS and Android: free, open source, and no data ever leaves the device.

It lets an adult who uses psychoactive substances log ingestions, understand durations, and avoid dangerous combinations and redosing. It takes PsychonautWiki Journal v11.11 (the last GPL release) as its functional reference.

**Status:** under development, not yet published.

## Principles

- **Absolute privacy**: no accounts, no server, no telemetry, no third-party SDKs. The only network connection is the optional download of the signed substance dataset.
- **Free forever**: no purchases, no ads, no locked features.
- **Non-judgmental harm reduction**: inform, never lecture.
- **Users own their data**: everything can be exported and deleted instantly.

## Documentation

- [Specification](docs/SPEC.md)
- [Architecture decision records](docs/adr/)

## Development

Flutter is pinned in `.fvmrc`: install [fvm](https://fvm.app) and run `fvm install` once.

```sh
make setup             # install the git hooks, once per clone
make check             # format, analyze, tests: before every commit
make ci                # plus coverage and the permission check: before opening a pull request
fvm flutter run        # run the app on a connected device or emulator
make integration-test  # integration tests on a running device or emulator
```

iOS builds need macOS with Xcode. `make help` lists every target.

See [CONTRIBUTING](https://github.com/Zadrya/.github/blob/main/CONTRIBUTING.md) and the [security policy](https://github.com/Zadrya/.github/blob/main/SECURITY.md).

## License

GPL-3.0-or-later. See [LICENSE](LICENSE). Zadrya is not medical advice.
