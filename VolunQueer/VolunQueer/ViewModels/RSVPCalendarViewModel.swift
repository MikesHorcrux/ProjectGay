import Foundation
import Combine

/// Calendar-specific view model that groups RSVPs by date.
@MainActor
final class RSVPCalendarViewModel: ObservableObject {
    @Published var currentMonth: Date
    @Published var selectedDate: Date?
    @Published private(set) var rowsByDate: [DateComponents: [RSVPListRow]] = [:]

    private var calendar = Calendar.current

    init(currentMonth: Date = Date()) {
        self.currentMonth = currentMonth
    }

    /// Groups RSVPs by their event date (timezone-aware).
    func groupEventsByDate(_ rows: [RSVPListRow]) {
        var grouped: [DateComponents: [RSVPListRow]] = [:]

        for row in rows {
            // Use event's timezone, not device timezone
            let eventTimeZone = TimeZone(identifier: row.event.timezone) ?? .current
            var eventCalendar = Calendar.current
            eventCalendar.timeZone = eventTimeZone

            // Extract just year/month/day
            let components = eventCalendar.dateComponents([.year, .month, .day], from: row.event.startsAt)

            // Group by date
            grouped[components, default: []].append(row)
        }

        rowsByDate = grouped
    }

    /// Generates array of dates for the current month grid (nil = empty cell).
    func datesInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        var dates: [Date?] = []

        // Add empty cells before first day
        for _ in 1..<firstWeekday {
            dates.append(nil)
        }

        // Add all days in month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }

        return dates
    }

    /// Navigates to a different month.
    func navigateMonth(by offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    /// Returns events for a specific date.
    func events(for date: Date) -> [RSVPListRow] {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return rowsByDate[components] ?? []
    }

    /// Checks if a date is today.
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    /// Checks if two dates are the same day.
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    /// Returns formatted month and year string.
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
}
