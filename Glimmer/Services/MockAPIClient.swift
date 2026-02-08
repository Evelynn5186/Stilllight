import Foundation

// MARK: - Mock API Client

class MockAPIClient: APIClientProtocol {
    static let shared = MockAPIClient()

    // MARK: - In-Memory Storage

    private var journals: [JournalRecord] = []
    private var moods: [MoodRecord] = []
    private var checkins: [String: CheckinStatus] = [:] // keyed by local_date
    private var pauseStatus = PauseStatus(paused: false, pausedAt: nil)
    private var emergencyContact: EmergencyContact?
    private var checkinReminder = CheckinReminder(
        enabled: true,
        timeLocal: "21:00",
        frequencyType: "daily",
        intervalDays: nil
    )
    private var missCheckinRule = MissCheckinRule(
        thresholdDays: 3,
        messageTemplate: "Hi {user_name}, we noticed you haven't checked in for {days_missed} days. Just wanted to make sure you're okay."
    )

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Initialization

    init() {
        setupMockData()
    }

    private func setupMockData() {
        let calendar = Calendar.current
        let today = Date()

        // Generate journals for past 14 days
        let journalContents = [
            "Had a great morning walk today. The air was crisp and refreshing.",
            "Finally finished that project I've been working on for weeks!",
            "Noticed the sunset was beautiful today. Took a moment to appreciate it.",
            "Met up with an old friend for coffee. It was really nice to catch up.",
            "Tried a new recipe for dinner. It turned out surprisingly well!",
            "Spent some time reading a good book. Very relaxing afternoon.",
            "Got some exercise in today. Feeling energized!",
            "Had a productive day at work. Accomplished everything on my list.",
            "Took time to meditate this morning. Starting the day with calm.",
            "Helped a neighbor with their groceries. Small acts of kindness matter.",
            "Learned something new today. Always growing!",
            "Grateful for the little things - a warm cup of tea, sunshine through the window.",
            "Had a meaningful conversation with family. Connection is important.",
            "Completed a task I'd been putting off. Relief!"
        ]

        let moodScores = [1, 2, 5, 1, 2, 5, 1, 2, 3, 4, 5, 1, 2, 1] // Happy=1, Normal=2, etc.

        // Start from day 1 (yesterday) - today has NO check-in by default for testing full flow
        for dayOffset in 1..<15 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let localDate = dateFormatter.string(from: date)
            let journalId = UUID().uuidString
            let moodId = UUID().uuidString

            // Skip some days to simulate missed check-ins
            if dayOffset > 2 && dayOffset % 4 == 3 {
                continue
            }

            let journal = JournalRecord(
                journalId: journalId,
                localDate: localDate,
                title: nil,
                content: journalContents[dayOffset % journalContents.count],
                occurredAtUtc: date,
                timezoneUsed: TimeZone.current.identifier,
                createdAt: date
            )
            journals.append(journal)

            let mood = MoodRecord(
                moodId: moodId,
                localDate: localDate,
                score: moodScores[dayOffset % moodScores.count],
                occurredAtUtc: date,
                timezoneUsed: TimeZone.current.identifier,
                createdAt: date
            )
            moods.append(mood)

            // Create check-in status for days with entries
            checkins[localDate] = CheckinStatus(
                checkinId: UUID().uuidString,
                localDate: localDate,
                checkedInToday: true,
                timezoneUsed: TimeZone.current.identifier
            )
        }

