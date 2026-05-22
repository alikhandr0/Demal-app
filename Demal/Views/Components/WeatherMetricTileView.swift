// Views/Components/WeatherMetricTileView.swift
// Small tile showing a single metric (wind, visibility, etc.)

import SwiftUI

struct WeatherMetricTileView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text(icon)
                        .font(.system(size: 15))
                }

                Spacer()

                Text(title.uppercased())
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                    .tracking(0.5)

                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 130)
    }
}

#Preview {
    ZStack {
        Color(red: 0.1, green: 0.1, blue: 0.12).ignoresSafeArea()
        HStack {
            WeatherMetricTileView(
                icon: "〜",
                iconColor: .blue,
                title: "Wind",
                value: "12 km/h",
                subtitle: "NE Direction"
            )
            WeatherMetricTileView(
                icon: "◎",
                iconColor: .orange,
                title: "Visibility",
                value: "0.8 km",
                subtitle: "Very Low"
            )
        }
        .padding()
    }
    .environment(ProfileViewModel())
}
