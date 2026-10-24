import SwiftUI

struct LobbyView: View {
    let fps: FPSMonitor
    @Binding var route: Route
    @State private var showSettings = false

    var body: some View {
        ZStack {
            LineBackdrop()
            FPSOverlay(monitor: fps).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            VStack(spacing: 8) {
                Spacer()
                Text("靶场工坊")
                    .font(.system(size: 64, weight: .light, design: .monospaced))
                    .foregroundStyle(Color(red: 0.55, green: 0.9, blue: 0.95))
                    .shadow(color: Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.5), radius: 12)
                Text("武器改装与实弹测试终端")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.gray)
                Spacer().frame(height: 50)
                VStack(spacing: 14) {
                    MilitaryButton(title: "进入改枪台") { route = .workshop }
                    MilitaryButton(title: "设置") { showSettings = true }
                }
                Spacer()
                Spacer()
            }
            if showSettings {
                SettingsPanel(show: $showSettings)
            }
        }
    }
}

enum Route { case lobby, workshop, range }

struct MilitaryButton: View {
    let title: String
    var width: CGFloat = 280
    let action: () -> Void
    @State private var hover = false
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundStyle(hover ? Color(red: 0.55, green: 0.9, blue: 0.95) : Color(red: 0.7, green: 0.75, blue: 0.8))
                .frame(width: width, height: 44)
                .background(Color(red: 0.06, green: 0.08, blue: 0.09))
                .overlay(
                    CutCornerShape(cut: 10)
                        .stroke(hover ? Color(red: 0.55, green: 0.9, blue: 0.95) : Color(red: 0.3, green: 0.38, blue: 0.42), lineWidth: 1)
                )
                .clipShape(CutCornerShape(cut: 10))
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
    }
}

struct CutCornerShape: Shape {
    let cut: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
        p.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
        p.closeSubpath()
        return p
    }
}

struct SettingsPanel: View {
    @Binding var show: Bool
    @State private var scale: Double = 1.0
    @State private var sound = true
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("设置").font(.system(size: 18, design: .monospaced)).foregroundStyle(.white)
                HStack { Text("界面缩放").foregroundStyle(.gray); Slider(value: $scale, in: 0.8...1.2) }
                HStack { Text("音效开关").foregroundStyle(.gray); Toggle("", isOn: $sound) }
                MilitaryButton(title: "关闭", width: 160) { show = false }
            }
            .padding(28)
            .frame(width: 360)
            .background(Color(red: 0.06, green: 0.08, blue: 0.09))
            .overlay(CutCornerShape(cut: 12).stroke(Color(red: 0.3, green: 0.38, blue: 0.42), lineWidth: 1))
            .clipShape(CutCornerShape(cut: 12))
        }
    }
}