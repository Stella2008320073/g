import SwiftUI

struct RangeView: View {
    let fps: FPSMonitor
    @Binding var route: Route
    @ObservedObject var store: LoadoutStore
    let weapons: [Weapon]
    let attachments: [Attachment]

    @State private var ammo: Int = 0
    @State private var reloading = false
    @State private var reloadProgress: Double = 0
    @State private var reloadDuration: Double = 0
    @State private var recoil: CGFloat = 0
    @State private var crosshairSpread: CGFloat = 0
    @State private var hitMarks: [CGPoint] = []
    @State private var lastShotTime = Date.distantPast
    @State private var boltLock = false
    @State private var escCount = 0
    @State private var escTimer: Date? = nil
    @State private var toast: String? = nil

    var weapon: Weapon { weapons.first(where: { $0.id == store.selectedWeaponID }) ?? weapons.first! }
    var currentFireMode: FireMode { store.fireModes[weapon.id] ?? weapon.defaultFireMode }
    var magazine: Int { store.magCapacity(for: weapon, all: attachments) }

    var body: some View {
        ZStack {
            // 背景射击场
            RangeBackdrop(weapon: weapon)

            // 人形假人靶
            HumanTarget(hits: hitMarks)
                .frame(width: 150, height: 360)
                .offset(y: -10)

            // 准星
            Crosshair(spread: crosshairSpread)

            // 第一人称手持武器
            FirstPersonWeapon(weapon: weapon, recoil: recoil)
                .frame(width: 500, height: 320)
                .offset(x: 40, y: 180 + recoil * 30)

            // HUD
            VStack {
                HStack {
                    FPSOverlay(monitor: fps)
                    Spacer()
                    hudInfo
                }.padding()
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 10) {
                        if reloading {
                            reloadHUD
                        }
                        MilitaryButton(title: "退出靶场（双击 ESC）", width: 220) {
                            exitRange()
                        }
                    }.padding(20)
                }
            }

            if let toast {
                VStack { Spacer(); Text(toast).font(.system(size: 12, design: .monospaced))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.black.opacity(0.75))
                    .foregroundStyle(Color(red: 0.55, green: 0.9, blue: 0.95))
                    .clipShape(Capsule()).padding(.bottom, 40) }
            }
        }
        .onAppear {
            ammo = magazine
            reloadDuration = store.reloadTime(for: weapon, all: attachments)
        }
        .onExitCommand { handleEsc() }
        .focusable()
    }

    var hudInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("射击模式：\(currentFireMode.rawValue)").font(.system(size: 11, design: .monospaced)).foregroundStyle(Color(red: 0.55, green: 0.9, blue: 0.95))
            if weapon.category == .melee {
                Text("挥砍速度 \(Int(store.stats(for: weapon, all: attachments)[.swingSpeed] ?? 0))  攻击范围 \(Int(store.stats(for: weapon, all: attachments)[.attackRange] ?? 0))")
                    .font(.system(size: 10, design: .monospaced)).foregroundStyle(.gray)
            } else {
                Text("弹药 \(ammo) / \(magazine)").font(.system(size: 11, design: .monospaced)).foregroundStyle(.white)
                Text("准星扩散 \(Int(crosshairSpread * 10))").font(.system(size: 10, design: .monospaced)).foregroundStyle(.gray)
            }
            Text("命中 \(hitMarks.count)").font(.system(size: 10, design: .monospaced)).foregroundStyle(.gray)
        }
    }

    var reloadHUD: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(String(format: "换弹中 %.1f 秒", max(0, reloadDuration * (1 - reloadProgress))))
                .font(.system(size: 12, design: .monospaced)).foregroundStyle(Color(red: 0.9, green: 0.65, blue: 0.25))
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule().fill(Color(red: 0.9, green: 0.65, blue: 0.25)).frame(width: g.size.width * reloadProgress)
                }
            }.frame(width: 220, height: 5)
        }.padding(8).background(Color.black.opacity(0.5))
    }

    // MARK: 开火
    func fire() {
        guard !reloading else { return }
        if weapon.category == .melee {
            meleeSwing()
            return
        }
        let now = Date()
        let interval: TimeInterval = {
            switch currentFireMode {
            case .boltAction: return 0.9
            case .pumpAction: return 0.75
            case .semiAuto: return 0.15
            case .fullAuto: return 0.09
            case .burst: return 0.09
            case .single: return 0.5
            case .melee: return 0.4
            }
        }()
        guard now.timeIntervalSince(lastShotTime) >= interval else { return }
        guard ammo > 0 else { startReload(); return }
        lastShotTime = now
        ammo -= 1
        let recoilAmt = max(0.15, 1.0 - (store.stats(for: weapon, all: attachments)[.recoilControl] ?? 50) / 120.0)
        withAnimation(.easeOut(duration: 0.08)) {
            recoil = CGFloat(recoilAmt)
            crosshairSpread = min(crosshairSpread + 0.3, 3)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.25)) { recoil = 0 }
        }
        // 命中
        let spread = Double(crosshairSpread) * 6
        let dx = Double.random(in: -spread...spread)
        let dy = Double.random(in: -spread...spread)
        if abs(dx) < 40 && abs(dy) < 90 {
            hitMarks.append(CGPoint(x: dx, y: dy))
        }
        // 准星恢复
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.4)) { crosshairSpread = max(0, crosshairSpread - 0.2) }
        }
        if ammo == 0 {
            startReload()
        }
    }

    func meleeSwing() {
        let now = Date()
        guard now.timeIntervalSince(lastShotTime) >= 0.5 else { return }
        lastShotTime = now
        let spread = Double(max(8, 60 - (store.stats(for: weapon, all: attachments)[.attackRange] ?? 30)))
        let dx = Double.random(in: -spread...spread)
        let dy = Double.random(in: -spread * 1.5...spread * 1.5)
        if abs(dx) < 40 && abs(dy) < 100 {
            hitMarks.append(CGPoint(x: dx, y: dy))
        }
    }

    func startReload() {
        guard !reloading else { return }
        guard ammo < magazine else { return }
        reloading = true
        reloadDuration = store.reloadTime(for: weapon, all: attachments)
        reloadProgress = 0
        let duration = reloadDuration
        let start = Date()
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(start)
            reloadProgress = min(1, elapsed / duration)
            if elapsed >= duration {
                timer.invalidate()
                reloading = false
                ammo = magazine
                toast = "换弹完成"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { if toast == "换弹完成" { toast = nil } }
            }
        }
    }

    func handleEsc() {
        if let t = escTimer, Date().timeIntervalSince(t) < 1.2 {
            exitRange()
        } else {
            escTimer = Date()
            toast = "再次按下 ESC 退出靶场"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { if toast == "再次按下 ESC 退出靶场" { toast = nil } }
        }
    }

    func exitRange() {
        // 配置保持不变，直接返回改装台
        route = .workshop
    }
}

