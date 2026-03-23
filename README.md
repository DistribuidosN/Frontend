<p align="center">
  <img src="./assets/banner.svg" alt="ImageFlow Frontend banner showing a premium distributed image operations dashboard" width="100%">
</p>

<p align="center">
  <img alt="Flutter frontend" src="https://img.shields.io/badge/Flutter-Frontend-02569B?style=for-the-badge&logo=flutter&logoColor=white">
  <img alt="Dart 3.9 plus" src="https://img.shields.io/badge/Dart-3.9%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white">
  <img alt="Material 3 responsive UI" src="https://img.shields.io/badge/Material%203-Responsive%20UI-1F2937?style=for-the-badge&logo=materialdesign&logoColor=white">
  <img alt="Current state mock data" src="https://img.shields.io/badge/State-Mock%20Data-FACC15?style=for-the-badge&labelColor=111827&color=FACC15">
</p>

<h1 align="center">ImageFlow Frontend</h1>

<p align="center">
  A premium Flutter control surface for distributed image-processing operations.
</p>

<p align="center">
  The repository currently ships a polished frontend prototype for authentication, upload, task configuration, progress tracking, results review and cluster observability.
</p>

<p align="center">
  <a href="#overview">Overview</a> |
  <a href="#demo">Demo</a> |
  <a href="#tech-stack">Tech Stack</a> |
  <a href="#architecture">Architecture</a> |
  <a href="#getting-started">Getting Started</a> |
  <a href="#roadmap">Roadmap</a>
</p>

<p align="center">
  <img src="./assets/separator.svg" alt="Decorative separator" width="100%">
</p>

## Overview

`ImageFlow Frontend` lives in `flutter_app/` and models the operator-facing experience of a distributed image pipeline. The app is structured around the workflow an operations team would actually use: sign in, upload a batch, configure transformations, monitor execution, inspect results and review historical or system-level activity.

> Current state: this repository is a frontend prototype. The UI is powered by local state, mock datasets and simulated progress. Real authentication, file upload, persistence and backend APIs are not connected yet.

## Demo

<p align="center">
  <img src="./assets/demo-placeholder.svg" alt="Placeholder preview for the ImageFlow Frontend interface" width="100%">
</p>

No screenshots are committed yet. Replace the placeholder above with a real dashboard, upload flow or results capture once you want to showcase the live interface.

## Table of Contents

