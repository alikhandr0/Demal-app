// ViewModels/SearchViewModel.swift
// TazaAua – Search view model with smart recommendation

import Foundation
import MapKit
import Observation

@Observable
@MainActor
final class SearchViewModel {
    enum Category: String, CaseIterable, Identifiable {
        case all
        case city
        case mountains

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all:
                return "All"
            case .city:
                return "City Districts"
            case .mountains:
                return "Mountain Trails"
            }
        }
    }

    var allLocations: [Location]
    var searchText: String = ""
    var selectedCategory: Category = .all

    var isLoading: Bool = false

    private let cityAQI: Int
    private let mountainRoutes: [MountainRoute]
    private let apiService = APIService.shared

    private var mountainLocations: [Location] {
        allLocations.filter { $0.type == .mountain || $0.type == .meadow }
    }

    init() {
        let locations = MockData.allLocations
        self.allLocations = locations
        self.cityAQI = MockData.almaty.airQuality.aqi
        self.mountainRoutes = Self.makeMockRoutes()
    }

    init(allLocations: [Location], cityAQI: Int, mountainRoutes: [MountainRoute]) {
        self.allLocations = allLocations
        self.cityAQI = cityAQI
        self.mountainRoutes = mountainRoutes
    }

    var filteredLocations: [Location] {
        let categoryFiltered = allLocations.filter { location in
            switch selectedCategory {
            case .all:
                return true
            case .city:
                return location.type == .city || location.type == .district
            case .mountains:
                return location.type == .mountain || location.type == .meadow
            }
        }

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return categoryFiltered
        }

        let query = searchText.lowercased()
        return categoryFiltered.filter {
            $0.name.lowercased().contains(query) || $0.subtitle.lowercased().contains(query)
        }
    }

    var recommendedRoute: MountainRoute? {
        generateRecommendedRoute()
    }

    func generateRecommendedRoute() -> MountainRoute? {
        guard cityAQI > 100 else { return nil }
        guard !mountainRoutes.isEmpty else { return nil }

        return mountainRoutes.max { score(for: $0) < score(for: $1) }
    }

    func location(for route: MountainRoute) -> Location? {
        let routeKey = normalized(route.name)
        return mountainLocations.first { normalized($0.name) == routeKey }
    }

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

    private func score(for route: MountainRoute) -> Double {
        let location = location(for: route)
        let aqi = location?.airQuality.aqi ?? route.aqi
        let weather = location?.weather

        let airScore = (200.0 - Double(aqi)) * 2.0
        let visibilityScore = (weather?.visibilityKm ?? 0) * 1.2
        let temperatureScore = (weather?.temperatureCelsius ?? 0) * 0.5
        let windPenalty = (weather?.windSpeedKmh ?? 0) * 0.4

        return airScore + visibilityScore + temperatureScore - windPenalty
    }

    private func normalized(_ value: String) -> String {
        value.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    private static func makeMockRoutes() -> [MountainRoute] {
        [
            MountainRoute(
                name: "Medeu",
                coordinate: CLLocationCoordinate2D(latitude: 43.1577, longitude: 77.0593),
                aqi: 18,
                difficulty: .easy
            ),
            MountainRoute(
                name: "Kok-Zhailau",
                coordinate: CLLocationCoordinate2D(latitude: 43.1415, longitude: 77.0055),
                aqi: 12,
                difficulty: .moderate
            ),
            MountainRoute(
                name: "Shymbulak",
                coordinate: CLLocationCoordinate2D(latitude: 43.1283, longitude: 77.0800),
                aqi: 14,
                difficulty: .hard
            )
        ]
    }
}
