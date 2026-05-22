// Views/DashboardView.swift
// TazaAua – Home / Dashboard screen

import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Namespace private var heroNamespace
    @State private var selectedLocation: Location? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient

                // Particle system (visualizing air quality)
                SmogParticleView(aqi: viewModel.currentLocation.airQuality.aqi)
                    .ignoresSafeArea()
                    .opacity(0.6)

                // Main content
                scrollContent
                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    .overlay { loadingOverlay }
            }
            .ignoresSafeArea(edges: .top)
            .task { await viewModel.loadData() }
            .refreshable { await viewModel.refresh() }
            .navigationDestination(item: $selectedLocation) { location in
                PeakDetailView(
                    location: location,
                    cityAQI: viewModel.latestCityAQI,
                    peakTemperature: Int(location.weather.temperatureCelsius),
                    isLoading: viewModel.isLoading,
                    errorMessage: viewModel.errorMessage,
                    namespace: heroNamespace
                )
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.09, blue: 0.12),
                Color(red: 0.10, green: 0.11, blue: 0.16)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Main scroll content

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if let errorMessage = viewModel.errorMessage {
                    errorBanner(message: errorMessage)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                }

                // Top safe-area spacer + header
                headerSection
                    .padding(.top, 60)
                    .padding(.bottom, 24)

                VStack(spacing: 20) {
                    // Current location weather summary
                    currentWeatherCard
                        .padding(.horizontal, 20)

                    // AQI Gauge
                    AQIGaugeView(
                        aqi: viewModel.currentLocation.airQuality.aqi,
                        category: viewModel.currentLocation.airQuality.category
                    )
                    .padding(.bottom, 8)

                    // Escape card
                    if let suggestion = viewModel.escapeSuggestion {
                        EscapeCardView(suggestion: suggestion)
                            .padding(.horizontal, 20)
                    }

                    // Weather metrics grid
                    weatherMetricsSection
                        .padding(.horizontal, 20)

                    // Mountain section header
                    sectionHeader(title: "Mountain Air", systemImage: "mountain.2.fill")
                        .padding(.horizontal, 20)

                    // Mountain location tiles
                    ForEach(viewModel.mountainLocations) { location in
                        mountainTile(location: location)
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Current Location")
                    .font(.caption)
                    .foregroundStyle(Color(red: 1.0, green: 0.45, blue: 0.2))
                    .fontWeight(.semibold)
                    .tracking(0.5)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                Text(viewModel.currentLocation.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }

            Spacer()

            // Avatar
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.45, blue: 0.2))
                    .frame(width: 40, height: 40)
                Text("AK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
    }

    // MARK: - Weather Metrics

    private var weatherMetricsSection: some View {
        let weather = viewModel.currentLocation.weather
        return LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            WeatherMetricTileView(
                icon: "〜",
                iconColor: .blue,
                title: "Wind",
                value: "\(Int(viewModel.windSpeed)) km/h",
                subtitle: "\(weather.windDirection) Direction"
            )
            WeatherMetricTileView(
                icon: "◎",
                iconColor: .orange,
                title: "Visibility",
                value: String(format: "%.1f km", viewModel.visibilityKm),
                subtitle: viewModel.visibilityKm < 1 ? "Very Low" : "Low"
            )
            WeatherMetricTileView(
                icon: "☁",
                iconColor: .gray,
                title: "Cloud Cover",
                value: "\(viewModel.cloudCover)%",
                subtitle: weather.cloudDescription
            )
            WeatherMetricTileView(
                icon: "🌡",
                iconColor: .red,
                title: "Feels Like",
                value: "\(Int(weather.feelsLikeCelsius))°C",
                subtitle: "Actual \(Int(weather.temperatureCelsius))°C"
            )
        }
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            Spacer()
        }
    }

    private func aqiColor(for value: Int) -> Color {
        switch value {
        case 0...50:
            return Color(red: 0.2, green: 0.8, blue: 0.4)
        case 51...100:
            return Color(red: 1.0, green: 0.75, blue: 0.1)
        case 101...150:
            return Color(red: 1.0, green: 0.55, blue: 0.2)
        default:
            return Color(red: 0.9, green: 0.2, blue: 0.2)
        }
    }

    // MARK: - Mountain Tile

    private func mountainTile(location: Location) -> some View {
        let aqiColor = aqiColor(for: location.airQuality.aqi)
        return Button {
            selectedLocation = location
        } label: {
            HStack(spacing: 16) {
                // Hero image
                RoundedRectangle(cornerRadius: 14, style: .continuous)
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
                    .frame(width: 60, height: 60)
                    .matchedGeometryEffect(id: "hero-image-\(location.id)", in: heroNamespace)

                // AQI circle
                ZStack {
                    Circle()
                        .fill(aqiColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Text("\(location.airQuality.aqi)")
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(aqiColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(location.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .matchedGeometryEffect(id: "hero-title-\(location.id)", in: heroNamespace)
                    Text(location.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(location.weather.temperatureCelsius))°C")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Text(location.airQuality.category.label)
                        .font(.caption2)
                        .foregroundStyle(aqiColor)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Current Weather

    private var currentWeatherCard: some View {
        let weather = viewModel.currentLocation.weather
        return HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Current Weather")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))
                Text("\(Int(weather.temperatureCelsius))°C")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(weather.cloudDescription)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Label("Feels \(Int(weather.feelsLikeCelsius))°C", systemImage: "thermometer.medium")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Label("Wind \(Int(weather.windSpeedKmh)) km/h", systemImage: "wind")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Label("Visibility \(String(format: "%.1f", weather.visibilityKm)) km", systemImage: "eye")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                }
            }
        }
    }

    // MARK: - Error Banner

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
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
        .environment(ProfileViewModel())
}
