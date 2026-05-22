// Models/MountainRoute.swift
// TazaAua – Mountain route model for MapKit

import Foundation
import MapKit

struct MountainRoute: Identifiable, Codable {
    let id: UUID
    var name: String
    var coordinate: CLLocationCoordinate2D
    var aqi: Int
    var difficulty: Difficulty

    init(
        id: UUID = UUID(),
        name: String,
        coordinate: CLLocationCoordinate2D,
        aqi: Int,
        difficulty: Difficulty
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.aqi = aqi
        self.difficulty = difficulty
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case aqi
        case difficulty
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        aqi = try container.decode(Int.self, forKey: .aqi)
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(aqi, forKey: .aqi)
        try container.encode(difficulty, forKey: .difficulty)
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy
    case moderate
    case hard
}
