import SwiftUI
import SwiftData
import Speech

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accomplishments: [Accomplishment]
    @AppStorage("pauseCheckIns") private var pauseCheckIns = false
    @State private var hasCheckedInToday = false
    @State private var showGlimmerInput = false
    @State private var showGlimmerOverlay = false
    @State private var selectedGlimmer: Accomplishment?
    @State private var breathGlow: CGFloat = 0
    @State private var isOrbPressed = false

    // Inline input form state
    @State private var glimmerText = ""
    @State private var selectedMood: Mood?
    @State private var showMoreMoods = false
    @State private var showEncouragement = false
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @FocusState private var isTextFieldFocused: Bool
    private let maxCharacters = 300

    // Theme brown color from Figma
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820)

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
                // Sleep Mode: dark navy gradient (170.8deg)
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.047, green: 0.067, blue: 0.145), location: 0.112), // #0C1125
                        .init(color: Color(red: 0.078, green: 0.106, blue: 0.220), location: 0.837), // #141B38
                        .init(color: Color(red: 0.094, green: 0.129, blue: 0.251), location: 0.912)  // #182140
                    ],
                    startPoint: UnitPoint(x: 0.42, y: 0.0),
                    endPoint: UnitPoint(x: 0.58, y: 1.0)
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
            } else if hasCheckedInToday || showGlimmerInput {
                // Warm cream/yellow gradient for checked-in and input mode
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.96, green: 0.9, blue: 0.75), location: 0.00),
                        .init(color: Color(red: 0.95, green: 0.87, blue: 0.64), location: 0.71),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0.32),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
                .ignoresSafeArea()
            } else {
                // Unchecked state: 两组背景渐变 + 图片一起呼吸变化
                ZStack {
                    // 第一组：球暗时的背景 (和 Lightdown 图片配合)
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.07, green: 0.09, blue: 0.11), location: 0.00),
                            .init(color: Color(red: 0.17, green: 0.23, blue: 0.28), location: 0.60),
                            .init(color: Color(red: 0.18, green: 0.24, blue: 0.29), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.45, y: 0.36),
                        endPoint: UnitPoint(x: 0.88, y: 0.85)
                    )

                    // 第二组：球亮时的背景 (和 LightdownHover 图片配合)
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.07, green: 0.09, blue: 0.11), location: 0.00),
                            .init(color: Color(red: 0.16, green: 0.22, blue: 0.27), location: 0.45),
                            .init(color: Color(red: 0.16, green: 0.22, blue: 0.28), location: 0.96),
                        ],
                        startPoint: UnitPoint(x: 0.17, y: 0.46),
                        endPoint: UnitPoint(x: 0.8, y: 0.95)
                    )
                    .opacity(isOrbPressed ? 1.0 : breathGlow)
                }
                .ignoresSafeArea()
            }

            // Fixed Lightup4 character image (locked to background)
            if showGlimmerInput {
                VStack {
                    Image("Lightup4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .padding(.top, 11)
                    Spacer()
                }
            }

            // Checked-in state: Lightup6 character + Gather button
            if hasCheckedInToday && !pauseCheckIns && !showGlimmerInput {
                checkedInContent
            }

            if pauseCheckIns {
                sleepModeContent
            } else if showGlimmerInput {
                glimmerInputContent
            } else {
                normalContent
            }

            // Encouragement overlay
            if showEncouragement {
                InputEncouragementOverlay(
                    onDismiss: {
                        showEncouragement = false
                        showGlimmerInput = false
                    }
                )
            }

            // Glimmer overlay (for "Gather a little light")
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
        .animation(.easeInOut(duration: 0.35), value: showGlimmerOverlay)
        .animation(.easeInOut(duration: 0.6), value: hasCheckedInToday)
        .animation(.easeInOut(duration: 0.6), value: pauseCheckIns)
        .animation(.easeInOut(duration: 0.5), value: showGlimmerInput)
        .animation(.easeInOut(duration: 0.3), value: showEncouragement)
        .onAppear {
            checkTodayStatus()
        }
    }

    // MARK: - Sleep Mode Content

    private var sleepModeContent: some View {
        ZStack {
            // Sleep character image (469×704, left: -37, top: 100)
            GeometryReader { geo in
                Button(action: {
                    pauseCheckIns = false
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 469, height: 704)
                        .background(
                            Image("SleepCharacter")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 449, height: 704)
                                .clipped()
                        )
                }
                .buttonStyle(LightUpButtonStyle())
                .position(
                    x: -37 + 469 / 2,
                    y: 100 + 704 / 2
                )
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Badge pill at top: 228
                Spacer().frame(height: 228)

                Text("Tap the light to resume.")
                    .font(.custom("Urbanist", size: 14).weight(.medium))
                    .foregroundColor(Color(red: 0.659, green: 0.635, blue: 0.624)) // #A8A29E
                    .tracking(-0.084)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 0.659, green: 0.635, blue: 0.624), lineWidth: 0.676)
                    )

                Spacer()

                // Message at top: 622
                VStack(spacing: 0) {
                    Text("The light stays on")
                        .font(.custom("Urbanist", size: 20).weight(.medium))
                        .foregroundColor(Color(red: 0.855, green: 0.855, blue: 0.855)) // #DADADA
                    Text(" ")
                        .font(.system(size: 14))
                    Text("quietly holding your place.")
                        .font(.custom("Urbanist", size: 20).weight(.medium))
                        .foregroundColor(Color(red: 0.855, green: 0.855, blue: 0.855))
                }
                .multilineTextAlignment(.center)

                Spacer()

                Color.clear.frame(height: 100)
            }
        }
    }

    // MARK: - Checked In Content

    private var checkedInContent: some View {
        ZStack {
            // Lightup6 character image (454×454, top: 202, left: -15)
            GeometryReader { geo in
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 454, height: 454)
                    .background(
                        Image("Lightup6")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 454, height: 454)
                            .clipped()
                    )
                    .position(
                        x: -15 + 454 / 2,
                        y: 202 + 454 / 2
                    )
            }
            .ignoresSafeArea()

            // "Gather a little light" button at bottom
            VStack {
                Spacer()

                Button(action: catchGlimmer) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 16, weight: .medium))
                        Text("Gather a little light")
                            .font(.custom("Urbanist", size: 16).weight(.medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.22, green: 0.10, blue: 0.01))
                    )
                }

                Spacer().frame(height: 140)
            }
        }
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
                    .padding(.horizontal, 8.11)
                    .padding(.vertical, 4.06)
                    .frame(width: 187, height: 29)
                    .cornerRadius(6759.89)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6759.89)
                            .inset(by: 0.34)
                            .stroke(Color(red: 0.66, green: 0.64, blue: 0.62), lineWidth: 0.68)
                    )
                    .padding(.bottom, 32)
            }

            // Character/Light illustration
            if hasCheckedInToday {
                // Checked-in state uses absolute positioning
                EmptyView()
            } else {
                Button(action: { showGlimmerInput = true }) {
                    Color.clear
                        .frame(width: 67, height: 63)
                        .contentShape(Rectangle())
                }
                .buttonStyle(LightDownButtonStyle(breathGlow: $breathGlow, isOrbPressed: $isOrbPressed))
            }

            Spacer()

            // Bottom spacer for tab bar
            Color.clear.frame(height: 120)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Inline Glimmer Input Content

    private var glimmerInputContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Transparent spacer so the fixed character image is visible
                Color.clear.frame(height: 310)

                // Close button
                Button(action: dismissInput) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 45, height: 47)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(themeBrown)
                        )
                        .shadow(color: Color(red: 0.98, green: 0.93, blue: 0.76).opacity(0.5), radius: 4, x: 0, y: 3.2)
                }

                // Form content
                VStack(spacing: 0) {
                    // "How are you feeling today?"
                    Text("How are you feeling today?")
                        .font(.custom("Libre Baskerville", size: 16))
                        .foregroundColor(themeBrown)
                        .tracking(-0.192)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)

                    // Mood selection bar
                    inlineMoodBar
                        .padding(.top, 12)

                    // "Where did the light show up today?"
                    Text("Where did the light show up today?")
                        .font(.custom("Libre Baskerville", size: 16))
                        .foregroundColor(themeBrown)
                        .tracking(-0.192)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)

                    // Input section
                    VStack(alignment: .leading, spacing: 8) {
                        // Sparkle + label
                        HStack(spacing: 6) {
                            Image("Sparkle4")
                                .resizable()
                                .frame(width: 18, height: 18)
                            Text("A trace of light…")
                                .font(.custom("Urbanist", size: 14).weight(.semibold))
                                .foregroundColor(themeBrown)
                                .tracking(-0.084)
                        }

                        // Text input area
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $glimmerText)
                                .font(.custom("Urbanist", size: 14))
                                .foregroundColor(themeBrown)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .frame(minHeight: 120, maxHeight: 160)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(borderColor, lineWidth: 1)
                                        )
                                )
                                .focused($isTextFieldFocused)
                                .onChange(of: speechRecognizer.transcript) {
                                    if !speechRecognizer.transcript.isEmpty {
                                        glimmerText = speechRecognizer.transcript
                                    }
                                }
                                .onChange(of: glimmerText) {
                                    if glimmerText.count > maxCharacters {
                                        glimmerText = String(glimmerText.prefix(maxCharacters))
                                    }
                                }

                            // Placeholder
                            if glimmerText.isEmpty {
                                Text("Ex. Video chatted with an old friend; Had a really good meal with a friend.")
                                    .font(.custom("Urbanist", size: 14))
                                    .foregroundColor(themeBrown.opacity(0.5))
                                    .padding(12)
                                    .padding(.top, 8)
                                    .allowsHitTesting(false)
                            }
                        }

                        // Character count + mic
                        HStack {
                            Spacer()
                            Text("\(glimmerText.count)/\(maxCharacters)")
                                .font(.custom("Urbanist", size: 12))
                                .foregroundColor(Color(red: 0.659, green: 0.635, blue: 0.624))
                                .tracking(-0.06)

                            Button(action: toggleRecording) {
                                Image(systemName: speechRecognizer.isRecording ? "mic.fill" : "mic")
                                    .font(.system(size: 10))
                                    .foregroundColor(speechRecognizer.isRecording ? .white : Color(red: 0.659, green: 0.635, blue: 0.624))
                                    .frame(width: 11, height: 11)
                            }
                        }

                        // Helper text
                        Text("It can be something small. Just a few words is enough.")
                            .font(.custom("Urbanist", size: 14))
                            .foregroundColor(themeBrown)
                            .tracking(-0.084)
                    }
                    .padding(.top, 4)

                    // Submit button
                    Button(action: submitGlimmer) {
                        HStack {
                            Text("This moment is kept.")
                                .font(.custom("Urbanist", size: 14))
                                .tracking(-0.14)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 21)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    glimmerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? themeBrown.opacity(0.3)
                                        : themeBrown
                                )
                        )
                    }
                    .disabled(glimmerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.top, 24)
                    .padding(.bottom, 140)
                }
                .padding(.horizontal, 28)
                .background(
                    // Union decorative gradient (scrolls with form)
                    UnionShape()
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(red: 0.84, green: 0.91, blue: 1.0), location: 0.00),
                                    .init(color: Color(red: 1.0, green: 0.98, blue: 0.93), location: 0.69),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 560, height: 662)
                        .shadow(color: Color(red: 1.0, green: 0.88, blue: 0.55), radius: 7.5, x: 0, y: -8)
                        .opacity(0.7)
                        .offset(y: -30)
                    , alignment: .top
                )
            }
        }
        .scrollIndicators(.hidden)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - Inline Mood Bar

    private var inlineMoodBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                ForEach(Mood.primary, id: \.self) { mood in
                    inlineMoodButton(mood)
                }

                // More button
                Button(action: { showMoreMoods.toggle() }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .stroke(themeBrown, lineWidth: 1)
                                .frame(width: 25, height: 25)
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Color(red: 0.196, green: 0.196, blue: 0.196))
                        }
                        .frame(width: 30, height: 30)
                        Text("More")
                            .font(.custom("Urbanist", size: 8))
                            .foregroundColor(themeBrown.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )

            if showMoreMoods {
                HStack(spacing: 0) {
                    ForEach(Mood.secondary, id: \.self) { mood in
                        inlineMoodButton(mood)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(borderColor, lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showMoreMoods)
    }

    private func inlineMoodButton(_ mood: Mood) -> some View {
        Button(action: {
            if selectedMood == mood {
                selectedMood = nil
            } else {
                selectedMood = mood
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(selectedMood == mood ? mood.color : mood.color.opacity(0.3))
                        .frame(width: 30, height: 30)
                    MoodEmojiView(mood: mood, size: 26)
                }
                .overlay(
                    selectedMood == mood
                        ? Circle().stroke(themeBrown, lineWidth: 2).frame(width: 34, height: 34)
                        : nil
                )
                Text(mood.rawValue)
                    .font(.custom("Urbanist", size: 8))
                    .foregroundColor(themeBrown.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Input Helpers

    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
        } else {
            speechRecognizer.startTranscribing()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func dismissInput() {
        isTextFieldFocused = false
        glimmerText = ""
        selectedMood = nil
        showMoreMoods = false
        showGlimmerInput = false
    }

    private func submitGlimmer() {
        let trimmedText = glimmerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showEncouragement = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            saveGlimmer(trimmedText, mood: selectedMood)
            glimmerText = ""
            selectedMood = nil
            showMoreMoods = false
            showGlimmerInput = false
        }
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
        selectedGlimmer = accomplishments.isEmpty ? nil : accomplishments.randomElement()
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

// MARK: - Light Down Button Style (breathing glow + full glow on press)

struct LightDownButtonStyle: ButtonStyle {
    @Binding var breathGlow: CGFloat
    @Binding var isOrbPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .bottomTrailing) {
            // Base dark image (always visible)
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 454, height: 454)
                .background(
                    Image("Lightdown")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 454, height: 454)
                        .clipped()
                )

            // Glowing image layered on top
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 454, height: 454)
                .background(
                    Image("LightdownHover")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 454, height: 454)
                        .clipped()
                )
                .opacity(configuration.isPressed ? 1.0 : breathGlow)

            // Position the hit-target label over the ball/orb
            configuration.label
                .padding(.trailing, 55)
                .padding(.bottom, 100)
        }
        .onChange(of: configuration.isPressed) { _, pressed in
            isOrbPressed = pressed
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.4)
                .repeatForever(autoreverses: true)
            ) {
                breathGlow = 0.6
            }
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

// MARK: - Union Shape (curved top decorative background)

struct UnionShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let curveHeight: CGFloat = rect.height * 0.1

        path.move(to: CGPoint(x: 0, y: curveHeight))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: curveHeight),
            control: CGPoint(x: rect.width / 2, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
}
