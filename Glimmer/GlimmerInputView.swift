import SwiftUI
import Speech

struct GlimmerInputView: View {
    let onSave: (String) -> Void
    let onDismiss: () -> Void

    @State private var glimmerText = ""
    @State private var showEncouragement = false
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @FocusState private var isTextFieldFocused: Bool

    private let maxCharacters = 300
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

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

            // Background ellipses
            ZStack {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.78, green: 0.88, blue: 0.95).opacity(0.7),
                                Color(red: 1.0, green: 0.96, blue: 0.8).opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 350, height: 250)
                    .blur(radius: 60)
                    .offset(x: -30, y: -280)

                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.78, green: 0.88, blue: 0.95).opacity(0.6),
                                Color(red: 1.0, green: 0.96, blue: 0.8).opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 200)
                    .blur(radius: 50)
                    .offset(x: 100, y: -180)
            }

            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Button(action: onDismiss) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeBrown.opacity(0.6))
                            )
                            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Lightup character
                Image("Lightup4")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.top, 20)

                // Question title
                Text("Where did the light show up today?")
                    .font(.custom("Urbanist", size: 22).weight(.semibold))
                    .foregroundColor(themeBrown)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                // Input section
                VStack(alignment: .leading, spacing: 8) {
                    // Label with sparkle
                    HStack(spacing: 6) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))
                        Text("A trace of light...")
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
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeBrown.opacity(0.15), lineWidth: 1)
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
                            .font(.custom("Urbanist", size: 11))
                            .foregroundColor(themeBrown.opacity(0.4))
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
                .padding(.top, 28)

                Spacer()

                // Save button
                Button(action: saveGlimmer) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text("This moment is kept.")
                            .font(.custom("Urbanist", size: 15).weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
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

    private func saveGlimmer() {
        let trimmedText = glimmerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        showEncouragement = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            onSave(trimmedText)
        }
    }
}

// MARK: - Input Encouragement Overlay

struct InputEncouragementOverlay: View {
    let onDismiss: () -> Void

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
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
        "You chose to show up. That's everything."
    ]

    @State private var message: String = ""

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 16) {
                Image(systemName: "sparkle")
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))

                Text(message)
                    .font(.custom("Urbanist", size: 18).weight(.medium))
                    .foregroundColor(themeBrown)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
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
            message = encouragements.randomElement() ?? encouragements[0]
        }
    }
}

#Preview {
    GlimmerInputView(
        onSave: { _ in },
        onDismiss: {}
    )
}
