import SwiftUI
import UIKit

struct SafetyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SafetySettingsViewModel()
    @State private var expandedSection: SafetySection?

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let bgColor = Color(red: 0.969, green: 0.953, blue: 0.937)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820)
    private let accentBrown = Color(red: 0.573, green: 0.384, blue: 0.278)

    enum SafetySection {
        case emergencyContact
        case missedCheckIns
    }

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    Text("Safety")
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
                        // Safety cards
                        VStack(spacing: 16) {
                            // Emergency Contact Section
                            emergencyContactCard

                            // Missed Check-ins Section
                            missedCheckInsCard
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
        .animation(.easeInOut(duration: 0.25), value: expandedSection)
        .task {
            await viewModel.loadSettings()
        }
    }

    // MARK: - Emergency Contact Card

    private var emergencyContactCard: some View {
        VStack(spacing: 0) {
            // Header row (always visible)
            Button(action: {
                expandedSection = expandedSection == .emergencyContact ? nil : .emergencyContact
            }) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Emergency contact")
                            .font(.custom("Urbanist", size: 16).weight(.bold))
                            .foregroundColor(themeBrown)

                        if expandedSection == .emergencyContact {
                            Text("Person we can reach if you stop checking in.")
                                .font(.custom("Urbanist", size: 12).weight(.medium))
                                .foregroundColor(grey)
                        } else {
                            Text(viewModel.hasEmergencyContact ? viewModel.contactName : "Not set")
                                .font(.custom("Urbanist", size: 12).weight(.medium))
                                .foregroundColor(grey)
                        }
                    }

                    Spacer()

                    Image(systemName: expandedSection == .emergencyContact ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeBrown.opacity(0.6))
                }
            }
            .buttonStyle(.plain)

            // Expanded form fields
            if expandedSection == .emergencyContact {
                VStack(spacing: 12) {
                    SafetyTextField(label: "Name", text: $viewModel.contactName)
                    SafetyTextField(label: "Email", text: $viewModel.contactEmail, keyboardType: .emailAddress)
                    SafetyTextField(label: "Relationship (optional)", text: $viewModel.contactRelationship)

                    // Save button
                    HStack {
                        Spacer()
                        Button(action: {
                            Task {
                                if await viewModel.saveEmergencyContact() {
                                    expandedSection = nil
                                }
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
                                    .fill(viewModel.isContactValid ? accentBrown : accentBrown.opacity(0.5))
                            )
                        }
                        .disabled(!viewModel.isContactValid || viewModel.isSaving)
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 16)
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

    // MARK: - Missed Check-ins Card

    private var missedCheckInsCard: some View {
        VStack(spacing: 0) {
            // Header row (always visible)
            Button(action: {
                expandedSection = expandedSection == .missedCheckIns ? nil : .missedCheckIns
            }) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Missed Check-ins")
                            .font(.custom("Urbanist", size: 16).weight(.bold))
                            .foregroundColor(themeBrown)

                        if expandedSection == .missedCheckIns {
                            Text("If you haven't checked in for a few days, we'll reach out to your emergency contact.")
                                .font(.custom("Urbanist", size: 12).weight(.medium))
                                .foregroundColor(grey)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("\(viewModel.missedCheckInDays) days")
                                .font(.custom("Urbanist", size: 12).weight(.medium))
                                .foregroundColor(grey)
                        }
                    }

                    Spacer()

                    Image(systemName: expandedSection == .missedCheckIns ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeBrown.opacity(0.6))
                }
            }
            .buttonStyle(.plain)

            // Expanded form fields
            if expandedSection == .missedCheckIns {
                VStack(alignment: .leading, spacing: 16) {
                    // Notify After - Days Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notify After")
                            .font(.custom("Urbanist", size: 14).weight(.bold))
                            .foregroundColor(themeBrown)

                        Picker("Days", selection: $viewModel.missedCheckInDays) {
                            ForEach(1...14, id: \.self) { day in
                                Text("\(day) day\(day == 1 ? "" : "s")").tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(themeBrown)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 9999)
                                .stroke(borderColor, lineWidth: 1)
                        )
                    }

                    // Message Preview
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Message Preview")
                            .font(.custom("Urbanist", size: 14).weight(.bold))
                            .foregroundColor(themeBrown)

                        Text(viewModel.messageTemplate
                            .replacingOccurrences(of: "{contact_name}", with: viewModel.contactName.isEmpty ? "Contact" : viewModel.contactName)
                            .replacingOccurrences(of: "{username}", with: "You")
                            .replacingOccurrences(of: "{interval_days}", with: "\(viewModel.missedCheckInDays)")
                        )
                            .font(.custom("Urbanist", size: 10))
                            .foregroundColor(themeBrown.opacity(0.5))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(borderColor, lineWidth: 1)
                            )
                    }

                    // Save button
                    HStack {
                        Spacer()
                        Button(action: {
                            Task {
                                if await viewModel.saveMissCheckinRule() {
                                    expandedSection = nil
                                }
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
                }
                .padding(.top, 16)
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

// MARK: - Safety Text Field

struct SafetyTextField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820)

    var body: some View {
        TextField(label, text: $text)
            .font(.custom("Urbanist", size: 16))
            .foregroundColor(themeBrown)
            .keyboardType(keyboardType)
            .autocapitalization(keyboardType == .emailAddress ? .none : .words)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 9999)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

// MARK: - Safety Dropdown Field (display-only)

struct SafetyDropdownField: View {
    let label: String
    let value: String

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820)

    var body: some View {
        HStack {
            Text(value)
                .font(.custom("Urbanist", size: 16))
                .foregroundColor(themeBrown)

            Spacer()

            Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeBrown.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 9999)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        SafetyView()
    }
}
