import SwiftUI

// Nokia 3310 LCD palette
let lcdBg = Color(red: 0.62, green: 0.74, blue: 0.40)
let lcdInk = Color(red: 0.10, green: 0.14, blue: 0.08)

struct ContentView: View {
    @StateObject private var game = GameModel()

    var body: some View {
        ZStack {
            Color(red: 0.25, green: 0.28, blue: 0.30).ignoresSafeArea()
            VStack(spacing: 12) {
                HStack {
                    Text("SCORE \(game.score)")
                    Spacer()
                    Text("BEST \(game.best)")
                }
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(lcdInk)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(lcdBg)

                GeometryReader { geo in
                    let cell = min(geo.size.width / CGFloat(game.cols), geo.size.height / CGFloat(game.rows))
                    let w = cell * CGFloat(game.cols), h = cell * CGFloat(game.rows)
                    ZStack(alignment: .topLeading) {
                        Rectangle().fill(lcdBg)
                        Rectangle().stroke(lcdInk, lineWidth: 3)
                        ForEach(Array(game.snake.enumerated()), id: \.offset) { _, p in
                            Rectangle().fill(lcdInk)
                                .frame(width: cell - 1, height: cell - 1)
                                .offset(x: CGFloat(p.x) * cell, y: CGFloat(p.y) * cell)
                        }
                        Rectangle().fill(lcdInk)
                            .frame(width: cell - 4, height: cell - 4)
                            .rotationEffect(.degrees(45))
                            .offset(x: CGFloat(game.food.x) * cell + 2, y: CGFloat(game.food.y) * cell + 2)

                        if !game.started || game.isOver {
                            VStack(spacing: 8) {
                                Text(game.isOver ? "GAME OVER" : "SNAKE II")
                                    .font(.system(size: 26, weight: .black, design: .monospaced))
                                Text("TAP TO PLAY")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(lcdInk)
                            .frame(width: w, height: h)
                            .background(lcdBg.opacity(0.85))
                        }
                    }
                    .frame(width: w, height: h)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { if !game.started || game.isOver { game.start() } }
                    .gesture(DragGesture(minimumDistance: 12).onEnded { v in
                        let dx = v.translation.width, dy = v.translation.height
                        if abs(dx) > abs(dy) { game.turn(dx > 0 ? .right : .left) }
                        else { game.turn(dy > 0 ? .down : .up) }
                    })
                }
                Text("SWIPE TO TURN")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(14)
        }
    }
}
