import SwiftUI
import Speech

struct GlimmerInputView: View {
    let onSave: (String, Mood?) -> Void
    let onDismiss: () -> Void

    @State private var glimmerText = ""
    @State private var selectedMood: Mood?
    @State private var showMoreMoods = false
    @State private var showEncouragement = false
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @FocusState private var isTextFieldFocused: Bool

    private let maxCharacters = 300
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820) // #D6D3D1

    var body: some View {
        ZStack {
            // Gradient background matching Figma
            LinearGradient(
                colors: [
                    Color(red: 0.843, green: 0.914, blue: 1.0),
                    Color(red: 1.0, green: 0.98, blue: 0.925)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Background decorative shape
            ZStack {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.843, green: 0.914, blue: 1.0).opacity(0.7),
                                Color(red: 1.0, green: 0.98, blue: 0.925).opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 25)
                    .offset(x: 0, y: -200)
            }

            ScrollView {
                VStack(spacing: 0) {
                    // Header with close button
                    HStack {
                        Spacer()
                        Button(action: onDismiss) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(themeBrown)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // Question 1: How are you feeling?
                    Text("How are you feeling today?")
                        .font(.custom("Baskerville", size: 16))
                        .foregroundColor(themeBrown)
                        .padding(.top, 24)

                    // Mood selection bar
                    moodSelectionBar
                        .padding(.top, 16)
                        .padding(.horizontal, 24)

                    // Question 2: Where did the light show up?
                    Text("Where did the light show up today?")
                        .font(.custom("Baskerville", size: 16))
                        .foregroundColor(themeBrown)
                        .padding(.top, 28)

                    // Input section
                    VStack(alignment: .leading, spacing: 8) {
                        // Label with sparkle
                        HStack(spacing: 6) {
                            Image(systemName: "sparkle")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeBrown)
                            Text("A trace of light…")
                                .font(.custom("Urbanist", size: 14).weight(.semibold))
                                .foregroundColor(themeBrown)
                        }
                        .padding(.leading, 4)

                        // Text input area
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $glimmerText)
                                .font(.custom("Urbanist", size: 15))
                                .foregroundColor(themeBrown)
                                .scrollContentBackground(.hidden)
                                .padding(14)
                                .frame(minHeight: 100, maxHeight: 140)
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
                                Text("Ex. Video chatted with an old friend; Had a really good meal")
                                    .font(.custom("Urbanist", size: 15))
                                    .foregroundColor(themeBrown.opacity(0.4))
                                    .padding(14)
                                    .padding(.top, 8)
                                    .allowsHitTesting(false)
                            }
                        }

                        // Helper text and controls row
                        HStack(alignment: .center) {
                            Text("It can be something small. Just a few words is enough.")
                                .font(.custom("Urbanist", size: 13))
                                .foregroundColor(themeBrown.opacity(0.6))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()

                            // Character count
                            Text("\(glimmerText.count)/\(maxCharacters)")
                                .font(.custom("Urbanist", size: 12))
                                .foregroundColor(Color(red: 0.659, green: 0.635, blue: 0.624)) // #A8A29E
                                .padding(.trailing, 8)

                            // Mic button
                            Button(action: toggleRecording) {
                                Circle()
                                    .fill(speechRecognizer.isRecording ? themeBrown : Color.white)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: speechRecognizer.isRecording ? "mic.fill" : "mic")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(speechRecognizer.isRecording ? .white : themeBrown.opacity(0.5))
                                    )
                                    .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer().frame(height: 40)

                    // Save button
                    Button(action: saveGlimmer) {
                        HStack {
                            Text("This moment is kept.")
                                .font(.custom("Urbanist", size: 14).weight(.medium))

                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.6))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
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
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .scrollIndicators(.hidden)

            // Encouragement overlay
            if showEncouragement {
                InputEncouragementOverlay(
                    onDismiss: {
                        showEncouragement = false
                        onDismiss()
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showEncouragement)
        .animation(.easeInOut(duration: 0.2), value: showMoreMoods)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - Mood Selection Bar

    private var moodSelectionBar: some View {
        VStack(spacing: 12) {
            // Primary moods row
            HStack(spacing: 0) {
                ForEach(Mood.primary, id: \.self) { mood in
                    moodButton(mood)
                }

                // More button
                Button(action: { showMoreMoods.toggle() }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(showMoreMoods ? themeBrown.opacity(0.1) : Color(red: 0.969, green: 0.969, blue: 0.969))
                                .frame(width: 36, height: 36)
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeBrown.opacity(0.6))
                        }
                        Text("More")
                            .font(.custom("Urbanist", size: 8))
                            .foregroundColor(themeBrown.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )

            // Secondary moods row (expandable)
            if showMoreMoods {
                HStack(spacing: 0) {
                    ForEach(Mood.secondary, id: \.self) { mood in
                        moodButton(mood)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
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
    }

    private func moodButton(_ mood: Mood) -> some View {
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
                        .frame(width: 36, height: 36)
                    MoodEmojiView(mood: mood, size: 30)
                }
                .overlay(
                    selectedMood == mood
                        ? Circle().stroke(themeBrown, lineWidth: 2).frame(width: 40, height: 40)
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

    private func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
        } else {
            speechRecognizer.startTranscribing()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func saveGlimmer() {
        let trimmedText = glimmerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showEncouragement = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            onSave(trimmedText, selectedMood)
        }
    }
}

// MARK: - Input Encouragement Overlay

struct InputEncouragementOverlay: View {
    let onDismiss: () -> Void
    var aiMessage: String? = nil  // AI-generated warm message
    var isLoading: Bool = false   // Loading state while fetching AI message

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let fallbackMessages = [
        "You're more alive than you think.",
        "That took courage. I see you.",
        "Small steps still move you forward.",
        "You showed up today. That matters.",
        "This moment counts.",
        "Gentle progress is still progress.",
        "You're doing better than you know.",
        "That was worth noticing.",
        "Every little thing adds up.",
        "You chose to show up. That's everything."
    ]

    @State private var fallbackMessage: String = ""

    private var displayMessage: String {
        if let aiMessage = aiMessage, !aiMessage.isEmpty {
            return aiMessage
        }
        return fallbackMessage
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isLoading {
                        onDismiss()
                    }
                }

            VStack(spacing: 16) {
                if isLoading {
                    // Loading state
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(Color(red: 1.0, green: 0.85, blue: 0.4))

                    Text("Preparing a message for you...")
                        .font(.custom("Urbanist", size: 14))
                        .foregroundColor(themeBrown.opacity(0.6))
                } else {
                    Image(systemName: "sparkle")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))

                    Text(displayMessage)
                        .font(.custom("Urbanist", size: 18).weight(.medium))
                        .foregroundColor(themeBrown)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    // Show "from Glimmer" label if it's an AI message
                    if aiMessage != nil && !aiMessage!.isEmpty {
                        Text("— from Glimmer")
                            .font(.custom("Urbanist", size: 12))
                            .foregroundColor(themeBrown.opacity(0.5))
                            .italic()
                    }
                }
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 36)
            .frame(maxWidth: 300)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
        .onAppear {
            fallbackMessage = fallbackMessages.randomElement() ?? fallbackMessages[0]
        }
    }
}

#Preview {
    GlimmerInputView(
        onSave: { _, _ in },
        onDismiss: {}
    )
}
