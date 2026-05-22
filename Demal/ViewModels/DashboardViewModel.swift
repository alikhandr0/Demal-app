// ViewModels/DashboardViewModel.swift
// TazaAua – @Observable ViewModel (iOS 17+, Swift 6 ready)

import Foundation
import Observation
import UIKit
import CoreLocation
import Combine

@Observable
@MainActor
final class DashboardViewModel {

    // MARK: - State

    var currentLocation: Location = Location(
        name: "No Data",
        subtitle: "",
        altitudeMeters: 0,
        type: .city,
        region: "",
        airQuality: AirQualityMetrics(aqi: 0, pm25: 0, pm10: 0, o3: 0, no2: 0),
        weather: WeatherMetrics(
            temperatureCelsius: 0,
            feelsLikeCelsius: 0,
            windSpeedKmh: 0,
            windDirection: "No Data",
            cloudCoverPercent: 0,
            visibilityKm: 0
        ),
        isPinned: false,
        lastUpdated: .now
    )
    var mountainLocations: [Location] = []
    var cityLocations: [Location] = []
    var escapeSuggestion: EscapeSuggestion? = nil
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var latestCityAQI: Int = 0
    var cityAQI: Int = 0
    var medeuTemperatureC: Int = 0
    var currentMountainTemp: Int? = nil
    var mountainWeatherCondition: String = "No Data"
    var windSpeed: Double = 0
    var cloudCover: Int = 0
    var visibilityKm: Double = 0

    // MARK: - Dependencies
    
    private let apiService = APIService.shared
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let locationManager = LocationManager()
    private nonisolated(unsafe) var locationUpdatesTask: Task<Void, Never>?

    // MARK: - Derived
    
    var bestEscapeLocation: Location? {
        mountainLocations.min(by: { $0.airQuality.aqi < $1.airQuality.aqi })
    }

    var cityAQICategory: AQICategory {
        currentLocation.airQuality.category
    }

    init() {
        locationUpdatesTask = Task { [weak self] in
            guard let self else { return }
            for await location in locationManager.$currentLocation.values {
                guard let location else { continue }
                await self.updateCurrentLocationWeather(using: location)
            }
        }
    }

    deinit {
        locationUpdatesTask?.cancel()
    }

    // MARK: - Load Data with Parallel Fetching

