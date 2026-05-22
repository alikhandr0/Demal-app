// Models/MockData.swift
// TazaAua – Static mock data for Phase 1

import Foundation

// MARK: - EscapeSuggestion

struct EscapeSuggestion: Identifiable, Hashable {
    var id: UUID = UUID()
    var headline: String
    var mountainLocation: Location
}

// MARK: - MockData

enum MockData {

    // MARK: - City Locations (High AQI)

    static let almaty = Location(
        name: "Almaty City Center",
        subtitle: "Medeu District",
        altitudeMeters: 800,
        type: .city,
        region: "Almaty",
        airQuality: AirQualityMetrics(
            aqi: 158,
            pm25: 67.8,
            pm10: 85.2,
            o3: 42.1,
            no2: 38.5
        ),
        weather: WeatherMetrics(
            temperatureCelsius: -3.0,
            feelsLikeCelsius: -7.5,
            windSpeedKmh: 12.0,
            windDirection: "N",
            cloudCoverPercent: 65,
            visibilityKm: 4.5
        ),
        isPinned: true
    )

    static let orbita = Location(
        name: "Orbita",
        subtitle: "Residential District",
        altitudeMeters: 750,
        type: .district,
        region: "Almaty",
        airQuality: AirQualityMetrics(
            aqi: 145,
            pm25: 61.3,
            pm10: 79.8,
            o3: 39.2,
            no2: 35.1
        ),
        weather: WeatherMetrics(
            temperatureCelsius: -2.5,
            feelsLikeCelsius: -6.8,
            windSpeedKmh: 10.5,
            windDirection: "NE",
            cloudCoverPercent: 70,
            visibilityKm: 5.2
        )
    )

    static let mikrorayon = Location(
        name: "Mikrorayon",
        subtitle: "Central Area",
        altitudeMeters: 780,
        type: .district,
        region: "Almaty",
        airQuality: AirQualityMetrics(
            aqi: 162,
            pm25: 70.1,
            pm10: 88.6,
            o3: 44.5,
            no2: 41.2
        ),
        weather: WeatherMetrics(
            temperatureCelsius: -3.2,
            feelsLikeCelsius: -8.0,
            windSpeedKmh: 13.5,
            windDirection: "N",
            cloudCoverPercent: 60,
            visibilityKm: 4.0
        )
    )

    // MARK: - Mountain Locations (Clean Air)

    static let shymbulak = Location(
        name: "Shymbulak",
        subtitle: "Ski Resort, 2260m",
        altitudeMeters: 2260,
        type: .mountain,
        region: "Trans-Ili Alatau",
        airQuality: AirQualityMetrics(
            aqi: 12,
            pm25: 4.8,
            pm10: 8.2,
            o3: 58.3,
            no2: 2.1
        ),
        weather: WeatherMetrics(
            temperatureCelsius: -8.0,
            feelsLikeCelsius: -14.0,
            windSpeedKmh: 18.0,
            windDirection: "W",
            cloudCoverPercent: 20,
            visibilityKm: 25.0
        ),
        isPinned: true
    )

    static let medeu = Location(
        name: "Medeu",
        subtitle: "Ice Rink, 1691m",
        altitudeMeters: 1691,
        type: .mountain,
        region: "Trans-Ili Alatau",
        airQuality: AirQualityMetrics(
            aqi: 18,
            pm25: 7.2,
            pm10: 11.5,
            o3: 55.8,
            no2: 3.8
        ),
        weather: WeatherMetrics(
            temperatureCelsius: -5.0,
            feelsLikeCelsius: -9.5,
            windSpeedKmh: 14.0,
            windDirection: "NW",
            cloudCoverPercent: 15,
            visibilityKm: 30.0
        )
    )

    static let kokZhailau = Location(
        name: "Kok Zhailau",
        subtitle: "Alpine Meadow, 1800m",
        altitudeMeters: 1800,
        type: .meadow,
        region: "Trans-Ili Alatau",
        airQuality: AirQualityMetrics(
            aqi: 8,
            pm25: 3.2,
            pm10: 5.8,
            o3: 62.1,
            no2: 1.5
        ),
        weather: WeatherMetrics(
            temperatureCelsius: -6.5,
            feelsLikeCelsius: -11.0,
            windSpeedKmh: 16.0,
            windDirection: "W",
            cloudCoverPercent: 10,
            visibilityKm: 35.0
        )
    )

    static let chimbulak = Location(
        name: "Chimbulak Peak",
        subtitle: "Summit, 3200m",
        altitudeMeters: 3200,
        type: .mountain,
        region: "Trans-Ili Alatau",
        airQuality: AirQualityMetrics(
            aqi: 5,
            pm25: 2.1,
            pm10: 3.5,
            o3: 68.5,
            no2: 0.8
        ),
        weather: WeatherMetrics(
            temperatureCelsius: 0,
            feelsLikeCelsius: 0,
            windSpeedKmh: 22.0,
            windDirection: "W",
            cloudCoverPercent: 5,
            visibilityKm: 40.0
        )
    )

    // MARK: - Collections

    static let cityLocations = [almaty, orbita, mikrorayon]
    static let mountainLocations = [shymbulak, medeu, kokZhailau, chimbulak]
    static let allLocations = cityLocations + mountainLocations

    // MARK: - Escape Suggestion

    static let escapeSuggestion = EscapeSuggestion(
        headline: "Fresh air at Shymbulak – AQI 12 vs City 158",
        mountainLocation: shymbulak
    )
}
