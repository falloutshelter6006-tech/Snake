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