// MARK: 靶场背景
struct RangeBackdrop: View {
    let weapon: Weapon
    var body: some View {
        Canvas { c, size in
            // 靶场墙 + 透视
            c.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.05, green: 0.07, blue: 0.08)))
            var grid = Path()
            let horizon = size.height * 0.35
            for i in 0...16 {
                let x = size.width * CGFloat(i) / 16
                grid.move(to: CGPoint(x: x, y: size.height))
                grid.addLine(to: CGPoint(x: size.width / 2 + (x - size.width / 2) * 0.2, y: horizon))
            }
            for i in 0...8 {
                let y = horizon + (size.height - horizon) * CGFloat(i) / 8
                grid.move(to: CGPoint(x: 0, y: y)); grid.addLine(to: CGPoint(x: size.width, y: y))
            }
            c.stroke(grid, with: .color(Color(red: 0.3, green: 0.55, blue: 0.6).opacity(0.08)), lineWidth: 0.6)
            // 远处靶纸
            for i in 0..<4 {
                let x = size.width * (0.15 + 0.2 * CGFloat(i))
                let w = size.width * 0.06
                let rect = CGRect(x: x, y: horizon + 40, width: w, height: w * 1.4)
                c.stroke(Path(rect), with: .color(Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.25)), lineWidth: 0.8)
            }
        }.ignoresSafeArea()
    }
}

// MARK: 人形假人靶（写实灰色轮廓）
struct HumanTarget: View {
    let hits: [CGPoint]
    var body: some View {
        Canvas { c, size in
            let w = size.width, h = size.height
            var silhouette = Path()
            // 头
            silhouette.addEllipse(in: CGRect(x: w * 0.36, y: 0, width: w * 0.28, height: h * 0.14))
            // 颈
            silhouette.addRect(CGRect(x: w * 0.44, y: h * 0.13, width: w * 0.12, height: h * 0.04))
            // 躯干
            silhouette.move(to: CGPoint(x: w * 0.28, y: h * 0.18))
            silhouette.addLine(to: CGPoint(x: w * 0.72, y: h * 0.18))
            silhouette.addLine(to: CGPoint(x: w * 0.66, y: h * 0.55))
            silhouette.addLine(to: CGPoint(x: w * 0.34, y: h * 0.55))
            silhouette.closeSubpath()
            // 手臂
            silhouette.addRect(CGRect(x: w * 0.18, y: h * 0.2, width: w * 0.1, height: h * 0.32))
            silhouette.addRect(CGRect(x: w * 0.72, y: h * 0.2, width: w * 0.1, height: h * 0.32))
            // 腿
            silhouette.addRect(CGRect(x: w * 0.36, y: h * 0.55, width: w * 0.12, height: h * 0.42))
            silhouette.addRect(CGRect(x: w * 0.52, y: h * 0.55, width: w * 0.12, height: h * 0.42))
            c.fill(silhouette, with: .linearGradient(Gradient(colors: [Color(white: 0.38), Color(white: 0.18)]),
                                                     startPoint: .init(x: 0.5, y: 0), endPoint: .init(x: 0.5, y: 1)))
            c.stroke(silhouette, with: .color(Color(white: 0.55)), lineWidth: 1)
            // 分区线
            var zones = Path()
            zones.move(to: CGPoint(x: w * 0.3, y: h * 0.3)); zones.addLine(to: CGPoint(x: w * 0.7, y: h * 0.3))
            zones.move(to: CGPoint(x: w * 0.3, y: h * 0.42)); zones.addLine(to: CGPoint(x: w * 0.7, y: h * 0.42))
            c.stroke(zones, with: .color(Color(white: 0.5).opacity(0.4)), lineWidth: 0.5)
            // 命中点
            for m in hits {
                let pt = CGPoint(x: w * 0.5 + m.x, y: h * 0.45 + m.y)
                c.fill(Path(ellipseIn: CGRect(x: pt.x - 2, y: pt.y - 2, width: 4, height: 4)), with: .color(Color.red.opacity(0.9)))
            }
        }
    }
}

