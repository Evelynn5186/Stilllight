import Foundation
import SwiftUI

@MainActor
class JournalViewModel: ObservableObject {
    // MARK: - Published State

    @Published var journals: [JournalRecord] = []
    @Published var moods: [MoodRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Date Helpers

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private let calendar = Calendar.current

    // MARK: - Computed Properties

    /// Check if user has checked in on a specific date
    func hasEntry(on date: Date) -> Bool {
        let localDate = dateFormatter.string(from: date)
        return journals.contains { $0.localDate == localDate }
    }

    /// Get journal for a specific date
    func journal(for date: Date) -> JournalRecord? {
        let localDate = dateFormatter.string(from: date)
        return journals.first { $0.localDate == localDate }
    }

    /// Get mood for a specific date
    func mood(for date: Date) -> MoodRecord? {
        let localDate = dateFormatter.string(from: date)
        return moods.first { $0.localDate == localDate }
    }

    /// Get Mood enum from MoodRecord
    func moodEnum(for date: Date) -> Mood? {
        guard let moodRecord = mood(for: date) else { return nil }
        return Mood.from(score: moodRecord.score)
    }

    /// Check if checked in today
    var hasCheckedInToday: Bool {
        hasEntry(on: Date())
    }

    /// Days with entries in current month
    var daysWithEntriesThisMonth: Set<Int> {
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        var days = Set<Int>()
        for journal in journals {
            if let date = dateFormatter.date(from: journal.localDate) {
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                if month == currentMonth && year == currentYear {
                    let day = calendar.component(.day, from: date)
                    days.insert(day)
                }
            }
        }
        return days
    }

    /// Entry count this month
    var entryCountThisMonth: Int {
        daysWithEntriesThisMonth.count
    }

    // MARK: - Private

    private let service = GlimmerService.shared

    // MARK: - Load Journals

    func loadJournals() async {
        isLoading = true
        errorMessage = nil

        do {
            // Load all journals
            journals = try await service.getJournals()

            // Load all moods
            moods = try await service.getMoods()

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("JournalViewModel loadJournals error: \(error)")
        }
    }

    // MARK: - Get Random Journal

    func getRandomJournal() async -> JournalRecord? {
        do {
            return try await service.getRandomJournal()
        } catch {
            print("JournalViewModel getRandomJournal error: \(error)")
            return nil
        }
    }

    // MARK: - Get Random Journal with Warm Message

    func getRandomJournalWithMessage() async -> JournalWithWarmMessage? {
        do {
            return try await service.getRandomJournalWithWarmMessage()
        } catch {
            print("JournalViewModel getRandomJournalWithMessage error: \(error)")
            return nil
        }
    }

    // MARK: - Week Dates Helper

    func weekDates() -> [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        let today = Date()
        var components = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        guard let monday = cal.date(from: components) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
    }
}
