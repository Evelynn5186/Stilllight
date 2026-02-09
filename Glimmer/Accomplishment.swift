import Foundation
import SwiftData
import SwiftUI

// MARK: - Mood Enum

enum Mood: String, Codable, CaseIterable {
    // 15 moods matching the emoji sprite sheet
    case happy = "Happy"           // 1 - peach, happy closed eyes
    case joyful = "Joyful"         // 2 - yellow, big smile
    case shy = "Shy"               // 3 - pink, blushing
    case peaceful = "Peaceful"     // 4 - light green, serene
    case calm = "Calm"             // 5 - mint, small neutral eyes
    case neutral = "Neutral"       // 6 - light blue, blank
    case sad = "Sad"               // 7 - gray-green, downturned mouth
    case worried = "Worried"       // 8 - blue, surprised/worried
    case annoyed = "Annoyed"       // 9 - purple, frowning
    case angry = "Angry"           // 10 - coral, angry
    case furious = "Furious"       // 11 - red, very angry
    case tired = "Tired"           // 12 - yellow, sleepy
    case dizzy = "Dizzy"           // 13 - pink, spiral eyes
    case down = "Down"             // 14 - blue, sad sideways
    case numb = "Numb"             // 15 - light purple, expressionless

    /// Asset image name for moods
    var imageName: String {
        switch self {
        case .happy: return "EmojiHappy"
        case .joyful: return "EmojiJoyful"
        case .shy: return "EmojiShy"
        case .peaceful: return "EmojiPeaceful"
        case .calm: return "EmojiCalm"
        case .neutral: return "EmojiNeutral"
        case .sad: return "EmojiSad"
        case .worried: return "EmojiWorried"
        case .annoyed: return "EmojiAnnoyed"
        case .angry: return "EmojiAngry"
        case .furious: return "EmojiFurious"
        case .tired: return "EmojiTired"
        case .dizzy: return "EmojiDizzy"
        case .down: return "EmojiDown"
        case .numb: return "EmojiNumb"
        }
    }

    /// Fallback text emoji
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .joyful: return "😄"
        case .shy: return "🥺"
        case .peaceful: return "😌"
        case .calm: return "🙂"
        case .neutral: return "😐"
        case .sad: return "😢"
        case .worried: return "😟"
        case .annoyed: return "😒"
        case .angry: return "😠"
        case .furious: return "😡"
        case .tired: return "😴"
        case .dizzy: return "😵"
        case .down: return "😞"
        case .numb: return "😶"
        }
    }

    /// Color extracted from the emoji images
    var color: Color {
        switch self {
        case .happy: return Color(red: 0.961, green: 0.796, blue: 0.765)     // Peach
        case .joyful: return Color(red: 0.976, green: 0.886, blue: 0.659)    // Yellow
        case .shy: return Color(red: 0.957, green: 0.765, blue: 0.780)       // Pink
        case .peaceful: return Color(red: 0.839, green: 0.906, blue: 0.725)  // Light green
        case .calm: return Color(red: 0.816, green: 0.925, blue: 0.878)      // Mint
        case .neutral: return Color(red: 0.792, green: 0.878, blue: 0.941)   // Light blue
        case .sad: return Color(red: 0.757, green: 0.800, blue: 0.749)       // Gray-green
        case .worried: return Color(red: 0.710, green: 0.765, blue: 0.878)   // Blue
        case .annoyed: return Color(red: 0.808, green: 0.765, blue: 0.878)   // Purple
        case .angry: return Color(red: 0.941, green: 0.702, blue: 0.671)     // Coral
        case .furious: return Color(red: 0.918, green: 0.608, blue: 0.576)   // Red
        case .tired: return Color(red: 0.976, green: 0.886, blue: 0.659)     // Yellow
        case .dizzy: return Color(red: 0.918, green: 0.667, blue: 0.667)     // Pink
        case .down: return Color(red: 0.710, green: 0.765, blue: 0.878)      // Blue
        case .numb: return Color(red: 0.831, green: 0.808, blue: 0.878)      // Light purple
        }
    }

    /// The 5 primary moods shown in the quick picker
    static var primary: [Mood] {
        [.happy, .joyful, .peaceful, .neutral, .sad]
    }

    /// Additional moods shown in "More"
    static var secondary: [Mood] {
        [.shy, .calm, .worried, .annoyed, .angry, .furious, .tired, .dizzy, .down, .numb]
    }

    /// API score mapping (1-15)
    var score: Int {
        switch self {
        case .happy: return 1
        case .joyful: return 2
        case .shy: return 3
        case .peaceful: return 4
        case .calm: return 5
        case .neutral: return 6
        case .sad: return 7
        case .worried: return 8
        case .annoyed: return 9
        case .angry: return 10
        case .furious: return 11
        case .tired: return 12
        case .dizzy: return 13
        case .down: return 14
        case .numb: return 15
        }
    }

    /// Create Mood from API score
    static func from(score: Int) -> Mood? {
        switch score {
        case 1: return .happy
        case 2: return .joyful
        case 3: return .shy
        case 4: return .peaceful
        case 5: return .calm
        case 6: return .neutral
        case 7: return .sad
        case 8: return .worried
        case 9: return .annoyed
        case 10: return .angry
        case 11: return .furious
        case 12: return .tired
        case 13: return .dizzy
        case 14: return .down
        case 15: return .numb
        default: return nil
        }
    }
}

// MARK: - Mood Emoji View

struct MoodEmojiView: View {
    let mood: Mood
    var size: CGFloat = 30

    var body: some View {
        Image(mood.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

// MARK: - Accomplishment Model

@Model
final class Accomplishment {
    var text: String
    var createdAt: Date
    var localDate: String = ""  // "yyyy-MM-dd" format for calendar matching
    var moodRaw: String?
    var journalId: String?  // Links to API JournalRecord
    var moodId: String?     // Links to API MoodRecord

    var mood: Mood? {
        get { moodRaw.flatMap { Mood(rawValue: $0) } }
        set { moodRaw = newValue?.rawValue }
    }

    init(text: String, mood: Mood? = nil, createdAt: Date = .now, localDate: String? = nil, journalId: String? = nil, moodId: String? = nil) {
        self.text = text
        self.moodRaw = mood?.rawValue
        self.createdAt = createdAt
        // Use provided localDate or generate from createdAt
        if let localDate = localDate {
            self.localDate = localDate
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            self.localDate = formatter.string(from: createdAt)
        }
        self.journalId = journalId
        self.moodId = moodId
    }

    /// Create from API JournalRecord and MoodRecord
    convenience init(from journal: JournalRecord, mood moodRecord: MoodRecord?) {
        let mood = moodRecord.flatMap { Mood.from(score: $0.score) }
        self.init(
            text: journal.content,
            mood: mood,
            createdAt: journal.createdAt,
            localDate: journal.localDate,  // Use the API's localDate
            journalId: journal.journalId,
            moodId: moodRecord?.moodId
        )
    }
}
