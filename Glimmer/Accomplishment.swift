import Foundation
import SwiftData
import SwiftUI

// MARK: - Mood Enum

enum Mood: String, Codable, CaseIterable {
    case happy = "Happy"
    case normal = "Normal"
    case angry = "Anger"
    case sad = "Sad"
    case peaceful = "Peaceful"
    case shy = "Shy"
    case tired = "Tired"
    case numb = "Numb"

    /// Asset image name for the 5 primary moods; nil for secondary moods
    var imageName: String? {
        switch self {
        case .happy: return "EmojiHappy"
        case .normal: return "EmojiNormal"
        case .angry: return "EmojiAngry"
        case .sad: return "EmojiSad"
        case .peaceful: return "EmojiPeaceful"
        case .shy, .tired, .numb: return nil
        }
    }

    /// Fallback text emoji for moods without custom assets
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .normal: return "😐"
        case .angry: return "😠"
        case .sad: return "😢"
        case .peaceful: return "😌"
        case .shy: return "🥺"
        case .tired: return "😴"
        case .numb: return "😶"
        }
    }

    var color: Color {
        switch self {
        case .happy: return Color(red: 0.988, green: 0.804, blue: 0.737)   // #FCCDBC
        case .normal: return Color(red: 0.816, green: 0.910, blue: 0.957)  // #D0E8F4
        case .angry: return Color(red: 0.953, green: 0.580, blue: 0.529)   // #F39487
        case .sad: return Color(red: 0.847, green: 0.761, blue: 0.914)     // #D8C2E9
        case .peaceful: return Color(red: 0.839, green: 0.910, blue: 0.702) // #D6E8B3
        case .shy: return Color(red: 0.980, green: 0.898, blue: 0.647)     // #FAE5A5
        case .tired: return Color(red: 0.976, green: 0.753, blue: 0.792)   // #F9C0CA
        case .numb: return Color(red: 0.678, green: 0.773, blue: 0.925)    // #ADC5EC
        }
    }

    /// The 5 primary moods shown in the quick picker
    static var primary: [Mood] {
        [.happy, .normal, .angry, .sad, .peaceful]
    }

    /// Additional moods shown in "More"
    static var secondary: [Mood] {
        [.shy, .tired, .numb]
    }
}

// MARK: - Mood Emoji View

struct MoodEmojiView: View {
    let mood: Mood
    var size: CGFloat = 30

    var body: some View {
        if let imageName = mood.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Text(mood.emoji)
                .font(.system(size: size * 0.6))
        }
    }
}

// MARK: - Accomplishment Model

@Model
final class Accomplishment {
    var text: String
    var createdAt: Date
    var moodRaw: String?

    var mood: Mood? {
        get { moodRaw.flatMap { Mood(rawValue: $0) } }
        set { moodRaw = newValue?.rawValue }
    }

    init(text: String, mood: Mood? = nil, createdAt: Date = .now) {
        self.text = text
        self.moodRaw = mood?.rawValue
        self.createdAt = createdAt
    }
}
