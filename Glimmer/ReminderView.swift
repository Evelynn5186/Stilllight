import SwiftUI

struct ReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ReminderSettingsViewModel()

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let bgColor = Color(red: 0.969, green: 0.953, blue: 0.937)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820)
    private let accentBrown = Color(red: 0.573, green: 0.384, blue: 0.278)

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

                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        // Reminder cards
                        VStack(spacing: 12) {
                            // Check-in Reminder toggle
                            reminderToggleCard

                            if viewModel.isEnabled {
                                // Reminder Time
                                reminderTimeCard

                                // Reminder Frequency
                                reminderFrequencyCard

                                // Interval Days (if every_n_days)
                                if viewModel.isEveryNDays {
                                    intervalDaysCard
                                }

                                // Save button
                                saveButton
                            }
                        }
                        .padding(.horizontal, 32)
                    }

                    Spacer()
                        .frame(height: 120)
                }
            }
            .scrollIndicators(.hidden)

            // Error/Success Toast
            if let message = viewModel.errorMessage ?? viewModel.successMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.custom("Urbanist", size: 14).weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(viewModel.errorMessage != nil ? Color.red.opacity(0.9) : Color.green.opacity(0.9))
                        )
                        .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            viewModel.clearMessages()
                        }
                    }
                }
            }
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
        .animation(.easeInOut(duration: 0.25), value: viewModel.isEnabled)
        .animation(.easeInOut(duration: 0.25), value: viewModel.isEveryNDays)
        .task {
            await viewModel.loadReminder()
        }
    }

    // MARK: - Reminder Toggle Card

    private var reminderToggleCard: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Check-in Reminder")
                    .font(.custom("Urbanist", size: 16).weight(.bold))
                    .foregroundColor(themeBrown)

                Text("A gentle reminder to check in.")
                    .font(.custom("Urbanist", size: 12).weight(.medium))
                    .foregroundColor(grey)
            }

            Spacer()

            Toggle("", isOn: $viewModel.isEnabled)
                .labelsHidden()
                .tint(themeBrown)
                .onChange(of: viewModel.isEnabled) { _, _ in
                    Task {
                        _ = await viewModel.saveReminder()
                    }
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

    // MARK: - Reminder Time Card

    private var reminderTimeCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reminder Time")
                    .font(.custom("Urbanist", size: 16).weight(.bold))
                    .foregroundColor(themeBrown)

                Text("When should we remind you?")
                    .font(.custom("Urbanist", size: 12).weight(.medium))
                    .foregroundColor(grey)
            }

            Spacer()

            DatePicker("", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
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

    // MARK: - Reminder Frequency Card

    private var reminderFrequencyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reminder Frequency")
                .font(.custom("Urbanist", size: 16).weight(.bold))
                .foregroundColor(themeBrown)

            HStack(spacing: 12) {
                frequencyButton(title: "Every day", value: "daily")
                frequencyButton(title: "Every N days", value: "every_n_days")
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

    private func frequencyButton(title: String, value: String) -> some View {
        Button(action: {
            viewModel.frequencyType = value
        }) {
            Text(title)
                .font(.custom("Urbanist", size: 14).weight(.semibold))
                .foregroundColor(viewModel.frequencyType == value ? .white : themeBrown)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(viewModel.frequencyType == value ? accentBrown : Color.clear)
                )
                .overlay(
                    Capsule()
                        .stroke(viewModel.frequencyType == value ? Color.clear : borderColor, lineWidth: 1)
                )
        }
    }

    // MARK: - Interval Days Card

    private var intervalDaysCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Interval Days")
                    .font(.custom("Urbanist", size: 16).weight(.bold))
                    .foregroundColor(themeBrown)

                Text("Remind me every \(viewModel.intervalDays) days")
                    .font(.custom("Urbanist", size: 12).weight(.medium))
                    .foregroundColor(grey)
            }

            Spacer()

            Picker("Days", selection: $viewModel.intervalDays) {
                ForEach(2...14, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(.menu)
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

    // MARK: - Save Button

    private var saveButton: some View {
        HStack {
            Spacer()
            Button(action: {
                Task {
                    _ = await viewModel.saveReminder()
                }
            }) {
                HStack(spacing: 6) {
                    if viewModel.isSaving {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Text("Save")
                            .font(.custom("Urbanist", size: 16).weight(.bold))
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(accentBrown)
                )
            }
            .disabled(viewModel.isSaving)
        }
        .padding(.top, 8)
    }
}

// MARK: - Reminder Toggle Card (Reusable)

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

// MARK: - Reminder Detail Card (Reusable)

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
