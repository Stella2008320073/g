import SwiftUI

struct WeaponPreview3D: View {
    let weapon: Weapon
    @ObservedObject var store: LoadoutStore
    let attachments: [Attachment]
    let focus: WeaponSlot?

    var body: some View {
        GeometryReader { geo in
            let scale: CGFloat = focus?.focusScale ?? 1.0
            let rot: Angle = focus?.focusRotate ?? .degrees(0)
            let offset: CGSize = focus?.focusOffset ?? .zero
            ZStack {
                // 透视网格
                Canvas { c, size in
                    c.stroke(Path { p in
                        for i in 0...20 {
                            let x = size.width * CGFloat(i) / 20
                            p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height))
                        }
                        for i in 0...12 {
                            let y = size.height * CGFloat(i) / 12
                            p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y))
                        }
                    }, with: .color(Color(red: 0.3, green: 0.6, blue: 0.65).opacity(0.06)), lineWidth: 0.5)
                }
                // 武器部件绘制
                WeaponBody(weapon: weapon, store: store, attachments: attachments)
                    .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.55)
                    .rotation3DEffect(rot, axis: (x: 0, y: 1, z: 0), perspective: 0.4)
                    .scaleEffect(scale)
                    .offset(offset)
                    .animation(.easeInOut(duration: 0.35), value: scale)
                    .animation(.easeInOut(duration: 0.35), value: rot.degrees)
            }
        }
    }
}

/// 用矢量绘制武器部件外观（受配件 visual 影响）
struct WeaponBody: View {
    let weapon: Weapon
    @ObservedObject var store: LoadoutStore
    let attachments: [Attachment]

    func visual(_ slotID: String) -> VisualVariant {
        let load = store.loadouts[weapon.id] ?? [:]
        if let aid = load[slotID], let a = attachments.first(where: { $0.id == aid }) { return a.visual }
        return .default
    }

    var body: some View {
        Canvas { c, size in
            let w = size.width, h = size.height
            let accent = weapon.accent
            // 机身
            var body = Path()
            body.move(to: CGPoint(x: w * 0.08, y: h * 0.55))
            body.addLine(to: CGPoint(x: w * 0.72, y: h * 0.42))
            body.addLine(to: CGPoint(x: w * 0.78, y: h * 0.52))
            body.addLine(to: CGPoint(x: w * 0.56, y: h * 0.56))
            body.addLine(to: CGPoint(x: w * 0.5, y: h * 0.86))
            body.addLine(to: CGPoint(x: w * 0.4, y: h * 0.86))
            body.addLine(to: CGPoint(x: w * 0.44, y: h * 0.58))
            body.addLine(to: CGPoint(x: w * 0.14, y: h * 0.6))
            body.closeSubpath()

            c.fill(body, with: .linearGradient(Gradient(colors: [accent.opacity(0.45), Color.black.opacity(0.4)]),
                                              startPoint: .init(x: 0, y: 0), endPoint: .init(x: 1, y: 1)))
            c.stroke(body, with: .color(accent.opacity(0.95)), lineWidth: 1.2)

            // 枪管（受 barrel 影响长度）
            let barrelVariant = visual("barrel")
            let barrelLen: CGFloat = barrelVariant == .long ? 0.95 : (barrelVariant == .short ? 0.68 : 0.82)
            var barrel = Path()
            barrel.move(to: CGPoint(x: w * 0.72, y: h * 0.44))
            barrel.addLine(to: CGPoint(x: w * barrelLen, y: h * 0.4))
            barrel.addLine(to: CGPoint(x: w * barrelLen, y: h * 0.47))
            barrel.addLine(to: CGPoint(x: w * 0.72, y: h * 0.5))
            barrel.closeSubpath()
            c.fill(barrel, with: .linearGradient(Gradient(colors: [accent.opacity(0.5), Color.black.opacity(0.5)]), startPoint: .init(x: 0, y: 0), endPoint: .init(x: 0, y: 1)))
            c.stroke(barrel, with: .color(accent.opacity(0.9)), lineWidth: 1)

            // 枪口
            let muzzleVariant = visual("muzzle")
            if muzzleVariant != .default {
                var mp = Path()
                mp.addRect(CGRect(x: w * barrelLen, y: h * 0.4, width: w * 0.05, height: h * 0.06))
                c.stroke(mp, with: .color(accent), lineWidth: 1)
            }

            // 弹匣
            let magVariant = visual("mag")
            var mag = Path()
            let magH: CGFloat = magVariant == .mag ? 0.24 : 0.18
            mag.move(to: CGPoint(x: w * 0.46, y: h * 0.58))
            mag.addLine(to: CGPoint(x: w * 0.5, y: h * 0.58))
            mag.addLine(to: CGPoint(x: w * 0.48, y: h * (0.58 + magH)))
            mag.addLine(to: CGPoint(x: w * 0.42, y: h * (0.58 + magH)))
            mag.closeSubpath()
            c.fill(mag, with: .color(accent.opacity(0.3)))
            c.stroke(mag, with: .color(accent.opacity(0.8)), lineWidth: 0.8)

            // 瞄准镜
            if visual("optic") == .optic {
                var op = Path()
                op.addRect(CGRect(x: w * 0.5, y: h * 0.28, width: w * 0.12, height: h * 0.08))
                c.stroke(op, with: .color(accent), lineWidth: 1)
            }

            // 激光
            if visual("laser") == .laser {
                var l = Path()
                l.move(to: CGPoint(x: w * 0.62, y: h * 0.58))
                l.addLine(to: CGPoint(x: w * 0.8, y: h * 0.58))
                c.stroke(l, with: .color(Color.red.opacity(0.8)), lineWidth: 0.8)
            }

            // 高光
            var hl = Path()
            hl.move(to: CGPoint(x: w * 0.15, y: h * 0.54))
            hl.addLine(to: CGPoint(x: w * 0.68, y: h * 0.45))
            c.stroke(hl, with: .color(.white.opacity(0.35)), lineWidth: 0.7)
        }
    }
}

/// 槽位节点与连线
struct SlotNodes: View {
    let weapon: Weapon
    let activeSlots: [WeaponSlot]
    @Binding var focused: String?

    var body: some View {
        GeometryReader { geo in
            ForEach(activeSlots) { slot in
                let anchor = CGPoint(x: geo.size.width * slot.anchor.x + 12, y: geo.size.height * slot.anchor.y + 12)
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        focused = (focused == slot.id) ? nil : slot.id
                    }
                } label: {
                    ZStack {
                        Circle().stroke(focused == slot.id ? Color(red: 0.9, green: 0.65, blue: 0.25) : Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.8), lineWidth: 1)
                            .frame(width: 12, height: 12)
                        Circle().fill(focused == slot.id ? Color(red: 0.9, green: 0.65, blue: 0.25) : Color(red: 0.55, green: 0.9, blue: 0.95)).frame(width: 4, height: 4)
                        Text(slot.name).font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(focused == slot.id ? Color(red: 0.9, green: 0.65, blue: 0.25) : .gray)
                            .offset(x: 20)
                    }
                    .position(anchor)
                }.buttonStyle(.plain)
            }
        }
    }
}