        // Setup emergency contact
        emergencyContact = EmergencyContact(
            contactId: UUID().uuidString,
            name: "John Smith",
            email: "john.smith@example.com",
            relationship: "Friend"
        )
    }

    // MARK: - Helper

    private func todayLocalDate() -> String {
        return dateFormatter.string(from: Date())
    }

    // MARK: - APIClientProtocol

    func get<T: Decodable>(_ endpoint: String, queryParams: [String: String]? = nil) async throws -> T {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

        switch endpoint {
        // Journals
        case "/journals":
            let list = JournalRecordList(items: journals.sorted { $0.createdAt > $1.createdAt }, count: journals.count, nextCursor: nil)
            let response = ApiResponse(data: list, message: "OK")
            return try cast(response)

        case "/journals/today":
            let todayJournals = journals.filter { $0.localDate == todayLocalDate() }
            let list = JournalRecordList(items: todayJournals, count: todayJournals.count, nextCursor: nil)
            let response = ApiResponse(data: list, message: "OK")
            return try cast(response)

        case "/journals/random":
            let pastJournals = journals.filter { $0.localDate != todayLocalDate() }
            guard let randomJournal = pastJournals.randomElement() else {
                throw APIClientError.notFound
            }
            let response = ApiResponse(data: randomJournal, message: "OK")
            return try cast(response)

        case "/journals/random-with-msg":
            let pastJournals = journals.filter { $0.localDate != todayLocalDate() }
            guard let randomJournal = pastJournals.randomElement() else {
                throw APIClientError.notFound
            }
            let warmMessages = AIWarmMessageList(
                messageId: UUID().uuidString,
                alternatives: [
                    AIWarmMessage(warmMessage: "That sounds like meaningful progress. Take a moment to appreciate this step forward.", tags: ["empathy", "encouragement"]),
                    AIWarmMessage(warmMessage: "I hear you. These moments matter. You're doing great.", tags: ["support", "calm"]),
                    AIWarmMessage(warmMessage: "You're making real progress. Keep trusting your process.", tags: ["proud", "hope"])
                ],
                generatedAt: Date()
            )
            let journalWithMsg = JournalWithWarmMessage(
                journalId: randomJournal.journalId,
                localDate: randomJournal.localDate,
                title: randomJournal.title,
                content: randomJournal.content,
                occurredAtUtc: randomJournal.occurredAtUtc,
                timezoneUsed: randomJournal.timezoneUsed,
                createdAt: randomJournal.createdAt,
                warmMessage: warmMessages
            )
            let response = ApiResponse(data: journalWithMsg, message: "OK")
            return try cast(response)

        // Moods
        case "/moods":
            let list = MoodRecordList(items: moods.sorted { $0.createdAt > $1.createdAt }, count: moods.count)
            let response = ApiResponse(data: list, message: "OK")
            return try cast(response)

        case "/moods/today":
            guard let todayMood = moods.first(where: { $0.localDate == todayLocalDate() }) else {
                throw APIClientError.notFound
            }
            let response = ApiResponse(data: todayMood, message: "OK")
            return try cast(response)

        // Checkins
        case "/checkins/today":
            let today = todayLocalDate()
            if let status = checkins[today] {
                let response = ApiResponse(data: status, message: "OK")
                return try cast(response)
            } else {
                let status = CheckinStatus(checkinId: nil, localDate: today, checkedInToday: false, timezoneUsed: TimeZone.current.identifier)
                let response = ApiResponse(data: status, message: "OK")
                return try cast(response)
            }

        // Safety
        case "/users/me/pause-checkin":
            let response = ApiResponse(data: pauseStatus, message: "OK")
            return try cast(response)

        case "/users/me/emergency-contact":
            let response = ApiResponse(data: emergencyContact, message: "OK")
            return try cast(response)

        case "/users/me/checkin-reminder":
            let response = ApiResponse(data: checkinReminder, message: "OK")
            return try cast(response)

        case "/users/me/miss-checkin-rule":
            let response = ApiResponse(data: missCheckinRule, message: "OK")
            return try cast(response)

        default:
            throw APIClientError.notFound
        }
    }

    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B?) async throws -> T {
        try await Task.sleep(nanoseconds: 300_000_000)

        switch endpoint {
        // Journals
        case "/journals":
            guard let request = body as? JournalCreateRequest else {
                throw APIClientError.serverError(400, "Invalid request body")
            }
            let today = todayLocalDate()
            let journal = JournalRecord(
                journalId: UUID().uuidString,
                localDate: today,
                title: request.title,
                content: request.content,
                occurredAtUtc: Date(),
                timezoneUsed: TimeZone.current.identifier,
                createdAt: Date()
            )
            journals.insert(journal, at: 0)
            let response = ApiResponse(data: journal, message: "OK")
            return try cast(response)

        // Moods
        case "/moods":
            guard let request = body as? MoodCreateRequest else {
                throw APIClientError.serverError(400, "Invalid request body")
            }
            let today = todayLocalDate()
            // Check if already exists
            if moods.contains(where: { $0.localDate == today }) {
                throw APIClientError.conflict("Mood already recorded for today")
            }
            let mood = MoodRecord(
                moodId: UUID().uuidString,
                localDate: today,
                score: request.score,
                occurredAtUtc: Date(),
                timezoneUsed: TimeZone.current.identifier,
                createdAt: Date()
            )
            moods.insert(mood, at: 0)
            let response = ApiResponse(data: mood, message: "OK")
            return try cast(response)

        // Checkins
        case "/checkins":
            if pauseStatus.paused {
                throw APIClientError.conflict("Check-ins are paused")
            }
            let today = todayLocalDate()
            // Idempotent: return existing if already checked in
            if let existing = checkins[today] {
                let response = ApiResponse(data: existing, message: "OK")
                return try cast(response)
            }
            let status = CheckinStatus(
                checkinId: UUID().uuidString,
                localDate: today,
                checkedInToday: true,
                timezoneUsed: TimeZone.current.identifier
            )
            checkins[today] = status
            let response = ApiResponse(data: status, message: "OK")
            return try cast(response)

        // Pause status
        case "/users/me/pause-checkin":
            guard let request = body as? PauseStatusUpdate else {
                throw APIClientError.serverError(400, "Invalid request body")
            }
            pauseStatus = PauseStatus(paused: request.paused, pausedAt: request.paused ? Date() : nil)
            let response = ApiResponse(data: pauseStatus, message: "OK")
            return try cast(response)

        default:
            throw APIClientError.notFound
        }
    }

    func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        try await Task.sleep(nanoseconds: 300_000_000)

        switch endpoint {
        case "/users/me/emergency-contact":
            guard let request = body as? EmergencyContactUpsert else {
                throw APIClientError.serverError(400, "Invalid request body")
            }
            let contact = EmergencyContact(
                contactId: emergencyContact?.contactId ?? UUID().uuidString,
                name: request.name,
                email: request.email,
                relationship: request.relationship
            )
            emergencyContact = contact
            let response = ApiResponse(data: Optional(contact), message: "OK")
            return try cast(response)

        case "/users/me/checkin-reminder":
            guard let request = body as? CheckinReminder else {
                throw APIClientError.serverError(400, "Invalid request body")
            }
            checkinReminder = request
            let response = ApiResponse(data: checkinReminder, message: "OK")
            return try cast(response)

        case "/users/me/miss-checkin-rule":
            guard let request = body as? MissCheckinRule else {
                throw APIClientError.serverError(400, "Invalid request body")
            }
            missCheckinRule = request
            let response = ApiResponse(data: missCheckinRule, message: "OK")
            return try cast(response)

        default:
            throw APIClientError.notFound
        }
    }

    func patch<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        throw APIClientError.notFound
    }

    func delete(_ endpoint: String) async throws {
        throw APIClientError.notFound
    }

    // MARK: - Helper

    private func cast<T>(_ value: Any) throws -> T {
        guard let result = value as? T else {
            throw APIClientError.decodingError(NSError(domain: "MockAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Type mismatch"]))
        }
        return result
    }

    // MARK: - Test Helpers

    func clearTodayData() {
        let today = todayLocalDate()
        journals.removeAll { $0.localDate == today }
        moods.removeAll { $0.localDate == today }
        checkins.removeValue(forKey: today)
    }

    func resetAllData() {
        journals.removeAll()
        moods.removeAll()
        checkins.removeAll()
        pauseStatus = PauseStatus(paused: false, pausedAt: nil)
        setupMockData()
    }
}
