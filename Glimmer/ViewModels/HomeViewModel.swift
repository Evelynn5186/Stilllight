import Foundation
import SwiftUI
import SwiftData

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published State

    @Published var hasCheckedInToday = false
    @Published var isPaused = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var todayJournal: JournalRecord?
    @Published var todayMood: MoodRecord?

    // MARK: - Computed Properties

    var daysSinceLastCheckIn: Int {
        guard let journals = try? GlimmerService.shared.cachedJournals.first else {
            return 999
        }
        let calendar = Calendar.current
        let lastDate = journals.createdAt
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: Date())).day ?? 0
        return days
    }

    var isLongtimeNoVisit: Bool {
        !GlimmerService.shared.cachedJournals.isEmpty && daysSinceLastCheckIn >= 7 && !isPaused
    }

    // MARK: - Private

    private let service = GlimmerService.shared

    // MARK: - Load Status

    func loadStatus() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load check-in status
            let checkinStatus = try await service.getTodayCheckinStatus()
            hasCheckedInToday = checkinStatus.checkedInToday

            // Load pause status
            let pauseStatus = try await service.getPauseStatus()
            isPaused = pauseStatus.paused

            // Load today's journal/mood if checked in
            if hasCheckedInToday {
                let todayJournals = try await service.getTodayJournals()
                todayJournal = todayJournals.first

                todayMood = try await service.getTodayMood()
            }

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("HomeViewModel loadStatus error: \(error)")
        }
    }

    // MARK: - Save Glimmer

    func saveGlimmer(text: String, mood: Mood?) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await service.saveGlimmer(content: text, mood: mood)
            hasCheckedInToday = true
            todayJournal = result.journal
            if let moodRecord = result.mood {
                todayMood = moodRecord
            }
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("HomeViewModel saveGlimmer error: \(error)")
            return false
        }
    }

    // MARK: - Toggle Pause

    func togglePause() async {
        isLoading = true
        errorMessage = nil

        do {
            let newStatus = try await service.setPauseStatus(paused: !isPaused)
            isPaused = newStatus.paused
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("HomeViewModel togglePause error: \(error)")
        }
    }

    func setPaused(_ paused: Bool) async {
        isLoading = true
        errorMessage = nil

        do {
            let newStatus = try await service.setPauseStatus(paused: paused)
            isPaused = newStatus.paused
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("HomeViewModel setPaused error: \(error)")
        }
    }

    // MARK: - Get Random Glimmer (for "Gather Light" feature)

    func getRandomGlimmer() async -> JournalWithWarmMessage? {
        do {
            return try await service.getRandomJournalWithWarmMessage()
        } catch {
            print("HomeViewModel getRandomGlimmer error: \(error)")
            return nil
        }
    }
}
