# Змейка (iOS, SwiftUI)

Готовая змейка на SwiftUI. Минимум iOS 16, зависимостей нет.

## Как получить IPA без мака и Xcode

1. Создайте **приватный** репозиторий на GitHub и залейте туда **все файлы из этого архива**
   (включая скрытую папку `.github/` — на macOS в Finder включите показ скрытых файлов: Cmd+Shift+.).
   Xcode-проекта в архиве нет — это нормально, он генерируется на CI.
2. Вкладка **Actions** → «Build SnakeGame IPA (unsigned)» → **Run workflow**.
3. Через 5–10 минут скачайте артефакт **SnakeGame-unsigned** — неподписанный IPA.
4. Подпишите в Esign на телефоне своим сертификатом.

## Управление

Свайпы или экранный D-pad. Кнопка «Старт»/«Пауза»/«Продолжить», «Сброс».
Каждые 50 очков уровень растёт, змейка ускоряется. Рекорд сохраняется на устройстве.

## Структура

- `project.yml` — описание проекта для XcodeGen (генерирует .xcodeproj на CI).
- `SnakeGame/SnakeGameApp.swift` — точка входа.
- `SnakeGame/ContentView.swift` — экран, свайпы, оверлеи.
- `SnakeGame/Game/GameModel.swift` — модель (сетка, направления, состояния).
- `SnakeGame/Game/SnakeViewModel.swift` — вся логика и таймер.
- `SnakeGame/Game/BoardView.swift` — отрисовка поля.
- `SnakeGame/Game/ControlsView.swift` — кнопки и D-pad.
- `.github/workflows/build.yml` — сборка на macOS-раннере GitHub.
