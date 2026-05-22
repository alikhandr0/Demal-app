// Models/APIModels.swift
// TazaAua – API Response Models for IQAir and OpenWeatherMap

import Foundation

// MARK: - IQAir API Response

/// Response structure for IQAir API
/// Endpoint: http://api.airvisual.com/v2/city?city=Almaty&state=Almaty&country=Kazakhstan&key=YOUR_API_KEY
struct IQAirResponse: Codable {
    let status: String
    let data: IQAirData
}

struct IQAirData: Codable {
    let city: String
    let state: String
    let country: String
    let location: IQAirLocation?
    let current: IQAirCurrent
}

struct IQAirLocation: Codable {
    let coordinates: [Double]
}

struct IQAirCurrent: Codable {
    let pollution: IQAirPollution
    let weather: IQAirWeather
}

struct IQAirPollution: Codable {
    let ts: String
    let aqius: Int       // US AQI value
    let mainus: String   // Main pollutant
    let aqicn: Int?      // China AQI value (optional)
    let maincn: String?  // Main pollutant CN
}

struct IQAirWeather: Codable {
    let ts: String
    let tp: Double       // Temperature
    let pr: Int?         // Atmospheric pressure
    let hu: Int?         // Humidity
    let ws: Double?      // Wind speed
    let wd: Int?         // Wind direction
}

// MARK: - Open-Meteo Air Quality Response

struct OpenMeteoAQIResponse: Codable {
    let current: OpenMeteoCurrent
}

struct OpenMeteoCurrent: Codable {
    let european_aqi: Int
}

// MARK: - OpenWeatherMap API Response

/// Response structure for OpenWeatherMap API
/// Endpoint: https://api.openweathermap.org/data/2.5/weather?lat=43.1283&lon=77.0800&appid=YOUR_API_KEY&units=metric
struct OpenWeatherResponse: Codable {
    let coord: OpenWeatherCoord?
    let weather: [OpenWeatherCondition]
    let base: String?
    let main: OpenWeatherMain
    let visibility: Int?
    let wind: OpenWeatherWind
    let clouds: OpenWeatherClouds?
    let dt: Int
    let sys: OpenWeatherSys?
    let timezone: Int?
    let id: Int?
    let name: String
    let cod: Int
}

struct OpenWeatherCoord: Codable {
    let lon: Double
    let lat: Double
}

struct OpenWeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct OpenWeatherMain: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double?
    let tempMax: Double?
    let pressure: Int?
    let humidity: Int?
    let seaLevel: Int?
    let grndLevel: Int?
}

struct OpenWeatherWind: Codable {
    let speed: Double
    let deg: Int?
    let gust: Double?
}

struct OpenWeatherClouds: Codable {
    let all: Int
}

struct OpenWeatherSys: Codable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}

// MARK: - Meteosource Response

/// Response structure for Meteosource
/// Endpoint: https://www.meteosource.com/api/v1/free/point?lat=43.1577&lon=77.0593&sections=current&language=en&units=metric&key=YOUR_API_KEY
struct MeteosourceResponse: Codable {
    let current: MeteosourceCurrent?
}

struct MeteosourceCurrent: Codable {
    let temperature: Double?
    let summary: String?
    let cloudCover: Double?
    let wind: MeteosourceWind?
    let visibility: Double?

    private enum CodingKeys: String, CodingKey {
        case temperature
        case summary
        case cloudCover = "cloud_cover"
        case wind
        case visibility
    }
}

struct MeteosourceWind: Codable {
    let speed: Double?
}

// MARK: - Helper Extensions

extension OpenWeatherWind {
    /// Convert wind degree to cardinal direction
    var cardinalDirection: String {
        guard let deg = deg else { return "N/A" }
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(deg) + 22.5) / 45.0) % 8
        return directions[index]
    }
}
