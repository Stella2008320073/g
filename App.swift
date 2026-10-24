import SwiftUI

@main
struct TargetWorkshopApp: App {
    @StateObject private var fps = FPSMonitor()
    @StateObject private var store = LoadoutStore()
    @State private var route: Route = .lobby

    let weapons: [Weapon]
    let attachments: [Attachment]

    init() {
        let w = Library.makeWeapons()
        weapons = w
        attachments = Library.makeAllAttachments(w)
    }

    var body: some Scene {
        WindowGroup {
            RootView(fps: fps, store: store, route: $route, weapons: weapons, attachments: attachments)
                .frame(minWidth: 1320, minHeight: 820)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @ObservedObject var fps: FPSMonitor
    @ObservedObject var store: LoadoutStore
    @Binding var route: Route
    let weapons: [Weapon]
    let attachments: [Attachment]

    var body: some View {
        Group {
            switch route {
            case .lobby:
                LobbyView(fps: fps, route: $route)
            case .workshop:
                WorkshopView(fps: fps, route: $route, store: store, weapons: weapons, attachments: attachments)
            case .range:
                RangeView(fps: fps, route: $route, store: store, weapons: weapons, attachments: attachments)
            }
        }
        .onAppear {
            if store.selectedWeaponID == nil {
                store.selectedWeaponID = weapons.first(where: { $0.category == store.selectedCategory })?.id
            }
        }
    }
}
