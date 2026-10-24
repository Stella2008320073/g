import SwiftUI

struct LineBackdrop: View {
    @State private var phase: Double = 0
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { ctx in
            Canvas { c, size in
                let t = ctx.date.timeIntervalSinceReferenceDate
                // 透视网格
                c.stroke(Path { p in
                    let cx = size.width * 0.5, horizon = size.height * 0.32
                    for i in 0...14 {
                        let x = CGFloat(i) / 14.0
                        p.move(to: CGPoint(x: size.width * x, y: size.height))
                        p.addLine(to: CGPoint(x: cx + (size.width * x - cx) * 0.18, y: horizon))
                    }
                    for i in 0...10 {
                        let y = horizon + (size.height - horizon) * CGFloat(i) / 10.0
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                    }
                }, with: .color(Color(red: 0.25, green: 0.55, blue: 0.6).opacity(0.10)), lineWidth: 0.6)

                // 流动数据线
                for i in 0..<4 {
                    var p = Path()
                    let y = size.height * (0.18 + 0.18 * Double(i))
                    p.move(to: CGPoint(x: 0, y: y))
                    let x = (sin(t * 0.15 + Double(i)) * 0.5 + 0.5) * size.width
                    p.addLine(to: CGPoint(x: x, y: y))
                    p.addLine(to: CGPoint(x: x + 40, y: y - 18))
                    c.stroke(p, with: .color(Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.18)), lineWidth: 0.7)
                    c.fill(Path(ellipseIn: CGRect(x: x + 38, y: y - 20, width: 4, height: 4)), with: .color(Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.5)))
                }

                // 扫描线
                let scanY = fmod(t * 40, size.height)
                c.fill(Path(CGRect(x: 0, y: scanY, width: size.width, height: 1)), with: .color(Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.08)))
            }
        }
        .background(Color(red: 0.03, green: 0.045, blue: 0.055))
        .ignoresSafeArea()
    }
}