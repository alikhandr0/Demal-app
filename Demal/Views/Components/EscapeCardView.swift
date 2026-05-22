// Views/Components/EscapeCardView.swift
// "Escape the Smog" mountain suggestion card

import SwiftUI

struct EscapeCardView: View {
    let suggestion: EscapeSuggestion

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Glassmorphism background
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.15, green: 0.35, blue: 0.65).opacity(0.7),
                                    Color(red: 0.05, green: 0.18, blue: 0.42).opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 10) {
                Label("ESCAPE THE SMOG", systemImage: "wind")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(1)

                Text(suggestion.headline)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Label("AQI \(suggestion.mountainLocation.airQuality.aqi) – Good", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 0.2, green: 0.8, blue: 0.4))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.2))
                        )

                    Label(
                        "\(Int(suggestion.mountainLocation.weather.temperatureCelsius))C",
                        systemImage: "thermometer.snowflake"
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(.white.opacity(0.15)))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(8)
                        .background(Circle().fill(.white.opacity(0.15)))
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EscapeCardView(suggestion: MockData.escapeSuggestion)
            .padding()
    }
    .environment(ProfileViewModel())
}
