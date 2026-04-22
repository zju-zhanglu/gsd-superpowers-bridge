# Compatibility Matrix

## Tested Versions

| GSD Version | Superpowers Version | Bridge Version | Status |
|-------------|-------------------|----------------|--------|
| >= 1.0.0 | >= 5.0.0 | 0.1.0 | Tested |

## Dependency Notes

- **GSD**: Bridge calls GSD commands via slash command interface. Internal `.planning/` file format changes may require bridge updates.
- **Superpowers**: Bridge uses SP skills as agent prompts. New SP skills are additive and don't affect bridge behavior. Removed SP skills cause graceful degradation.

## Reporting Incompatibilities

If you encounter issues with a specific version combination, open an issue with:
- GSD version (`gsd --version` or git commit)
- Superpowers version (git commit or plugin version)
- Bridge version
- Error output or unexpected behavior
