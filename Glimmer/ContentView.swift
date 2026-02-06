import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @Query private var accomplishments: [Accomplishment]
    @AppStorage("pauseCheckIns") private var pauseCheckIns = false

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    private var hasCheckedInToday: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return accomplishments.contains { accomplishment in
            calendar.isDate(accomplishment.createdAt, inSameDayAs: today)
        }
    }

    private var isDarkTheme: Bool {
        selectedTab == 0 && (!hasCheckedInToday || pauseCheckIns)
    }

    init() {
        // Hide default tab bar
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)

                JournalView()
                    .tag(1)

                SettingsView()
                    .tag(2)
            }

            // Custom Tab Bar matching Figma design
            CustomTabBar(selectedTab: $selectedTab, isDarkTheme: isDarkTheme)
        }
        .ignoresSafeArea(.keyboard)
        .animation(.easeInOut(duration: 0.3), value: isDarkTheme)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    var isDarkTheme: Bool = false

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    var body: some View {
        HStack(spacing: 0) {
            // Here tab - uses custom blob icon from Figma
            BlobTabBarItem(
                title: "Here",
                isSelected: selectedTab == 0,
                isDarkTheme: isDarkTheme,
                action: { selectedTab = 0 }
            )

            // Journal tab
            TabBarItem(
                icon: "book.closed",
                selectedIcon: "book.closed.fill",
                title: "Journal",
                isSelected: selectedTab == 1,
                isDarkTheme: isDarkTheme,
                action: { selectedTab = 1 }
            )

            // Settings tab
            TabBarItem(
                icon: "gearshape",
                selectedIcon: "gearshape.fill",
                title: "Settings",
                isSelected: selectedTab == 2,
                isDarkTheme: isDarkTheme,
                action: { selectedTab = 2 }
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(isDarkTheme ? Color(red: 0.24, green: 0.30, blue: 0.34) : Color.white)
                .shadow(
                    color: isDarkTheme
                        ? Color(red: 0.17, green: 0.23, blue: 0.28)
                        : Color(red: 0.98, green: 0.61, blue: 0.27).opacity(0.20),
                    radius: 30,
                    x: 0,
                    y: 20
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

// MARK: - Tab Bar Item

struct TabBarItem: View {
    let icon: String
    let selectedIcon: String
    let title: String
    let isSelected: Bool
    var isDarkTheme: Bool = false
    let action: () -> Void

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    private var activeColor: Color {
        isDarkTheme ? .white : themeBrown
    }

    private var inactiveColor: Color {
        isDarkTheme ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.34, green: 0.33, blue: 0.31)
    }

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? activeColor : inactiveColor)

                Text(title)
                    .font(.custom("Urbanist", size: 12).weight(isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? activeColor : inactiveColor)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Blob Tab Bar Item (custom "Here" icon from Figma)

struct BlobTabBarItem: View {
    let title: String
    let isSelected: Bool
    var isDarkTheme: Bool = false
    let action: () -> Void

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    private var activeColor: Color {
        isDarkTheme ? .white : themeBrown
    }

    private var inactiveColor: Color {
        isDarkTheme ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.34, green: 0.33, blue: 0.31)
    }

    private var blobIconName: String {
        if isDarkTheme {
            return isSelected ? "BlobIconDarkSelected" : "BlobIconUnselected"
        } else {
            return isSelected ? "BlobIconSelected" : "BlobIconUnselected"
        }
    }

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            VStack(spacing: 4) {
                Image(blobIconName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 18)

                Text(title)
                    .font(.custom("Urbanist", size: 12).weight(isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? activeColor : inactiveColor)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Journal View

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Accomplishment.createdAt, order: .reverse) private var accomplishments: [Accomplishment]

    @State private var isCardFlipped = false
    @State private var selectedGlimmer: Accomplishment?

    private let bgColor = Color(red: 0.969, green: 0.953, blue: 0.937)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Gather a Little Light card (with flip support)
                    GatherLightFlipCard(
                        isFlipped: $isCardFlipped,
                        accomplishment: selectedGlimmer,
                        onGather: catchGlimmer
                    )
                    .padding(.top, 8)

                    // Week strip
                    WeekStripView(accomplishments: accomplishments)

                    // Today's mood card
                    TodayMoodCard(accomplishments: accomplishments)

                    // Mood Calendar
                    MoodCalendarSection(accomplishments: accomplishments)

                    Spacer().frame(height: 100)
                }
                .padding(.top, 16)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func catchGlimmer() {
        selectedGlimmer = accomplishments.isEmpty ? nil : accomplishments.randomElement()
        withAnimation(.easeInOut(duration: 0.4)) {
            isCardFlipped = true
        }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

// MARK: - Gather a Little Light Flip Card (Journal Page)

struct GatherLightFlipCard: View {
    @Binding var isFlipped: Bool
    let accomplishment: Accomplishment?
    let onGather: () -> Void

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let cardBlue = Color(red: 0.84, green: 0.91, blue: 1.0)

    private let insights = [
        "Simple moments can still mean something.",
        "You noticed the light. That's enough.",
        "This was worth holding onto.",
        "The small things carry the most warmth.",
        "You showed up, and that matters.",
        "Every glimmer adds to the whole.",
    ]

    private var insight: String {
        let day = Calendar.current.component(.day, from: Date())
        return insights[day % insights.count]
    }

    var body: some View {
        ZStack {
            // Front of card (before flip)
            frontCard
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )

            // Back of card (after flip)
            backCard
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .padding(.horizontal, 32)
    }

    private var frontCard: some View {
        VStack(spacing: 0) {
            // Gradient button
            Button(action: onGather) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 20, weight: .medium))
                    Text("Gather a little light")
                        .font(.custom("Urbanist", size: 20).weight(.medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(LinearGradient(
                                        colors: [
                                            Color(red: 0.224, green: 0.098, blue: 0.012),
                                            Color(red: 0.588, green: 0.361, blue: 0.035)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)

            // Description text
            VStack(spacing: 2) {
                Text("Rediscover a moment with us:")
                Text("We'll bring back a moment you once shared,")
                Text("along with a thoughtful reflection from us.")
            }
            .font(.custom("Urbanist", size: 14))
            .foregroundColor(Color(red: 0.33, green: 0.21, blue: 0.19))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .frame(height: 218)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
    }

    private var backCard: some View {
        VStack(spacing: 0) {
            // Blue inner card with glimmer content
            VStack(spacing: 12) {
                if let accomplishment = accomplishment {
                    // Glimmer text
                    Text("\u{201C}" + accomplishment.text + "\u{201D}")
                        .font(.custom("Baskerville", size: 15))
                        .foregroundColor(themeBrown)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    // Timestamp
                    Text(formattedDate(accomplishment.createdAt))
                        .font(.custom("Urbanist", size: 10))
                        .foregroundColor(themeBrown.opacity(0.5))
                } else {
                    Text("Keep collecting glimmers,\nthey'll be here waiting for you.")
                        .font(.custom("Urbanist", size: 14))
                        .foregroundColor(themeBrown.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(cardBlue)
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Encouraging message
            Text(insight)
                .font(.custom("Urbanist", size: 12))
                .foregroundColor(themeBrown.opacity(0.6))
                .italic()
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)

            // Tap to flip back
            Button(action: {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isFlipped = false
                }
            }) {
                Text("Tap to gather another")
                    .font(.custom("Urbanist", size: 12).weight(.medium))
                    .foregroundColor(themeBrown.opacity(0.5))
            }
            .padding(.bottom, 16)
        }
        .frame(height: 218)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }

        return formatter.string(from: date)
    }
}

// MARK: - Gather a Little Light Card (for other use)

struct GatherLightCard: View {
    let action: () -> Void

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    var body: some View {
        VStack(spacing: 0) {
            // Gradient button
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 20, weight: .medium))
                    Text("Gather a little light")
                        .font(.custom("Urbanist", size: 20).weight(.medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.224, green: 0.098, blue: 0.012),
                                    Color(red: 0.588, green: 0.361, blue: 0.035)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 32)

            // Description text
            VStack(spacing: 2) {
                Text("Rediscover a moment with us:")
                Text("We'll bring back a moment you once shared,")
                Text("along with a thoughtful reflection from us.")
            }
            .font(.custom("Urbanist", size: 14))
            .foregroundColor(themeBrown)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
        .padding(.horizontal, 32)
    }
}

// MARK: - Week Strip View

struct WeekStripView: View {
    let accomplishments: [Accomplishment]

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        return cal
    }()

    private var weekDates: [Date] {
        let today = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        guard let monday = calendar.date(from: components) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
    }

    private func entryForDate(_ date: Date) -> Accomplishment? {
        accomplishments.first { calendar.isDate($0.createdAt, inSameDayAs: date) }
    }

    private func hasEntry(on date: Date) -> Bool {
        entryForDate(date) != nil
    }

    private func moodColor(for date: Date) -> Color {
        if let entry = entryForDate(date), let mood = entry.mood {
            return mood.color
        }
        // Light warm color for entries without mood
        return Color(red: 0.98, green: 0.93, blue: 0.76)
    }

    private func moodFor(date: Date) -> Mood? {
        return entryForDate(date)?.mood
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.self) { date in
                let isToday = calendar.isDateInToday(date)
                let isFuture = date > Date() && !isToday
                let hasLog = hasEntry(on: date)
                let dayNum = calendar.component(.day, from: date)

                VStack(spacing: 3) {
                    VStack(spacing: 0) {
                        Text(dayLetter(for: date))
                            .font(.custom("Urbanist", size: 12))
                            .foregroundColor(isToday ? .white : Color(red: 0.341, green: 0.325, blue: 0.306))

                        Text("\(dayNum)")
                            .font(.custom("Urbanist", size: 14).weight(.semibold))
                            .foregroundColor(isToday ? .white : Color(red: 0.161, green: 0.145, blue: 0.141))
                    }
                    .padding(8)
                    .frame(width: 36)
                    .background(
                        Capsule()
                            .fill(isToday ? Color(red: 0.325, green: 0.212, blue: 0.188).opacity(0.8) : Color.white)
                            .overlay(
                                !isToday && !isFuture
                                    ? Capsule().stroke(Color(red: 0.839, green: 0.827, blue: 0.820), lineWidth: 1)
                                    : nil
                            )
                    )
                    .opacity(isFuture ? 0.7 : 1.0)

                    // Mood indicator
                    if hasLog && !isToday {
                        if let mood = moodFor(date: date) {
                            // Show mood emoji
                            MoodEmojiView(mood: mood, size: 12)
                                .frame(width: 14, height: 14)
                        } else {
                            // No mood selected - pure light dot
                            Circle()
                                .fill(moodColor(for: date))
                                .frame(width: 6, height: 6)
                        }
                    } else {
                        Color.clear.frame(width: 14, height: 14)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }

    private func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }
}

// MARK: - Today Mood Card

struct TodayMoodCard: View {
    let accomplishments: [Accomplishment]

    private let calendar = Calendar.current
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)
    private let insights = [
        "Simple moments can still mean something.",
        "You noticed the light. That's enough.",
        "This was worth holding onto.",
        "The small things carry the most warmth.",
        "You showed up, and that matters.",
        "Every glimmer adds to the whole.",
    ]

    private var todayAccomplishment: Accomplishment? {
        accomplishments.first { calendar.isDateInToday($0.createdAt) }
    }

    private var insight: String {
        let day = calendar.component(.day, from: Date())
        return insights[day % insights.count]
    }

    var body: some View {
        if let entry = todayAccomplishment {
            let mood = entry.mood ?? .happy

            VStack(spacing: 12) {
                // Mood name
                Text(mood.rawValue)
                    .font(.custom("Urbanist", size: 24).weight(.medium))
                    .foregroundColor(themeBrown)

                // Mood emoji with colored background
                ZStack {
                    Circle()
                        .fill(mood.color)
                        .frame(width: 80, height: 80)
                    MoodEmojiView(mood: mood, size: 60)
                }
                .frame(width: 130, height: 120)

                // Entry text in Baskerville (per Figma)
                Text("\u{201C}" + entry.text + "\u{201D}")
                    .font(.custom("Baskerville", size: 15))
                    .foregroundColor(themeBrown)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)

                // Timestamp
                Text(formattedTimestamp(entry.createdAt))
                    .font(.custom("Urbanist", size: 10))
                    .foregroundColor(themeBrown.opacity(0.5))

                // Insight
                Text(insight)
                    .font(.custom("Urbanist", size: 12))
                    .foregroundColor(themeBrown.opacity(0.6))
                    .italic()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.980, green: 0.980, blue: 0.976))
            )
            .padding(.horizontal, 32)
        }
    }

    private func formattedTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "'Written on' MMM d, yyyy '·' h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Mood Calendar Section

struct MoodCalendarSection: View {
    let accomplishments: [Accomplishment]

    private let brandAccent = Color(red: 0.573, green: 0.384, blue: 0.278)

    var body: some View {
        VStack(spacing: 12) {
            // Section header
            HStack {
                Text("Mood Calendar")
                    .font(.custom("Urbanist", size: 16).weight(.bold))
                    .foregroundColor(Color(red: 0.161, green: 0.145, blue: 0.141))

                Spacer()

                Button(action: {}) {
                    Text("See All")
                        .font(.custom("Urbanist", size: 14).weight(.medium))
                        .foregroundColor(brandAccent)
                }
            }

            // Calendar card
            MoodCalendarCard(accomplishments: accomplishments)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Mood Calendar Card

struct MoodCalendarCard: View {
    let accomplishments: [Accomplishment]

    @State private var selectedEntry: Accomplishment?
    @State private var showEntryDetail = false

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Monday
        return cal
    }()
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
    private let gray30 = Color(red: 0.839, green: 0.827, blue: 0.820)
    private let gray60 = Color(red: 0.341, green: 0.325, blue: 0.306)
    private let gray80 = Color(red: 0.161, green: 0.145, blue: 0.141)
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    private static let fallbackMoodColors: [Color] = [
        Color(red: 0.988, green: 0.804, blue: 0.737), // Happy peach
        Color(red: 0.816, green: 0.910, blue: 0.957), // Normal blue
        Color(red: 0.839, green: 0.910, blue: 0.702), // Peaceful green
        Color(red: 0.980, green: 0.898, blue: 0.647), // Shy yellow
        Color(red: 0.976, green: 0.753, blue: 0.792), // Tired pink
        Color(red: 0.847, green: 0.761, blue: 0.914), // Sad purple
        Color(red: 0.953, green: 0.580, blue: 0.529), // Angry red
    ]

    private var today: Date { Date() }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: today)!.count
    }

    private var firstOfMonth: Date {
        let comps = calendar.dateComponents([.year, .month], from: today)
        return calendar.date(from: comps)!
    }

    /// Monday-based offset: Monday=0, Tuesday=1, ..., Sunday=6
    private var startOffset: Int {
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return (weekday - 2 + 7) % 7
    }

    private var entriesByDay: [Int: Accomplishment] {
        var map: [Int: Accomplishment] = [:]
        for acc in accomplishments {
            if calendar.isDate(acc.createdAt, equalTo: today, toGranularity: .month) {
                let day = calendar.component(.day, from: acc.createdAt)
                map[day] = acc
            }
        }
        return map
    }

    private var daysWithEntries: Set<Int> {
        Set(entriesByDay.keys)
    }

    private func colorForDay(_ day: Int) -> Color {
        if let acc = entriesByDay[day], let mood = acc.mood {
            return mood.color
        }
        // Light warm color for entries without mood
        return Color(red: 0.98, green: 0.93, blue: 0.76)
    }

    private func moodForDay(_ day: Int) -> Mood? {
        return entriesByDay[day]?.mood
    }

    private var entryCount: Int {
        daysWithEntries.count
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: today)
    }

    private var todayDay: Int {
        calendar.component(.day, from: today)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Month stats
            VStack(alignment: .leading, spacing: 8) {
                Text("\(entryCount)/\(daysInMonth)")
                    .font(.custom("Urbanist", size: 24).weight(.bold))
                    .foregroundColor(gray80)

                Text("Moods logged this month")
                    .font(.custom("Urbanist", size: 16))
                    .foregroundColor(gray80)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Divider
            Rectangle()
                .fill(gray30)
                .frame(height: 0.5)

            // Day headers
            HStack(spacing: 8) {
                ForEach(dayLabels, id: \.self) { label in
                    Text(label)
                        .font(.custom("Urbanist", size: 14).weight(.semibold))
                        .foregroundColor(gray80)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            let totalCells = startOffset + daysInMonth
            let rows = (totalCells + 6) / 7

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { col in
                            let index = row * 7 + col
                            let day = index - startOffset + 1

                            if day >= 1 && day <= daysInMonth {
                                let hasEntry = daysWithEntries.contains(day)
                                let isFutureDay = day > todayDay

                                let isToday = day == todayDay

                                VStack(spacing: 4) {
                                    Text("\(day)")
                                        .font(.custom("Urbanist", size: 12).weight(.medium))
                                        .foregroundColor(gray60)

                                    if hasEntry {
                                        // Mood circle with emoji or plain light circle - tappable
                                        Button(action: {
                                            if let entry = entriesByDay[day] {
                                                selectedEntry = entry
                                                showEntryDetail = true
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                        }) {
                                            if let mood = moodForDay(day) {
                                                ZStack {
                                                    Circle()
                                                        .fill(mood.color)
                                                        .frame(width: 28, height: 28)
                                                    MoodEmojiView(mood: mood, size: 20)
                                                }
                                                .overlay(
                                                    isToday ? Circle().stroke(gray60, style: StrokeStyle(lineWidth: 1, dash: [3, 2])).frame(width: 32, height: 32) : nil
                                                )
                                            } else {
                                                // No mood selected - pure light warm circle
                                                Circle()
                                                    .fill(Color(red: 0.98, green: 0.93, blue: 0.76))
                                                    .frame(width: 28, height: 28)
                                                    .overlay(
                                                        isToday ? Circle().stroke(gray60, style: StrokeStyle(lineWidth: 1, dash: [3, 2])).frame(width: 32, height: 32) : nil
                                                    )
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    } else if isFutureDay {
                                        // Future: empty outlined circle
                                        Circle()
                                            .stroke(gray30, lineWidth: 1)
                                            .frame(width: 28, height: 28)
                                    } else {
                                        // Past without entry: circle with +
                                        ZStack {
                                            Circle()
                                                .stroke(gray30, lineWidth: 1)
                                                .frame(width: 28, height: 28)
                                            Image(systemName: "plus")
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundColor(gray30)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 56)
                            } else {
                                // Empty cell
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 56)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.980, green: 0.980, blue: 0.976))
        )
        .overlay(
            // Entry detail popup
            Group {
                if showEntryDetail, let entry = selectedEntry {
                    ZStack {
                        // Dimmed background
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showEntryDetail = false
                            }

                        // Entry card
                        VStack(spacing: 12) {
                            // Mood emoji if available
                            if let mood = entry.mood {
                                ZStack {
                                    Circle()
                                        .fill(mood.color)
                                        .frame(width: 50, height: 50)
                                    MoodEmojiView(mood: mood, size: 36)
                                }
                            }

                            // Entry text
                            Text("\u{201C}" + entry.text + "\u{201D}")
                                .font(.custom("Baskerville", size: 15))
                                .foregroundColor(themeBrown)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)

                            // Date
                            Text(formatEntryDate(entry.createdAt))
                                .font(.custom("Urbanist", size: 11))
                                .foregroundColor(themeBrown.opacity(0.5))
                        }
                        .padding(24)
                        .frame(maxWidth: 280)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                    }
                }
            }
        )
        .animation(.easeInOut(duration: 0.25), value: showEntryDetail)
    }

    private func formatEntryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Swipeable Entry Card

struct SwipeableEntryCard: View {
    let accomplishment: Accomplishment
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showingDelete = false

    private let deleteThreshold: CGFloat = -70
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete background
            HStack {
                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "leaf")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(themeBrown.opacity(0.5))
                        .frame(width: 50, height: 50)
                }
                .opacity(showingDelete ? 1 : 0)
            }

            // Main card
            EntryCard(accomplishment: accomplishment)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = value.translation.width
                                showingDelete = offset < deleteThreshold / 2
                            }
                        }
                        .onEnded { value in
                            withAnimation(.easeOut(duration: 0.25)) {
                                if offset < deleteThreshold {
                                    onDelete()
                                }
                                offset = 0
                                showingDelete = false
                            }
                        }
                )
        }
    }
}

// MARK: - Entry Card

struct EntryCard: View {
    let accomplishment: Accomplishment

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(accomplishment.text)
                .font(.custom("Urbanist", size: 15))
                .foregroundColor(themeBrown)
                .lineSpacing(4)

            Text(formattedDate)
                .font(.custom("Urbanist", size: 12))
                .foregroundColor(themeBrown.opacity(0.45))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
        )
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(accomplishment.createdAt) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if calendar.isDateInYesterday(accomplishment.createdAt) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else if calendar.isDate(accomplishment.createdAt, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }

        return formatter.string(from: accomplishment.createdAt)
    }
}