- [Why It Matters](#why-it-matters)
- [Core Views](#core-views)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Useful Commands](#useful-commands)
- [App Flow](#app-flow)
- [Current Limitations](#current-limitations)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [FAQ](#faq)
- [License](#license)
- [Maintainer](#maintainer)

## Why It Matters

- It validates the full operator journey for a distributed image-processing product before backend wiring is finished.
- It establishes a strong visual system with responsive layouts, editorial typography and reusable dashboard primitives.
- It gives the project a feature-based Flutter foundation that can later be connected to real services without rewriting the UI from scratch.

## Core Views

- `Auth`: login, registration and multi-step password reset screens.
- `Dashboard`: throughput, queue pressure, recent batches and node health summaries.
- `Upload`: batch intake surface with simulated file cards and size totals.
- `Task Builder`: transformation controls, output settings and live preview states.
- `Progress`: job-level processing status with simulated completion across worker nodes.
- `Results`: success metrics, before and after comparison, asset grid and download actions.
- `History`: request listing with filters, status chips and quick drill-down access.
- `Request Detail`: per-request metrics, transformation values, image details and logs.
- `Worker Nodes`: cluster monitoring, load distribution and heartbeat visibility.
- `Logs`: operational event stream with severity and source labels.
- `Settings`: profile, password, notification and API access surfaces.

## Tech Stack

<p align="center">
  <img src="./assets/stack.svg" alt="ImageFlow Frontend technology stack overview" width="100%">
</p>

- `Flutter` for the cross-platform application shell.
- `Dart` for UI logic, state transitions and feature modules.
- `Material 3` as the component baseline, customized through a project-specific theme.
- `google_fonts` for the `Fraunces` plus `Manrope` typography pairing.
- Feature-first folders with `presentation`, `domain` and `data` slices where appropriate.
- Mock data sources for dashboard, history, nodes, request detail, results and logs.

## Architecture

<p align="center">
  <img src="./assets/architecture.svg" alt="Architecture diagram for the ImageFlow Frontend Flutter app" width="100%">
</p>

- `lib/main.dart` boots the app and hands control to `ImageFlowApp`.
- `lib/features/shell/presentation/shell.dart` owns auth gating, navigation state and the responsive workspace shell.
- `lib/core/theme/app_theme.dart` defines the visual language, colors, typography and component theming.
- `lib/shared/widgets/shared_widgets.dart` contains reusable UI primitives such as panels, metric cards, pills and grid helpers.
- Feature modules under `lib/features/` keep screens close to their supporting models and mock datasets.
- The current data layer is local-only. Pages read mock models and simulated timers instead of network responses.

## Project Structure

```text
Frontend/
|-- assets/                      # README visuals
`-- flutter_app/
    |-- lib/
    |   |-- app.dart
    |   |-- main.dart
    |   |-- core/
    |   |   `-- theme/
    |   |-- shared/
    |   |   `-- widgets/
    |   `-- features/
    |       |-- auth/
    |       |-- dashboard/
    |       |-- history/
    |       |-- logs/
    |       |-- nodes/
    |       |-- progress/
    |       |-- request_detail/
    |       |-- results/
    |       |-- settings/
    |       |-- shell/
    |       |-- task_builder/
    |       `-- upload/
    |-- android/
    |-- ios/
    |-- linux/
    |-- macos/
    |-- web/
    `-- windows/
```

## Getting Started

### Prerequisites

- A working Flutter SDK installation.
- A target device, emulator or browser.
- `flutter doctor` passing for the platform you want to run.

### Install and run

```bash
cd flutter_app
flutter pub get
flutter run -d chrome
```

If you prefer desktop on Windows:

```bash
cd flutter_app
flutter run -d windows
```

## Environment Variables

No environment variables are required for the current mock-driven build.

## Useful Commands

- `flutter pub get` installs dependencies.
- `flutter run` launches the app on the default target.
- `flutter analyze` runs static analysis.
- `flutter test` is available, but there are currently no project-specific automated tests in `test/`.
- `flutter build web` creates a web build.
- `flutter build windows` creates a Windows desktop build.

## App Flow

1. Sign in through the branded auth surface.
2. Move into the workspace shell and review cluster health from the dashboard.
3. Upload a sample batch and continue into the task builder.
4. Configure transforms such as brightness, contrast, blur, rotation and output format.
5. Start processing and watch simulated progress advance across worker nodes.
6. Review output metrics, results and operational history.

## Current Limitations

- Upload interactions are simulated and do not use a real file picker or storage backend.
- Authentication is local UI state only.
- Progress, logs, history, node health and results are all mock-driven.
- Navigation is handled inside the shell state rather than a dedicated routing package.
- The repository does not currently include a CI pipeline definition or a license file.

## Roadmap

- Connect the UI to real authentication, upload and job-processing APIs.
- Replace mock datasets with repository or service abstractions.
- Add persistent state, richer error handling and real request retries.
- Introduce widget and integration tests for the main user journeys.
- Add actual screenshots or GIF demos to replace the placeholder artwork.
- Package the web build or desktop target for easier stakeholder review.

## Contributing

- Keep new work aligned with the existing feature-first folder structure.
- Reuse `core/theme` and `shared/widgets` before introducing one-off styles.
- If you change a mock workflow, update the related `data` and `domain` files together.
- Run `flutter analyze` before opening a pull request.

## FAQ

**Is the app connected to a backend already?**

No. The current implementation is a frontend prototype with local state and mock datasets.

**Does the upload screen handle real files?**

Not yet. The upload experience is simulated to validate layout and interactions.

**Which platforms are supported?**

The Flutter project includes Android, iOS, web, Windows, Linux and macOS scaffolding. Use the targets that match your local Flutter setup.

## License

This repository does not currently include a license file. Add one before publishing the project publicly or accepting outside contributions.

## Maintainer

- Owner: `[ADD OWNER OR TEAM]`
- Contact: `[ADD EMAIL OR PROJECT URL]`
- Demo URL: `[ADD DEPLOYED WEB OR DESKTOP DEMO LINK]`
