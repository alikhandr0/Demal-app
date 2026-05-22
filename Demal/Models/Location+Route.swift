// Models/Location+Route.swift
// TazaAua – Helpers to map locations to routes

import Foundation
import MapKit

extension Location {
    func asMountainRoute() -> MountainRoute? {
        guard type == .mountain || type == .meadow else { return nil }

        let key = normalizedName
        let coordinate = Self.routeCoordinates[key] ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let difficulty = Self.routeDifficulties[key] ?? .moderate

        return MountainRoute(
            id: id,
            name: name,
            coordinate: coordinate,
            aqi: airQuality.aqi,
            difficulty: difficulty
        )
    }

    private var normalizedName: String {
        name.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    private static let routeCoordinates: [String: CLLocationCoordinate2D] = [
        "medeu": CLLocationCoordinate2D(latitude: 43.1577, longitude: 77.0593),
        "kokzhailau": CLLocationCoordinate2D(latitude: 43.1415, longitude: 77.0055),
        "shymbulak": CLLocationCoordinate2D(latitude: 43.1283, longitude: 77.0800),
        "chimbulakpeak": CLLocationCoordinate2D(latitude: 43.1283, longitude: 77.0800)
    ]

    private static let routeDifficulties: [String: Difficulty] = [
        "medeu": .easy,
        "kokzhailau": .moderate,
        "shymbulak": .hard,
        "chimbulakpeak": .hard
    ]
}
