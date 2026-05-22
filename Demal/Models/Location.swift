// Models/Location.swift
// TazaAua – Domain Models

import Foundation

// MARK: - AQI Category

enum AQICategory: String, Codable, Hashable {
    case good        = "Good"
    case moderate    = "Moderate"
    case unhealthy   = "Unhealthy"
    case hazardous   = "Hazardous"

    init(aqi: Int) {
        switch aqi {
        case 0...50:   self = .good
        case 51...100: self = .moderate
        case 101...200: self = .unhealthy
        default:       self = .hazardous
        }
    }

    var label: String { rawValue }

    var emoji: String {
        switch self {
        case .good:      return "🟢"
        case .moderate:  return "🟡"
        case .unhealthy: return "🔴"
        case .hazardous: return "☠️"
        }
    }
}

// MARK: - Air Quality Metrics

struct AirQualityMetrics: Codable, Hashable {
    var aqi: Int
    var pm25: Double
    var pm10: Double
    var o3: Double
    var no2: Double

    var category: AQICategory { AQICategory(aqi: aqi) }
}

// MARK: - Weather Metrics

struct WeatherMetrics: Codable, Hashable {
    var temperatureCelsius: Double
    var feelsLikeCelsius: Double
    var windSpeedKmh: Double
    var windDirection: String
    var cloudCoverPercent: Int
    var visibilityKm: Double

    var cloudDescription: String {
        switch cloudCoverPercent {
        case 0...10:  return "Clear"
        case 11...40: return "Mostly Clear"
        case 41...70: return "Partly Cloudy"
        default:      return "Overcast"
        }
    }
}

// MARK: - Location Type

enum LocationType: String, Codable, Hashable {
    case city     = "City"
    case district = "District"
    case mountain = "Mountain"
    case meadow   = "Alpine Meadow"
}

// MARK: - Location

struct Location: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var subtitle: String
    var altitudeMeters: Int
    var type: LocationType
    var region: String
    var airQuality: AirQualityMetrics
    var weather: WeatherMetrics
    var isPinned: Bool
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        name: String,
        subtitle: String,
        altitudeMeters: Int,
        type: LocationType,
        region: String,
        airQuality: AirQualityMetrics,
        weather: WeatherMetrics,
        isPinned: Bool = false,
        lastUpdated: Date = .now
    ) {
        self.id             = id
        self.name           = name
        self.subtitle       = subtitle
        self.altitudeMeters = altitudeMeters
        self.type           = type
        self.region         = region
        self.airQuality     = airQuality
        self.weather        = weather
        self.isPinned       = isPinned
        self.lastUpdated    = lastUpdated
    }
}
