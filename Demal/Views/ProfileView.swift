// Views/ProfileView.swift
// TazaAua – Profile screen (screen 05)

import SwiftUI

struct ProfileView: View {
    @Environment(ProfileViewModel.self) private var viewModel
    @State private var notificationsEnabled = true
    @State private var useMetricSystem = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ProfileHeaderCard(
                        username: viewModel.username,
                        totalEscapes: viewModel.totalEscapes,
                        favoritesCount: viewModel.favoriteRoutes.count
                    )
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                Section("Favorites") {
                    if viewModel.favoriteRoutes.isEmpty {
                        FavoritesEmptyStateCard()
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(viewModel.favoriteRoutes) { route in
                            FavoriteRouteCard(route: route)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                .textCase(nil)

                Section("Settings") {
                    Toggle("Push Notifications for High AQI", isOn: $notificationsEnabled)
                        .toggleStyle(.switch)
                        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
                    Toggle("Use Metric System", isOn: $useMetricSystem)
                        .toggleStyle(.switch)
                        .listRowBackground(Rectangle().fill(.ultraThinMaterial))
                }
                .textCase(nil)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemBackground))
            .navigationTitle("Profile")
        }
        .task {
            await viewModel.loadProfile()
        }
    }
}

private struct ProfileHeaderCard: View {
    let username: String
    let totalEscapes: Int
    let favoritesCount: Int

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.25, green: 0.65, blue: 1.0), Color(red: 0.95, green: 0.45, blue: 0.25)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 84, height: 84)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )

                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(gradient)
            }

            VStack(spacing: 6) {
                Text(username)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("Escaped Smog \(totalEscapes) times")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                StatPill(title: "Favorites", value: "\(favoritesCount)")
                StatPill(title: "Escapes", value: "\(totalEscapes)")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.weight(.semibold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
    }
}

private struct FavoriteRouteCard: View {
    let route: MountainRoute

    private var badgeColor: Color { route.aqi <= 100 ? .green : .red }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(route.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("Difficulty: \(route.difficulty.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("AQI \(route.aqi)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(badgeColor.opacity(0.85), in: Capsule())
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct FavoritesEmptyStateCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "wind")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("No escapes planned yet.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Text("Go find some fresh air in the Search tab!")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    ProfileView()
        .environment(ProfileViewModel())
}
