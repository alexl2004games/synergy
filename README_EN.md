<div align="center">
  <img src="assets/images/synergy_icon.png" width="150" alt="Synergy Logo">
  <h1>Synergy</h1>
  <p><b>Local AI-powered Task Scheduler</b></p>
  <p><a href="README.md">Русская версия</a></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Linux-lightgrey?style=for-the-badge" />
</p>

---

Synergy is a fully local task scheduler.

## Core components

* **Offline speech recognition (Speech-to-Text)**: voice-to-text conversion is handled locally via the Sherpa ONNX model.
* **Local NLP parser**: text processing uses the Gemma model. The parser extracts deadlines and creates tasks.
* **Scheduling algorithms**: includes two planning and load balancing algorithms.
* **Localization**: supported languages are English and Russian.

## User Interface

The application consists of 6 main tabs:

1. **Today**: current day tasks.
2. **Inbox**: unsorted tasks.
3. **Upcoming**: future deadlines scheduling.
4. **Calendar**: monthly grid. Multi-day events are shown as blocks, while specific tasks are attached to their dates.
5. **Spaces**: thematic task grouping.
6. **Settings**: system configuration.

## System Requirements

Linux: Fedora 44+<br>
Android: 12+<br>
iOS / macOS: 26+

## Build and run

Models (Gemma `*.litertlm` and Sherpa ONNX) must be downloaded and placed in the `assets/models/` directory.

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d <macos|linux|ios> --profile
```

*Android is temporarily unsupported due to apk format restrictions.*
