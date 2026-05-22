// Services/APIService.swift
// TazaAua – API Service for fetching Air Quality and Weather Data

import Foundation

/// Service for fetching air quality and weather data from IQAir and OpenWeatherMap APIs
@MainActor
final class APIService {
    
    // MARK: - Properties
    
    private let networkManager = NetworkManager()
    
    // API Keys (Replace with your actual keys)
    private let iqairAPIKey = "YOUR_IQAIR_KEY" // ⚠️ REPLACE WITH REAL API KEY
    private let openWeatherAPIKey = "YOUR_OPENWEATHER_KEY" // ⚠️ REPLACE WITH REAL API KEY
    
    // MARK: - Singleton
    
    static let shared = APIService()
    
    private init() {}
    
    // MARK: - Fetch Air Quality (Open-Meteo)

    /// Fetches air quality data for Almaty from Open-Meteo (keyless)
    func fetchCityAirQuality() async throws -> OpenMeteoAQIResponse {
        let aqiURLString = "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=43.2567&longitude=76.9286&current=european_aqi"

        guard let url = URL(string: aqiURLString) else {
            throw NetworkError.invalidURL
        }

        return try await networkManager.fetch(url: url)
    }

    /// Convenience wrapper for city AQI data
    func fetchCityAQI() async throws -> OpenMeteoAQIResponse {
        try await fetchCityAirQuality()
    }

    /// Fetches air quality data for mountain location (using coordinates)
    /// For demo purposes, we'll use a nearby location API call
    func fetchMountainAirQuality(latitude: Double, longitude: Double) async throws -> IQAirResponse {
        let urlString = "https://api.airvisual.com/v2/nearest_city?lat=\(latitude)&lon=\(longitude)&key=\(iqairAPIKey)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        return try await networkManager.fetch(url: url)
    }
    
    // MARK: - Fetch Weather (OpenWeatherMap)
    
