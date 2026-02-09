import SwiftUI
import SwiftData
import Speech

struct HomeView: View {
    // MARK: - Environment
    @EnvironmentObject var viewModel: HomeViewModel

    // MARK: - UI State
    @State private var showGlimmerInput = false
    @State private var showGlimmerOverlay = false
    @State private var selectedGlimmer: Accomplishment?
    @State private var selectedWarmMessage: String?  // AI warm message for overlay
    @State private var breathGlow: CGFloat = 0
    @State private var isOrbPressed = false

    // Inline input form state
    @State private var glimmerText = ""
    @State private var selectedMood: Mood?
    @State private var showMoreMoods = false
    @State private var showEncouragement = false
    @State private var encouragementMessage: String?  // AI message for encouragement
    @State private var isLoadingAIMessage = false     // Loading state for AI message
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @FocusState private var isTextFieldFocused: Bool
    private let maxCharacters = 300

    // Theme brown color from Figma
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820)

    // MARK: - Computed Properties (use ViewModel)

    private var pauseCheckIns: Bool { viewModel.isPaused }
    private var hasCheckedInToday: Bool { viewModel.hasCheckedInToday }
    private var daysSinceLastCheckIn: Int { viewModel.daysSinceLastCheckIn }
    private var isLongtimeNoVisit: Bool { viewModel.isLongtimeNoVisit }

    var body: some View {
        ZStack {
            // Background - changes based on state
            if pauseCheckIns {
                // Sleep Mode: dark navy gradient
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.05, green: 0.07, blue: 0.15), location: 0.00),
                        .init(color: Color(red: 0.08, green: 0.11, blue: 0.22), location: 0.82),
                        .init(color: Color(red: 0.09, green: 0.13, blue: 0.25), location: 0.90),
                    ],
                    startPoint: UnitPoint(x: 0.62, y: 0.07),
                    endPoint: UnitPoint(x: 0.95, y: 1)
                )
                .ignoresSafeArea()
            } else if showGlimmerInput {
                // Input mode: warm cream gradient
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.98, green: 0.93, blue: 0.76), location: 0.00),
                        .init(color: Color(red: 0.98, green: 0.93, blue: 0.76), location: 0.71),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0.32),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
                .ignoresSafeArea()
            } else if hasCheckedInToday {
                // Checked-in mode: warm cream/yellow gradient
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.96, green: 0.9, blue: 0.75), location: 0.00),
                        .init(color: Color(red: 0.95, green: 0.87, blue: 0.64), location: 0.71),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0.32),
                    endPoint: UnitPoint(x: 0.5, y: 1)
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

            // Checked-in state: Lightup6 character + Gather button
            if hasCheckedInToday && !pauseCheckIns && !showGlimmerInput {
                checkedInContent
            }

            if pauseCheckIns {
                sleepModeContent
            } else if showGlimmerInput {
                // Input mode: Lightup4 at top + form below
                ZStack(alignment: .top) {
                    // Lightup4 character at top
                    VStack {
                        Image("Lightup4")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .padding(.top, 11)
                        Spacer()
                    }

                    // Form content
                    glimmerInputContent
                }
                .transition(.opacity)
            } else {
                normalContent
            }

            // Encouragement overlay with AI message
            if showEncouragement {
                InputEncouragementOverlay(
                    onDismiss: {
                        showEncouragement = false
                        showGlimmerInput = false
                        encouragementMessage = nil
                        isLoadingAIMessage = false
                    },
                    aiMessage: encouragementMessage,
                    isLoading: isLoadingAIMessage
                )
            }

            // Glimmer overlay (for "Gather a little light")
            if showGlimmerOverlay {
                GlimmerOverlay(
                    accomplishment: selectedGlimmer,
                    warmMessage: selectedWarmMessage,
                    isPresented: $showGlimmerOverlay
                )
                .onTapGesture {
                    showGlimmerOverlay = false
                    selectedWarmMessage = nil
                }
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showGlimmerOverlay)
        .animation(.easeInOut(duration: 0.6), value: hasCheckedInToday)
        .animation(.easeInOut(duration: 0.6), value: pauseCheckIns)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showGlimmerInput)
        .animation(.easeInOut(duration: 0.3), value: showEncouragement)
        .onAppear {
            checkTodayStatus()
        }
    }

    // MARK: - Sleep Mode Content

    private var sleepModeContent: some View {
        ZStack {
            // Sleep character image (缩小居中)
            GeometryReader { geo in
                Button(action: {
                    Task { await viewModel.setPaused(false) }
                }) {
                    Image("SleepCharacter")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 469, height: 704)
                }
                .buttonStyle(LightUpButtonStyle())
                .position(
                    x: geo.size.width / 2,  // 居中偏左20pt
                    y: 100 + 352                  // top: 100 + 半高
                )
            }
            .ignoresSafeArea()

            // UI overlay
            VStack(spacing: 0) {
                Spacer().frame(height: 180)

                // "Tap the light to resume." badge
                Text("Tap the light to resume.")
                    .font(.custom("Urbanist", size: 14).weight(.medium))
                    .foregroundColor(Color(red: 0.659, green: 0.635, blue: 0.624))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 0.659, green: 0.635, blue: 0.624), lineWidth: 1)
                    )

                Spacer()

                // Bottom message
                VStack(spacing: 4) {
                    Text("The light stays on")
                        .font(.custom("Urbanist", size: 20).weight(.medium))
                        .foregroundColor(Color(red: 0.855, green: 0.855, blue: 0.855))
                    Text("quietly holding your place.")
                        .font(.custom("Urbanist", size: 20).weight(.medium))
                        .foregroundColor(Color(red: 0.855, green: 0.855, blue: 0.855))
                }
                .multilineTextAlignment(.center)

                Spacer().frame(height: 140)
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

            // "Record another light" button at bottom
            VStack {
                Spacer()

                Button(action: { showGlimmerInput = true }) {
                    HStack(alignment: .center, spacing: 8) {
                        Image("Sparkle4")
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text("Record another light")
                            .font(.custom("Urbanist", size: 14).weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.29, green: 0.29, blue: 0.29))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .cornerRadius(9999)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9999)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.29, green: 0.29, blue: 0.29), lineWidth: 1)
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
                MoodEmojiView(mood: mood, size: 30)
                    .opacity(selectedMood == mood ? 1.0 : 0.5)
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

        // Show loading state immediately
        isLoadingAIMessage = true
        showEncouragement = true

        let moodToSave = selectedMood
        let textToSave = trimmedText

        Task {
            // 1. Save the glimmer first (API handles storage)
            let success = await viewModel.saveGlimmer(text: textToSave, mood: moodToSave)

            // Note: We don't insert into SwiftData here anymore
            // JournalView will fetch fresh data from API

            // 2. Fetch AI warm message
            if let journalWithMsg = await viewModel.getRandomGlimmer() {
                if let warmMessages = journalWithMsg.warmMessage?.alternatives,
                   !warmMessages.isEmpty {
                    let randomIndex = Int.random(in: 0..<warmMessages.count)
                    encouragementMessage = warmMessages[randomIndex].warmMessage
                }
            }

            // 3. Show the message (stop loading)
            isLoadingAIMessage = false
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            // 4. Clear input state
            glimmerText = ""
            selectedMood = nil
            showMoreMoods = false

            // 5. Auto-dismiss after showing the message
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            showGlimmerInput = false
            showEncouragement = false
            encouragementMessage = nil
        }
    }

    // MARK: - Functions

    private func checkTodayStatus() {
        Task {
            await viewModel.loadStatus()
        }
    }

    private func catchGlimmer() {
        Task {
            // First ensure moods are loaded
            await viewModel.loadMoods()

            // Try to get journal with AI warm message first
            if let journalWithMsg = await viewModel.getRandomGlimmer() {
                let mood = viewModel.getMoodForDate(journalWithMsg.localDate)
                selectedGlimmer = Accomplishment(
                    text: journalWithMsg.content,
                    mood: mood,
                    createdAt: journalWithMsg.createdAt,
                    localDate: journalWithMsg.localDate,
                    journalId: journalWithMsg.journalId
                )
                // Extract warm message from API response
                if let warmMessages = journalWithMsg.warmMessage?.alternatives,
                   !warmMessages.isEmpty {
                    let randomIndex = Int.random(in: 0..<warmMessages.count)
                    selectedWarmMessage = warmMessages[randomIndex].warmMessage
                } else {
                    selectedWarmMessage = nil
                }
            } else if let journal = await viewModel.getRandomJournalFallback() {
                // Fallback: get random journal without AI message
                let mood = viewModel.getMoodForDate(journal.localDate)
                selectedGlimmer = Accomplishment(
                    text: journal.content,
                    mood: mood,
                    createdAt: journal.createdAt,
                    localDate: journal.localDate,
                    journalId: journal.journalId
                )
                selectedWarmMessage = nil  // No AI message available
            } else {
                selectedGlimmer = nil
                selectedWarmMessage = nil
            }
            showGlimmerOverlay = true
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
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
    var warmMessage: String? = nil  // AI-generated warm message
    @Binding var isPresented: Bool

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let cardBlue = Color(red: 0.84, green: 0.91, blue: 1.0)

    // Fallback messages when no AI message is available
    private let fallbackInsights = [
        "Simple moments can still mean something.",
        "You noticed the light. That's enough.",
        "This was worth holding onto.",
        "The small things carry the most warmth.",
        "You showed up, and that matters.",
        "Every glimmer adds to the whole.",
    ]

    private var insight: String {
        if let warmMessage = warmMessage, !warmMessage.isEmpty {
            return warmMessage
        }
        let day = Calendar.current.component(.day, from: Date())
        return fallbackInsights[day % fallbackInsights.count]
    }

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
                    // Character emoji (no background needed)
                    if let mood = accomplishment.mood {
                        MoodEmojiView(mood: mood, size: 60, style: .character)
                            .padding(.bottom, 4)
                    }

                    // Journal content in blue card
                    VStack(spacing: 8) {
                        Text("\u{201C}" + accomplishment.text + "\u{201D}")
                            .font(.custom("Baskerville", size: 15))
                            .foregroundColor(themeBrown)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(formattedDate(accomplishment.createdAt))
                            .font(.custom("Urbanist", size: 11))
                            .foregroundColor(themeBrown.opacity(0.5))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(cardBlue)
                    )

                    // AI warm message below
                    Text(insight)
                        .font(.custom("Urbanist", size: 14))
                        .foregroundColor(themeBrown.opacity(0.7))
                        .italic()
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)

                    // Tap to dismiss hint
                    Text("Tap to close")
                        .font(.custom("Urbanist", size: 11))
                        .foregroundColor(themeBrown.opacity(0.4))
                        .padding(.top, 4)
                } else {
                    Text("Keep collecting glimmers,\nthey'll be here waiting for you.")
                        .font(.custom("Urbanist", size: 16))
                        .foregroundColor(themeBrown.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
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
