import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accomplishments: [Accomplishment]
    @AppStorage("pauseCheckIns") private var pauseCheckIns = false
    @State private var hasCheckedInToday = false
    @State private var showGlimmerInput = false
    @State private var showGlimmerOverlay = false
    @State private var selectedGlimmer: Accomplishment?

    // Theme brown color from Figma
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    /// Days since last check-in
    private var daysSinceLastCheckIn: Int {
        guard let latest = accomplishments.max(by: { $0.createdAt < $1.createdAt }) else {
            return 999
        }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: latest.createdAt), to: calendar.startOfDay(for: Date())).day ?? 0
        return days
    }

    /// Show "longtime no visit" state when user hasn't checked in for 7+ days
    private var isLongtimeNoVisit: Bool {
        !accomplishments.isEmpty && daysSinceLastCheckIn >= 7 && !pauseCheckIns
    }

    var body: some View {
        ZStack {
            // Background - changes based on state
            if pauseCheckIns {
                // Sleep Mode: dark navy gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.047, green: 0.067, blue: 0.145), // #0C1125
                        Color(red: 0.094, green: 0.129, blue: 0.251)  // #182140
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else if isLongtimeNoVisit {
                // Longtime no visit: dark blue-purple gradient
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.129, green: 0.165, blue: 0.310), location: 0.0),  // #212A4F
                        .init(color: Color(red: 0.251, green: 0.306, blue: 0.471), location: 0.4),  // #404E78
                        .init(color: Color(red: 0.353, green: 0.420, blue: 0.592), location: 0.7),  // #5A6B97
                        .init(color: Color(red: 0.251, green: 0.302, blue: 0.478), location: 1.0)   // #404D7A
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else if hasCheckedInToday {
                // Warm cream/yellow gradient background when checked in
                LinearGradient(
                    colors: [
                        Color(red: 0.976, green: 0.929, blue: 0.757),
                        Color(red: 0.980, green: 0.929, blue: 0.757)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                // Dark gradient background when not checked in
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.067, green: 0.086, blue: 0.110), location: 0.37),
                        .init(color: Color(red: 0.173, green: 0.231, blue: 0.278), location: 0.66),
                        .init(color: Color(red: 0.176, green: 0.239, blue: 0.290), location: 0.85)
                    ],
                    startPoint: UnitPoint(x: 0.3, y: 0.0),
                    endPoint: UnitPoint(x: 0.7, y: 1.0)
                )
                .ignoresSafeArea()
            }

            if pauseCheckIns {
                // Sleep Mode content
                sleepModeContent
            } else {
                // Normal mode content
                normalContent
            }

            // Glimmer overlay
            if showGlimmerOverlay {
                GlimmerOverlay(
                    accomplishment: selectedGlimmer,
                    isPresented: $showGlimmerOverlay
                )
                .onTapGesture {
                    showGlimmerOverlay = false
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: hasCheckedInToday)
        .animation(.easeInOut(duration: 0.6), value: pauseCheckIns)
        .animation(.easeInOut(duration: 0.35), value: showGlimmerOverlay)
        .sheet(isPresented: $showGlimmerInput) {
            GlimmerInputView(
                onSave: { text, mood in
                    saveGlimmer(text, mood: mood)
                    showGlimmerInput = false
                },
                onDismiss: {
                    showGlimmerInput = false
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            checkTodayStatus()
        }
    }

    // MARK: - Sleep Mode Content

    private var sleepModeContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Badge pill
            Text("Tap the light to resume.")
                .font(.custom("Urbanist", size: 14).weight(.medium))
                .foregroundColor(Color(red: 0.855, green: 0.855, blue: 0.855)) // #DADADA
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .overlay(
                    Capsule()
                        .stroke(Color(red: 0.855, green: 0.855, blue: 0.855).opacity(0.4), lineWidth: 0.68)
                )
                .padding(.bottom, 24)

            // Character image - tappable to resume
            Button(action: {
                pauseCheckIns = false
            }) {
                Image("Lightup4")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 420, maxHeight: 420)
                    .opacity(0.6)
            }
            .buttonStyle(LightUpButtonStyle())

            // Message
            Text("The light stays on quietly\nholding your place.")
                .font(.custom("Urbanist", size: 20).weight(.medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 16)

            Spacer()

            Color.clear.frame(height: 120)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Normal Content

    private var normalContent: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hint pill - shown when not checked in
            if !hasCheckedInToday {
                Text("Tap the light to mark today.")
                    .font(.custom("Urbanist", size: 12).weight(.medium))
                    .foregroundColor(Color(red: 0.66, green: 0.64, blue: 0.62))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 0.66, green: 0.64, blue: 0.62), lineWidth: 0.68)
                    )
                    .padding(.bottom, 32)
            }

            // Character/Light illustration
            if hasCheckedInToday {
                Button(action: {}) {
                    Image("Lightup6")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320, maxHeight: 380)
                }
                .buttonStyle(LightUpButtonStyle())
            } else {
                Button(action: { showGlimmerInput = true }) {
                    // The label is just the ball hit area; background image is handled by the style
                    Color.clear
                        .frame(width: 67, height: 63)
                        .contentShape(Rectangle())
                }
                .buttonStyle(LightDownButtonStyle())
            }

            Spacer()

            // Bottom button area - only when checked in
            if hasCheckedInToday {
                Button(action: catchGlimmer) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .medium))
                        Text("Gather a little light")
                            .font(.custom("Urbanist", size: 14).weight(.medium))
                    }
                    .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0.29, green: 0.29, blue: 0.29), lineWidth: 0.5)
                    )
                }
                .padding(.bottom, 120)
            } else {
                Color.clear.frame(height: 120)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Functions

    private func checkTodayStatus() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        hasCheckedInToday = accomplishments.contains { accomplishment in
            calendar.isDate(accomplishment.createdAt, inSameDayAs: today)
        }
    }

    private func saveGlimmer(_ text: String, mood: Mood? = nil) {
        let accomplishment = Accomplishment(text: text, mood: mood)
        modelContext.insert(accomplishment)
        hasCheckedInToday = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func catchGlimmer() {
        if accomplishments.isEmpty {
            selectedGlimmer = nil
        } else {
            selectedGlimmer = accomplishments.randomElement()
        }
        showGlimmerOverlay = true
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

// MARK: - Light Up Button Style (touched_mode press effect)

struct LightUpButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            .brightness(configuration.isPressed ? 0.08 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Light Down Button Style (swaps background image on press)

struct LightDownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 454, height: 454)
                .background(
                    Image(configuration.isPressed ? "LightdownHover" : "Lightdown")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 454, height: 454)
                        .clipped()
                )
                .animation(.easeInOut(duration: 0.3), value: configuration.isPressed)

            // Position the hit-target label over the ball/orb
            configuration.label
                .padding(.trailing, 55)
                .padding(.bottom, 100)
        }
    }
}

// MARK: - Glimmer Overlay

struct GlimmerOverlay: View {
    let accomplishment: Accomplishment?
    @Binding var isPresented: Bool

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                    .padding(.bottom, 4)

                if let accomplishment = accomplishment {
                    if let mood = accomplishment.mood {
                        Text(mood.rawValue)
                            .font(.custom("Urbanist", size: 20).weight(.medium))
                            .foregroundColor(themeBrown)
                    }

                    Text(accomplishment.text)
                        .font(.custom("Baskerville", size: 17))
                        .foregroundColor(themeBrown)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(formattedDate(accomplishment.createdAt))
                        .font(.custom("Urbanist", size: 13))
                        .foregroundColor(themeBrown.opacity(0.6))
                        .padding(.top, 4)
                } else {
                    Text("Keep collecting glimmers,\nthey'll be here waiting for you.")
                        .font(.custom("Urbanist", size: 16))
                        .foregroundColor(themeBrown.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 32)
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 8)
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

#Preview {
    HomeView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
}
