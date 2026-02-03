import SwiftUI
import SwiftData
import Speech

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
    @Query private var accomplishments: [Accomplishment]
    @State private var accomplishmentText = ""
    @State private var showEncouragement = false
    @State private var currentEncouragement = ""
    @State private var currentPlaceholder = ""
    @State private var dismissTask: Task<Void, Never>?
    @State private var showGlimmer = false
    @State private var selectedGlimmer: Accomplishment?
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var hasSpeechPermission = false

    private let placeholders = [
        "One tiny thing you did for yourself today...",
        "What made today 1% better?",
        "A small moment that wasn't bad...",
        "Something you noticed today...",
        "One thing that went okay...",
        "A quiet moment you had...",
        "Something small you managed...",
        "What's one thing you didn't hate today?",
        "A little thing that happened...",
        "Something you got through...",
        "One gentle thing from today...",
        "A moment you can hold onto...",
        "Something that felt like enough..."
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
                    // Text input with microphone button
                    HStack(alignment: .bottom, spacing: 12) {
                        TextField(currentPlaceholder, text: $accomplishmentText, axis: .vertical)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(Color("TextPrimary"))
                            .padding(20)
                            .background(Color("CardBackground"))
                            .cornerRadius(16)
                            .lineLimit(3...6)
                            .onChange(of: speechRecognizer.transcript) {
                                if !speechRecognizer.transcript.isEmpty {
                                    accomplishmentText = speechRecognizer.transcript
                                }
                            }

                        // Microphone button
                        Button(action: toggleRecording) {
                            Image(systemName: speechRecognizer.isRecording ? "mic.fill" : "mic")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(speechRecognizer.isRecording ? .white : Color("ButtonPrimary"))
                                .frame(width: 52, height: 52)
                                .background(
                                    Circle()
                                        .fill(speechRecognizer.isRecording ? Color("ButtonPrimary") : Color("CardBackground"))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color("ButtonPrimary").opacity(speechRecognizer.isRecording ? 0 : 0.3), lineWidth: 1)
                                )
                        }
                        .animation(.easeInOut(duration: 0.2), value: speechRecognizer.isRecording)
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

                // Catch a Glimmer button
                CatchGlimmerButton {
                    catchGlimmer()
                }
                .padding(.bottom, 32)
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

            // Glimmer overlay
            if showGlimmer {
                GlimmerOverlay(
                    accomplishment: selectedGlimmer,
                    isPresented: $showGlimmer
                )
                .onTapGesture {
                    showGlimmer = false
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showEncouragement)
        .animation(.easeInOut(duration: 0.35), value: showGlimmer)
        .onAppear {
            currentPlaceholder = placeholders.randomElement() ?? placeholders[0]
        }
        .task {
            hasSpeechPermission = await speechRecognizer.requestAuthorization()
        }
    }

    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
        } else {
            speechRecognizer.startTranscribing()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

    private func catchGlimmer() {
        if accomplishments.isEmpty {
            selectedGlimmer = nil
        } else {
            selectedGlimmer = accomplishments.randomElement()
        }
        showGlimmer = true
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

// MARK: - Catch Glimmer Button

struct CatchGlimmerButton: View {
    let action: () -> Void
    @State private var glowOpacity: Double = 0.3
    @State private var glowScale: CGFloat = 0.95

    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer glow layers
                Capsule()
                    .fill(Color("ButtonPrimary").opacity(0.15))
                    .frame(width: 180, height: 52)
                    .scaleEffect(glowScale + 0.15)
                    .opacity(glowOpacity * 0.5)

                Capsule()
                    .fill(Color("ButtonPrimary").opacity(0.2))
                    .frame(width: 170, height: 48)
                    .scaleEffect(glowScale + 0.08)
                    .opacity(glowOpacity * 0.7)

                // Button
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 15, weight: .medium))
                    Text("捞取微光")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                }
                .foregroundColor(Color("ButtonPrimary"))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color("CardBackground"))
                        .shadow(color: Color("ButtonPrimary").opacity(0.15), radius: 12, x: 0, y: 4)
                )
                .overlay(
                    Capsule()
                        .stroke(Color("ButtonPrimary").opacity(0.25), lineWidth: 1)
                )
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 5.5)
                .repeatForever(autoreverses: true)
            ) {
                glowOpacity = 0.8
                glowScale = 1.1
            }
        }
    }
}

// MARK: - Glimmer Overlay

struct GlimmerOverlay: View {
    let accomplishment: Accomplishment?
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Soft dimmed background
            Color.black.opacity(0.08)
                .ignoresSafeArea()
                .transition(.opacity)

            // Card
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(Color("ButtonPrimary").opacity(0.8))
                    .padding(.bottom, 4)

                if let accomplishment = accomplishment {
                    Text(accomplishment.text)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(formattedDate(accomplishment.createdAt))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.top, 4)
                } else {
                    Text("Keep collecting glimmers,\nthey'll be here waiting for you.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }

        return formatter.string(from: date)
    }
}

// MARK: - Breathing Circle

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

// MARK: - Encouragement Overlay

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

// MARK: - Previews

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

#Preview("Catch Glimmer Button") {
    ZStack {
        Color("Background")
            .ignoresSafeArea()

        CatchGlimmerButton {
            print("Caught!")
        }
    }
}
