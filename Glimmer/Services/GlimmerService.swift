import Foundation
import SwiftUI
import SwiftData

// MARK: - App Settings

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("apiMode") var apiModeRaw: String = APIMode.live.rawValue

    var apiMode: APIMode {
        get { APIMode(rawValue: apiModeRaw) ?? .mock }
        set { apiModeRaw = newValue.rawValue }
    }
}

// MARK: - Glimmer Service

@MainActor
class GlimmerService: ObservableObject {
    static let shared = GlimmerService()

    private var apiClient: APIClientProtocol {
        AppSettings.shared.apiMode == .mock ? MockAPIClient.shared : APIClient.shared
    }

    // MARK: - Cache (SwiftData integration point)
    // These will be populated from API and can be used for offline access

    @Published var cachedJournals: [JournalRecord] = []
    @Published var cachedMoods: [MoodRecord] = []
    @Published var lastCacheUpdate: Date?

    // MARK: - Check-in Operations

    /// Get today's check-in status
    func getTodayCheckinStatus() async throws -> CheckinStatus {
        let response: ApiResponseCheckinStatus = try await apiClient.get("/checkins/today", queryParams: nil)
        return response.data
    }

    /// Create today's check-in (tap-only, no mood/journal required)
    func checkInToday() async throws -> CheckinStatus {
        let response: ApiResponseCheckinStatus = try await apiClient.post("/checkins", body: EmptyBody())
        return response.data
    }

    // MARK: - Journal Operations

    /// Create a new journal entry
    func createJournal(content: String, title: String? = nil) async throws -> JournalRecord {
        let request = JournalCreateRequest(content: content, title: title)
        let response: ApiResponseJournal = try await apiClient.post("/journals", body: request)
        // Update cache
        cachedJournals.insert(response.data, at: 0)
        return response.data
    }

    /// Get all journals (with optional date range)
    func getJournals(from: String? = nil, to: String? = nil) async throws -> [JournalRecord] {
        var params: [String: String] = [:]
        if let from = from { params["from"] = from }
        if let to = to { params["to"] = to }

        let response: ApiResponseJournalList = try await apiClient.get("/journals", queryParams: params.isEmpty ? nil : params)
        // Update cache
        cachedJournals = response.data.items
        lastCacheUpdate = Date()
        return response.data.items
    }

    /// Get today's journals
    func getTodayJournals() async throws -> [JournalRecord] {
        let response: ApiResponseJournalList = try await apiClient.get("/journals/today", queryParams: nil)
        return response.data.items
    }

    /// Get a random past journal entry
    func getRandomJournal() async throws -> JournalRecord {
        let response: ApiResponseJournal = try await apiClient.get("/journals/random", queryParams: nil)
        return response.data
    }

    /// Get a random journal with AI warm message
    func getRandomJournalWithWarmMessage() async throws -> JournalWithWarmMessage {
        let response: ApiResponseJournalWithWarmMessage = try await apiClient.get("/journals/random-with-msg", queryParams: nil)
        return response.data
    }

    // MARK: - Mood Operations

    /// Record today's mood
    func createMood(score: Int) async throws -> MoodRecord {
        let request = MoodCreateRequest(score: score)
        let response: ApiResponseMood = try await apiClient.post("/moods", body: request)
        // Update cache
        cachedMoods.insert(response.data, at: 0)
        return response.data
    }

    /// Get all moods (with optional date range)
    func getMoods(from: String? = nil, to: String? = nil) async throws -> [MoodRecord] {
        var params: [String: String] = [:]
        if let from = from { params["from"] = from }
        if let to = to { params["to"] = to }

        let response: ApiResponseMoodList = try await apiClient.get("/moods", queryParams: params.isEmpty ? nil : params)
        // Update cache
        cachedMoods = response.data.items
        return response.data.items
    }

    /// Get today's mood
    func getTodayMood() async throws -> MoodRecord? {
        do {
            let response: ApiResponseMood = try await apiClient.get("/moods/today", queryParams: nil)
            return response.data
        } catch APIClientError.notFound {
            return nil
        }
    }

    // MARK: - Combined Save Glimmer (Journal + Mood + Checkin)

    /// Save a glimmer (creates journal, mood, and check-in)
    func saveGlimmer(content: String, mood: Mood?) async throws -> (journal: JournalRecord, mood: MoodRecord?, checkin: CheckinStatus) {
        // Create journal
        let journal = try await createJournal(content: content)

        // Create mood if provided
        var moodRecord: MoodRecord?
        if let mood = mood {
            do {
                moodRecord = try await createMood(score: mood.score)
            } catch APIClientError.conflict {
                // Mood already recorded today - ignore
            }
        }

        // Create check-in
        let checkin = try await checkInToday()

        return (journal, moodRecord, checkin)
    }

    // MARK: - Pause Status

    /// Get pause status
    func getPauseStatus() async throws -> PauseStatus {
        let response: ApiResponsePauseStatus = try await apiClient.get("/users/me/pause-checkin", queryParams: nil)
        return response.data
    }

    /// Set pause status
    func setPauseStatus(paused: Bool) async throws -> PauseStatus {
        let request = PauseStatusUpdate(paused: paused)
        let response: ApiResponsePauseStatus = try await apiClient.post("/users/me/pause-checkin", body: request)
        return response.data
    }

    // MARK: - Emergency Contact

    /// Get emergency contact
    func getEmergencyContact() async throws -> EmergencyContact? {
        let response: ApiResponseEmergencyContact = try await apiClient.get("/users/me/emergency-contact", queryParams: nil)
        return response.data
    }

    /// Update emergency contact
    func updateEmergencyContact(name: String, email: String, relationship: String?) async throws -> EmergencyContact {
        let request = EmergencyContactUpsert(name: name, email: email, relationship: relationship)
        let response: ApiResponseEmergencyContact = try await apiClient.put("/users/me/emergency-contact", body: request)
        guard let contact = response.data else {
            throw APIClientError.noData
        }
        return contact
    }

    // MARK: - Check-in Reminder

    /// Get check-in reminder settings
    func getCheckinReminder() async throws -> CheckinReminder {
        let response: ApiResponseCheckinReminder = try await apiClient.get("/users/me/checkin-reminder", queryParams: nil)
        return response.data
    }

    /// Update check-in reminder settings
    func updateCheckinReminder(_ reminder: CheckinReminder) async throws -> CheckinReminder {
        let response: ApiResponseCheckinReminder = try await apiClient.put("/users/me/checkin-reminder", body: reminder)
        return response.data
    }

    // MARK: - Miss Check-in Rule

    /// Get miss check-in rule
    func getMissCheckinRule() async throws -> MissCheckinRule {
        let response: ApiResponseMissCheckinRule = try await apiClient.get("/users/me/miss-checkin-rule", queryParams: nil)
        return response.data
    }

    /// Update miss check-in rule
    func updateMissCheckinRule(_ rule: MissCheckinRule) async throws -> MissCheckinRule {
        let response: ApiResponseMissCheckinRule = try await apiClient.put("/users/me/miss-checkin-rule", body: rule)
        return response.data
    }
}
