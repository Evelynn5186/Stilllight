import Foundation
import SwiftUI

@MainActor
class SafetySettingsViewModel: ObservableObject {
    // MARK: - Published State

    // Emergency Contact
    @Published var contactName: String = ""
    @Published var contactEmail: String = ""
    @Published var contactRelationship: String = ""
    @Published var hasEmergencyContact: Bool = false

    // Miss Checkin Rule
    @Published var missedCheckInDays: Int = 3
    @Published var messageTemplate: String = MissCheckinRule.defaultTemplate

    // UI State
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Private

    private let service = GlimmerService.shared

    // MARK: - Computed Properties

    var isContactValid: Bool {
        !contactName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !contactEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
        contactEmail.contains("@")
    }

    // MARK: - Load Data

    func loadSettings() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load Emergency Contact
            if let contact = try await service.getEmergencyContact() {
                contactName = contact.name
                contactEmail = contact.email
                contactRelationship = contact.relationship ?? ""
                hasEmergencyContact = true
            } else {
                hasEmergencyContact = false
            }

            // Load Miss Checkin Rule
            let rule = try await service.getMissCheckinRule()
            missedCheckInDays = rule.thresholdDays
            messageTemplate = rule.messageTemplate

            isLoading = false
        } catch {
            isLoading = false
            // If 404, it means no data yet - that's OK
            if case APIClientError.notFound = error {
                hasEmergencyContact = false
            } else {
                errorMessage = error.localizedDescription
                print("SafetySettingsViewModel loadSettings error: \(error)")
            }
        }
    }

    // MARK: - Save Emergency Contact

    func saveEmergencyContact() async -> Bool {
        guard isContactValid else {
            errorMessage = "Please enter a valid name and email"
            return false
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        do {
            let contact = try await service.updateEmergencyContact(
                name: contactName.trimmingCharacters(in: .whitespaces),
                email: contactEmail.trimmingCharacters(in: .whitespaces),
                relationship: contactRelationship.isEmpty ? nil : contactRelationship.trimmingCharacters(in: .whitespaces)
            )
            contactName = contact.name
            contactEmail = contact.email
            contactRelationship = contact.relationship ?? ""
            hasEmergencyContact = true
            isSaving = false
            successMessage = "Emergency contact saved"
            return true
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            print("SafetySettingsViewModel saveEmergencyContact error: \(error)")
            return false
        }
    }

    // MARK: - Save Miss Checkin Rule

    func saveMissCheckinRule() async -> Bool {
        guard missedCheckInDays >= 1 else {
            errorMessage = "Threshold days must be at least 1"
            return false
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        do {
            let rule = try await service.updateMissCheckinRule(
                MissCheckinRule(
                    thresholdDays: missedCheckInDays,
                    messageTemplate: messageTemplate.isEmpty ? MissCheckinRule.defaultTemplate : messageTemplate
                )
            )
            missedCheckInDays = rule.thresholdDays
            messageTemplate = rule.messageTemplate
            isSaving = false
            successMessage = "Settings saved"
            return true
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            print("SafetySettingsViewModel saveMissCheckinRule error: \(error)")
            return false
        }
    }

    // MARK: - Clear Messages

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