    func loadData() async {
        isLoading = true

        // Prepare haptic generator
        hapticGenerator.prepare()

        var fetchedAirQuality: AirQualityMetrics? = nil
        var fetchedMedeuWeather: MeteosourceResponse? = nil
        var fetchedShymbulakWeather: MeteosourceResponse? = nil
        var fetchedKokZhailauWeather: MeteosourceResponse? = nil
        var fetchedCurrentLocationWeather: MeteosourceResponse? = nil
        let gpsLocation = locationManager.currentLocation

        do {
            let aqiResponse = try await apiService.fetchCityAirQuality()
            let airQuality = apiService.mapToAirQualityMetrics(from: aqiResponse)
            fetchedAirQuality = airQuality
            cityAQI = airQuality.aqi
        } catch {
            print("❌ Open-Meteo AQI Error: \(error)")
            cityAQI = 0
            fetchedAirQuality = nil
        }

        if let gpsLocation {
            do {
                fetchedCurrentLocationWeather = try await apiService.fetchMountainWeather(
                    latitude: gpsLocation.coordinate.latitude,
                    longitude: gpsLocation.coordinate.longitude
                )
            } catch {
                fetchedCurrentLocationWeather = nil
            }
        }

        do {
            let weatherResponse = try await apiService.fetchMedeuWeather()
            fetchedMedeuWeather = weatherResponse
            currentMountainTemp = Int(weatherResponse.current?.temperature ?? 0)
            mountainWeatherCondition = weatherResponse.current?.summary ?? "No Data"
        } catch {
            print("❌ Meteosource Medeu Error: \(error)")
            currentMountainTemp = nil
            mountainWeatherCondition = "No Data"
            fetchedMedeuWeather = nil
        }

        do {
            let shymbulakResponse = try await apiService.fetchShymbulakWeather()
            fetchedShymbulakWeather = shymbulakResponse
        } catch {
            print("❌ Meteosource Shymbulak Error: \(error)")
            fetchedShymbulakWeather = nil
        }

        do {
            let kokZhailauResponse = try await apiService.fetchMountainWeather(
                latitude: 43.1430,
                longitude: 76.9830
            )
            fetchedKokZhailauWeather = kokZhailauResponse
        } catch {
            print("❌ Meteosource Kok Zhailau Error: \(error)")
            fetchedKokZhailauWeather = nil
        }

        if fetchedCurrentLocationWeather == nil {
            fetchedCurrentLocationWeather = fetchedMedeuWeather
        }

        let airQuality = fetchedAirQuality ?? AirQualityMetrics(aqi: 0, pm25: 0, pm10: 0, o3: 0, no2: 0)
        let weather = fetchedCurrentLocationWeather.map { apiService.mapToWeatherMetrics(from: $0) } ?? WeatherMetrics(
            temperatureCelsius: 0,
            feelsLikeCelsius: 0,
            windSpeedKmh: 0,
            windDirection: "No Data",
            cloudCoverPercent: 0,
            visibilityKm: 0
        )

        if let currentWeather = fetchedCurrentLocationWeather {
            windSpeed = currentWeather.current?.wind?.speed ?? 0
            cloudCover = Int((currentWeather.current?.cloudCover ?? 0).rounded())
            visibilityKm = currentWeather.current?.visibility ?? 0
        } else {
            windSpeed = 0
            cloudCover = 0
            visibilityKm = 0
        }

        latestCityAQI = airQuality.aqi
        medeuTemperatureC = Int(weather.temperatureCelsius)

        // Update current location with available data
        currentLocation = Location(
            name: gpsLocation != nil ? "Current Location" : "Almaty City Center",
            subtitle: gpsLocation != nil ? "GPS" : "Medeu District",
            altitudeMeters: gpsLocation.map { max(0, Int($0.altitude.rounded())) } ?? 800,
            type: .city,
            region: "Almaty",
            airQuality: airQuality,
            weather: weather,
            isPinned: true,
            lastUpdated: .now
        )

        let shymbulakWeather = fetchedShymbulakWeather.map { apiService.mapToWeatherMetrics(from: $0) } ?? WeatherMetrics(
            temperatureCelsius: 0,
            feelsLikeCelsius: 0,
            windSpeedKmh: 0,
            windDirection: "No Data",
            cloudCoverPercent: 0,
            visibilityKm: 0
        )
        let medeuWeather = fetchedMedeuWeather.map { apiService.mapToWeatherMetrics(from: $0) } ?? WeatherMetrics(
            temperatureCelsius: 0,
            feelsLikeCelsius: 0,
            windSpeedKmh: 0,
            windDirection: "No Data",
            cloudCoverPercent: 0,
            visibilityKm: 0
        )
        let kokZhailauWeather = fetchedKokZhailauWeather.map { apiService.mapToWeatherMetrics(from: $0) } ?? WeatherMetrics(
            temperatureCelsius: 0,
            feelsLikeCelsius: 0,
            windSpeedKmh: 0,
            windDirection: "No Data",
            cloudCoverPercent: 0,
            visibilityKm: 0
        )

        // Update mountains, injecting the Meteosource payload if available
        mountainLocations = MockData.mountainLocations.map { location in
            if location.name == "Medeu" {
                return Location(
                    id: location.id,
                    name: location.name,
                    subtitle: location.subtitle,
                    altitudeMeters: location.altitudeMeters,
                    type: location.type,
                    region: location.region,
                    airQuality: location.airQuality,
                    weather: medeuWeather,
                    isPinned: location.isPinned,
                    lastUpdated: .now
                )
            }
            if location.name == "Shymbulak" {
                return Location(
                    id: location.id,
                    name: location.name,
                    subtitle: location.subtitle,
                    altitudeMeters: location.altitudeMeters,
                    type: location.type,
                    region: location.region,
                    airQuality: location.airQuality,
                    weather: shymbulakWeather,
                    isPinned: location.isPinned,
                    lastUpdated: .now
                )
            }
            if location.name == "Kok Zhailau" {
                return Location(
                    id: location.id,
                    name: location.name,
                    subtitle: location.subtitle,
                    altitudeMeters: location.altitudeMeters,
                    type: location.type,
                    region: location.region,
                    airQuality: location.airQuality,
                    weather: kokZhailauWeather,
                    isPinned: location.isPinned,
                    lastUpdated: .now
                )
            }
            return location
        }
        cityLocations = MockData.cityLocations

        // Generate escape suggestion if city AQI is high
        if airQuality.aqi > 100, let bestMountain = mountainLocations.first {
            escapeSuggestion = EscapeSuggestion(
                headline: "Fresh air at \(bestMountain.name) – AQI \(bestMountain.airQuality.aqi) vs City \(airQuality.aqi)",
                mountainLocation: bestMountain
            )
        } else {
            escapeSuggestion = nil
        }

        // Trigger haptic feedback on successful data fetch
        hapticGenerator.impactOccurred()

        isLoading = false
    }

    // MARK: - Actions

    func refresh() async {
        await loadData()
    }

    func togglePin(location: Location) {
        if let idx = mountainLocations.firstIndex(where: { $0.id == location.id }) {
            mountainLocations[idx].isPinned.toggle()
        } else if let idx = cityLocations.firstIndex(where: { $0.id == location.id }) {
            cityLocations[idx].isPinned.toggle()
        }
    }

    private func updateCurrentLocationWeather(using location: CLLocation) async {
        do {
            let response = try await apiService.fetchMountainWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            let weather = apiService.mapToWeatherMetrics(from: response)
            let altitudeMeters = max(0, Int(location.altitude.rounded()))

            windSpeed = response.current?.wind?.speed ?? 0
            cloudCover = Int((response.current?.cloudCover ?? 0).rounded())
            visibilityKm = response.current?.visibility ?? 0

            currentLocation = Location(
                name: "Current Location",
                subtitle: "GPS",
                altitudeMeters: altitudeMeters,
                type: .city,
                region: currentLocation.region,
                airQuality: currentLocation.airQuality,
                weather: weather,
                isPinned: currentLocation.isPinned,
                lastUpdated: .now
            )
            medeuTemperatureC = Int(weather.temperatureCelsius)
        } catch {
            errorMessage = "Unable to fetch weather for your location."
        }
    }
}
