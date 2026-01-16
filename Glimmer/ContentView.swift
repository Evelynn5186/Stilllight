import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "CardBackground")
        appearance.shadowColor = .clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ComposeView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
        }
        .tint(Color("ButtonPrimary"))
    }
}

struct ComposeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var accomplishmentText = ""
    @State private var showEncouragement = false
    @State private var currentEncouragement = ""

    private let encouragements = [
        "You're more alive than you think.",
        "That took courage. I see you.",
        "Small steps still move you forward.",
        "You showed up today. That matters.",
        "This moment counts.",
        "Gentle progress is still progress.",
        "You're doing better than you know.",
        "That was worth noticing.",
        "Every little thing adds up.",
        "You chose to show up. That's everything.",
        "This is what growth looks like.",
        "You're building something quietly beautiful."
    ]

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                Text("glimmer")
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
                    .padding(.bottom, 8)

                Text("What's one small thing you did today?")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color("TextSecondary"))
                    .padding(.bottom, 48)

                VStack(spacing: 24) {
                    TextField("I...", text: $accomplishmentText, axis: .vertical)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(20)
                        .background(Color("CardBackground"))
                        .cornerRadius(16)
                        .lineLimit(3...6)
                        .onChange(of: accomplishmentText) {
                            if showEncouragement {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showEncouragement = false
                                }
                            }
                        }

                    Button(action: saveAccomplishment) {
                        Text("Save")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                accomplishmentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color("ButtonDisabled")
                                    : Color("ButtonPrimary")
                            )
                            .cornerRadius(12)
                    }
                    .disabled(accomplishmentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 48)

                if showEncouragement {
                    Text(currentEncouragement)
                        .font(.system(size: 19, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                Spacer()
            }
        }
    }

    private func saveAccomplishment() {
        let trimmedText = accomplishmentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let accomplishment = Accomplishment(text: trimmedText)
        modelContext.insert(accomplishment)

        accomplishmentText = ""
        currentEncouragement = encouragements.randomElement() ?? encouragements[0]

        withAnimation(.easeInOut(duration: 0.4)) {
            showEncouragement = true
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
}
