import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var appSettings: AppSettings
    @State private var showProfileView = false
    @State private var showSafetyView = false
    @State private var showReminderView = false
    @State private var showDeveloperView = false

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

                            // Pause check-ins (toggle card) - now uses API
                            PauseCheckInsToggleCard(
                                viewModel: homeViewModel
                            )

                            #if DEBUG
                            // Developer menu (DEBUG only)
                            SettingsCard(
                                title: "Developer",
                                subtitle: "API Mode: \(appSettings.apiMode.rawValue)",
                                action: { showDeveloperView = true }
                            )
                            #endif
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
            #if DEBUG
            .navigationDestination(isPresented: $showDeveloperView) {
                DeveloperSettingsView()
            }
            #endif
        }
    }
}

// MARK: - Pause Check-ins Toggle Card (uses API)

struct PauseCheckInsToggleCard: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var isToggling = false

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pause check-ins")
                    .font(.custom("Urbanist", size: 16).weight(.bold))
                    .foregroundColor(themeBrown)

                Text("Temporarily stop daily check-ins. \nNo alerts or emergency contacts will be triggered during this time.")
                    .font(.custom("Urbanist", size: 14).weight(.medium))
                    .foregroundColor(grey)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if isToggling {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: themeBrown))
            } else {
                Toggle("", isOn: Binding(
                    get: { viewModel.isPaused },
                    set: { newValue in
                        isToggling = true
                        Task {
                            await viewModel.setPaused(newValue)
                            isToggling = false
                        }
                    }
                ))
                .labelsHidden()
                .tint(themeBrown)
            }
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

// MARK: - Developer Settings View (DEBUG only)

#if DEBUG
struct DeveloperSettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showClearCacheAlert = false

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let bgColor = Color(red: 0.969, green: 0.953, blue: 0.937)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // API Mode Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Mode")
                            .font(.custom("Urbanist", size: 16).weight(.bold))
                            .foregroundColor(themeBrown)

                        Picker("API Mode", selection: Binding(
                            get: { appSettings.apiMode },
                            set: { appSettings.apiModeRaw = $0.rawValue }
                        )) {
                            ForEach(APIMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                    )

                    // Base URL Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Base URL")
                            .font(.custom("Urbanist", size: 16).weight(.bold))
                            .foregroundColor(themeBrown)

                        Text(appSettings.apiMode == .mock ? "Mock (In-Memory)" : "lumenary-api.onrender.com")
                            .font(.custom("Urbanist", size: 14))
                            .foregroundColor(grey)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                    )

                    // Clear Cache Button
                    Button(action: {
                        showClearCacheAlert = true
                    }) {
                        HStack {
                            Text("Clear Mock Data")
                                .font(.custom("Urbanist", size: 16).weight(.medium))
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                        )
                    }
                    .buttonStyle(.plain)

                    // Reset Mock Data Button
                    Button(action: {
                        MockAPIClient.shared.resetAllData()
                    }) {
                        HStack {
                            Text("Reset Mock Data")
                                .font(.custom("Urbanist", size: 16).weight(.medium))
                                .foregroundColor(themeBrown)
                            Spacer()
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(themeBrown)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Developer")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear Mock Data", isPresented: $showClearCacheAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                MockAPIClient.shared.clearTodayData()
            }
        } message: {
            Text("This will clear today's mock data. Are you sure?")
        }
    }
}
#endif

#Preview {
    SettingsView()
        .environmentObject(HomeViewModel())
        .environmentObject(AppSettings.shared)
}
