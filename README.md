<p align="center">
  <img src="https://github.com/gonz-tyler/portfolio-assets/blob/main/burnout/banner.png?raw=true" alt="Burnout" width="100%">
</p>

<p align="center">
  <img src="https://img.shields.io/github/v/release/gonz-tyler/burnout?label=Version&style=flat-square&color=C4A454&labelColor=100E0C" alt="Release">
  <img src="https://img.shields.io/badge/Flutter-3.x-C4A454?style=flat-square&labelColor=100E0C" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android-C4A454?style=flat-square&labelColor=100E0C" alt="Platform">
</p>

A Greek-mythology-themed fitness tracker built with Flutter — workout
logging, automatic progression, and body measurement tracking, styled
around classical iconography rather than the usual fitness-app palette.

## Features

| Feature                   | Description                                                                                   |
| ------------------------- | --------------------------------------------------------------------------------------------- |
| **Workout Builder**       | Custom routines, with challenges organized around figures from Greek mythology                |
| **Automatic Progression** | Working weights update session-to-session based on exercise difficulty and logged performance |
| **Body Measurements**     | Full measurement tracking, including golden-ratio comparisons                                 |
| **Muscle Heatmap**        | Interactive visualization of training volume by muscle group over time                        |
| **Offline Support**       | Fully functional without a network connection                                                 |

## Tech Stack

| Layer         | Choice                                                                       |
| ------------- | ---------------------------------------------------------------------------- |
| Framework     | Flutter (Dart)                                                               |
| Local Storage | Hive                                                                         |
| Architecture  | Clean Architecture — UI, domain, and data layers separated                   |
| Animation     | Flutter's animation controllers, used for transitions between workout states |

## Installation (Android)

1. Go to the [Releases page](https://github.com/gonz-tyler/burnout/releases).
2. Download the latest `app-release-vX.X.X.apk`.
3. Open the file on your Android device (you may need to enable "Install from unknown sources").

## Local Development

```bash
git clone https://github.com/gonz-tyler/burnout.git
cd burnout
flutter pub get
flutter run
```

Requires the Flutter SDK. See the [official install guide](https://flutter.dev/docs/get-started/install) if you don't have it set up.

## Roadmap

| Version | Status  | Scope                                                     |
| ------- | ------- | --------------------------------------------------------- |
| v0.1    | Shipped | Core workout tracking, initial theme implementation       |
| v0.2.2  | Shipped | APK release, performance optimizations                    |
| v0.3    | Planned | Full localization, gender support, complete exercise list |
| v0.4    | Planned | Custom illustration for all exercises and medals          |
| v1.0    | Planned | iOS App Store & Google Play release                       |

## Contact

Built by [gonz-tyler](https://gonztyler.com) — portfolio at [gonztyler.com](https://gonztyler.com).

Bug reports and feature requests: open an issue on this repo.
