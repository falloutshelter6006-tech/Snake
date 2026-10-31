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
