import SwiftUI
import SwiftData

@main
struct GlimmerApp: App {
    @State private var showSplash = true
    @StateObject private var appSettings = AppSettings.shared
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var journalViewModel = JournalViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Accomplishment.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(showSplash ? 0 : 1)
                    .environmentObject(appSettings)
                    .environmentObject(homeViewModel)
                    .environmentObject(journalViewModel)

                if showSplash {
                    SplashView(isActive: $showSplash)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
        }
        .modelContainer(sharedModelContainer)
    }
}
