// Views/PeakDetailView.swift
// TazaAua – Peak detail screen with sharing

import SwiftUI
import UIKit

struct PeakDetailView: View {
    let location: Location
    let cityAQI: Int
    let peakTemperature: Int
    let isLoading: Bool
    let errorMessage: String?
    let namespace: Namespace.ID

    @Environment(\.dismiss) private var dismiss
    @Environment(ProfileViewModel.self) private var profileVM

    private var favoriteRoute: MountainRoute? {
        location.asMountainRoute()
    }

    private var isFavorite: Bool {
        guard let route = favoriteRoute else { return false }
        return profileVM.favoriteRoutes.contains(where: { $0.id == route.id })
    }

    private var aqiColor: Color {
        switch location.airQuality.category {
        case .good:      return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .moderate:  return Color(red: 1.0, green: 0.75, blue: 0.1)
        case .unhealthy: return Color(red: 1.0, green: 0.35, blue: 0.2)
        case .hazardous: return Color(red: 0.7, green: 0.1, blue: 0.1)
        }
    }

    private var shareMessage: String {
        let mapLink = "https://maps.apple.com/?q=\(location.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? location.name)"
        return "The city is choking with an AQI of \(cityAQI). I'm escaping to \(location.name) where it's \(peakTemperature)°C! Join me: \(mapLink)"
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.1, green: 0.11, blue: 0.14)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    if let errorMessage {
                        errorBanner(message: errorMessage)
                    }

                    headerSection
                        .padding(.top, 60)

                    statusLabel

                    heroSection

                    metricsGrid

                    shareButton

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .overlay { loadingOverlay }
        }
    }

    private var headerSection: some View {
        HStack {
            backButton
            Spacer()
            favoriteButton
        }
    }

    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
                Text("Back")
                    .fontWeight(.semibold)
            }
            .font(.body)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var favoriteButton: some View {
        Button(action: toggleFavorite) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isFavorite ? Color(red: 1.0, green: 0.35, blue: 0.5) : .white)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(favoriteRoute == nil)
    }

    private var statusLabel: some View {
        Text("AIR IS \(location.airQuality.category.label.uppercased())")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(aqiColor)
            .tracking(1.5)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.35, blue: 0.65),
                            Color(red: 0.08, green: 0.2, blue: 0.42)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)
                .matchedGeometryEffect(id: "hero-image-\(location.id)", in: namespace)

            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .matchedGeometryEffect(id: "hero-title-\(location.id)", in: namespace)
                Text(location.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

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
                bigValue: "\(Int(w.temperatureCelsius))°C",
                bottomLabel: "Feels like \(Int(w.feelsLikeCelsius))°C"
            )
            metricTile(
                letter: "〜",
                letterColor: Color(red: 0.55, green: 0.45, blue: 0.95),
                topLabel: "WIND",
                bigValue: "\(Int(w.windSpeedKmh)) km/h",
                bottomLabel: "Direction \(w.windDirection)"
            )
            metricTile(
                letter: "C",
                letterColor: Color(red: 0.85, green: 0.65, blue: 0.2),
                topLabel: "CLOUD COVER",
                bigValue: "\(w.cloudCoverPercent)%",
                bottomLabel: w.cloudDescription
            )
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func metricTile(
        letter: String,
        letterColor: Color,
        topLabel: String,
        bigValue: String,
        bottomLabel: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
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
        .frame(height: 150)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var shareButton: some View {
        ShareLink(item: shareMessage) {
            Label("Escape Together", systemImage: "paperplane.fill")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(red: 0.25, green: 0.5, blue: 1.0))
                )
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var loadingOverlay: some View {
        Group {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }

    private func errorBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color(red: 1.0, green: 0.7, blue: 0.2))
            Text(message)
                .font(.callout)
                .foregroundStyle(.white)
                .lineLimit(3)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func toggleFavorite() {
        guard let route = favoriteRoute else { return }
        let shouldRemove = isFavorite

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        Task {
            if shouldRemove {
                await profileVM.removeFavorite(route: route)
            } else {
                await profileVM.saveFavorite(route: route)
            }
        }
    }
}

#Preview {
    PreviewWrapper()
        .environment(ProfileViewModel())
}

private struct PreviewWrapper: View {
    @Namespace private var namespace

    var body: some View {
        PeakDetailView(
            location: MockData.shymbulak,
            cityAQI: 158,
            peakTemperature: -5,
            isLoading: false,
            errorMessage: nil,
            namespace: namespace
        )
        .environment(ProfileViewModel())
    }
}
