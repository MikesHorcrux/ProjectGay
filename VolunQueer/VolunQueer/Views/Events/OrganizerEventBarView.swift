import SwiftUI

/// Callout shown when the signed-in user manages the event.
struct OrganizerEventBarView: View {
    @EnvironmentObject private var store: AppStore
    @State private var isShowingRsvps = false

    let event: Event
    let service: RSVPService

    var body: some View {
        VStack(spacing: 10) {
            Text("You manage this event")
                .font(.headline)
                .foregroundStyle(Theme.softCharcoal)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("View RSVPs") {
                isShowingRsvps = true
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Theme.cream)
        .sheet(isPresented: $isShowingRsvps) {
            OrganizerRSVPListView(event: event, service: service)
                .environmentObject(store)
        }
    }
}
