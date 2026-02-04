import SwiftUI

/// Individual date cell in the calendar grid.
struct CalendarDayCell: View {
    let date: Date?
    let isToday: Bool
    let isSelected: Bool
    let events: [RSVPListRow]

    private var isPast: Bool {
        guard let date else { return false }
        return date < Date()
    }

    var body: some View {
        VStack(spacing: 4) {
            if let date {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isPast ? Theme.softCharcoal.opacity(0.4) : Theme.softCharcoal)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isSelected ? Theme.skyTeal : Color.clear)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(isToday ? Theme.skyTeal : Color.clear, lineWidth: 2)
                    )

                // Event indicator dots
                if !events.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(Array(events.prefix(3)), id: \.rsvp.id) { row in
                            Circle()
                                .fill(row.rsvp.status == .rsvp ? Theme.skyTeal : .orange)
                                .frame(width: 4, height: 4)
                        }
                        if events.count > 3 {
                            Text("+\(events.count - 3)")
                                .font(.system(size: 8))
                                .foregroundStyle(Theme.softCharcoal.opacity(0.6))
                        }
                    }
                    .frame(height: 8)
                } else {
                    Spacer()
                        .frame(height: 8)
                }
            } else {
                // Empty cell
                Spacer()
                    .frame(height: 44)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        guard let date else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        var label = formatter.string(from: date)

        if isToday {
            label += ", today"
        }

        if !events.isEmpty {
            label += ", has \(events.count) event\(events.count == 1 ? "" : "s")"
        }

        return label
    }
}

#Preview("With Events") {
    CalendarDayCell(
        date: Date(),
        isToday: true,
        isSelected: false,
        events: [
            RSVPListRow(
                event: Event(
                    id: "1",
                    orgId: "org-1",
                    title: "Event 1",
                    description: nil,
                    startsAt: Date(),
                    endsAt: Date(),
                    timezone: "America/Los_Angeles",
                    location: LocationInfo(name: "Test", address: nil, city: nil, region: nil, postalCode: nil, country: nil, geo: nil),
                    accessibility: nil,
                    tags: [],
                    rsvpCap: nil,
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
            )
        ]
    )
    .padding()
}

#Preview("Empty Day") {
    CalendarDayCell(
        date: Date(),
        isToday: false,
        isSelected: false,
        events: []
    )
    .padding()
}
