# Code Snippets - Phase 2 Quick Reference

## 🎯 Core Patterns

### 1. Generic Network Fetch
```swift
// NetworkManager.swift
actor NetworkManager {
    func fetch<T: Decodable>(url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

---

### 2. Parallel API Calls
```swift
// DashboardViewModel.swift
@MainActor
func loadData() async {
    isLoading = true
    
    do {
        // 🚀 Parallel fetching - both run simultaneously
        async let cityAQI = apiService.fetchCityAirQuality()
        async let cityWeather = apiService.fetchCityWeather()
        
        // ⏱️ Await both together (not sequentially)
        let (aqiResponse, weatherResponse) = try await (cityAQI, cityWeather)
        
        // ✅ Process results
        let airQuality = apiService.mapToAirQualityMetrics(from: aqiResponse)
        let weather = apiService.mapToWeatherMetrics(from: weatherResponse)
        
        // 📳 Haptic feedback
        hapticGenerator.impactOccurred()
        
    } catch {
        errorMessage = error.localizedDescription
    }
    
    isLoading = false
}
```

---

### 3. Skeleton Loader Pattern
```swift
// DashboardView.swift
var body: some View {
    ScrollView {
        // Your content here
    }
    .redacted(reason: viewModel.isLoading ? .placeholder : [])
    //                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    //                Shows shimmer effect while loading
}
```

---

### 4. Particle System
```swift
// SmogParticleView.swift
struct SmogParticleView: View {
    let aqi: Int
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            Canvas { context, size in
                let particles = generateParticles(for: size)
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for particle in particles {
                    // Calculate animated position
                    let y = calculateYPosition(particle, time, size.height)
                    
                    // Draw particle
                    context.fill(
                        Circle().path(in: CGRect(x: particle.x, y: y, 
                                                  width: particle.size, 
                                                  height: particle.size)),
                        with: .color(particle.color)
                    )
                }
            }
        }
    }
    
    private func generateParticles(for size: CGSize) -> [Particle] {
        let isHighAQI = aqi > 100
        let count = isHighAQI ? 40 : 25
        
        return (0..<count).map { _ in
            if isHighAQI {
                // Smog particles
                return Particle(
                    size: CGFloat.random(in: 20...50),
                    speed: CGFloat.random(in: 15...30),
                    color: Color(red: 0.45, green: 0.4, blue: 0.35)
                )
            } else {
                // Fresh air particles
                return Particle(
                    size: CGFloat.random(in: 8...20),
                    speed: CGFloat.random(in: 40...80),
                    color: .white
                )
            }
        }
    }
}
```

---

### 5. Haptic Feedback
```swift
// In ViewModel
private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

func loadData() async {
    hapticGenerator.prepare() // ← Prepare before API call
    
    // Fetch data...
    
    hapticGenerator.impactOccurred() // ← Trigger after success
}
```

---

### 6. Error Handling with Fallback
```swift
@MainActor
func loadData() async {
    do {
        // Try real API
        let data = try await apiService.fetchData()
        self.currentLocation = data
        
    } catch let error as NetworkError {
        // Handle network-specific errors
        self.errorMessage = error.localizedDescription
        
        // Fallback to mock data
        self.currentLocation = MockData.almaty
        
    } catch {
        // Handle unexpected errors
        self.errorMessage = "Unexpected error: \(error)"
        self.currentLocation = MockData.almaty
    }
}
```

---

### 7. API Response Mapping
```swift
// APIService.swift
func mapToAirQualityMetrics(from iqair: IQAirResponse) -> AirQualityMetrics {
    let aqi = iqair.data.current.pollution.aqius
    let pm25 = estimatePM25(from: aqi)
    
    return AirQualityMetrics(
        aqi: aqi,
        pm25: pm25,
        pm10: pm25 * 1.2,
        o3: 50.0,
        no2: 30.0
    )
}

