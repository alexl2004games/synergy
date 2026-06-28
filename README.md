<div align="center">
  <img src="assets/images/synergy_icon.png" width="150" alt="Synergy Logo">
  <h1>Synergy</h1>
  <p><b>Локальный планировщик задач</b></p>
  <p><a href="README_EN.md">English version</a></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20macOS%20%7C%20Linux-lightgrey?style=for-the-badge" />
</p>

---

Synergy — это полностью локальный планировщик задач.

## Ключевые компоненты

* **оффлайн распознавание речи (speech-to-text)**: перевод голоса в текст локально с помощью sherpa onnx.
* **локальный парсер (nlp)**: обработка текста через модель gemma. Парсер извлекает сроки и формирует задачи.
* **алгоритмы расписания**: реализованы два алгоритма планирования и балансировки нагрузки.
* **локализация**: поддерживаются два языка интерфейса — русский и английский.

## Интерфейс

Приложение состоит из 6 вкладок:

1. **сегодня**: задачи текущего дня.
2. **входящие**: неотсортированные задачи.
3. **скоро**: планирование будущих дедлайнов.
4. **календарь**: сетка месяца. Многодневные события показаны блоками, а точечные привязаны к дате.
5. **списки**: тематическая группировка задач.
6. **настройки**: конфигурация системы.

## Системные требования

linux: fedora 44+<br>
android: 12+<br>
ios / macos: 26+

## Сборка и запуск

модели (gemma `*.litertlm` и sherpa onnx) должны быть скачаны и размещены в директории `assets/models/`.

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d <macos|linux|ios> --profile
```

*android временно не поддерживается из-за ограничений формата apk.*