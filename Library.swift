import SwiftUI

enum Library {
    // MARK: 通用配件工厂
    static func genericAttachments(prefix: String, slots: [WeaponSlot], category: WeaponCategory) -> [Attachment] {
        var result: [Attachment] = []
        for slot in slots {
            switch slot.id {
            case "muzzle":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "战术消焰器", desc: "削弱枪口焰，略微降低后坐力", statDeltas: [.recoilControl: 4, .muzzleVelocity: -2], visual: .muzzle),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "重型补偿器", desc: "大幅压枪，但限制初速", statDeltas: [.recoilControl: 9, .muzzleVelocity: -5], visual: .muzzle),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "轻量化枪口", desc: "提升操控，牺牲稳定", statDeltas: [.handling: 5, .stability: -3], visual: .light),
                ]
            case "barrel":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准枪管", desc: "均衡表现", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "长程重枪管", desc: "提升初速与射程，新增导轨片槽位", statDeltas: [.muzzleVelocity: 12, .effectiveRange: 10, .handling: -6], grantsTag: "rail", visual: .long),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "短突击枪管", desc: "机动优先", statDeltas: [.handling: 8, .effectiveRange: -8], visual: .short),
                ]
            case "grip":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "垂直握把", desc: "降低垂直后坐", statDeltas: [.recoilControl: 6], visual: .grip),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "斜角握把", desc: "提升操控", statDeltas: [.handling: 5, .recoilControl: 2], visual: .grip),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "轻量折叠握把", desc: "极致机动", statDeltas: [.handling: 9, .stability: -2], visual: .light),
                ]
            case "stock":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准枪托", desc: "稳定基线", statDeltas: [.stability: 3], visual: .stock),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "重型缓冲枪托", desc: "显著压后坐", statDeltas: [.stability: 8, .recoilControl: 5, .handling: -4], visual: .heavy),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "折叠轻型枪托", desc: "机动优先，新增缓冲垫槽位", statDeltas: [.handling: 7, .stability: -4], grantsTag: "buttpad", visual: .stock),
                ]
            case "mag":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准弹匣", desc: "均衡", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "扩容弹匣", desc: "容量+10，换弹略慢", statDeltas: [.handling: -3], visual: .mag),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "快速弹匣", desc: "换弹更快", statDeltas: [.handling: 6], visual: .mag),
                ]
            case "optic":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "机械瞄具", desc: "轻便", statDeltas: [.handling: 2], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "红点瞄准镜", desc: "快速对准，新增增高架槽位", statDeltas: [.stability: 4, .hipAccuracy: 3], grantsTag: "riser", visual: .optic),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "高倍瞄准镜", desc: "远距精准", statDeltas: [.stability: 7, .effectiveRange: 6, .handling: -5], grantsTag: "riser", visual: .optic),
                ]
            case "rail":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "导轨片", desc: "扩展安装", statDeltas: [.stability: 2], visual: .rail),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "战术导轨片", desc: "提升稳定", statDeltas: [.stability: 4, .hipAccuracy: 2], visual: .rail),
                ]
            case "laser":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "激光镭指", desc: "腰射提升", statDeltas: [.hipAccuracy: 8], visual: .laser),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "红外照明", desc: "稳定提升", statDeltas: [.stability: 3], visual: .laser),
                ]
            case "riser":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "增高架", desc: "抬高瞄具", statDeltas: [.stability: 2], visual: .optic),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "侧置红点", desc: "切换更快", statDeltas: [.handling: 3], visual: .optic),
                ]
            case "buttpad":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "缓冲垫", desc: "减少后坐", statDeltas: [.recoilControl: 3], visual: .stock),
                ]
            case "bolt":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准拉机柄", desc: "基础", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "加长拉机柄", desc: "拉栓更快", statDeltas: [.handling: 4], visual: .long),
                ]
            case "bipod":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "战术脚架", desc: "据枪稳定", statDeltas: [.stability: 9, .handling: -3], visual: .heavy),
                ]
            case "cheek":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "可调腮托", desc: "稳定提升", statDeltas: [.stability: 4], visual: .stock),
                ]
            case "tube":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准发射管", desc: "均衡", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "加长发射管", desc: "射程更远", statDeltas: [.effectiveRange: 8, .muzzleVelocity: 6], visual: .long),
                ]
            case "sightSpecial":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "机械瞄具", desc: "轻便", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "光学瞄具", desc: "瞄准稳定", statDeltas: [.aimStability: 5], visual: .optic),
                ]
            case "gripSpecial":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "防滑握把", desc: "稳定", statDeltas: [.aimStability: 3], visual: .grip),
                ]
            case "flame":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "尾焰抑制器", desc: "装填略快", statDeltas: [.reloadSpeed: 4], visual: .muzzle),
                ]
            case "drum":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准弹鼓", desc: "均衡", statDeltas: [:], visual: .mag),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "大容量弹鼓", desc: "装填慢", statDeltas: [.reloadSpeed: -4], visual: .mag),
                ]
            case "crystal":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准聚焦晶体", desc: "均衡", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "高纯聚焦晶体", desc: "精度提升", statDeltas: [.focusPrecision: 6, .energyEfficiency: -2], visual: .optic),
                ]
            case "cooling":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "散热模块", desc: "散热提升", statDeltas: [.cooling: 6], visual: .heavy),
                ]
            case "battery":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准能量电池", desc: "均衡", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "高密度电池", desc: "效率提升", statDeltas: [.energyEfficiency: 7, .cooling: -2], visual: .heavy),
                ]
            // 近战
            case "blade":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准刃身", desc: "均衡", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "等离子强化刃身", desc: "穿透提升，新增配重尾环槽位", statDeltas: [.penetration: 8, .agility: -3], grantsTag: "pommel", visual: .blade),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "加长刀身", desc: "范围更大，新增刀鞘槽位", statDeltas: [.attackRange: 10, .swingSpeed: -4], grantsTag: "sheath", visual: .long),
                ]
            case "tip":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准刀尖", desc: "均衡", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "热能聚焦刀尖", desc: "穿透提升", statDeltas: [.penetration: 6], visual: .blade),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "纳米自锐涂层", desc: "挥砍更快", statDeltas: [.swingSpeed: 5], visual: .light),
                ]
            case "guard":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准护手", desc: "均衡", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "碳纤维机械护手", desc: "灵活提升", statDeltas: [.agility: 6], visual: .guard),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "能量护手模块", desc: "范围提升", statDeltas: [.attackRange: 4, .penetration: 3], visual: .guard),
                ]
            case "handle":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准握柄", desc: "均衡", statDeltas: [:], visual: .default),
                    .init(id: "\(prefix).\(slot.id).2", slotID: slot.id, name: "磁吸防滑握柄", desc: "灵活提升，新增联动关节槽位", statDeltas: [.agility: 5], grantsTag: "joint", visual: .handle),
                    .init(id: "\(prefix).\(slot.id).3", slotID: slot.id, name: "碳纤维机械护手", desc: "平衡优化", statDeltas: [.balance: 4], visual: .handle),
                ]
            case "pommel":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "配重尾环", desc: "平衡提升", statDeltas: [.balance: 5], visual: .pommel),
                ]
            case "joint":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "折叠联动关节", desc: "灵活提升", statDeltas: [.agility: 4], visual: .handle),
                ]
            case "sheath":
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "折叠联动刀鞘", desc: "灵活提升", statDeltas: [.agility: 3], visual: .sheath),
                ]
            default:
                result += [
                    .init(id: "\(prefix).\(slot.id).1", slotID: slot.id, name: "标准部件", desc: "均衡", statDeltas: [:], visual: .default),
                ]
            }
        }
        return result
    }

    // MARK: 槽位模板
    static func rifleSlots() -> [WeaponSlot] {
        [
            .init(id: "muzzle", name: "枪口", focusRotate: .degrees(-8), focusScale: 2.2, focusOffset: CGSize(width: 200, height: -10), anchor: UnitPoint(x: 0.86, y: 0.5), partKey: "muzzle"),
            .init(id: "barrel", name: "枪管", focusRotate: .degrees(-5), focusScale: 1.9, focusOffset: CGSize(width: 120, height: -6), anchor: UnitPoint(x: 0.72, y: 0.5), partKey: "barrel"),
            .init(id: "grip", name: "握把", focusRotate: .degrees(6), focusScale: 2.0, focusOffset: CGSize(width: -10, height: 40), anchor: UnitPoint(x: 0.42, y: 0.72), partKey: "grip"),
            .init(id: "stock", name: "枪托", focusRotate: .degrees(4), focusScale: 1.9, focusOffset: CGSize(width: -140, height: 6), anchor: UnitPoint(x: 0.14, y: 0.55), partKey: "stock"),
            .init(id: "mag", name: "弹匣", focusRotate: .degrees(2), focusScale: 2.1, focusOffset: CGSize(width: -30, height: 60), anchor: UnitPoint(x: 0.46, y: 0.82), partKey: "mag"),
            .init(id: "optic", name: "瞄准镜", focusRotate: .degrees(-4), focusScale: 2.0, focusOffset: CGSize(width: 20, height: -50), anchor: UnitPoint(x: 0.5, y: 0.28), partKey: "optic"),
            .init(id: "rail", name: "护木导轨", focusRotate: .degrees(-4), focusScale: 2.0, focusOffset: CGSize(width: 90, height: 30), anchor: UnitPoint(x: 0.64, y: 0.62), partKey: "rail", initiallyVisible: false, requiresTag: "rail"),
            .init(id: "laser", name: "激光镭指", focusRotate: .degrees(-2), focusScale: 2.0, focusOffset: CGSize(width: 60, height: 20), anchor: UnitPoint(x: 0.68, y: 0.6), partKey: "laser", initiallyVisible: true),
            .init(id: "riser", name: "增高架", focusRotate: .degrees(-4), focusScale: 2.1, focusOffset: CGSize(width: 10, height: -56), anchor: UnitPoint(x: 0.48, y: 0.2), partKey: "riser", initiallyVisible: false, requiresTag: "riser"),
            .init(id: "buttpad", name: "缓冲垫", focusRotate: .degrees(4), focusScale: 2.1, focusOffset: CGSize(width: -170, height: 8), anchor: UnitPoint(x: 0.08, y: 0.56), partKey: "buttpad", initiallyVisible: false, requiresTag: "buttpad"),
        ]
    }

    static func sniperSlots() -> [WeaponSlot] {
        rifleSlots() + [
            .init(id: "bipod", name: "脚架", focusRotate: .degrees(-3), focusScale: 1.9, focusOffset: CGSize(width: 140, height: 50), anchor: UnitPoint(x: 0.8, y: 0.75), partKey: "bipod"),
            .init(id: "cheek", name: "腮托", focusRotate: .degrees(4), focusScale: 2.0, focusOffset: CGSize(width: -90, height: -20), anchor: UnitPoint(x: 0.22, y: 0.4), partKey: "cheek"),
            .init(id: "bolt", name: "拉机柄", focusRotate: .degrees(-6), focusScale: 2.2, focusOffset: CGSize(width: -20, height: -30), anchor: UnitPoint(x: 0.4, y: 0.32), partKey: "bolt"),
        ]
    }

    static func pistolSlots() -> [WeaponSlot] {
        [
            .init(id: "muzzle", name: "枪口", focusRotate: .degrees(-8), focusScale: 2.3, focusOffset: CGSize(width: 180, height: -10), anchor: UnitPoint(x: 0.88, y: 0.45), partKey: "muzzle"),
            .init(id: "barrel", name: "枪管", focusRotate: .degrees(-5), focusScale: 2.0, focusOffset: CGSize(width: 100, height: -6), anchor: UnitPoint(x: 0.7, y: 0.45), partKey: "barrel"),
            .init(id: "grip", name: "握把", focusRotate: .degrees(8), focusScale: 2.0, focusOffset: CGSize(width: -40, height: 40), anchor: UnitPoint(x: 0.3, y: 0.72), partKey: "grip"),
            .init(id: "mag", name: "弹匣", focusRotate: .degrees(6), focusScale: 2.1, focusOffset: CGSize(width: -50, height: 55), anchor: UnitPoint(x: 0.26, y: 0.82), partKey: "mag"),
            .init(id: "optic", name: "瞄具", focusRotate: .degrees(-4), focusScale: 2.0, focusOffset: CGSize(width: 0, height: -50), anchor: UnitPoint(x: 0.55, y: 0.25), partKey: "optic"),
            .init(id: "laser", name: "激光镭指", focusRotate: .degrees(-2), focusScale: 2.0, focusOffset: CGSize(width: 50, height: 30), anchor: UnitPoint(x: 0.6, y: 0.62), partKey: "laser"),
        ]
    }

    static func shotgunSlots() -> [WeaponSlot] {
        rifleSlots() + [
            .init(id: "tube", name: "弹仓", focusRotate: .degrees(-3), focusScale: 1.9, focusOffset: CGSize(width: 130, height: 30), anchor: UnitPoint(x: 0.7, y: 0.68), partKey: "tube"),
        ]
    }

    static func specialSlots(kind: String) -> [WeaponSlot] {
        switch kind {
        case "launcher":
            return [
                .init(id: "sightSpecial", name: "瞄具", focusRotate: .degrees(-4), focusScale: 2.0, focusOffset: CGSize(width: 30, height: -40), anchor: UnitPoint(x: 0.55, y: 0.3), partKey: "optic"),
                .init(id: "gripSpecial", name: "握把", focusRotate: .degrees(6), focusScale: 2.0, focusOffset: CGSize(width: 0, height: 40), anchor: UnitPoint(x: 0.4, y: 0.68), partKey: "grip"),
                .init(id: "tube", name: "发射管", focusRotate: .degrees(-5), focusScale: 1.8, focusOffset: CGSize(width: 120, height: 0), anchor: UnitPoint(x: 0.7, y: 0.5), partKey: "tube"),
                .init(id: "flame", name: "尾焰抑制", focusRotate: .degrees(-8), focusScale: 2.0, focusOffset: CGSize(width: -150, height: 10), anchor: UnitPoint(x: 0.12, y: 0.55), partKey: "muzzle"),
            ]
        case "grenade":
            return [
                .init(id: "sightSpecial", name: "瞄具", focusRotate: .degrees(-4), focusScale: 2.0, focusOffset: CGSize(width: 30, height: -40), anchor: UnitPoint(x: 0.55, y: 0.3), partKey: "optic"),
                .init(id: "gripSpecial", name: "握把", focusRotate: .degrees(6), focusScale: 2.0, focusOffset: CGSize(width: 0, height: 40), anchor: UnitPoint(x: 0.4, y: 0.68), partKey: "grip"),
                .init(id: "drum", name: "弹鼓", focusRotate: .degrees(2), focusScale: 2.0, focusOffset: CGSize(width: -20, height: 55), anchor: UnitPoint(x: 0.46, y: 0.8), partKey: "mag"),
            ]
        default: // laser
            return [
                .init(id: "crystal", name: "聚焦晶体", focusRotate: .degrees(-5), focusScale: 2.0, focusOffset: CGSize(width: 140, height: 0), anchor: UnitPoint(x: 0.78, y: 0.5), partKey: "barrel"),
                .init(id: "cooling", name: "散热模块", focusRotate: .degrees(-3), focusScale: 2.0, focusOffset: CGSize(width: 60, height: 30), anchor: UnitPoint(x: 0.62, y: 0.68), partKey: "rail"),
                .init(id: "battery", name: "能量电池", focusRotate: .degrees(4), focusScale: 2.0, focusOffset: CGSize(width: -60, height: 40), anchor: UnitPoint(x: 0.28, y: 0.72), partKey: "mag"),
                .init(id: "sightSpecial", name: "瞄具", focusRotate: .degrees(-4), focusScale: 2.0, focusOffset: CGSize(width: 30, height: -40), anchor: UnitPoint(x: 0.5, y: 0.3), partKey: "optic"),
            ]
        }
    }

    static func meleeSlots() -> [WeaponSlot] {
        [
            .init(id: "blade", name: "刀身", focusRotate: .degrees(-6), focusScale: 2.0, focusOffset: CGSize(width: 120, height: 0), anchor: UnitPoint(x: 0.7, y: 0.5), partKey: "blade"),
            .init(id: "tip", name: "刀尖", focusRotate: .degrees(-8), focusScale: 2.2, focusOffset: CGSize(width: 200, height: -10), anchor: UnitPoint(x: 0.88, y: 0.45), partKey: "tip"),
            .init(id: "guard", name: "护手", focusRotate: .degrees(6), focusScale: 2.1, focusOffset: CGSize(width: 0, height: 40), anchor: UnitPoint(x: 0.36, y: 0.66), partKey: "guard"),
            .init(id: "handle", name: "握柄", focusRotate: .degrees(8), focusScale: 2.0, focusOffset: CGSize(width: -100, height: 40), anchor: UnitPoint(x: 0.22, y: 0.7), partKey: "handle"),
            .init(id: "pommel", name: "配重尾环", focusRotate: .degrees(6), focusScale: 2.1, focusOffset: CGSize(width: -180, height: 30), anchor: UnitPoint(x: 0.1, y: 0.72), partKey: "pommel", initiallyVisible: false, requiresTag: "pommel"),
            .init(id: "sheath", name: "刀鞘", focusRotate: .degrees(4), focusScale: 1.9, focusOffset: CGSize(width: -60, height: 70), anchor: UnitPoint(x: 0.3, y: 0.82), partKey: "sheath", initiallyVisible: false, requiresTag: "sheath"),
            .init(id: "joint", name: "联动关节", focusRotate: .degrees(7), focusScale: 2.0, focusOffset: CGSize(width: -80, height: 50), anchor: UnitPoint(x: 0.2, y: 0.78), partKey: "joint", initiallyVisible: false, requiresTag: "joint"),
        ]
    }

    // MARK: 武器工厂
    static func makeWeapons() -> [Weapon] {
        var list: [Weapon] = []

        // 狙击枪 10
        let sniperNames = ["寒鸦-7 栓动狙击", "远望-12 半自动狙击", "雷霆-M99 反器材", "静默-3 侦察狙击", "破晓-50 重型反器材", "游隼-8 半自动", "霜刃-11 栓动", "天穹-4 精确射手", "裂空-70 反器材", "低语-2 微声狙击"]
        for (i, n) in sniperNames.enumerated() {
            var modes: [FireMode] = i % 3 == 0 ? [.semiAuto] : [.boltAction]
            modes = i == 1 || i == 5 ? [.semiAuto, .boltAction] : modes
            list.append(Weapon(id: "sn\(i)", name: n, category: .sniper, fireModes: modes, defaultFireMode: modes[0],
                               slots: sniperSlots(),
                               baseStats: [.recoilControl: 45 + Double(i), .stability: 55 + Double(i * 2), .handling: 35, .hipAccuracy: 25, .muzzleVelocity: 80 + Double(i * 3), .effectiveRange: 85, .fireRate: 30],
                               magazineSize: 5 + i % 3, baseReload: 2.6 + Double(i % 2) * 0.4, accent: Color(red: 0.5, green: 0.85, blue: 0.95)))
        }
        // 步枪 10
        let rifleNames = ["赤隼-15 突击步枪", "灰狼-21 战斗步枪", "锐爪-9 精确射手", "断岳-16 突击步枪", "钢翼-27 战斗步枪", "青锋-4 突击步枪", "疾风-33 精确射手", "铁砧-11 战斗步枪", "晨星-5 突击步枪", "暗刃-19 短突击"]
        for (i, n) in rifleNames.enumerated() {
            let modes: [FireMode] = (i % 4 == 2) ? [.semiAuto] : [.fullAuto, .semiAuto, .burst]
            list.append(Weapon(id: "rf\(i)", name: n, category: .rifle, fireModes: modes, defaultFireMode: modes[0],
                               slots: rifleSlots(),
                               baseStats: [.recoilControl: 50 + Double(i), .stability: 50, .handling: 55, .hipAccuracy: 45, .muzzleVelocity: 70, .effectiveRange: 60, .fireRate: 75],
                               magazineSize: 30, baseReload: 2.1 + Double(i % 2) * 0.2, accent: Color(red: 0.55, green: 0.88, blue: 0.75)))
        }
        // 冲锋枪 10
        let smgNames = ["蜂鸟-4 冲锋枪", "短喙-9 冲锋枪", "蜂群-45 冲锋枪", "疾闪-7 冲锋枪", "沙狐-11 冲锋枪", "闪电-2 冲锋枪", "钉刺-6 冲锋枪", "近卫-18 冲锋枪", "碎星-5 冲锋枪", "针锋-33 冲锋枪"]
        for (i, n) in smgNames.enumerated() {
            let modes: [FireMode] = [.fullAuto, .semiAuto, .burst]
            list.append(Weapon(id: "smg\(i)", name: n, category: .smg, fireModes: modes, defaultFireMode: .fullAuto,
                               slots: rifleSlots(),
                               baseStats: [.recoilControl: 40, .stability: 42, .handling: 80, .hipAccuracy: 65, .muzzleVelocity: 45, .effectiveRange: 35, .fireRate: 95],
                               magazineSize: 32, baseReload: 1.8 + Double(i % 2) * 0.2, accent: Color(red: 0.95, green: 0.8, blue: 0.45)))
        }
        // 手枪 10
        let pistolNames = ["短兵-9 半自动手枪", "守望-45 左轮", "侧影-4 冲锋手枪", "袖箭-22 半自动", "烈风-6 左轮", "微光-17 半自动", "铁指-10 冲锋手枪", "直击-3 半自动", "月牙-8 左轮", "寸锋-5 半自动"]
        for (i, n) in pistolNames.enumerated() {
            let modes: [FireMode] = i % 3 == 1 ? [.semiAuto] : [.semiAuto, .fullAuto]
            list.append(Weapon(id: "ps\(i)", name: n, category: .pistol, fireModes: modes, defaultFireMode: .semiAuto,
                               slots: pistolSlots(),
                               baseStats: [.recoilControl: 35, .stability: 30, .handling: 90, .hipAccuracy: 70, .muzzleVelocity: 40, .effectiveRange: 25, .fireRate: 60],
                               magazineSize: 12 + i % 5, baseReload: 1.5 + Double(i % 2) * 0.2, accent: Color(red: 0.85, green: 0.65, blue: 0.95)))
        }
        // 霰弹枪 10
        let shotgunNames = ["破门-12 泵动霰弹", "洪流-8 半自动霰弹", "双管-2 双管霰弹", "碎骨-20 泵动", "怒涛-6 半自动", "风箱-9 弹鼓霰弹", "锤击-4 泵动", "浪涌-11 半自动", "裂隙-7 双管", "压路-15 弹鼓"]
        for (i, n) in shotgunNames.enumerated() {
            let modes: [FireMode] = (i % 4 == 1) ? [.semiAuto] : [.pumpAction]
            list.append(Weapon(id: "sg\(i)", name: n, category: .shotgun, fireModes: modes, defaultFireMode: modes[0],
                               slots: shotgunSlots(),
                               baseStats: [.recoilControl: 30, .stability: 35, .handling: 50, .hipAccuracy: 55, .muzzleVelocity: 35, .effectiveRange: 22, .fireRate: 40],
                               magazineSize: 6 + i % 3, baseReload: 2.8 + Double(i % 2) * 0.4, accent: Color(red: 0.95, green: 0.55, blue: 0.4)))
        }
        // 特殊武器 6
        let specials: [(String, String, [FireMode])] = [
            ("sp0", "重锤-80 火箭筒", [.single]),
            ("sp1", "雨幕-40 榴弹发射器", [.single]),
            ("sp2", "棱镜-7 激光射线", [.single]),
            ("sp3", "熔核-1 等离子发射器", [.single]),
            ("sp4", "裂隙-9 榴弹发射器", [.single]),
            ("sp5", "辉光-2 激光射线", [.single]),
        ]
        for (i, s) in specials.enumerated() {
            let kind = i % 3 == 0 ? "launcher" : (i % 3 == 1 ? "grenade" : "laser")
            var stats: [StatKey: Double]
            if kind == "launcher" {
                stats = [.reloadSpeed: 40, .aimStability: 50, .blastRadius: 70, .muzzleVelocity: 60]
            } else if kind == "grenade" {
                stats = [.reloadSpeed: 50, .aimStability: 45, .blastRadius: 60, .muzzleVelocity: 40]
            } else {
                stats = [.energyEfficiency: 55, .cooling: 45, .focusPrecision: 60, .rangeFalloff: 35]
            }
            list.append(Weapon(id: s.0, name: s.1, category: .special, fireModes: s.2, defaultFireMode: .single,
                               slots: specialSlots(kind: kind), baseStats: stats, magazineSize: 1, baseReload: 3.0, accent: Color(red: 0.9, green: 0.5, blue: 0.5)))
        }
        // 近战 5
        let melees = ["蝶影 蝴蝶刀", "裂爪 爪刀", "弹簧刃 弹簧刀", "直脊 战术刀", "回环 折叠刀"]
        for (i, n) in melees.enumerated() {
            list.append(Weapon(id: "ml\(i)", name: n, category: .melee, fireModes: [.melee], defaultFireMode: .melee,
                               slots: meleeSlots(),
                               baseStats: [.swingSpeed: 60 + Double(i * 3), .attackRange: 30 + Double(i * 2), .penetration: 40, .agility: 65, .balance: 50],
                               magazineSize: 0, baseReload: 0, accent: Color(red: 0.5, green: 0.95, blue: 0.95)))
        }
        return list
    }

    static func makeAllAttachments(_ weapons: [Weapon]) -> [Attachment] {
        var all: [Attachment] = []
        for w in weapons {
            all += genericAttachments(prefix: w.id, slots: w.slots, category: w.category)
        }
        // 去重（同 id 不重复）
        var seen = Set<String>()
        return all.filter { seen.insert($0.id).inserted }
    }
}