func mapToWeatherMetrics(from weather: OpenWeatherResponse) -> WeatherMetrics {
    return WeatherMetrics(
        temperatureCelsius: weather.main.temp,
        feelsLikeCelsius: weather.main.feelsLike,
        windSpeedKmh: weather.wind.speed * 3.6, // m/s → km/h
        windDirection: weather.wind.cardinalDirection,
        cloudCoverPercent: weather.clouds?.all ?? 0,
        visibilityKm: Double(weather.visibility ?? 10000) / 1000.0
    )
}
```

---

### 8. Wind Direction Conversion
```swift
// APIModels.swift
extension OpenWeatherWind {
    var cardinalDirection: String {
        guard let deg = deg else { return "N/A" }
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        let index = Int((Double(deg) + 22.5) / 45.0) % 8
        return directions[index]
    }
}
```

---

### 9. Custom Error Types
```swift
// NetworkError.swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkFailure(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding failed: \(error.localizedDescription)"
        // ... other cases
        }
    }
}
```

---

### 10. Alert with Error
```swift
// DashboardView.swift
.alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
    Button("OK") {
        viewModel.errorMessage = nil
    }
} message: {
    if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
    }
}
```

---

## 🎨 SwiftUI Modifiers

### Redacted (Skeleton Loader)
```swift
.redacted(reason: isLoading ? .placeholder : [])
```

### TimelineView (Animation)
```swift
TimelineView(.animation(minimumInterval: 1/60)) { timeline in
    // 60 FPS animation
}
```

### Canvas (High Performance)
```swift
Canvas { context, size in
    context.fill(path, with: .color(.blue))
}
```

### Task (Async on Appear)
```swift
.task {
    await viewModel.loadData()
}
```

### Refreshable (Pull to Refresh)
```swift
.refreshable {
    await viewModel.refresh()
}
```

---

## 🔧 Swift 6 Patterns

### Actor
```swift
actor NetworkManager {
    // Thread-safe by default
    func fetch() async throws -> Data { }
}
```

### @MainActor
```swift
@MainActor
final class ViewModel {
    var isLoading = false // Always updated on main thread
}
```

### async let (Parallel)
```swift
async let a = fetchA()
async let b = fetchB()
let (resultA, resultB) = try await (a, b)
```

### Sendable (Thread Safety)
```swift
struct Location: Sendable {
    // Safe to pass between actors
}
```

---

## 📱 Usage Examples

### Fetch and Display
```swift
@State private var viewModel = DashboardViewModel()

var body: some View {
    VStack {
        Text("AQI: \(viewModel.currentLocation.airQuality.aqi)")
    }
    .task {
        await viewModel.loadData()
    }
}
```

### With Loading State
```swift
if viewModel.isLoading {
    ProgressView()
} else {
    ContentView(data: viewModel.data)
}
```

### With Error Handling
```swift
if let error = viewModel.errorMessage {
    Text("Error: \(error)")
        .foregroundStyle(.red)
}
```

---

## 🧪 Testing Patterns

### Mock NetworkManager
```swift
actor MockNetworkManager {
    func fetch<T: Decodable>(url: URL) async throws -> T {
        // Return mock data
        return mockResponse as! T
    }
}
```

### Test Parallel Fetching
```swift
func testParallelFetch() async throws {
    let start = Date()
    
    async let a = service.fetchA()
    async let b = service.fetchB()
    let _ = try await (a, b)
    
    let duration = Date().timeIntervalSince(start)
    XCTAssertLessThan(duration, 1.0) // Should be fast
}
```

---

## 🎯 Key Takeaways

1. **Generic `fetch<T>`** → One method for all APIs
2. **`async let`** → Parallel execution
3. **`@MainActor`** → UI safety
4. **`.redacted()`** → Skeleton loaders
5. **`Canvas`** → High-performance rendering
6. **Haptic feedback** → Better UX
7. **Error fallback** → Graceful degradation

---

**Copy & Paste Ready!** 🚀
