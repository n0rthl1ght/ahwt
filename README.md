# AHWT

[RUS](README_RU.md)

Another Hardening Windows Tool is a desktop GUI application that generates Windows hardening `.bat` scripts from curated SQLite databases and security templates.

This repository is a Flutter/Dart rebuild of the original Python-based project. The goal of this repo is to keep the release available in editable sources, preserve the original database/template workflow, and provide a usable cross-platform GUI for generating scripts.

## What It Does

AHWT generates batch scripts for applying Windows and Microsoft Office hardening settings. The settings are stored in SQLite databases and are grouped by operating system, hardening level, and optional addon profile.

The generated scripts can include:

- restore point creation commands
- security template application through `secedit`
- audit policy commands
- optional service and legacy component hardening
- registry-based policy settings
- optional firewall rules
- Microsoft Office hardening settings

Generated output is always a `.bat` file intended to be reviewed and then run on the target Windows machine.

## Supported Targets

Operating systems:

- Windows XP
- Windows Vista
- Windows 7
- Windows 8
- Windows 8.1
- Windows 10
- Windows 11

Microsoft Office:

- Office 2003
- Office 2007
- Office 2010
- Office 2013
- Office 2016, including 2019 and 2021 baseline usage
- Office 365

## Hardening Modes

AHWT supports several generation flows:

- `Auto` creates a complete OS hardening script by selected level.
- `Manual` lets you inspect, search, filter, and select individual parameters.
- `Addons` generates scripts only for optional profiles such as Firewall, Internet Explorer, Defender, BitLocker, Edge, or Next Generation Security.
- `Office` generates Microsoft Office hardening scripts by Office version and target OS.

Hardening levels are mapped to database profiles:

- `Minimum` uses the `Min` profile, corresponding to level 3 parameters.
- `Medium` uses `Min + Med`, corresponding to levels 2 and 3.
- `Full` uses `Min + Med + Full`, corresponding to levels 1, 2, and 3.

Manual OS mode displays records from the database profiles and allows selecting only the parameters you want in the final script. Office manual mode works from Office profiles and does not use OS hardening level filters.

## Addon Profiles

Available addons depend on the selected Windows version:

- Windows XP: Firewall, Internet Explorer 6-8
- Windows Vista: Firewall, Defender, Internet Explorer 7-9
- Windows 7: Firewall, Defender, BitLocker, Internet Explorer 8-11
- Windows 8: Firewall, Defender, BitLocker, Internet Explorer 10-11
- Windows 8.1: Firewall, Defender, BitLocker, Internet Explorer 11
- Windows 10: Firewall, Defender, BitLocker, Edge, Next Generation Security, Internet Explorer
- Windows 11: Firewall, Defender, BitLocker, Edge, Next Generation Security

Firewall generation supports an optional ShieldUp mode. ShieldUp blocks all incoming connections, including connections allowed through normal Windows Firewall allow-list settings.

## Repository Layout

Important source directories:

- `lib/` - Flutter UI, application flow, BAT generation logic, and shared helpers
- `dbs/` - primary SQLite databases used by the generator
- `Templates/` - release templates used by generated scripts
- `data/` - runtime UI settings such as language and theme
- `windows/` - Flutter Windows runner and release packaging rules
- `linux/` - Flutter Linux runner and release packaging rules
- `test/` - smoke tests for runtime assets and UI
- `tool/` - helper scripts for generating and validating sample BAT files

The release bundle expects runtime data under `data/dbs`, `data/Templates`, `data/lang.ini`, and `data/theme.ini`. Windows and Linux build rules copy these files into the final bundle automatically.

## Requirements

Common requirements:

- Flutter SDK with desktop support
- Dart SDK included with Flutter
- Git

Windows build requirements:

- Windows 10 or newer for building
- Visual Studio 2022 or Build Tools for Visual Studio with the Desktop development with C++ workload
- CMake and Ninja from the Visual Studio/Flutter toolchain

Linux build requirements on Debian/Ubuntu-like systems:

```bash
sudo apt update
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev libsqlite3-dev
```

## Build From Source

Fetch dependencies:

```bash
flutter pub get
```

Enable desktop targets when needed:

```bash
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

Build a Windows release binary:

```bash
flutter build windows --release
```

Windows output:

```text
build/windows/x64/runner/Release/
```

Build a Linux release bundle:

```bash
flutter build linux --release
```

Linux output:

```text
build/linux/x64/release/bundle/
```

Run from source during development:

```bash
flutter run -d windows
flutter run -d linux
```

## Verification

Recommended local checks:

```bash
flutter analyze
flutter test
dart run tool/generate_sample_bats.dart
dart run tool/validate_generated_bats.dart
```

The sample BAT generator writes repeatable test scripts to `tool/generated_samples`. That directory is generated output and should not be committed.

## Usage

1. Start the application.
2. Select the target hardening item: Windows or Microsoft Office.
3. Enter the output BAT filename.
4. Choose automatic, manual, addon-only, or Office generation flow.
5. Select the desired hardening level, addon profiles, or individual parameters.
6. Generate the `.bat` file.
7. Review the generated script before running it on a target machine.
8. Run the script with administrative privileges on the target Windows system.

For OS hardening scripts, copy or keep the generated script together with the relevant files from `Templates` when the script expects external security templates or installers.

## Safety Notes

Hardening scripts can change security policy, registry values, firewall behavior, optional Windows features, and Office policy settings. Test generated scripts in virtual machines before applying them to real systems.

Some database entries reflect historical CIS Benchmark, DoD STIG, Microsoft documentation, and researcher guidance from the original AHWT release line. Review the generated output against your current security baseline before production use.
