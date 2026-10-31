import Foundation

struct GridPoint: Hashable {
    let x: Int
    let y: Int
}

enum Direction {
    case up, down, left, right

    var dx: Int {
        switch self {
        case .up, .down: return 0
        case .left: return -1
        case .right: return 1
        }
    }

    var dy: Int {
        switch self {
        case .up: return -1
        case .down: return 1
        case .left, .right: return 0
        }
    }

    func isOpposite(to other: Direction) -> Bool {
        dx + other.dx == 0 && dy + other.dy == 0
    }
}

enum GameState {
    case ready, playing, paused, gameOver
}

import Foundation

final class SnakeViewModel: ObservableObject {

    static let columns = 15
    static let rows = 22

    @Published private(set) var snake: [GridPoint] = []
    @Published private(set) var food = GridPoint(x: 0, y: 0)
    @Published private(set) var score = 0
    @Published private(set) var bestScore = 0
    @Published private(set) var level = 1
    @Published private(set) var state: GameState = .ready

    private var direction: Direction = .right
    private var pendingDirection: Direction = .right
    private var timer: Timer?

    private let bestScoreKey = "snake.bestScore"

    init() {
        bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
        reset()
    }

    /// Интервал тика; ускоряется с ростом уровня.
    var tickInterval: TimeInterval {
        max(0.07, 0.28 - Double(level - 1) * 0.025)
    }

    // MARK: - Управление

    func start() {
        reset()
        state = .playing
        scheduleTimer()
    }

    func togglePause() {
        switch state {
        case .playing:
            state = .paused
            timer?.invalidate()
            timer = nil
        case .paused:
            state = .playing
            scheduleTimer()
        case .ready, .gameOver:
            break
        }
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        score = 0
        level = 1
        direction = .right
        pendingDirection = .right
        let cx = Self.columns / 2
        let cy = Self.rows / 2
        snake = [
            GridPoint(x: cx, y: cy),
            GridPoint(x: cx - 1, y: cy),
            GridPoint(x: cx - 2, y: cy)
        ]
        spawnFood()
        state = .ready
    }

    func changeDirection(_ newDirection: Direction) {
        guard state == .playing || state == .paused else { return }
        guard !newDirection.isOpposite(to: direction),
              newDirection != pendingDirection else { return }
        pendingDirection = newDirection
    }

    // MARK: - Игровой цикл

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard state == .playing else { return }
        direction = pendingDirection

        let head = snake[0]
        let newHead = GridPoint(x: head.x + direction.dx, y: head.y + direction.dy)

        let hitsWall = newHead.x < 0 || newHead.x >= Self.columns
            || newHead.y < 0 || newHead.y >= Self.rows
        if hitsWall {
            finishGame()
            return
        }

        let willEat = newHead == food
        // Если едим — хвост не двигается, значит его клетка занята.
        let body = willEat ? snake : Array(snake.dropLast())
        if body.contains(newHead) {
            finishGame()
            return
        }

        snake.insert(newHead, at: 0)

        if willEat {
            score += 10
            let newLevel = score / 50 + 1
            if score > bestScore {
                bestScore = score
                UserDefaults.standard.set(bestScore, forKey: bestScoreKey)
            }
            spawnFood()
            if newLevel != level {
                level = newLevel
                scheduleTimer()
            }
        } else {
            snake.removeLast()
        }
    }

    private func finishGame() {
        state = .gameOver
        timer?.invalidate()
        timer = nil
    }

    private func spawnFood() {
        var freeCells: Set<GridPoint> = []
        for x in 0..<Self.columns {
            for y in 0..<Self.rows {
                let point = GridPoint(x: x, y: y)
                if !snake.contains(point) {
                    freeCells.insert(point)
                }
            }
        }
        food = freeCells.randomElement() ?? GridPoint(x: 0, y: 0)
    }
}

import SwiftUI

struct BoardView: View {
    @ObservedObject var vm: SnakeViewModel

    private let cols = SnakeViewModel.columns
    private let rows = SnakeViewModel.rows

    var body: some View {
        GeometryReader { geo in
            let cell = min(geo.size.width / CGFloat(cols), geo.size.height / CGFloat(rows))
            let boardW = cell * CGFloat(cols)
            let boardH = cell * CGFloat(rows)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))

                grid(cell: cell)
                    .frame(width: boardW, height: boardH)

                Circle()
                    .fill(Color.red)
                    .frame(width: cell * 0.62, height: cell * 0.62)
                    .position(x: (CGFloat(vm.food.x) + 0.5) * cell,
                              y: (CGFloat(vm.food.y) + 0.5) * cell)

