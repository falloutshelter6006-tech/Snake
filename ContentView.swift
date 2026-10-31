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
