import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Accomplishment.createdAt, order: .reverse) private var accomplishments: [Accomplishment]

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            if accomplishments.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "leaf")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Color("TextSecondary").opacity(0.5))

                    Text("Nothing here yet")
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextSecondary"))

                    Text("Your accomplishments will appear here")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color("TextSecondary").opacity(0.7))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        Spacer()
                            .frame(height: 24)

                        ForEach(accomplishments) { accomplishment in
                            EntryCard(accomplishment: accomplishment)
                        }

                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

struct EntryCard: View {
    let accomplishment: Accomplishment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(accomplishment.text)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundColor(Color("TextPrimary"))
                .lineSpacing(4)

            Text(formattedDate)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(16)
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

#Preview {
    HistoryView()
        .modelContainer(for: Accomplishment.self, inMemory: true)
}
