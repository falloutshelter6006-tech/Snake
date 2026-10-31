import SwiftUI

struct Point: Equatable, Hashable { var x: Int; var y: Int }
enum Dir { case up, down, left, right
    var opposite: Dir { switch self { case .up: return .down; case .down: return .up; case .left: return .right; case .right: return .left } }
}

final class GameModel: ObservableObject {
    let cols = 16
    let rows = 20
    @Published var snake: [Point] = []
    @Published var food = Point(x: 0, y: 0)
    @Published var score = 0
    @Published var best = UserDefaults.standard.integer(forKey: "best")
    @Published var isOver = false
    @Published var started = false

    private var dir: Dir = .right
    private var nextDir: Dir = .right
    private var timer: Timer?
    private var interval: TimeInterval = 0.18

    init() { reset() }

    func reset() {
        snake = [Point(x: 5, y: 10), Point(x: 4, y: 10), Point(x: 3, y: 10)]
        dir = .right; nextDir = .right
        score = 0; isOver = false; interval = 0.18
        placeFood()
    }

    func start() {
        reset(); started = true
        schedule()
    }

    private func schedule() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in self?.tick() }
    }

    func turn(_ d: Dir) { if d != dir.opposite { nextDir = d } }

    private func placeFood() {
        var p: Point
        repeat { p = Point(x: .random(in: 0..<cols), y: .random(in: 0..<rows)) } while snake.contains(p)
        food = p
    }

    private func tick() {
        dir = nextDir
        var head = snake[0]
        switch dir {
        case .up: head.y -= 1
        case .down: head.y += 1
        case .left: head.x -= 1
        case .right: head.x += 1
        }
        // Nokia style: walls are deadly
        if head.x < 0 || head.y < 0 || head.x >= cols || head.y >= rows || snake.contains(head) {
            gameOver(); return
        }
        snake.insert(head, at: 0)
        if head == food {
            score += 10
            if interval > 0.07 { interval -= 0.005; schedule() }
            placeFood()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            snake.removeLast()
        }
    }

    private func gameOver() {
        timer?.invalidate()
        isOver = true
        if score > best { best = score; UserDefaults.standard.set(best, forKey: "best") }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
