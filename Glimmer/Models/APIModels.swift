import Foundation

// MARK: - Base Response Wrapper

struct ApiResponse<T: Codable>: Codable {
    let data: T
    let message: String
}

struct ApiResponseMessage: Codable {
    let message: String
}

// MARK: - Journal Models

struct JournalRecord: Codable, Identifiable {
    let journalId: String
    let localDate: String
    let title: String?
    let content: String
    let occurredAtUtc: Date
    let timezoneUsed: String?
    let createdAt: Date

    var id: String { journalId }

    enum CodingKeys: String, CodingKey {
        case journalId = "journal_id"
        case localDate = "local_date"
        case title
        case content
        case occurredAtUtc = "occurred_at_utc"
        case timezoneUsed = "timezone_used"
        case createdAt = "created_at"
    }
}

struct JournalCreateRequest: Codable {
    let content: String
    let title: String?

    init(content: String, title: String? = nil) {
        self.content = content
        self.title = title
    }
}

struct JournalRecordList: Codable {
    let items: [JournalRecord]
    let count: Int
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case items
        case count
        case nextCursor = "next_cursor"
    }
}

// MARK: - Journal with Warm Message

struct JournalWithWarmMessage: Codable {
    let journalId: String
    let localDate: String
    let title: String?
    let content: String
    let occurredAtUtc: Date
    let timezoneUsed: String?
    let createdAt: Date
    let warmMessage: AIWarmMessageList?

    enum CodingKeys: String, CodingKey {
        case journalId = "journal_id"
        case localDate = "local_date"
        case title
        case content
        case occurredAtUtc = "occurred_at_utc"
        case timezoneUsed = "timezone_used"
        case createdAt = "created_at"
        case warmMessage = "warm_message"
    }
}

struct AIWarmMessageList: Codable {
    let messageId: String
    let alternatives: [AIWarmMessage]
    let generatedAt: Date

    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case alternatives
        case generatedAt = "generated_at"
    }
}

struct AIWarmMessage: Codable {
    let warmMessage: String
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case warmMessage = "warm_message"
        case tags
    }
}

// MARK: - Mood Models

struct MoodRecord: Codable, Identifiable {
    let moodId: String
    let localDate: String
    let score: Int
    let occurredAtUtc: Date
    let timezoneUsed: String?
    let createdAt: Date

    var id: String { moodId }

    enum CodingKeys: String, CodingKey {
        case moodId = "mood_id"
        case localDate = "local_date"
        case score
        case occurredAtUtc = "occurred_at_utc"
        case timezoneUsed = "timezone_used"
        case createdAt = "created_at"
    }
}

struct MoodCreateRequest: Codable {
    let score: Int
}

struct MoodRecordList: Codable {
    let items: [MoodRecord]
    let count: Int
}

// MARK: - Checkin Models

struct CheckinStatus: Codable {
    let checkinId: String?
    let localDate: String
    let checkedInToday: Bool

    enum CodingKeys: String, CodingKey {
        case checkinId = "checkin_id"
        case localDate = "local_date"
        case checkedInToday = "checked_in_today"
    }
}

// MARK: - Pause Status

struct PauseStatus: Codable {
    let paused: Bool
    let pausedAt: Date?

    enum CodingKeys: String, CodingKey {
        case paused
        case pausedAt = "paused_at"
    }
}

struct PauseStatusUpdate: Codable {
    let paused: Bool
}

// MARK: - Emergency Contact

struct EmergencyContact: Codable {
    let contactId: String
    let name: String
    let email: String
    let relationship: String?

    enum CodingKeys: String, CodingKey {
        case contactId = "contact_id"
        case name
        case email
        case relationship
    }
}

struct EmergencyContactUpsert: Codable {
    let name: String
    let email: String
    let relationship: String?
}

// MARK: - Checkin Reminder

struct CheckinReminder: Codable {
    let enabled: Bool
    let timeLocal: String
    let frequencyType: String
    let intervalDays: Int?

    enum CodingKeys: String, CodingKey {
        case enabled
        case timeLocal = "time_local"
        case frequencyType = "frequency_type"
        case intervalDays = "interval_days"
    }
}

// MARK: - Miss Checkin Rule

struct MissCheckinRule: Codable {
    let thresholdDays: Int
    let messageTemplate: String

    enum CodingKeys: String, CodingKey {
        case thresholdDays = "threshold_days"
        case messageTemplate = "message_template"
    }
}

// MARK: - Error Response

struct APIError: Codable {
    let error: ErrorDetail
    let timestamp: Date

    struct ErrorDetail: Codable {
        let code: String
        let message: String
        let details: [String: String]?
    }
}

// MARK: - Type Aliases for API Responses

typealias ApiResponseJournal = ApiResponse<JournalRecord>
typealias ApiResponseJournalList = ApiResponse<JournalRecordList>
typealias ApiResponseJournalWithWarmMessage = ApiResponse<JournalWithWarmMessage>
typealias ApiResponseMood = ApiResponse<MoodRecord>
typealias ApiResponseMoodList = ApiResponse<MoodRecordList>
typealias ApiResponseCheckinStatus = ApiResponse<CheckinStatus>
typealias ApiResponsePauseStatus = ApiResponse<PauseStatus>
typealias ApiResponseEmergencyContact = ApiResponse<EmergencyContact?>
typealias ApiResponseCheckinReminder = ApiResponse<CheckinReminder>
typealias ApiResponseMissCheckinRule = ApiResponse<MissCheckinRule>
