# Змейка (iOS, SwiftUI)

Готовый Xcode-проект. Минимум iOS 16, зависимостей нет, ассеты не нужны.

## Сборка и подпись

1. Откройте `SnakeGame.xcodeproj` в Xcode 16+.
2. Выберите таргет **SnakeGame** → вкладка **Signing & Capabilities**:
   - Team: ваш сертификат разработчика;
   - Bundle Identifier: поменяйте `com.example.snakegame` на свой (например `com.вашеимя.snakegame`).
3. Подключите iPhone, выберите его в схеме и нажмите Run (⌘R) — для проверки на устройстве.
4. Для ipa: **Product → Archive** → **Distribute App** → **Ad Hoc** (или **Development**) → выберите сертификат → Export. Получите `SnakeGame.ipa`, подпишите/установите как обычно.

## Управление

- Свайпы в любую сторону или D-pad на экране.
- Кнопка «Старт» / «Пауза» / «Продолжить», «Сброс» — начать заново.
- Каждые 50 очков уровень растёт, змейка ускоряется.
- Рекорд сохраняется на устройстве.

## Структура

- `SnakeGame/SnakeGameApp.swift` — точка входа.
- `SnakeGame/ContentView.swift` — экран, свайпы, оверлеи.
- `SnakeGame/Game/GameModel.swift` — модель (сетка, направления, состояния).
- `SnakeGame/Game/SnakeViewModel.swift` — вся логика и таймер.
- `SnakeGame/Game/BoardView.swift` — отрисовка поля.
- `SnakeGame/Game/ControlsView.swift` — кнопки и D-pad.
