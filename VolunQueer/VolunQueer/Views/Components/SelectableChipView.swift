import SwiftUI

/// A tappable chip used for multi-select lists.
struct SelectableChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? Theme.softCharcoal : Theme.softCharcoal.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Theme.lavenderMist : Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Theme.lavenderMist, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
