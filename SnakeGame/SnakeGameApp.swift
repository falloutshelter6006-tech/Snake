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

    var tickInterval: TimeInterval {
        max(0.07, 0.28 - Double(level - 1) * 0.025)
    }

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
            .position(x: geo.size.width / 2, y: geo