    /// Fetches weather data for Almaty from OpenWeatherMap API
    func fetchCityWeather() async throws -> OpenWeatherResponse {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=43.1577&lon=77.0593&appid=\(openWeatherAPIKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        return try await networkManager.fetch(url: url)
    }
    
    /// Fetches weather data for Medeu from Meteosource
    func fetchMedeuWeather() async throws -> MeteosourceResponse {
        let weatherURLString = "https://www.meteosource.com/api/v1/free/point?lat=43.1577&lon=77.0593&sections=current&language=en&units=metric&key=brj9b5vvba9jk1qtjb22gs6fpckbxxdg59c3o604"

        guard let url = URL(string: weatherURLString) else {
            throw NetworkError.invalidURL
        }

        return try await networkManager.fetch(url: url)
    }

    /// Fetches weather data for Shymbulak from Meteosource
    func fetchShymbulakWeather() async throws -> MeteosourceResponse {
        let shymbulakURLString = "https://www.meteosource.com/api/v1/free/point?lat=43.1283&lon=77.0800&sections=current&language=en&units=metric&key=brj9b5vvba9jk1qtjb22gs6fpckbxxdg59c3o604"

        guard let url = URL(string: shymbulakURLString) else {
            throw NetworkError.invalidURL
        }

        return try await networkManager.fetch(url: url)
    }

    /// Fetches weather data for Kok Zhailau from Meteosource
    func fetchKokZhailauWeather() async throws -> MeteosourceResponse {
        let kokZhailauURLString = "https://www.meteosource.com/api/v1/free/point?lat=43.1430&lon=76.9830&sections=current&language=en&units=metric&key=brj9b5vvba9jk1qtjb22gs6fpckbxxdg59c3o604"

        guard let url = URL(string: kokZhailauURLString) else {
            throw NetworkError.invalidURL
        }

        return try await networkManager.fetch(url: url)
    }

    /// Fetches weather data for a mountain location from Meteosource using coordinates
    func fetchMountainWeather(latitude: Double, longitude: Double) async throws -> MeteosourceResponse {
        let weatherURLString = "https://www.meteosource.com/api/v1/free/point?lat=\(latitude)&lon=\(longitude)&sections=current&language=en&units=metric&key=brj9b5vvba9jk1qtjb22gs6fpckbxxdg59c3o604"

        guard let url = URL(string: weatherURLString) else {
            throw NetworkError.invalidURL
        }

        return try await networkManager.fetch(url: url)
    }
    
    // MARK: - Data Mapping Helpers

    /// Maps Open-Meteo response to our domain AirQualityMetrics model
    func mapToAirQualityMetrics(from response: OpenMeteoAQIResponse) -> AirQualityMetrics {
        let aqi = max(0, response.current.european_aqi)
        let pm25 = estimatePM25(from: aqi)

        return AirQualityMetrics(
            aqi: aqi,
            pm25: pm25,
            pm10: pm25 * 1.2,  // Rough estimate
            o3: 50.0,          // Default placeholder
            no2: 30.0          // Default placeholder
        )
    }

    /// Maps IQAir response to our domain AirQualityMetrics model
    func mapToAirQualityMetrics(from iqair: IQAirResponse) -> AirQualityMetrics {
        let pollution = iqair.data.current.pollution

        // IQAir primarily provides AQI, we'll estimate other values based on AQI
        let aqi = pollution.aqius
        let pm25 = estimatePM25(from: aqi)

        return AirQualityMetrics(
            aqi: aqi,
            pm25: pm25,
            pm10: pm25 * 1.2,  // Rough estimate
            o3: 50.0,          // Default placeholder
            no2: 30.0          // Default placeholder
        )
    }

    /// Maps OpenWeather response to our domain WeatherMetrics model
    func mapToWeatherMetrics(from weather: OpenWeatherResponse) -> WeatherMetrics {
        let main = weather.main
        let wind = weather.wind
        let clouds = weather.clouds?.all ?? 0
        let visibility = Double(weather.visibility ?? 10000) / 1000.0 // Convert m to km

        return WeatherMetrics(
            temperatureCelsius: main.temp,
            feelsLikeCelsius: main.feelsLike,
            windSpeedKmh: wind.speed * 3.6, // Convert m/s to km/h
            windDirection: wind.cardinalDirection,
            cloudCoverPercent: clouds,
            visibilityKm: visibility
        )
    }

    /// Maps Meteosource response to our domain WeatherMetrics model
    func mapToWeatherMetrics(from weather: MeteosourceResponse) -> WeatherMetrics {
        let temperature = weather.current?.temperature ?? 0
        let windSpeed = weather.current?.wind?.speed ?? 0
        let cloudCover = Int((weather.current?.cloudCover ?? 0).rounded())
        let visibility = weather.current?.visibility ?? 0

        return WeatherMetrics(
            temperatureCelsius: temperature,
            feelsLikeCelsius: temperature,
            windSpeedKmh: windSpeed,
            windDirection: "N/A",
            cloudCoverPercent: cloudCover,
            visibilityKm: visibility
        )
    }
    
    // MARK: - Private Helpers
    
    /// Estimates PM2.5 concentration from AQI (simplified conversion)
    private func estimatePM25(from aqi: Int) -> Double {
        switch aqi {
        case 0...50:
            return Double(aqi) * 0.24
        case 51...100:
            return 12.1 + (Double(aqi - 51) * 0.47)
        case 101...150:
            return 35.5 + (Double(aqi - 101) * 0.49)
        case 151...200:
            return 55.5 + (Double(aqi - 151) * 0.99)
        case 201...300:
            return 150.5 + (Double(aqi - 201) * 0.99)
        default:
            return 250.5 + (Double(aqi - 301) * 0.99)
        }
    }

    private func cardinalDirection(from degrees: Int?) -> String {
        guard let degrees else { return "N/A" }
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(degrees) + 22.5) / 45.0) % 8
        return directions[index]
    }
}
