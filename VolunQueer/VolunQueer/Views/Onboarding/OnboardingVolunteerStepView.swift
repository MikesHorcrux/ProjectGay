import SwiftUI

/// Step for volunteer interests, skills, and availability.
struct OnboardingVolunteerStepView: View {
    @Binding var interests: Set<String>
    @Binding var skills: Set<String>
    @Binding var weekdays: Set<Weekday>
    @Binding var period: OnboardingAvailabilityPeriod
    @Binding var accessibilityNeeds: String

    private let interestOptions = [
        "Community", "Mutual aid", "Youth", "Arts", "Health", "Housing", "Events"
    ]
    private let skillOptions = [
        "Setup", "Hospitality", "Outreach", "Logistics", "Tech", "Translation"
    ]
    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader("Interests")
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(interestOptions, id: \.self) { option in
                    SelectableChipView(
                        title: option,
                        isSelected: interests.contains(option)
                    ) {
                        toggle(option, in: &interests)
                    }
                }
            }

            sectionHeader("Skills")
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(skillOptions, id: \.self) { option in
                    SelectableChipView(
                        title: option,
                        isSelected: skills.contains(option)
                    ) {
                        toggle(option, in: &skills)
                    }
                }
            }

            sectionHeader("Availability")
            VStack(alignment: .leading, spacing: 12) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                    ForEach(Weekday.allCases, id: \.self) { day in
                        SelectableChipView(
                            title: dayLabel(day),
                            isSelected: weekdays.contains(day)
                        ) {
                            toggle(day, in: &weekdays)
                        }
                    }
                }

                Picker("Time of day", selection: $period) {
                    ForEach(OnboardingAvailabilityPeriod.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            sectionHeader("Accessibility needs (optional)")
            TextField("Anything organizers should know?", text: $accessibilityNeeds)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(Theme.softCharcoal)
    }

    private func toggle(_ value: String, in set: inout Set<String>) {
        if set.contains(value) {
            set.remove(value)
        } else {
            set.insert(value)
        }
    }

    private func toggle(_ value: Weekday, in set: inout Set<Weekday>) {
        if set.contains(value) {
            set.remove(value)
        } else {
            set.insert(value)
        }
    }

    private func dayLabel(_ day: Weekday) -> String {
        switch day {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
}
