# AHWT

[ENG](README.md)

Another Hardening Windows Tool - desktop GUI-приложение для генерации `.bat`-скриптов харденинга Windows на основе подготовленных SQLite-баз и security templates.

Этот репозиторий является Flutter/Dart-ребилдом оригинального Python-проекта. Цель репозитория - сохранить релиз в виде редактируемых исходников, оставить прежнюю логику работы с базами и шаблонами, а также предоставить удобный кроссплатформенный GUI для генерации скриптов.

## Что делает приложение

AHWT генерирует batch-скрипты для применения настроек харденинга Windows и Microsoft Office. Настройки хранятся в SQLite-базах и сгруппированы по операционной системе, уровню харденинга и дополнительным профилям.

Сгенерированные скрипты могут включать:

- команды создания точки восстановления
- применение security template через `secedit`
- команды audit policy
- харденинг опциональных служб и устаревших компонентов
- registry-based policy settings
- дополнительные правила firewall
- настройки харденинга Microsoft Office

Результат генерации всегда является `.bat`-файлом, который нужно проверить перед запуском на целевой Windows-машине.

## Поддерживаемые цели

Операционные системы:

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
- Office 2016, включая использование baseline для 2019 и 2021
- Office 365

## Режимы харденинга

AHWT поддерживает несколько сценариев генерации:

- `Auto` создает полный OS hardening script по выбранному уровню.
- `Manual` позволяет просматривать, искать, фильтровать и выбирать отдельные параметры.
- `Addons` генерирует скрипты только для дополнительных профилей, например Firewall, Internet Explorer, Defender, BitLocker, Edge или Next Generation Security.
- `Office` генерирует скрипты харденинга Microsoft Office по версии Office и целевой ОС.

Уровни харденинга сопоставлены с профилями базы:

- `Minimum` использует профиль `Min`, соответствующий параметрам уровня 3.
- `Medium` использует `Min + Med`, соответствующие параметрам уровней 2 и 3.
- `Full` использует `Min + Med + Full`, соответствующие параметрам уровней 1, 2 и 3.

Ручной режим ОС отображает записи из профилей базы и позволяет выбрать только нужные параметры для итогового скрипта. Ручной режим Office работает с Office-профилями и не использует фильтры уровней харденинга ОС.

## Дополнительные профили

Доступные addons зависят от выбранной версии Windows:

- Windows XP: Firewall, Internet Explorer 6-8
- Windows Vista: Firewall, Defender, Internet Explorer 7-9
- Windows 7: Firewall, Defender, BitLocker, Internet Explorer 8-11
- Windows 8: Firewall, Defender, BitLocker, Internet Explorer 10-11
- Windows 8.1: Firewall, Defender, BitLocker, Internet Explorer 11
- Windows 10: Firewall, Defender, BitLocker, Edge, Next Generation Security, Internet Explorer
- Windows 11: Firewall, Defender, BitLocker, Edge, Next Generation Security

Генерация Firewall поддерживает опциональный режим ShieldUp. ShieldUp блокирует все входящие подключения, включая подключения, разрешенные через стандартные allow-list настройки Windows Firewall.

## Структура репозитория

Важные директории исходников:

- `lib/` - Flutter UI, workflow приложения, логика генерации BAT и общие helper-функции
- `dbs/` - основные SQLite-базы, используемые генератором
- `Templates/` - релизные templates, используемые сгенерированными скриптами
- `data/` - runtime-настройки UI, например язык и тема
- `windows/` - Flutter Windows runner и правила упаковки релиза
- `linux/` - Flutter Linux runner и правила упаковки релиза
- `test/` - smoke-тесты runtime assets и UI
- `tool/` - вспомогательные скрипты для генерации и проверки sample BAT files

Релизный bundle ожидает runtime-данные в `data/dbs`, `data/Templates`, `data/lang.ini` и `data/theme.ini`. Правила сборки Windows и Linux копируют эти файлы в итоговый bundle автоматически.

## Требования

Общие требования:

- Flutter SDK с поддержкой desktop
- Dart SDK, входящий в Flutter
- Git

Требования для сборки Windows:

- Windows 10 или новее для сборки
- Visual Studio 2022 или Build Tools for Visual Studio с workload `Desktop development with C++`
- CMake и Ninja из Visual Studio/Flutter toolchain

Требования для сборки Linux на Debian/Ubuntu-like системах:

```bash
sudo apt update
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev libsqlite3-dev
```

## Сборка из исходников

Получить зависимости:

```bash
flutter pub get
```

Включить desktop targets при необходимости:

```bash
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

Собрать release-бинарник Windows:

```bash
flutter build windows --release
```

Выходная директория Windows:

```text
build/windows/x64/runner/Release/
```

Собрать release bundle Linux:

```bash
flutter build linux --release
```

Выходная директория Linux:

```text
build/linux/x64/release/bundle/
```

Запуск из исходников во время разработки:

```bash
flutter run -d windows
flutter run -d linux
```

## Проверка

Рекомендуемые локальные проверки:

```bash
flutter analyze
flutter test
dart run tool/generate_sample_bats.dart
dart run tool/validate_generated_bats.dart
```

Генератор sample BAT создает повторяемые тестовые скрипты в `tool/generated_samples`. Эта директория является generated output и не должна попадать в коммит.

## Использование

1. Запустите приложение.
2. Выберите цель харденинга: Windows или Microsoft Office.
3. Укажите имя выходного BAT-файла.
4. Выберите автоматический, ручной, addon-only или Office-сценарий генерации.
5. Выберите нужный уровень харденинга, дополнительные профили или отдельные параметры.
6. Сгенерируйте `.bat`-файл.
7. Проверьте сгенерированный скрипт перед запуском на целевой машине.
8. Запустите скрипт с правами администратора на целевой Windows-системе.

Для OS hardening scripts держите сгенерированный скрипт рядом с соответствующими файлами из `Templates`, если скрипту нужны внешние security templates или installers.

## Примечания по безопасности

Hardening-скрипты могут менять security policy, значения реестра, поведение firewall, optional Windows features и Office policy settings. Проверяйте сгенерированные скрипты в виртуальных машинах перед применением на реальных системах.

Часть записей в базах отражает исторические CIS Benchmark, DoD STIG, документацию Microsoft и рекомендации исследователей из оригинальной релизной ветки AHWT. Перед production-использованием сверяйте сгенерированный результат с вашим актуальным security baseline.
