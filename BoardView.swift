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
