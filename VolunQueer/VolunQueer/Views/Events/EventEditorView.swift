import SwiftUI

/// Form for creating a new organizer event.
struct EventEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let userId: String
    let existingEvent: Event?

    @State private var draft: EventDraft
    @State private var selectedOrgId: String
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(userId: String, event: Event? = nil, roles: [EventRole] = []) {
        self.userId = userId
        existingEvent = event
        if let event {
            _draft = State(initialValue: EventDraft(event: event, roles: roles))
            _selectedOrgId = State(initialValue: event.orgId)
        } else {
            _draft = State(initialValue: EventDraft())
            _selectedOrgId = State(initialValue: "")
        }
    }

    var body: some View {
        Form {
            organizationSection
            detailsSection
            scheduleSection
            locationSection
            accessibilitySection
            rolesSection
            capacitySection
            contactSection
            statusSection
            submissionSection
        }
        .navigationTitle(isEditing ? "Edit Event" : "New Event")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.cream)
        .onAppear(perform: prefill)
        .onChange(of: draft.startsAt) { newValue in
            let minEnd = newValue.addingTimeInterval(15 * 60)
            if draft.endsAt < minEnd {
                draft.endsAt = minEnd
            }
        }
        .onChange(of: availableOrganizations) { orgs in
            if selectedOrgId.isEmpty, let first = orgs.first {
                selectedOrgId = first.id
            }
        }
    }

    private var isEditing: Bool {
        existingEvent != nil
    }

    private var organizationSection: some View {
        Section("Organization") {
            if availableOrganizations.isEmpty {
                Text("No organizations found. Add one in your organizer profile.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Picker("Host organization", selection: $selectedOrgId) {
                    ForEach(availableOrganizations) { org in
                        Text(org.name).tag(org.id)
                    }
                }
                .disabled(isEditing)
            }
        }
    }

    private var detailsSection: some View {
        Section("Event details") {
            TextField("Title", text: $draft.title)
            TextEditor(text: $draft.description)
                .frame(minHeight: 80)
            TextField("Tags (comma separated)", text: $draft.tags)
        }
    }

    private var scheduleSection: some View {
        Section("Schedule") {
            DatePicker("Starts", selection: $draft.startsAt, displayedComponents: [.date, .hourAndMinute])
            DatePicker(
                "Ends",
                selection: $draft.endsAt,
                in: draft.startsAt.addingTimeInterval(15 * 60)...Date.distantFuture,
                displayedComponents: [.date, .hourAndMinute]
            )
            Text("Timezone: \(draft.timezone)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var locationSection: some View {
        Section("Location") {
            TextField("Location name", text: $draft.locationName)
            TextField("Address", text: $draft.locationAddress)
            TextField("City", text: $draft.locationCity)
            TextField("State / Region", text: $draft.locationRegion)
            TextField("Postal code", text: $draft.locationPostalCode)
            TextField("Country", text: $draft.locationCountry)
        }
    }

    private var accessibilitySection: some View {
        Section("Accessibility") {
            TextEditor(text: $draft.accessibilityNotes)
                .frame(minHeight: 70)
            TextField("Tags (comma separated)", text: $draft.accessibilityTags)
        }
    }

    private var rolesSection: some View {
        Section("Roles") {
            ForEach(Array(draft.roles.enumerated()), id: \.element.id) { index, _ in
                let roleBinding = $draft.roles[index]
                let roleValue = draft.roles[index]
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Role title", text: roleBinding.title)
                    TextField("Role description", text: roleBinding.description)

                    Stepper(value: roleBinding.slotsTotal, in: minSlots(for: roleValue)...maxSlots(for: roleValue)) {
                        Text("Slots: \(roleValue.slotsTotal)")
                    }

                    if roleValue.slotsFilled > 0 {
                        Text("Filled: \(roleValue.slotsFilled)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    TextField("Skills (comma separated)", text: roleBinding.skills)

                    Toggle("Check-in required", isOn: roleBinding.checkInRequired)

                    Toggle("Minimum age", isOn: roleBinding.minAgeEnabled)
                    if roleValue.minAgeEnabled {
                        Stepper(value: roleBinding.minAge, in: 1...100) {
                            Text("Min age: \(roleValue.minAge)")
                        }
                    }

                    if draft.roles.count > 1 {
                        Button(roleRemovalLabel(for: roleValue)) {
                            removeRole(id: roleValue.id)
                        }
                        .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 8)
            }

            Button {
                draft.roles.append(EventRoleDraft())
            } label: {
                Label("Add role", systemImage: "plus")
            }
        }
    }

    private var capacitySection: some View {
        Section("RSVP cap") {
            Toggle("Limit RSVPs", isOn: $draft.rsvpCapEnabled)
            if draft.rsvpCapEnabled {
                Stepper(value: $draft.rsvpCap, in: 1...1000) {
                    Text("Cap: \(draft.rsvpCap)")
                }
            }
        }
    }

    private var contactSection: some View {
        Section("Contact") {
            TextField("Contact name", text: $draft.contactName)
            TextField("Contact email", text: $draft.contactEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            TextField("Contact phone", text: $draft.contactPhone)
                .keyboardType(.phonePad)
        }
    }

    private var statusSection: some View {
        Section("Visibility") {
            Picker("Status", selection: $draft.status) {
                ForEach(statusOptions, id: \.self) { status in
                    Text(statusLabel(status)).tag(status)
                }
            }
        }
    }

    private var submissionSection: some View {
        Section {
            if let message = submissionMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            Button {
                Task { await submit() }
            } label: {
                if isSaving {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text(primaryActionTitle)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .disabled(!canSubmit || isSaving)
        }
    }

    private var availableOrganizations: [Organization] {
        guard let user = store.user(for: userId) else { return [] }
        let orgIds = Set(user.organizerProfile?.orgIds ?? [])
        var organizations: [Organization]
        if orgIds.isEmpty {
            organizations = store.organizations.filter { $0.ownerUid == user.id }
        } else {
            organizations = store.organizations.filter { orgIds.contains($0.id) }
        }
        if let existingEvent,
           let eventOrg = store.organizations.first(where: { $0.id == existingEvent.orgId }),
           !organizations.contains(where: { $0.id == eventOrg.id }) {
            organizations.append(eventOrg)
        }
        return organizations
    }

    private var canSubmit: Bool {
        submissionMessage == nil && store.user(for: userId) != nil
    }

    private var submissionMessage: String? {
        if availableOrganizations.isEmpty {
            return "Add an organization in your profile to create events."
        }
        if selectedOrgId.isEmpty {
            return "Select an organization."
        }
        return draft.validationMessage
    }

    private var primaryActionTitle: String {
        if isEditing {
            return "Save changes"
        }
        return draft.status == .published ? "Publish event" : "Save draft"
    }

    private var statusOptions: [EventStatus] {
        [.draft, .published, .cancelled, .archived]
    }

    private func statusLabel(_ status: EventStatus) -> String {
        switch status {
        case .draft:
            return "Draft"
        case .published:
            return "Published"
        case .cancelled:
            return "Cancelled"
        case .archived:
            return "Archived"
        }
    }

    private func minSlots(for role: EventRoleDraft) -> Int {
        max(1, role.slotsFilled)
    }

    private func maxSlots(for role: EventRoleDraft) -> Int {
        max(200, role.slotsFilled)
    }

    private func removeRole(id: String) {
        draft.roles.removeAll { $0.id == id }
    }

    private func roleRemovalLabel(for role: EventRoleDraft) -> String {
        role.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Remove role" : "Remove \(role.title)"
    }

    private func prefill() {
        guard let user = store.user(for: userId) else { return }
        if selectedOrgId.isEmpty, let firstOrg = availableOrganizations.first {
            selectedOrgId = firstOrg.id
        }
        if draft.contactName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.contactName = user.displayName
        }
        if let email = user.contact?.email,
           draft.contactEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.contactEmail = email
        }
        if let phone = user.contact?.phone,
           draft.contactPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.contactPhone = phone
        }
    }

    private func submit() async {
        errorMessage = nil
        guard let user = store.user(for: userId) else {
            errorMessage = "User profile unavailable."
            return
        }
        guard submissionMessage == nil else {
            errorMessage = submissionMessage
            return
        }
        isSaving = true
        let (event, roles) = draft.buildEvent(
            userId: user.id,
            orgId: selectedOrgId,
            eventId: existingEvent?.id,
            createdAt: existingEvent?.createdAt,
            createdBy: existingEvent?.createdBy
        )
        do {
            try await store.saveEvent(event)
            try await store.saveRoles(roles, for: event.id)
            isSaving = false
            dismiss()
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        EventEditorView(userId: "user-jules")
            .environmentObject(AppStore(dataSource: .mock, preload: true))
    }
}
