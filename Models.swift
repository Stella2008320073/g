import SwiftUI

// MARK: - 射击模式
enum FireMode: String, CaseIterable, Codable {
    case fullAuto = "全自动连发"
    case semiAuto = "半自动单发"
    case boltAction = "栓动单发"
    case pumpAction = "泵动单发"
    case burst = "三连发点射"
    case single = "单发发射"
    case melee = "近战挥砍"
}

// MARK: - 大分类
enum WeaponCategory: String, CaseIterable, Identifiable {
    case sniper = "狙击枪"
    case rifle = "步枪"
    case smg = "冲锋枪"
    case pistol = "手枪"
    case shotgun = "霰弹枪"
    case special = "特殊武器"
    case melee = "近战武器"
    var id: String { rawValue }

    /// 线路风格分类图标（矢量绘制，非 emoji）
    var lineIcon: LineIconKind {
        switch self {
        case .sniper, .rifle, .smg, .pistol, .shotgun: return .gun
        case .special: return .launcher
        case .melee: return .blade
        }
    }
}

// MARK: - 属性键
enum StatKey: String, Codable {
    // 枪械
    case recoilControl = "后坐力控制"
    case stability = "据枪稳定性"
    case handling = "操控速度"
    case hipAccuracy = "腰际射击精度"
    case muzzleVelocity = "枪口初速度"
    case effectiveRange = "优势射程"
    case fireRate = "射速"
    // 特殊武器
    case reloadSpeed = "装填速度"
    case aimStability = "瞄准稳定性"
    case blastRadius = "爆炸范围"
    case energyEfficiency = "能量效率"
    case cooling = "散热"
    case focusPrecision = "聚焦精度"
    case rangeFalloff = "射程衰减"
    // 近战
    case swingSpeed = "挥砍速度"
    case attackRange = "攻击范围"
    case penetration = "穿透力"
    case agility = "操控灵活度"
    case balance = "配重平衡"

    var isPositiveGood: Bool { true }
}

// MARK: - 槽位
struct WeaponSlot: Identifiable, Hashable {
    let id: String
    let name: String
    /// 聚焦参数：旋转、缩放、位移（相对预览容器）
    let focusRotate: Angle
    let focusScale: CGFloat
    let focusOffset: CGSize
    /// 在预览图上的锚点（0~1 相对坐标），用于连线
    let anchor: UnitPoint
    /// 该槽位对应的部件绘制区（用于外观替换时的定位）
    let partKey: String
    /// 初始是否可见
    var initiallyVisible: Bool = true
    /// 依赖联动：装某类配件后出现
    var requiresTag: String? = nil
}

// MARK: - 配件
struct Attachment: Identifiable, Hashable {
    let id: String
    let slotID: String
    let name: String
    let desc: String
    /// 属性增减
    let statDeltas: [StatKey: Double]
    /// 触发新增槽位的标签
    var grantsTag: String? = nil
    /// 外观参数（供部件重绘）
    var visual: VisualVariant = .default
}

enum VisualVariant: String, Hashable {
    case `default`
    case long, short, heavy, light, optic, grip, stock, mag, muzzle, laser, rail, blade, `guard`, handle, pommel, sheath
}

// MARK: - 武器
struct Weapon: Identifiable, Hashable {
    let id: String
    let name: String
    let category: WeaponCategory
    let fireModes: [FireMode]
    let defaultFireMode: FireMode
    var slots: [WeaponSlot]
    let baseStats: [StatKey: Double]
    /// 弹药容量（近战无）
    var magazineSize: Int = 0
    /// 基础换弹秒数
    var baseReload: Double = 0
    /// 卡图用色
    var accent: Color = Color(red: 0.55, green: 0.9, blue: 0.95)

    static func == (l: Weapon, r: Weapon) -> Bool { l.id == r.id }
    func hash(into h: inout Hasher) { h.combine(id) }

    /// 该武器默认配件（每槽位选第一个）
    func defaultLoadout(_ all: [Attachment]) -> [String: String] {
        var result: [String: String] = [:]
        for s in slots {
            if let a = all.first(where: { $0.slotID == s.id }) {
                result[s.id] = a.id
            }
        }
        return result
    }
}

// MARK: - 配置状态（跨界面保持）
final class LoadoutStore: ObservableObject {
    @Published var selectedWeaponID: String? = nil
    @Published var selectedCategory: WeaponCategory = .rifle
    /// weaponID -> [slotID: attachmentID]
    @Published var loadouts: [String: [String: String]] = [:]
    @Published var fireModes: [String: FireMode] = [:]

    func attachment(for weapon: Weapon, slot: WeaponSlot, all: [Attachment]) -> Attachment? {
        let load = loadouts[weapon.id] ?? [:]
        if let id = load[slot.id], let a = all.first(where: { $0.id == id }) { return a }
        return all.first(where: { $0.slotID == slot.id })
    }

    func selectAttachment(_ a: Attachment, weapon: Weapon) {
        var load = loadouts[weapon.id] ?? [:]
        load[a.slotID] = a.id
        loadouts[weapon.id] = load
    }

    func ensureDefault(for weapon: Weapon, all: [Attachment]) {
        if loadouts[weapon.id] == nil {
            loadouts[weapon.id] = weapon.defaultLoadout(all)
        }
        if fireModes[weapon.id] == nil {
            fireModes[weapon.id] = weapon.defaultFireMode
        }
    }

    /// 当前已激活的槽位（含联动出现的）
    func activeSlots(for weapon: Weapon, all: [Attachment]) -> [WeaponSlot] {
        var grantedTags = Set<String>()
        let load = loadouts[weapon.id] ?? [:]
        for (_, aid) in load {
            if let a = all.first(where: { $0.id == aid }), let t = a.grantsTag {
                grantedTags.insert(t)
            }
        }
        return weapon.slots.filter { s in
            if let req = s.requiresTag { return grantedTags.contains(req) }
            return true
        }
    }

    /// 汇总属性
    func stats(for weapon: Weapon, all: [Attachment]) -> [StatKey: Double] {
        var stats = weapon.baseStats
        let load = loadouts[weapon.id] ?? [:]
        for (_, aid) in load {
            if let a = all.first(where: { $0.id == aid }) {
                for (k, v) in a.statDeltas {
                    stats[k, default: 0] += v
                }
            }
        }
        return stats
    }

    func reloadTime(for weapon: Weapon, all: [Attachment]) -> Double {
        guard weapon.baseReload > 0 else { return 0 }
        let load = loadouts[weapon.id] ?? [:]
        var t = weapon.baseReload
        for (_, aid) in load {
            if let a = all.first(where: { $0.id == aid }) {
                // 弹匣/操控影响
                t += a.statDeltas[.handling].map { -$0 * 0.02 } ?? 0
                if a.visual == .mag { t -= 0.25 }
            }
        }
        return max(0.8, t)
    }

    func magCapacity(for weapon: Weapon, all: [Attachment]) -> Int {
        guard weapon.magazineSize > 0 else { return 0 }
        let load = loadouts[weapon.id] ?? [:]
        var cap = weapon.magazineSize
        for (_, aid) in load {
            if let a = all.first(where: { $0.id == aid }), a.visual == .mag {
                cap += 10
            }
        }
        return cap
    }
}
