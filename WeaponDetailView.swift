import SwiftUI

struct WeaponDetailView: View {
    let weapon: Weapon
    @ObservedObject var store: LoadoutStore
    let attachments: [Attachment]
    @Binding var focusedSlot: String?
    let onEnterRange: () -> Void

    var activeSlots: [WeaponSlot] { store.activeSlots(for: weapon, all: attachments) }
    var currentFocus: WeaponSlot? { activeSlots.first { $0.id == focusedSlot } }
    var stats: [StatKey: Double] { store.stats(for: weapon, all: attachments) }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 10) {
                // 预览区
                ZStack {
                    WeaponPreview3D(weapon: weapon, store: store, attachments: attachments, focus: currentFocus)
                        .frame(maxWidth: .infinity).frame(height: 300)
                        .background(Color.black.opacity(0.25))
                        .overlay(CutCornerShape(cut: 10).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        .clipShape(CutCornerShape(cut: 10))
                        .onTapGesture { withAnimation(.easeInOut(duration: 0.3)) { focusedSlot = nil } }
                        .padding(12)

                    // 槽位节点
                    SlotNodes(weapon: weapon, activeSlots: activeSlots, focused: $focusedSlot)
                        .padding(12)
                }
                .frame(height: 324)

                // 射击模式切换
                if weapon.fireModes.count > 1 && weapon.category != .melee {
                    HStack(spacing: 6) {
                        Text("射击模式").font(.system(size: 10, design: .monospaced)).foregroundStyle(.gray)
                        ForEach(weapon.fireModes, id: \.self) { m in
                            Button { store.fireModes[weapon.id] = m } label: {
                                Text(m.rawValue)
                                    .font(.system(size: 10, design: .monospaced))
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(store.fireModes[weapon.id] == m ? Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.2) : Color.clear)
                                    .overlay(CutCornerShape(cut: 4).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                            }.buttonStyle(.plain)
                        }
                    }.padding(.horizontal, 12)
                }

                // 配件列表 + 属性
                HStack(alignment: .top, spacing: 10) {
                    attachmentList.frame(width: 280)
                    attributePanel.frame(maxWidth: .infinity)
                }.padding(.horizontal, 12)
                Spacer(minLength: 60)
            }

            // 右下角进入靶场
            MilitaryButton(title: "进入靶场", width: 200, action: onEnterRange)
                .padding(20)
        }
    }

    var attachmentList: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let slot = currentFocus {
                Text("\(slot.name) 配件").font(.system(size: 11, design: .monospaced)).foregroundStyle(Color(red: 0.55, green: 0.9, blue: 0.95))
                ScrollView {
                    let opts = attachments.filter { $0.slotID == slot.id }
                    ForEach(opts) { a in
                        let selected = store.attachment(for: weapon, slot: slot, all: attachments)?.id == a.id
                        Button {
                            store.selectAttachment(a, weapon: weapon)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(a.name).font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(selected ? Color(red: 0.55, green: 0.9, blue: 0.95) : .white)
                                Text(a.desc).font(.system(size: 9, design: .monospaced)).foregroundStyle(.gray)
                                HStack(spacing: 6) {
                                    ForEach(Array(a.statDeltas.keys), id: \.self) { k in
                                        let d = a.statDeltas[k]!
                                        Text("\(k.rawValue)\(d > 0 ? "+\(Int(d))" : "\(Int(d))")")
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundStyle(d > 0 ? Color.green : Color.red)
                                    }
                                }
                            }
                            .padding(6).frame(maxWidth: .infinity, alignment: .leading)
                            .background(selected ? Color.white.opacity(0.06) : Color.white.opacity(0.02))
                            .overlay(CutCornerShape(cut: 5).stroke(selected ? Color(red: 0.55, green: 0.9, blue: 0.95).opacity(0.6) : Color.white.opacity(0.06), lineWidth: 0.6))
                            .clipShape(CutCornerShape(cut: 5))
                        }.buttonStyle(.plain)
                    }
                }.frame(maxHeight: 240)
            } else {
                Text("点击预览上的槽位查看配件").font(.system(size: 11, design: .monospaced)).foregroundStyle(.gray)
            }
        }
    }

    var attributePanel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("属性").font(.system(size: 11, design: .monospaced)).foregroundStyle(Color(red: 0.55, green: 0.9, blue: 0.95))
            let keys = statKeysForCategory(weapon.category)
            ForEach(keys, id: \.self) { k in
                let base = weapon.baseStats[k] ?? 0
                let cur = stats[k] ?? base
                StatBar(key: k, value: cur, delta: cur - base)
            }
        }
    }

    func statKeysForCategory(_ c: WeaponCategory) -> [StatKey] {
        switch c {
        case .sniper, .rifle, .smg, .pistol, .shotgun:
            return [.recoilControl, .stability, .handling, .hipAccuracy, .muzzleVelocity, .effectiveRange, .fireRate]
        case .special:
            if weapon.id.hasPrefix("sp2") || weapon.id.hasPrefix("sp5") {
                return [.energyEfficiency, .cooling, .focusPrecision, .rangeFalloff]
            }
            return [.reloadSpeed, .aimStability, .blastRadius, .muzzleVelocity]
        case .melee:
            return [.swingSpeed, .attackRange, .penetration, .agility, .balance]
        }
    }
}