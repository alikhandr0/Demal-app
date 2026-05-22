// Views/LocationsListView.swift
// TazaAua – Locations search & list screen

import SwiftUI

struct LocationsListView: View {
    @State private var viewModel = LocationsViewModel()
    @State private var selectedLocation: Location? = nil

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.96, green: 0.96, blue: 0.97)
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading locations…")
                    .tint(.blue)
            } else {
                locationsList
            }
        }
        .navigationTitle("Locations")
        .navigationBarTitleDisplayMode(.large)
        .searchable(
            text: $viewModel.searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search districts or peaks…"
        )
        .task { await viewModel.loadLocations() }
        .sheet(item: $selectedLocation) { location in
            LocationDetailView(location: location)
        }
    }

    // MARK: - List

    private var locationsList: some View {
        List {
            if !viewModel.cityLocations.isEmpty {
                Section {
                    ForEach(viewModel.cityLocations) { location in
                        Button {
                            selectedLocation = location
                        } label: {
                            LocationRowView(location: location)
                        }
                        .listRowBackground(Color.white)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                } header: {
                    sectionHeader("CITY")
                }
            }

            if !viewModel.mountainLocations.isEmpty {
                Section {
                    ForEach(viewModel.mountainLocations) { location in
                        Button {
                            selectedLocation = location
                        } label: {
                            LocationRowView(
                                location: location,
                                onPin: { },
                                onShare: { },
                                showActions: true
                            )
                        }
                        .listRowBackground(Color.white)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                } header: {
                    sectionHeader("MOUNTAINS")
                }
            }

            if !viewModel.hasResults {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different district or mountain name.")
                )
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .tracking(1)
    }
}

#Preview {
    NavigationStack {
        LocationsListView()
    }
    .environment(ProfileViewModel())
}