                ForEach(Array(vm.snake.enumerated()), id: \.offset) { index, point in
                    RoundedRectangle(cornerRadius: cell * 0.28)
                        .fill(index == 0 ? Color.green : Color.green.opacity(0.72))
                        .frame(width: cell * 0.92, height: cell * 0.92)
                        .position(x: (CGFloat(point.x) + 0.5) * cell,
                                  y: (CGFloat(point.y) + 0.5) * cell)
                }
            }
            .frame(width: boardW, height: boardH)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }

    private func grid(cell: CGFloat) -> some View {
        Path { path in
            for x in 1..<cols {
                let px = CGFloat(x) * cell
                path.move(to: CGPoint(x: px, y: 0))
                path.addLine(to: CGPoint(x: px, y: CGFloat(rows) * cell))
            }
            for y in 1..<rows {
                let py = CGFloat(y) * cell
                path.move(to: CGPoint(x: 0, y: py))
                path.addLine(to: CGPoint(x: CGFloat(cols) * cell, y: py))
            }
        }
        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
    }
}

import SwiftUI

struct ControlsView: View {
    @ObservedObject var vm: SnakeViewModel

    var body: some View {
        HStack(spacing: 28) {
            VStack(spacing: 12) {
                Button(action: toggle) {
                    Label(mainButtonTitle, systemImage: mainButtonIcon)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button(action: { vm.reset() }) {
                    Label("Сброс", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                .disabled(vm.state == .ready)
            }

            DPad { direction in
                vm.changeDirection(direction)
            }
        }
        .padding(.bottom, 8)
    }

    private var mainButtonTitle: String {
        switch vm.state {
        case .ready, .gameOver: return "Старт"
        case .playing: return "Пауза"
        case .paused: return "Продолжить"
        }
    }

    private var mainButtonIcon: String {
        switch vm.state {
        case .ready, .gameOver: return "play.fill"
        case .playing: return "pause.fill"
        case .paused: return "play.fill"
        }
    }

    private func toggle() {
        switch vm.state {
        case .ready, .gameOver: vm.start()
        case .playing, .paused: vm.togglePause()
        }
    }
}

struct DPad: View {
    let onDirection: (Direction) -> Void

    var body: some View {
        Grid {
            GridRow {
                Color.clear.frame(width: 44, height: 44)
                padButton(systemName: "chevron.up") { onDirection(.up) }
                Color.clear.frame(width: 44, height: 44)
            }
            GridRow {
                padButton(systemName: "chevron.left") { onDirection(.left) }
                Color.clear.frame(width: 44, height: 44)
                padButton(systemName: "chevron.right") { onDirection(.right) }
            }
            GridRow {
                Color.clear.frame(width: 44, height: 44)
                padButton(systemName: "chevron.down") { onDirection(.down) }
                Color.clear.frame(width: 44, height: 44)
            }
        }
    }

    private func padButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3.bold())
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = SnakeViewModel()

    private let boardAspect = CGFloat(SnakeViewModel.columns) / CGFloat(SnakeViewModel.rows)

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 14) {
                header
                board
                ControlsView(vm: vm)
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
        }
        .contentShape(Rectangle())
        .gesture(swipeGesture)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("ЗМЕЙКА")
                .font(.title.bold())
                .tracking(4)
            HStack(spacing: 12) {
                ScoreChip(title: "Счёт", value: vm.score)
                ScoreChip(title: "Рекорд", value: vm.bestScore)
                ScoreChip(title: "Уровень", value: vm.level)
            }
        }
    }

    private var board: some View {
        BoardView(vm: vm)
            .aspectRatio(boardAspect, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                if vm.state == .ready {
                    Text("Свайп или кнопка «Старт»")
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .overlay {
                if vm.state == .gameOver {
                    GameOverOverlay(score: vm.score, best: vm.bestScore) {
                        vm.start()
                    }
                }
            }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onEnded { value in
                if vm.state == .ready { vm.start() }
                let dx = value.translation.width
                let dy = value.translation.height
                if abs(dx) > abs(dy) {
                    vm.changeDirection(dx > 0 ? .right : .left)
                } else {
                    vm.changeDirection(dy > 0 ? .down : .up)
                }
            }
    }
}

struct ScoreChip: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.headline.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct GameOverOverlay: View {
    let score: Int
    let best: Int
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Игра окончена")
                .font(.title2.bold())
            Text("Счёт: \(score)  •  Рекорд: \(best)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Заново", action: onRestart)
                .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 10)
    }
}

import SwiftUI

@main
struct SnakeGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
