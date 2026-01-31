import SwiftUI

/// Form for editing the current user's profile.
struct ProfileEditView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let userId: String

    @State private var displayName: String = ""
    @State private var pronouns: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var preferredChannel: ContactChannel = .email
    @State private var shareEmail: Bool = true
    @State private var sharePhone: Bool = false
    @State private var sharePronouns: Bool = true
    @State private var shareAccessibility: Bool = true

    @State private var interests: Set<String> = []
    @State private var skills: Set<String> = []
    @State private var weekdays: Set<Weekday> = []
    @State private var period: OnboardingAvailabilityPeriod = .evening
    @State private var accessibilityNeeds: String = ""

    @State private var organizerRoleTitle: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let interestOptions = [
        "Community", "Mutual aid", "Youth", "Arts", "Health", "Housing", "Events"
    ]
    private let skillOptions = [
        "Setup", "Hospitality", "Outreach", "Logistics", "Tech", "Translation"
    ]
    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 8)]

    var body: some View {
        Form {
            if let user = store.user(for: userId) {
                Section("Basics") {
                    TextField("Display name", text: $displayName)
                    TextField("Pronouns", text: $pronouns)
                }

                Section("Contact") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)

                    Picker("Preferred contact", selection: $preferredChannel) {
                        Text("Email").tag(ContactChannel.email)
                        Text("SMS").tag(ContactChannel.sms)
                        Text("Push").tag(ContactChannel.push)
                    }
                }

                Section("Organizer visibility") {
                    Toggle("Share email", isOn: $shareEmail)
                    Toggle("Share phone", isOn: $sharePhone)
                    Toggle("Share pronouns", isOn: $sharePronouns)
                    Toggle("Share accessibility needs", isOn: $shareAccessibility)
                }

                if user.roles.contains(.volunteer) {
                    Section("Volunteer profile") {
                        Text("Interests")
                            .font(.caption)
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

                        Text("Skills")
                            .font(.caption)
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

                        Text("Availability")
                            .font(.caption)
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

                        TextField("Accessibility needs", text: $accessibilityNeeds)
                    }
                }

                if user.roles.contains(.organizer) {
                    Section("Organizer profile") {
                        TextField("Your role", text: $organizerRoleTitle)
                        if let organizer = user.organizerProfile {
                            let names = organizer.orgIds.compactMap { id in
                                store.organizations.first { $0.id == id }?.name
                            }
                            Text("Organizations: \(names.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let message = errorMessage {
                    Section {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await saveProfile() }
                }
                .disabled(isSaving)
            }
        }
        .onAppear(perform: loadProfile)
    }

    private func loadProfile() {
        guard let user = store.user(for: userId) else { return }
        displayName = user.displayName
        pronouns = user.pronouns ?? ""
        email = user.contact?.email ?? ""
        phone = user.contact?.phone ?? ""
        preferredChannel = user.contact?.preferredChannel ?? .email
        shareEmail = user.visibility.shareEmail
        sharePhone = user.visibility.sharePhone
        sharePronouns = user.visibility.sharePronouns
        shareAccessibility = user.visibility.shareAccessibility

        if let profile = user.volunteerProfile {
            interests = Set(profile.interests)
            skills = Set(profile.skills)
            accessibilityNeeds = profile.accessibilityNeeds?.joined(separator: ", ") ?? ""
            if let availability = profile.availability {
                weekdays = Set(availability.weekly.map { $0.weekday })
                if let window = availability.weekly.first?.windows.first {
                    period = periodForWindow(window)
                }
            }
        }

        if let organizer = user.organizerProfile {
            organizerRoleTitle = organizer.contactRole ?? ""
        }
    }

    private func saveProfile() async {
        guard var user = store.user(for: userId) else { return }
        isSaving = true
        errorMessage = nil

        user.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        user.pronouns = pronouns.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : pronouns
        user.contact = ContactInfo(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : phone,
            preferredChannel: preferredChannel
        )
        user.visibility = UserVisibility(
            shareEmail: shareEmail,
            sharePhone: sharePhone,
            sharePronouns: sharePronouns,
            shareAccessibility: shareAccessibility
        )

        if user.roles.contains(.volunteer) {
            let availability = buildAvailability()
            let access = accessibilityNeeds.trimmingCharacters(in: .whitespacesAndNewlines)
            user.volunteerProfile = VolunteerProfile(
                interests: Array(interests),
                skills: Array(skills),
                availability: availability,
                accessibilityNeeds: access.isEmpty ? nil : [access],
                location: user.volunteerProfile?.location,
                bio: user.volunteerProfile?.bio,
                experienceNotes: user.volunteerProfile?.experienceNotes
            )
        }

        if user.roles.contains(.organizer) {
            let role = organizerRoleTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            var organizer = user.organizerProfile ?? OrganizerProfile(orgIds: [], contactRole: nil, verified: false)
            organizer.contactRole = role.isEmpty ? nil : role
            user.organizerProfile = organizer
        }

        user.updatedAt = Date()

        do {
            try await store.saveUser(user)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
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

    private func periodForWindow(_ window: TimeWindow) -> OnboardingAvailabilityPeriod {
        let mid = (window.startMinutes + window.endMinutes) / 2
        switch mid {
        case ..<12 * 60:
            return .morning
        case ..<17 * 60:
            return .afternoon
        default:
            return .evening
        }
    }

    private func buildAvailability() -> Availability? {
        guard !weekdays.isEmpty else { return nil }
        let windows = [period.window]
        let weekly = weekdays.sorted(by: { $0.rawValue < $1.rawValue }).map { day in
            WeekdayAvailability(weekday: day, windows: windows)
        }
        return Availability(timezone: TimeZone.current.identifier, weekly: weekly)
    }
}
