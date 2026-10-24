import SwiftUI

/// 全局左上角帧率显示（所有界面共用）
final class FPSMonitor: ObservableObject {
    @Published var fps: Int = 60
    private var timer: Timer?
    private var last = Date()
    private var frames = 0

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.fps = Int(Double(self.frames) / 0.5)
            self.frames = 0
        }
        // 用 CADisplayLink 类似机制统计更精确
        let display = DisplayLinkProxy { [weak self] in
            self?.frames += 1
        }
        display.start()
        self.proxy = display
    }
    private var proxy: DisplayLinkProxy?

    deinit { timer?.invalidate() }
}

/// CVDisplayLink 包装，统计真实刷新帧数
final class DisplayLinkProxy {
    private var link: CVDisplayLink?
    private let tick: () -> Void
    init(_ tick: @escaping () -> Void) { self.tick = tick }
    func start() {
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let link else { return }
        CVDisplayLinkSetOutputCallback(link, { _, _, _, _, _, ctx in
            let p = Unmanaged<DisplayLinkProxy>.fromOpaque(ctx!).takeUnretainedValue()
            DispatchQueue.main.async { p.tick() }
            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkStart(link)
    }
}

struct FPSOverlay: View {
    @ObservedObject var monitor: FPSMonitor
    var body: some View {
        Text("FPS: \(monitor.fps)")
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundStyle(Color(red: 0.55, green: 0.9, blue: 0.95))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.35))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(red: 0.3, green: 0.7, blue: 0.75).opacity(0.4), lineWidth: 0.5)
            )
            .padding(10)
    }
}