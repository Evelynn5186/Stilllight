import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accomplishments: [Accomplishment]
    @State private var hasCheckedInToday = false
    @State private var showGlimmerInput = false
    @State private var showGlimmerOverlay = false
    @State private var selectedGlimmer: Accomplishment?

    // Theme brown color from Figma
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    var body: some View {
        ZStack {
            // Background - changes based on check-in state
            if hasCheckedInToday {
                // Warm cream/yellow gradient background when checked in (from Figma #F9EDC1 to #FAEDC1)
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
                // Dark gradient background when not checked in (from Figma ~158° angle)
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

            // No additional ellipses needed - clean gradient background per Figma design

            VStack(spacing: 0) {
                Spacer()

                // Hint pill - only shown when not checked in
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

                // Character/Light illustration - tappable to light up
                Button(action: {
                    if !hasCheckedInToday {
                        showGlimmerInput = true
                    }
                }) {
                    if hasCheckedInToday {
                        Image("Lightup6")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 320, maxHeight: 380)
                    } else {
                        Image("Lightup4")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 420, maxHeight: 420)
                    }
                }
                .buttonStyle(LightUpButtonStyle())

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
        .animation(.easeInOut(duration: 0.35), value: showGlimmerOverlay)
        .sheet(isPresented: $showGlimmerInput) {
            GlimmerInputView(
                onSave: { text in
                    saveGlimmer(text)
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

    private func checkTodayStatus() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        hasCheckedInToday = accomplishments.contains { accomplishment in
            calendar.isDate(accomplishment.createdAt, inSameDayAs: today)
        }
    }

    private func saveGlimmer(_ text: String) {
        let accomplishment = Accomplishment(text: text)
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
                    Text(accomplishment.text)
                        .font(.custom("Urbanist", size: 17))
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
