import SwiftUI

struct SettingsView: View {
    @State private var showProfileView = false
    @State private var showSafetyView = false
    @State private var showReminderView = false
    @AppStorage("pauseCheckIns") var pauseCheckIns = false

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let bgColor = Color(red: 0.969, green: 0.953, blue: 0.937)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        Text("Setting")
                            .font(.custom("Baskerville", size: 24))
                            .foregroundColor(themeBrown)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 32)
                            .padding(.top, 24)
                            .padding(.bottom, 24)

                        // Settings cards
                        VStack(spacing: 16) {
                            // Profile
                            SettingsCard(
                                title: "Profile",
                                subtitle: "General Info, Sign out",
                                action: { showProfileView = true }
                            )

                            // Safety
                            SettingsCard(
                                title: "Safety",
                                subtitle: "Emergency Contact, Check-ins",
                                action: { showSafetyView = true }
                            )

                            // Reminders
                            SettingsCard(
                                title: "Reminders",
                                subtitle: "Check-in Reminders",
                                action: { showReminderView = true }
                            )

                            // Account
                            SettingsCard(
                                title: "Account",
                                subtitle: "Our app, Privacy, Contact Us",
                                action: {}
                            )

                            // Pause check-ins (toggle card)
                            SettingsToggleCard(
                                title: "Pause check-ins",
                                subtitle: "Temporarily stop daily check-ins. \nNo alerts or emergency contacts will be triggered during this time.",
                                isOn: $pauseCheckIns
                            )
                        }
                        .padding(.horizontal, 32)

                        Spacer()
                            .frame(height: 120)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationDestination(isPresented: $showProfileView) {
                AccountView()
            }
            .navigationDestination(isPresented: $showSafetyView) {
                SafetyView()
            }
            .navigationDestination(isPresented: $showReminderView) {
                ReminderView()
            }
        }
    }
}

// MARK: - Settings Card

struct SettingsCard: View {
    let title: String
    let subtitle: String
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

                    Text(subtitle)
                        .font(.custom("Urbanist", size: 14).weight(.medium))
                        .foregroundColor(grey)
                }

                Spacer()

                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 20, weight: .light))
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

// MARK: - Settings Toggle Card

struct SettingsToggleCard: View {
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
                    .font(.custom("Urbanist", size: 14).weight(.medium))
                    .foregroundColor(grey)
                    .fixedSize(horizontal: false, vertical: true)
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

#Preview {
    SettingsView()
}