// MARK: - Delete Confirmation Overlay

struct DeleteConfirmationOverlay: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
                .transition(.opacity)

            VStack(spacing: 20) {
                Image(systemName: "leaf")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(themeBrown.opacity(0.6))

                Text("Hide this glimmer?")
                    .font(.custom("Urbanist", size: 16).weight(.medium))
                    .foregroundColor(themeBrown)
                    .multilineTextAlignment(.center)

                HStack(spacing: 14) {
                    Button(action: onCancel) {
                        Text("Keep")
                            .font(.custom("Urbanist", size: 14).weight(.medium))
                            .foregroundColor(themeBrown.opacity(0.6))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(themeBrown.opacity(0.08))
                            )
                    }

                    Button(action: onConfirm) {
                        Text("Hide")
                            .font(.custom("Urbanist", size: 14).weight(.medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(themeBrown.opacity(0.8))
                            )
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
            )
            .transition(
                .opacity
                .combined(with: .scale(scale: 0.92))
            )
        }
    }
}

// MARK: - Deleted Message Overlay

struct DeletedMessageOverlay: View {
    private let themeBrown = Color(red: 0.325, green: 0.212, blue: 0.188)

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.4))

            Text("Hidden")
                .font(.custom("Urbanist", size: 15).weight(.medium))
                .foregroundColor(themeBrown)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 6)
        )
        .transition(
            .opacity
            .combined(with: .scale(scale: 0.9))
        )
    }
}

// MARK: - Previews

#Preview {
    ContentView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
}
