# Repository Guidelines

## Project Structure & Module Organization
- `Sources/CustomRepeatDate/` contains the Swift package source (calendar extensions, repeat option models).
- `Tests/CustomRepeatDateTests/` holds the unit tests for the package.
- `Examples/CustomRepeatDateSample/` is a SwiftUI sample app with an Xcode project and assets.
- `Package.swift` defines the SwiftPM package, platforms, and dependencies.

## Build, Test, and Development Commands
- `swift build` builds the library with Swift Package Manager.
- `swift test` runs the test suite.
- `open Examples/CustomRepeatDateSample/CustomRepeatDateSample.xcodeproj` opens the demo app in Xcode.

## Coding Style & Naming Conventions
- Follow standard Swift API Design Guidelines: `UpperCamelCase` types, `lowerCamelCase` functions and properties.
- Indentation is 4 spaces and braces follow Swift defaults.
- Keep public APIs documented with concise `///` comments.
- No formatter or linter is enforced; keep diffs consistent with surrounding code.

## Testing Guidelines
- Tests use Swift Testing (`import Testing`) with `@Test` and `#expect`.
- Place new tests in `Tests/CustomRepeatDateTests/` and keep file names ending in `Tests.swift`.
- For date logic, prefer deterministic calendars/time zones (see existing tests for GMT usage).

## Commit & Pull Request Guidelines
- Commit subjects in this repo are short, imperative, and capitalized (e.g., "Add .swift-version", "Fix missing simulator").
- Pull requests should include a clear description and test results (at least `swift test`).
- If modifying the sample app UI, include before/after screenshots in the PR.

## GitHub Workflow
- Use the `gh` CLI to open or reference issues and pull requests when needed.
