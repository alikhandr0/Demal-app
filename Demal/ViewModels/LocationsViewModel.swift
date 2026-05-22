// ViewModels/LocationsViewModel.swift
// TazaAua – Locations list ViewModel

import Foundation
import Observation

@Observable
@MainActor
final class LocationsViewModel {

    // MARK: - State

    var allLocations: [Location] = MockData.allLocations
    var searchQuery: String = ""
    var isLoading: Bool = false

    private let apiService = APIService.shared

    // MARK: - Filtered

    var cityLocations: [Location] {
        filter(allLocations.filter { $0.type == .city || $0.type == .district })
    }

    var mountainLocations: [Location] {
        filter(allLocations.filter { $0.type == .mountain || $0.type == .meadow })
    }

    var hasResults: Bool {
        !cityLocations.isEmpty || !mountainLocations.isEmpty
    }

    private func filter(_ list: [Location]) -> [Location] {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return list }
        return list.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    // MARK: - Load

    func loadLocations() async {
        isLoading = true

        var updatedLocations = MockData.allLocations

        async let medeuWeather = try? apiService.fetchMedeuWeather()
        async let shymbulakWeather = try? apiService.fetchShymbulakWeather()
        async let kokZhailauWeather = try? apiService.fetchMountainWeather(
            latitude: 43.1430,
            longitude: 76.9830
        )

        let weatherByName: [String: MeteosourceResponse?] = [
            "Medeu": await medeuWeather,
            "Shymbulak": await shymbulakWeather,
            "Kok Zhailau": await kokZhailauWeather
        ]

        updatedLocations = updatedLocations.map { location in
            guard let response = weatherByName[location.name], let response else { return location }
            let updatedWeather = apiService.mapToWeatherMetrics(from: response)
            return Location(
                id: location.id,
                name: location.name,
                subtitle: location.subtitle,
                altitudeMeters: location.altitudeMeters,
                type: location.type,
                region: location.region,
                airQuality: location.airQuality,
                weather: updatedWeather,
                isPinned: location.isPinned,
                lastUpdated: .now
            )
        }

        allLocations = updatedLocations
        isLoading = false
    }
}
