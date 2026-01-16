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
    @State private var currentPlaceholder = ""
    @State private var dismissTask: Task<Void, Never>?

    private let placeholders = [
        "Did you drink water today?",
        "Did you see a nice cloud?",
        "Did you put your phone down for a bit?",
        "Did you step outside?",
        "Did you eat something you liked?",
        "Did you stretch a little?",
        "Did you take a deep breath?",
        "Did you notice something beautiful?",
        "Did you rest for a moment?",
        "Did you feel the sun today?",
        "Did you listen to a song you love?",
        "Did you sit somewhere comfortable?",
        "Did you look out a window?",
        "Did you wash your face?",
        "Did you make your bed?",
        "Did you say something kind to yourself?"
    ]

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

            // Breathing circle
            BreathingCircle()

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
                    TextField(currentPlaceholder, text: $accomplishmentText, axis: .vertical)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(20)
                        .background(Color("CardBackground"))
                        .cornerRadius(16)
                        .lineLimit(3...6)

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
            }

            // Encouragement overlay
            if showEncouragement {
                EncouragementOverlay(
                    message: currentEncouragement,
                    isPresented: $showEncouragement
                )
                .onTapGesture {
                    dismissOverlay()
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showEncouragement)
        .onAppear {
            currentPlaceholder = placeholders.randomElement() ?? placeholders[0]
        }
    }

    private func saveAccomplishment() {
        let trimmedText = accomplishmentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let accomplishment = Accomplishment(text: trimmedText)
        modelContext.insert(accomplishment)

        accomplishmentText = ""
        currentEncouragement = encouragements.randomElement() ?? encouragements[0]
        showEncouragement = true

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Cancel any existing dismiss task
        dismissTask?.cancel()

        // Auto-dismiss after 3 seconds
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                await MainActor.run {
                    dismissOverlay()
                }
            }
        }
    }

    private func dismissOverlay() {
        dismissTask?.cancel()
        showEncouragement = false
    }
}

struct BreathingCircle: View {
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.3

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color("ButtonPrimary").opacity(0.15),
                        Color("ButtonPrimary").opacity(0.05),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                )
            )
            .frame(width: 320, height: 320)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: -50)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 5.5)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.2
                    opacity = 0.7
                }
            }
    }
}

struct EncouragementOverlay: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Soft dimmed background
            Color.black.opacity(0.08)
                .ignoresSafeArea()
                .transition(.opacity)

            // Card
            VStack(spacing: 20) {
                Image(systemName: "sparkle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Color("ButtonPrimary").opacity(0.8))

                Text(message)
                    .font(.system(size: 19, weight: .regular, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 36)
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("CardBackground"))
                    .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 8)
            )
            .transition(
                .opacity
                .combined(with: .scale(scale: 0.92))
            )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
}

#Preview("Overlay") {
    ZStack {
        Color("Background")
            .ignoresSafeArea()

        EncouragementOverlay(
            message: "You're more alive than you think.",
            isPresented: .constant(true)
        )
    }
}
