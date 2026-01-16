import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Accomplishment.createdAt, order: .reverse) private var accomplishments: [Accomplishment]

    @State private var entryToDelete: Accomplishment?
    @State private var showDeleteConfirmation = false
    @State private var showDeletedMessage = false

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            if accomplishments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "leaf")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color("TextSecondary").opacity(0.5))

                    Text("Nothing here yet")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextSecondary"))

                    Text("Your accomplishments will appear here")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextSecondary").opacity(0.7))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        Spacer()
                            .frame(height: 24)

                        ForEach(accomplishments) { accomplishment in
                            SwipeableEntryCard(
                                accomplishment: accomplishment,
                                onDelete: {
                                    entryToDelete = accomplishment
                                    showDeleteConfirmation = true
                                }
                            )
                        }

                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                }
                .scrollIndicators(.hidden)
            }

            // Delete confirmation overlay
            if showDeleteConfirmation {
                DeleteConfirmationOverlay(
                    onConfirm: {
                        deleteEntry()
                    },
                    onCancel: {
                        showDeleteConfirmation = false
                        entryToDelete = nil
                    }
                )
            }

            // Deleted message overlay
            if showDeletedMessage {
                DeletedMessageOverlay()
                    .onAppear {
                        Task {
                            try? await Task.sleep(for: .seconds(1.2))
                            withAnimation {
                                showDeletedMessage = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showDeleteConfirmation)
        .animation(.easeInOut(duration: 0.25), value: showDeletedMessage)
    }

    private func deleteEntry() {
        guard let entry = entryToDelete else { return }

        showDeleteConfirmation = false

        withAnimation {
            modelContext.delete(entry)
        }

        entryToDelete = nil

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showDeletedMessage = true
        }
    }
}

// MARK: - Swipeable Entry Card

struct SwipeableEntryCard: View {
    let accomplishment: Accomplishment
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showingDelete = false

    private let deleteThreshold: CGFloat = -80

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete background
            HStack {
                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "leaf")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Color("TextSecondary"))
                        .frame(width: 60, height: 60)
                }
                .opacity(showingDelete ? 1 : 0)
            }

            // Main card
            EntryCard(accomplishment: accomplishment)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = value.translation.width
                                showingDelete = offset < deleteThreshold / 2
                            }
                        }
                        .onEnded { value in
                            withAnimation(.easeOut(duration: 0.25)) {
                                if offset < deleteThreshold {
                                    onDelete()
                                }
                                offset = 0
                                showingDelete = false
                            }
                        }
                )
        }
    }
}

// MARK: - Entry Card

struct EntryCard: View {
    let accomplishment: Accomplishment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(accomplishment.text)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(4)

            Text(formattedDate)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(16)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(accomplishment.createdAt) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInYesterday(accomplishment.createdAt) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else if calendar.isDate(accomplishment.createdAt, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }

        return formatter.string(from: accomplishment.createdAt)
    }
}

// MARK: - Delete Confirmation Overlay

struct DeleteConfirmationOverlay: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.08)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
                .transition(.opacity)

            // Card
            VStack(spacing: 24) {
                Image(systemName: "leaf")
                    .font(.system(size: 26, weight: .light))
                    .foregroundColor(Color("TextSecondary").opacity(0.7))

                Text("这道光要暂时收起来吗？")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)

                HStack(spacing: 16) {
                    Button(action: onCancel) {
                        Text("留下")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Color("TextSecondary"))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color("Background"))
                            )
                    }

                    Button(action: onConfirm) {
                        Text("收好")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color("ButtonPrimary").opacity(0.85))
                            )
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 32)
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

// MARK: - Deleted Message Overlay

struct DeletedMessageOverlay: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(Color("ButtonPrimary").opacity(0.8))

            Text("已收好")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color("TextPrimary"))
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 6)
        )
        .transition(
            .opacity
            .combined(with: .scale(scale: 0.9))
        )
    }
}

// MARK: - Previews

#Preview {
    HistoryView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
}

#Preview("Delete Confirmation") {
    ZStack {
        Color("Background")
            .ignoresSafeArea()

        DeleteConfirmationOverlay(
            onConfirm: {},
            onCancel: {}
        )
    }
}

#Preview("Deleted Message") {
    ZStack {
        Color("Background")
            .ignoresSafeArea()

        DeletedMessageOverlay()
    }
}
