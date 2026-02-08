import Foundation
import SwiftUI

@MainActor
class ReminderSettingsViewModel: ObservableObject {
    // MARK: - Published State

    @Published var isEnabled: Bool = false
    @Published var reminderTime: Date = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: "09:00") ?? Date()
    }()
    @Published var frequencyType: String = "daily"  // "daily" or "every_n_days"
    @Published var intervalDays: Int = 2

    // UI State
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Private

    private let service = GlimmerService.shared

    // MARK: - Computed Properties

    var frequencyOptions: [String] {
        ["daily", "every_n_days"]
    }

    var frequencyDisplayName: String {
        switch frequencyType {
        case "daily":
            return "Every day"
        case "every_n_days":
            return "Every \(intervalDays) days"
        default:
            return frequencyType
        }
    }

    var isEveryNDays: Bool {
        frequencyType == "every_n_days"
    }

    // MARK: - Load Data

    func loadReminder() async {
        isLoading = true
        errorMessage = nil

        do {
            let reminder = try await service.getCheckinReminder()
            isEnabled = reminder.enabled
            reminderTime = reminder.timeAsDate
            frequencyType = reminder.frequencyType
            if let days = reminder.intervalDays {
                intervalDays = days
            }
            isLoading = false
        } catch {
            isLoading = false
            // If 404, use defaults - that's OK
            if case APIClientError.notFound = error {
                // Keep defaults
            } else {
                errorMessage = error.localizedDescription
                print("ReminderSettingsViewModel loadReminder error: \(error)")
            }
        }
    }

    // MARK: - Save Reminder

    func saveReminder() async -> Bool {
        // Validate interval days for every_n_days
        if frequencyType == "every_n_days" && intervalDays < 2 {
            errorMessage = "Interval must be at least 2 days"
            return false
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        do {
            let reminder = CheckinReminder.create(
                enabled: isEnabled,
                time: reminderTime,
                frequencyType: frequencyType,
                intervalDays: frequencyType == "every_n_days" ? intervalDays : nil
            )
            let saved = try await service.updateCheckinReminder(reminder)
            isEnabled = saved.enabled
            reminderTime = saved.timeAsDate
            frequencyType = saved.frequencyType
            if let days = saved.intervalDays {
                intervalDays = days
            }
            isSaving = false
            successMessage = "Reminder saved"
            return true
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            print("ReminderSettingsViewModel saveReminder error: \(error)")
            return false
        }
    }

    // MARK: - Toggle Enabled (with auto-save)

    func toggleEnabled() async {
        isEnabled.toggle()
        _ = await saveReminder()
    }

    // MARK: - Clear Messages

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
