import SwiftUI

struct WorkshopView: View {
    let fps: FPSMonitor
    @Binding var route: Route
    @ObservedObject var store: LoadoutStore
    let weapons: [Weapon]
    let attachments: [Attachment]

    @State private var focusedSlot: String? = nil
    @State private var toast: String? = nil

    var categoryWeapons: [Weapon] { weapons.filter { $0.category == store.selectedCategory } }
    var selected: Weapon? { weapons.first(where: { $0.id == store.selectedWeaponID }) }

    var body: some View {
        HStack(spacing: 0) {
            categoryColumn.frame(width: 228)
            Divider().overlay(Color.white.opacity(0.08))
            weaponColumn.frame(maxWidth: .infinity)
            Divider().overlay(Color.white.opacity(0.08))
            detailColumn.frame(width: 620)
        }
        .background(LineBackdrop())
        .overlay(FPSOverlay(monitor: fps).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading))
        .overlay(alignment: .bottom) {
            if let toast {
                Text(toast).font(.system(size: 12, design: .monospaced))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.black.opacity(0.7))
                    .foregroundStyle(Color(red: 0.55, green: 0.9, blue: 0.95))
                    .clipShape(Capsule())
                    .padding(.bottom, 14)
            }
        }
    }

    // MARK: 左：分类
    var categoryColumn: some View {
        VStack(spacing: 0) {
            Text("武器分类").font(.system(size: 11, design: .monospaced)).foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 16).padding(.vertical, 10)
            Divider().overlay(Color.white.opacity(0.06))
            ForEach(WeaponCategory.allCases) { cat in
                let count = weapons.filter { $0.category == cat }.count
                Button {
                    store.selectedCategory = cat
                    store.selectedWeaponID = categoryWeaponsFor(cat).first?.id
                } label: {
                    HStack(spacing: 10) {
                        LineIcon(kind: cat.lineIcon)
                        Text(cat.rawValue).font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(store.selectedCategory == cat ? Color(red: 0.55, green: 0.9, blue: 0.95) : .gray)
                        Spacer()
                        Text("\(count)").font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.gray).padding(.horizontal, 6).padding(.vertical, 2)
                            .overlay(CutCornerShape(cut: 4).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                    }
                    .padding(.horizontal, 16).frame(height: 58)
                    .background(store.selectedCategory == cat ? Color.white.opacity(0.05) : Color.clear)
                    .overlay(alignment: .leading) {
                        Rectangle().fill(store.selectedCategory == cat ? Color(red: 0.9, green: 0.65, blue: 0.25) : .clear).frame(width: 3)
                    }
                }.buttonStyle(.plain)
                Divider().overlay(Color.white.opacity(0.04))
            }
            Spacer()
            VStack(spacing: 8) {
                MilitaryButton(title: "返回大厅", width: 190) { route = .lobby }
                MilitaryButton(title: "设置", width: 190) { toast = "设置面板占位" }
            }.padding(.bottom, 14)
        }
        .background(Color.black.opacity(0.3))
    }

    func categoryWeaponsFor(_ c: WeaponCategory) -> [Weapon] { weapons.filter { $0.category == c } }

    // MARK: 中：武器列表
    var weaponColumn: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(categoryWeapons) { w in
                    WeaponCard(weapon: w, selected: w.id == store.selectedWeaponID, store: store, attachments: attachments)
                        .onTapGesture {
                            store.selectedWeaponID = w.id
                            store.ensureDefault(for: w, all: attachments)
                            focusedSlot = nil
                        }
                }
            }.padding(12)
        }
        .background(Color.black.opacity(0.2))
    }

    // MARK: 右：改装详情
    var detailColumn: some View {
        ZStack {
            if let w = selected {
                WeaponDetailView(weapon: w, store: store, attachments: attachments,
                                 focusedSlot: $focusedSlot, onEnterRange: { route = .range })
            } else {
                Text("请从左侧选择一把武器开始改装")
                    .font(.system(size: 13, design: .monospaced)).foregroundStyle(.gray)
            }
        }
        .background(Color.black.opacity(0.35))
    }
}

struct WeaponCard: View {
    let weapon: Weapon
    let selected: Bool
    @ObservedObject var store: LoadoutStore
    let attachments: [Attachment]
    var body: some View {
        HStack(spacing: 12) {
            WeaponThumb(weapon: weapon).frame(width: 96, height: 54)
            VStack(alignment: .leading, spacing: 3) {
                Text(weapon.name).font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(selected ? Color(red: 0.55, green: 0.9, blue: 0.95) : .white)
                let modeText = weapon.fireModes.map { $0.rawValue }.joined(separator: " / ")
                Text("射击模式：\(modeText)").font(.system(size: 10, design: .monospaced)).foregroundStyle(.gray)
                Text("后坐 \(Int(store.stats(for: weapon, all: attachments)[.recoilControl] ?? weapon.baseStats[.recoilControl] ?? 0))  操控 \(Int(store.stats(for: weapon, all: attachments)[.handling] ?? 0))")
                    .font(.system(size: 10, design: .monospaced)).foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(8)
        .background(selected ? Color.white.opacity(0.06) : Color.white.opacity(0.02))
        .overlay(CutCornerShape(cut: 8).stroke(selected ? Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.7) : Color.white.opacity(0.08), lineWidth: 1))
        .clipShape(CutCornerShape(cut: 8))
    }
}

/// 武器卡图（矢量武器轮廓 + 光泽）
struct WeaponThumb: View {
    let weapon: Weapon
    var body: some View {
        Canvas { c, size in
            let w = size.width, h = size.height
            var p = Path()
            p.move(to: CGPoint(x: w * 0.06, y: h * 0.5))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.44))
            p.addLine(to: CGPoint(x: w * 0.88, y: h * 0.52))
            p.addLine(to: CGPoint(x: w * 0.6, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.52, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.58))
            p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.56))
            p.closeSubpath()
            c.fill(p, with: .linearGradient(Gradient(colors: [weapon.accent.opacity(0.35), Color.black.opacity(0.1)]),
                                             startPoint: .zero, endPoint: CGPoint(x: w, y: h)))
            c.stroke(p, with: .color(weapon.accent.opacity(0.9)), lineWidth: 1)
            // 高光
            var hl = Path()
            hl.move(to: CGPoint(x: w * 0.2, y: h * 0.5))
            hl.addLine(to: CGPoint(x: w * 0.7, y: h * 0.46))
            c.stroke(hl, with: .color(.white.opacity(0.4)), lineWidth: 0.6)
        }
        .background(Color.black.opacity(0.3))
    }
}