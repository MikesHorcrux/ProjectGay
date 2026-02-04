import SwiftUI

/// Main calendar grid view showing RSVPs by month.
struct RSVPCalendarView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = RSVPCalendarViewModel()
    @State private var selectedDate: Date?

    let rows: [RSVPListRow]
    let userId: String

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Month navigation header
                HStack {
                    Button(action: { viewModel.navigateMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(Theme.skyTeal)
                    }

                    Spacer()

                    Text(viewModel.monthYearString)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Theme.softCharcoal)

                    Spacer()

                    Button(action: { viewModel.navigateMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundStyle(Theme.skyTeal)
                    }
                }
                .padding(.horizontal)

                // Weekday headers
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.softCharcoal.opacity(0.6))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)

                // Calendar grid
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(viewModel.datesInMonth().enumerated()), id: \.offset) { _, date in
                        if let date {
                            Button(action: {
                                selectedDate = date
                            }) {
                                CalendarDayCell(
                                    date: date,
                                    isToday: viewModel.isToday(date),
                                    isSelected: selectedDate.map { viewModel.isSameDay($0, date) } ?? false,
                                    events: viewModel.events(for: date)
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            CalendarDayCell(
                                date: nil,
                                isToday: false,
                                isSelected: false,
                                events: []
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Theme.cream)
        .sheet(item: Binding(
            get: { selectedDate },
            set: { selectedDate = $0 }
        )) { date in
            RSVPDayDetailView(
                date: date,
                events: viewModel.events(for: date),
                userId: userId
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: rows) { _, newRows in
            viewModel.groupEventsByDate(newRows)
        }
        .onAppear {
            viewModel.groupEventsByDate(rows)
        }
    }
}

// Extension to make Date identifiable for sheet presentation
extension Date: Identifiable {
    public var id: TimeInterval {
        timeIntervalSince1970
    }
}

#Preview {
    NavigationStack {
        RSVPCalendarView(
            rows: [
                RSVPListRow(
                    event: Event(
                        id: "1",
                        orgId: "org-1",
                        title: "Community Cleanup",
                        description: "Help clean up the park",
                        startsAt: Date(),
                        endsAt: Date().addingTimeInterval(3600),
                        timezone: "America/Los_Angeles",
                        location: LocationInfo(name: "Golden Gate Park", address: nil, city: "San Francisco", region: "CA", postalCode: nil, country: nil, geo: nil),
                        accessibility: nil,
                        tags: ["outdoors"],
                        rsvpCap: 20,
                        status: .published,
                        contact: nil,
                        createdBy: "user",
                        createdAt: Date(),
                        updatedAt: Date()
                    ),
                    rsvp: RSVP(
                        id: "rsvp-1",
                        userId: "user-1",
                        eventId: "1",
                        roleId: nil,
                        status: .rsvp,
                        consent: ConsentSnapshot(shareEmail: true, sharePhone: true, sharePronouns: true, shareAccessibility: true),
                        answers: nil,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                ),
                RSVPListRow(
                    event: Event(
                        id: "2",
                        orgId: "org-1",
                        title: "Food Bank",
                        description: "Sort donations",
                        startsAt: Date().addingTimeInterval(86400 * 3),
                        endsAt: Date().addingTimeInterval(86400 * 3 + 3600),
                        timezone: "America/Los_Angeles",
                        location: LocationInfo(name: "SF Food Bank", address: nil, city: "San Francisco", region: "CA", postalCode: nil, country: nil, geo: nil),
                        accessibility: nil,
                        tags: ["food"],
                        rsvpCap: 10,
                        status: .published,
                        contact: nil,
                        createdBy: "user",
                        createdAt: Date(),
                        updatedAt: Date()
                    ),
                    rsvp: RSVP(
                        id: "rsvp-2",
                        userId: "user-1",
                        eventId: "2",
                        roleId: nil,
                        status: .waitlisted,
                        consent: ConsentSnapshot(shareEmail: true, sharePhone: true, sharePronouns: true, shareAccessibility: true),
                        answers: nil,
                        createdAt: Date(),
                        updatedAt: Date()
                    )
                )
            ],
            userId: "user-1"
        )
        .environmentObject(AppStore(dataSource: .mock, preload: true))
    }
}
