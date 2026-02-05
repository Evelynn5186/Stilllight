import SwiftUI

struct SafetyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSection: SafetySection?

    // Emergency Contact fields
    @AppStorage("emergencyContactName") private var contactName = "John C"
    @AppStorage("emergencyContactPhone") private var contactPhone = "(802)-231-3211"
    @AppStorage("emergencyContactRelationship") private var contactRelationship = "Friend"

    // Missed Check-ins fields
    @AppStorage("missedCheckInDays") private var notifyAfterDays = "3 days (default)"
    @AppStorage("checkInPromptEnabled") private var checkInPromptEnabled = true
    @AppStorage("missedCheckInMessage") private var missedMessage = "Hi, this is a message from [App Name] on behalf of [User]. They haven't checked in for a few days, and you're listed as their emergency contact. It might be a good time to reach out."

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let bgColor = Color(red: 0.969, green: 0.953, blue: 0.937)
    private let grey = Color(red: 0.294, green: 0.294, blue: 0.294)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820)
    private let accentBrown = Color(red: 0.573, green: 0.384, blue: 0.278) // #926247

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

                    // Safety cards
                    VStack(spacing: 16) {
                        // Emergency Contact Section
                        emergencyContactCard

                        // Missed Check-ins Section
                        missedCheckInsCard
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
        .animation(.easeInOut(duration: 0.25), value: expandedSection)
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
                            Text(contactName)
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
                    SafetyTextField(label: "Name", text: $contactName)
                    SafetyTextField(label: "Phone", text: $contactPhone)
                    SafetyDropdownField(label: "Relationship (optional)", value: contactRelationship)

                    // Save button
                    HStack {
                        Spacer()
                        Button(action: {
                            expandedSection = nil
                        }) {
                            HStack(spacing: 6) {
                                Text("Save")
                                    .font(.custom("Urbanist", size: 16).weight(.bold))
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(accentBrown)
                            )
                        }
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
                            Text(notifyAfterDays.replacingOccurrences(of: " (default)", with: ""))
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
                    // Notify After
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notify After")
                            .font(.custom("Urbanist", size: 14).weight(.bold))
                            .foregroundColor(themeBrown)
                        SafetyDropdownField(label: "", value: notifyAfterDays)
                    }

                    // Check-in Prompt
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Before we reach out, do you want us to check in with you first?")
                            .font(.custom("Urbanist", size: 14).weight(.bold))
                            .foregroundColor(themeBrown)
                            .fixedSize(horizontal: false, vertical: true)
                        SafetyDropdownField(label: "", value: checkInPromptEnabled ? "Yes" : "No")
                    }

                    // Message Preview
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Message Preview")
                            .font(.custom("Urbanist", size: 14).weight(.bold))
                            .foregroundColor(themeBrown)

                        Text(missedMessage)
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
                            expandedSection = nil
                        }) {
                            HStack(spacing: 6) {
                                Text("Save")
                                    .font(.custom("Urbanist", size: 16).weight(.bold))
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(accentBrown)
                            )
                        }
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

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let borderColor = Color(red: 0.839, green: 0.827, blue: 0.820)

    var body: some View {
        TextField(label, text: $text)
            .font(.custom("Urbanist", size: 16))
            .foregroundColor(themeBrown)
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
