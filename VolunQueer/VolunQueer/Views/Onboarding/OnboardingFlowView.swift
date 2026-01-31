import SwiftUI

/// Handles the multi-step onboarding flow.
struct OnboardingFlowView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = OnboardingViewModel()

    let userId: String

    var body: some View {
        VStack(spacing: 24) {
            header

            ScrollView {
                VStack(spacing: 20) {
                    stepView
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
            }

            footer
        }
        .padding(.vertical)
        .background(Theme.cream)
        .onAppear {
            viewModel.prefillIfNeeded(from: store.user(for: userId))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: viewModel.progressValue)
                .tint(Theme.coralRose)

            Text(viewModel.currentStep.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.softCharcoal)

            Text(viewModel.currentStep.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var stepView: some View {
        switch viewModel.currentStep {
        case .role:
            OnboardingRoleStepView(selectedRoles: $viewModel.selectedRoles)
        case .basics:
            OnboardingBasicsStepView(
                displayName: $viewModel.displayName,
                pronouns: $viewModel.pronouns,
                email: $viewModel.email,
                phone: $viewModel.phone,
                preferredChannel: $viewModel.preferredChannel,
                shareEmail: $viewModel.shareEmail,
                sharePhone: $viewModel.sharePhone,
                sharePronouns: $viewModel.sharePronouns,
                shareAccessibility: $viewModel.shareAccessibility
            )
        case .volunteer:
            OnboardingVolunteerStepView(
                interests: $viewModel.volunteerInterests,
                skills: $viewModel.volunteerSkills,
                weekdays: $viewModel.volunteerWeekdays,
                period: $viewModel.volunteerPeriod,
                accessibilityNeeds: $viewModel.accessibilityNeeds
            )
        case .organizer:
            OnboardingOrganizerStepView(
                organizationName: $viewModel.organizationName,
                organizerRoleTitle: $viewModel.organizerRoleTitle,
                organizationMission: $viewModel.organizationMission,
                organizationWebsite: $viewModel.organizationWebsite
            )
        case .done:
            OnboardingDoneStepView()
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            if viewModel.currentStepIndex > 0 {
                Button("Back") {
                    viewModel.back()
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Button(viewModel.currentStep == .done ? "Finish" : "Next") {
                Task { await handleNext() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canAdvance() || viewModel.isSaving)
        }
        .padding(.horizontal)
    }

    private func handleNext() async {
        viewModel.clearError()
        if viewModel.currentStep == .done {
            await completeOnboarding()
        } else {
            viewModel.advance()
        }
    }

    private func completeOnboarding() async {
        viewModel.isSaving = true
        do {
            let existingUser = store.user(for: userId)
            let organization = viewModel.buildOrganization(ownerId: userId)
            if let organization {
                try await store.saveOrganization(organization)
                var user = viewModel.buildUser(userId: userId, orgId: organization.id)
                if let existingUser {
                    user.createdAt = existingUser.createdAt
                    user.photoURL = existingUser.photoURL
                    user.impactSummary = existingUser.impactSummary
                }
                try await store.saveUser(user)
            } else {
                var user = viewModel.buildUser(userId: userId, orgId: nil)
                if let existingUser {
                    user.createdAt = existingUser.createdAt
                    user.photoURL = existingUser.photoURL
                    user.impactSummary = existingUser.impactSummary
                }
                try await store.saveUser(user)
            }
        } catch {
            viewModel.setError(error.localizedDescription)
        }
        viewModel.isSaving = false
    }
}
