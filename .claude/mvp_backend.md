# Backend Integration Plan for Glimmer iOS App

## Overview
Refactor Glimmer from local SwiftData persistence to a frontend-backend separated architecture using the provided REST API.

## Status: IMPLEMENTED

## Design Decisions
- **SwiftData**: Keep as local cache for offline support
- **Mock Mode**: Compiler flag (#if DEBUG) + in-app toggle for runtime switching
- **Auth**: Skip for MVP; use no-auth demo endpoints

---

## Next Steps: Add Files to Xcode Project

The following new files were created and need to be added to the Xcode project:

1. Open `Glimmer.xcodeproj` in Xcode
2. Right-click on the `Glimmer` folder in the Project Navigator
3. Select "Add Files to Glimmer..."
4. Add these folders/files:
   - `Glimmer/Models/APIModels.swift`
   - `Glimmer/Services/APIClient.swift`
   - `Glimmer/Services/MockAPIClient.swift`
   - `Glimmer/Services/GlimmerService.swift`
   - `Glimmer/ViewModels/HomeViewModel.swift`
   - `Glimmer/ViewModels/JournalViewModel.swift`
5. Ensure "Copy items if needed" is **unchecked** (files are already in place)
6. Build the project (Cmd+B)

---

## API Mapping

### Current → API Mapping
| Current | API Endpoint | Notes |
|---------|--------------|-------|
| `Accomplishment.text` | `POST /journals` (content) | Journal stores text |
| `Accomplishment.mood` | `POST /moods` (score 1-8) | Mood enum maps to score |
| `hasCheckedInToday` | `GET /checkins/today` | Returns check-in status |
| Create check-in | `POST /checkins` | Simple tap check-in |
| `pauseCheckIns` | `GET/POST /users/me/pause-checkin` | Pause status |
| Emergency contact | `GET/PUT /users/me/emergency-contact` | SafetyView |
| Reminder settings | `GET/PUT /users/me/checkin-reminder` | ReminderView |
| Miss check-in rule | `GET/PUT /users/me/miss-checkin-rule` | SafetyView |

### Mood Enum → Score Mapping
```
Happy(1), Normal(2), Angry(3), Sad(4), Peaceful(5), Shy(6), Tired(7), Numb(8)
```

---

## Files to Create

### 1. `Glimmer/Services/APIClient.swift`
Core networking layer with:
- Base URL configuration (localhost:8000/api/v1)
- HTTP methods (GET, POST, PUT, PATCH)
- Error handling
- Mock mode toggle

### 2. `Glimmer/Services/MockAPIClient.swift`
Mock backend for testing:
- In-memory storage for journals, moods, check-ins
- Simulated responses matching API spec
- Pre-populated test data

### 3. `Glimmer/Models/APIModels.swift`
API response models:
- `JournalRecord`, `JournalCreateRequest`, `ApiResponseJournal`
- `MoodRecord`, `MoodCreateRequest`, `ApiResponseMood`
- `CheckinStatus`, `ApiResponseCheckinStatus`
- `PauseStatus`, `EmergencyContact`, `CheckinReminder`

### 4. `Glimmer/Services/GlimmerService.swift`
High-level service combining Journal + Mood + Checkin:
- `checkInToday()` → POST /checkins
- `getTodayStatus()` → GET /checkins/today
- `saveGlimmer(text:, mood:)` → POST /journals + POST /moods
- `getJournals(from:to:)` → GET /journals
- `getRandomJournal()` → GET /journals/random
- `getPauseStatus()` / `setPauseStatus()` → pause-checkin endpoints

### 5. `Glimmer/ViewModels/HomeViewModel.swift`
Observable class for HomeView state:
- `@Published hasCheckedInToday: Bool`
- `@Published isPaused: Bool`
- `@Published isLoading: Bool`
- Methods: `loadStatus()`, `saveGlimmer()`, `togglePause()`

### 6. `Glimmer/ViewModels/JournalViewModel.swift`
Observable class for JournalView state:
- `@Published journals: [JournalRecord]`
- `@Published moods: [MoodRecord]`
- Methods: `loadJournals()`, `getRandomJournal()`

---

## Files to Modify

### 1. `GlimmerApp.swift`
- Keep SwiftData model container (for caching)
- Add `@StateObject` for `AppSettings` (API mode toggle)
- Add environment object for `GlimmerService`

### 2. `ContentView.swift`
- Remove `@Query private var accomplishments`
- Add `@StateObject` for shared view model
- Update `hasCheckedInToday` to use view model

### 3. `HomeView.swift`
- Remove `@Query`, `@Environment(\.modelContext)`
- Replace `@AppStorage("pauseCheckIns")` with API call
- Use `HomeViewModel` for all data operations
- Update `saveGlimmer()` to call API

### 4. `JournalView` (in ContentView.swift)
- Remove `@Query`
- Use `JournalViewModel` for data
- Map `JournalRecord` to display

### 5. `SettingsView.swift`
- Update pause toggle to use API

### 6. `SafetyView.swift`
- Replace `@AppStorage` with API calls for emergency contact

### 7. `ReminderView.swift`
- Replace `@AppStorage` with API calls for reminder settings

### 8. `Accomplishment.swift`
- Keep `Mood` enum (still needed for UI)
- Add `Mood.score` computed property for API mapping
- Keep `@Model` class for SwiftData caching
- Add `journalId` field to link with API records

---

## Implementation Order

### Phase 1: Foundation
1. Create `APIModels.swift` - API data structures
2. Create `APIClient.swift` - Network layer
3. Create `MockAPIClient.swift` - Mock backend with test data

### Phase 2: Service Layer
4. Create `GlimmerService.swift` - Business logic layer with caching
5. Update `Accomplishment.swift` - Add score mapping, add journalId for API linking

### Phase 3: View Models
6. Create `HomeViewModel.swift`
7. Create `JournalViewModel.swift`

### Phase 4: View Updates
8. Update `GlimmerApp.swift` - Add AppSettings, keep SwiftData for cache
9. Update `HomeView.swift` - Use HomeViewModel
10. Update `ContentView.swift` + `JournalView` - Use JournalViewModel
11. Update `SettingsView.swift` - Use API for pause

### Phase 5: Safety/Reminder Views
12. Update `SafetyView.swift` - Use API
13. Update `ReminderView.swift` - Use API

---

## Mock Data

Pre-populate MockAPIClient with:
```swift
// Sample journals
[
    JournalRecord(journal_id: UUID(), local_date: "2026-02-06", content: "Had a great morning walk today", occurred_at_utc: Date(), timezone_used: "America/New_York"),
    JournalRecord(journal_id: UUID(), local_date: "2026-02-05", content: "Finally finished that project I've been working on", ...),
    JournalRecord(journal_id: UUID(), local_date: "2026-02-04", content: "Noticed the sunset was beautiful today", ...),
    // ... more entries over past 2 weeks
]

// Sample moods matching journal dates
[
    MoodRecord(mood_id: UUID(), local_date: "2026-02-06", score: 1), // Happy
    MoodRecord(mood_id: UUID(), local_date: "2026-02-05", score: 5), // Peaceful
    MoodRecord(mood_id: UUID(), local_date: "2026-02-04", score: 2), // Normal
]
```

---

## Configuration

### API Mode Toggle
```swift
enum APIMode: String, CaseIterable {
    case mock = "Mock"
    case live = "Live"
}

class AppSettings: ObservableObject {
    @AppStorage("apiMode") var apiMode: APIMode = {
        #if DEBUG
        return .mock
        #else
        return .live
        #endif
    }()
}
```

### In-App Toggle (Debug Menu)
Add to SettingsView a "Developer" section (DEBUG only):
- API Mode picker (Mock/Live)
- Clear cache button
- Show current base URL

### SwiftData Caching Strategy
1. On API success → save to SwiftData
2. On API failure → read from SwiftData cache
3. On app launch → show cached data immediately, then refresh from API
4. Cache invalidation: 24 hours for journal list, immediate for today's status

---

## Verification

1. **Build**: Project compiles with SwiftData (used for caching)
2. **Mock Mode**: App runs with mock data showing:
   - Home screen shows correct check-in state
   - Journal displays past entries
   - Mood calendar shows colored circles
   - Pause toggle works
   - Developer menu shows API mode toggle
3. **API Mode**: Connect to localhost:8000:
   - Create new glimmer → appears in journal
   - Check-in state persists across app restart
   - Pause status syncs with server
4. **Offline/Cache**:
   - Kill network → app shows cached data
   - Restart app → cached data appears immediately before API refresh

---

## Key Considerations

- **Offline support**: SwiftData cache provides read-only offline access
- **Error handling**: Show alerts for network failures, fall back to cache
- **Loading states**: Add loading indicators during API calls
- **Caching**: SwiftData stores API responses for offline viewing
- **Auth**: Skip for MVP; use no-auth demo endpoints
