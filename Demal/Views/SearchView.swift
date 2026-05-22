// Views/SearchView.swift
// TazaAua – Search placeholder

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @Environment(ProfileViewModel.self) private var profileVM

    var body: some View {
        NavigationStack {
            List {
                if let recommendation = viewModel.recommendedRoute {
                    Section {
                        SmartRecommendationCard(
                            route: recommendation,
                            location: viewModel.location(for: recommendation)
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }

                Section {
                    Picker("Category", selection: $viewModel.selectedCategory) {
                        ForEach(SearchViewModel.Category.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section {
                    if viewModel.filteredLocations.isEmpty {
                        EmptyStateRow()
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(viewModel.filteredLocations) { location in
                            let route = location.asMountainRoute()

                            LocationResultRow(location: location)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if let route {
                                        Button {
                                            Task { await profileVM.saveFavorite(route: route) }
                                        } label: {
                                            Label(
                                                "Save to Profile",
                                                systemImage: isFavorite(route) ? "heart.fill" : "heart"
                                            )
                                        }
                                        .tint(isFavorite(route) ? .pink : .blue)
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .navigationTitle("Search")
        }
        .searchable(text: $viewModel.searchText, prompt: "Search locations")
        .task { await viewModel.loadLocations() }
    }

    private func isFavorite(_ route: MountainRoute) -> Bool {
        profileVM.favoriteRoutes.contains(where: { $0.id == route.id })
    }
}

private struct SmartRecommendationCard: View {
    let route: MountainRoute
    let location: Location?

    private var aqi: Int { location?.airQuality.aqi ?? route.aqi }
    private var badgeColor: Color { aqi <= 100 ? .green : .red }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                Text("Smart Recommendation")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                AQIBadge(aqi: aqi)
            }

            Text(route.name)
                .font(.title3.weight(.semibold))

            Text(detailLine)
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Text("Difficulty: \(route.difficulty.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Circle()
                    .fill(badgeColor)
                    .frame(width: 6, height: 6)
                Text(aqi <= 100 ? "Clean air" : "Smoggy")
                    .font(.caption)
                    .foregroundStyle(badgeColor)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var detailLine: String {
        guard let weather = location?.weather else {
            return "Best air quality route outside the city"
        }

        let temp = Int(weather.temperatureCelsius.rounded())
        let visibility = String(format: "%.1f", weather.visibilityKm)
        return "Temp \(temp)°C • Visibility \(visibility) km"
    }
}

private struct LocationResultRow: View {
    let location: Location

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                Text(typeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            AQIBadge(aqi: location.airQuality.aqi)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var typeLabel: String {
        switch location.type {
        case .city, .district:
            return "City"
        case .mountain, .meadow:
            return "Mountain"
        }
    }
}

private struct AQIBadge: View {
    let aqi: Int

    private var badgeColor: Color { aqi <= 100 ? .green : .red }

    var body: some View {
        Text("AQI \(aqi)")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(badgeColor.opacity(0.85), in: Capsule())
    }
}

private struct EmptyStateRow: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("No matches")
                .font(.subheadline.weight(.semibold))
            Text("Try a different keyword or category")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    SearchView()
        .environment(ProfileViewModel())
}
