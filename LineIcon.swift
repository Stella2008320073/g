import SwiftUI

enum LineIconKind { case gun, launcher, blade }

struct LineIcon: View {
    let kind: LineIconKind
    var color: Color = Color(red: 0.55, green: 0.9, blue: 0.95)
    var body: some View {
        Canvas { ctx, size in
            var path = Path()
            let w = size.width, h = size.height
            let p = CGPoint(x: w / 2, y: h / 2)
            switch kind {
            case .gun:
                path.move(to: CGPoint(x: w * 0.08, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.45))
                path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.52, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.48, y: h * 0.8))
                path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.8))
                path.addLine(to: CGPoint(x: w * 0.38, y: h * 0.62))
                path.addLine(to: CGPoint(x: w * 0.16, y: h * 0.6))
                path.closeSubpath()
                path.move(to: CGPoint(x: w * 0.5, y: h * 0.45))
                path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.3))
                path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.3))
            case .launcher:
                path.move(to: CGPoint(x: w * 0.1, y: h * 0.58))
                path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.42))
                path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.58))
                path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.68))
                path.closeSubpath()
                path.move(to: CGPoint(x: w * 0.38, y: h * 0.66))
                path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.82))
            case .blade:
                path.move(to: CGPoint(x: w * 0.1, y: h * 0.7))
                path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.2))
                path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.28))
                path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.78))
                path.closeSubpath()
                path.move(to: CGPoint(x: w * 0.1, y: h * 0.7))
                path.addLine(to: CGPoint(x: w * 0.05, y: h * 0.82))
                path.move(to: CGPoint(x: w * 0.2, y: h * 0.6))
                path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.8))
            }
            ctx.stroke(path, with: .color(color), lineWidth: 1.2)
        }
        .frame(width: 26, height: 18)
    }
}

/// 属性条
struct StatBar: View {
    let key: StatKey
    let value: Double
    let delta: Double
    var body: some View {
        HStack(spacing: 6) {
            Text(key.rawValue).font(.system(size: 10, design: .monospaced)).foregroundStyle(.gray).frame(width: 72, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 4)
                    Capsule().fill(Color(red: 0.4, green: 0.85, blue: 0.9)).frame(width: geo.size.width * CGFloat(min(100, max(0, value)) / 100), height: 4)
                }.frame(maxHeight: .infinity, alignment: .center)
            }.frame(height: 14)
            if delta != 0 {
                Text(delta > 0 ? "+\(Int(delta))" : "\(Int(delta))")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(delta > 0 ? Color.green : Color.red)
                    .frame(width: 30, alignment: .trailing)
            } else {
                Spacer().frame(width: 30)
            }
        }
    }
}