struct Crosshair: View {
    let spread: CGFloat
    var body: some View {
        Canvas { c, size in
            let cx = size.width / 2, cy = size.height / 2
            let r: CGFloat = 8 + spread * 4
            var p = Path()
            p.move(to: CGPoint(x: cx - r - 8, y: cy)); p.addLine(to: CGPoint(x: cx - r, y: cy))
            p.move(to: CGPoint(x: cx + r, y: cy)); p.addLine(to: CGPoint(x: cx + r + 8, y: cy))
            p.move(to: CGPoint(x: cx, y: cy - r - 8)); p.addLine(to: CGPoint(x: cx, y: cy - r))
            p.move(to: CGPoint(x: cx, y: cy + r)); p.addLine(to: CGPoint(x: cx, y: cy + r + 8))
            c.stroke(p, with: .color(Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.9)), lineWidth: 1.2)
            c.fill(Path(ellipseIn: CGRect(x: cx - 1.5, y: cy - 1.5, width: 3, height: 3)), with: .color(Color(red: 0.55, green: 0.9, blue: 0.95)))
        }.frame(width: 120, height: 120)
    }
}

// MARK: 第一人称手持武器（写实矢量）
struct FirstPersonWeapon: View {
    let weapon: Weapon
    let recoil: CGFloat
    var body: some View {
        Canvas { c, size in
            let w = size.width, h = size.height
            let accent = weapon.accent
            // 枪身
            var gun = Path()
            gun.move(to: CGPoint(x: w * 0.55, y: h * 0.5))
            gun.addLine(to: CGPoint(x: w * 0.95, y: h * 0.42))
            gun.addLine(to: CGPoint(x: w * 0.98, y: h * 0.52))
            gun.addLine(to: CGPoint(x: w * 0.7, y: h * 0.6))
            gun.addLine(to: CGPoint(x: w * 0.6, y: h * 0.78))
            gun.addLine(to: CGPoint(x: w * 0.5, y: h * 0.78))
            gun.addLine(to: CGPoint(x: w * 0.54, y: h * 0.62))
            gun.addLine(to: CGPoint(x: w * 0.4, y: h * 0.62))
            gun.closeSubpath()
            c.fill(gun, with: .linearGradient(Gradient(colors: [accent.opacity(0.5), Color.black.opacity(0.6)]),
                                              startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 1)))
            c.stroke(gun, with: .color(accent.opacity(0.95)), lineWidth: 1.5)

            // 手部
            var hand = Path()
            hand.addRoundedRect(in: CGRect(x: w * 0.5, y: h * 0.66, width: w * 0.16, height: h * 0.22), cornerSize: CGSize(width: 10, height: 10))
            c.fill(hand, with: .linearGradient(Gradient(colors: [Color(red: 0.65, green: 0.5, blue: 0.4), Color(red: 0.45, green: 0.32, blue: 0.25)]),
                                               startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1)))
            c.stroke(hand, with: .color(Color(red: 0.3, green: 0.2, blue: 0.15)), lineWidth: 1)
            // 手指
            for i in 0..<3 {
                var f = Path()
                f.addRoundedRect(in: CGRect(x: w * (0.52 + 0.04 * CGFloat(i)), y: h * 0.7, width: w * 0.03, height: h * 0.1), cornerSize: CGSize(width: 4, height: 4))
                c.stroke(f, with: .color(Color(red: 0.3, green: 0.2, blue: 0.15).opacity(0.7)), lineWidth: 0.8)
            }
            // 枪口火光
            if recoil > 0.1 {
                var flash = Path()
                flash.addEllipse(in: CGRect(x: w * 0.96, y: h * 0.42, width: 30, height: 24))
                c.fill(flash, with: .color(Color(red: 1, green: 0.8, blue: 0.3).opacity(0.8)))
            }
            // 高光
            var hl = Path()
            hl.move(to: CGPoint(x: w * 0.56, y: h * 0.52))
            hl.addLine(to: CGPoint(x: w * 0.94, y: h * 0.44))
            c.stroke(hl, with: .color(.white.opacity(0.35)), lineWidth: 0.8)
        }
    }
}
