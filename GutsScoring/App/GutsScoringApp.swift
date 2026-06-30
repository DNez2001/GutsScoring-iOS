import SwiftData
import SwiftUI

@main
struct GutsScoringApp: App {
    private let modelContainer = ScoringModelContainer.makeContainer()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        BackgroundSyncScheduler.register()
        BackgroundSyncScheduler.schedule()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            BackgroundSyncScheduler.schedule()
            Task {
                _ = await SyncFlushService.flushPendingOutboxes(container: modelContainer)
            }
        }
    }
}
