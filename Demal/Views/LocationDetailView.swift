// Views/LocationDetailView.swift
// TazaAua – Location detail screen (screen 03 in Figma)

import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @Environment(\.dismiss) private var dismiss

    private var aqiColor: Color {
        switch location.airQuality.category {
        case .good:      return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .moderate:  return Color(red: 1.0, green: 0.75, blue: 0.1)
        case .unhealthy: return Color(red: 1.0, green: 0.35, blue: 0.2)
        case .hazardous: return Color(red: 0.7, green: 0.1, blue: 0.1)
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Dark background
            Color(red: 0.1, green: 0.11, blue: 0.14)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with back button
                    headerSection
                        .padding(.top, 60)

                    // AQI status label
                    statusLabel

                    // Location name
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text(location.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Metrics grid
                    metricsGrid

                    Spacer(minLength: 20)

                    // Plan Route CTA
                    planRouteButton
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                Text("Back")
                    .fontWeight(.semibold)
            }
            .font(.body)
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status label

    private var statusLabel: some View {
        Text("AIR IS \(location.airQuality.category.label.uppercased())")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(aqiColor)
            .tracking(1.5)
    }

    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        let w = location.weather
        let a = location.airQuality
        return LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            metricTile(
                letter: "O",
                letterColor: aqiColor,
                topLabel: "AIR QUALITY",
                bigValue: "\(a.aqi)",
                bottomLabel: "AQI \(a.category.label)"
            )
            metricTile(
                letter: "T",
                letterColor: Color(red: 0.4, green: 0.65, blue: 1.0),
                topLabel: "TEMPERATURE",
                bigValue: "\(Int(w.temperatureCelsius))",
                bottomLabel: "Celsius Feels like \(Int(w.feelsLikeCelsius))C"
            )
            metricTile(
                letter: "〜",
                letterColor: Color(red: 0.55, green: 0.45, blue: 0.95),
                topLabel: "WIND",
                bigValue: "\(Int(w.windSpeedKmh))",
                bottomLabel: "km/h \(w.windDirection) Light breeze"
            )
            metricTile(
                letter: "C",
                letterColor: Color(red: 0.85, green: 0.65, blue: 0.2),
                topLabel: "CLOUD COVER",
                bigValue: w.cloudDescription,
                bottomLabel: "Clear Sky \(w.cloudCoverPercent)% cloud cover"
            )
        }
    }

    private func metricTile(
        letter: String,
        letterColor: Color,
        topLabel: String,
        bigValue: String,
        bottomLabel: String
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.18, green: 0.19, blue: 0.23))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 10) {
                // Letter badge
                ZStack {
                    Circle()
                        .fill(letterColor.opacity(0.18))
                        .frame(width: 36, height: 36)
                    Text(letter)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(letterColor)
                }

                Spacer()

                Text(topLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .tracking(0.5)

                Text(bigValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text(bottomLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 160)
    }

    // MARK: - CTA

    private var planRouteButton: some View {
        Button(action: {}) {
            Text("Plan Route")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(red: 0.25, green: 0.5, blue: 1.0))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LocationDetailView(location: MockData.shymbulak)
        .environment(ProfileViewModel())
}
