import SwiftUI

struct ReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("checkInReminderEnabled") private var checkInReminderEnabled = true
    @AppStorage("reminderTime") private var reminderTime = "9:00 PM"
    @AppStorage("reminderFrequency") private var reminderFrequency = "Once a day"
    @AppStorage("reminderMessage") private var reminderMessage = "This is what we'll send you."

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let bgColor = Color(red: 0.969, green: 0.953, blue: 0.937)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    Text("Reminder")
                        .font(.custom("Baskerville", size: 24))
                        .foregroundColor(themeBrown)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .padding(.top, 24)
                        .padding(.bottom, 24)

                    // Reminder cards
                    VStack(spacing: 12) {
                        // Check-in Reminder toggle
                        ReminderToggleCard(
                            title: "Check-in Reminder",
                            subtitle: "A gentle reminder to check in.",
                            isOn: $checkInReminderEnabled
                        )

                        // Reminder Time
                        ReminderDetailCard(
                            title: "Reminder Time",
                            value: reminderTime,
                            icon: "clock",
                            action: {}
                        )

                        // Reminder Frequency
                        ReminderDetailCard(
                            title: "Reminder Frequency",
                            value: reminderFrequency,
                            icon: "paintbrush",
                            action: {}
                        )

                        // Reminder Message
                        ReminderDetailCard(
                            title: "Reminder Message",
                            value: reminderMessage,
                            icon: "paintbrush",
                            action: {}
                        )
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                        .frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeBrown)
                }
            }
        }
    }
}

// MARK: - Reminder Toggle Card

struct ReminderToggleCard: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Urbanist", size: 16).weight(.bold))
                    .foregroundColor(themeBrown)

                Text(subtitle)
                    .font(.custom("Urbanist", size: 12).weight(.medium))
                    .foregroundColor(grey)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(themeBrown)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.03), radius: 4, x: 0, y: 4)
                .shadow(color: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.02), radius: 8, x: 0, y: 8)
        )
    }
}

// MARK: - Reminder Detail Card

struct ReminderDetailCard: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Urbanist", size: 16).weight(.bold))
                        .foregroundColor(themeBrown)

                    Text(value)
                        .font(.custom("Urbanist", size: 12).weight(.medium))
                        .foregroundColor(grey)
                }

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(themeBrown.opacity(0.6))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.03), radius: 4, x: 0, y: 4)
                    .shadow(color: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.02), radius: 8, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ReminderView()
    }
}
