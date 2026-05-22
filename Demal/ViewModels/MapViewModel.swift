// ViewModels/MapViewModel.swift
// TazaAua – Map view model with actor-backed cache

import Foundation
import MapKit
import Observation

@Observable
@MainActor
final class MapViewModel {
    var routes: [MountainRoute] = []

    private let cache: MapDataCache

    init(cache: MapDataCache) {
        self.cache = cache
        routes = Self.makeMockRoutes()
        Task { await primeCache() }
    }

    private func primeCache() async {
        for route in routes {
            await cache.saveRoute(route)
        }
    }

    private static func makeMockRoutes() -> [MountainRoute] {
        [
            MountainRoute(
                name: "Medeu",
                coordinate: CLLocationCoordinate2D(latitude: 43.1577, longitude: 77.0593),
                aqi: 42,
                difficulty: .easy
            ),
            MountainRoute(
                name: "Kok-Zhailau",
                coordinate: CLLocationCoordinate2D(latitude: 43.1415, longitude: 77.0055),
                aqi: 55,
                difficulty: .moderate
            ),
            MountainRoute(
                name: "Shymbulak",
                coordinate: CLLocationCoordinate2D(latitude: 43.1283, longitude: 77.0800),
                aqi: 68,
                difficulty: .hard
            )
        ]
    }
}
