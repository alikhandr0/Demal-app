# Quick Start Guide - Phase 2

## 🚀 Get Started in 3 Steps

### Step 1: Add API Keys
Open `Demal/Services/APIService.swift` and replace:
```swift
private let iqairAPIKey = "YOUR_IQAIR_KEY"
private let openWeatherAPIKey = "YOUR_OPENWEATHER_KEY"
```

### Step 2: Build Project
```bash
open Demal.xcodeproj
# Press ⌘ + B to build
```

### Step 3: Run
```bash
# Press ⌘ + R to run on simulator
```

---

## 📦 What's New in Phase 2

### 1. Real API Integration
- **IQAir API** → Live AQI data for Almaty
- **OpenWeatherMap API** → Real-time weather

### 2. Parallel Fetching
- Both APIs called simultaneously
- 2x faster than sequential calls

### 3. UX Polish
- **Skeleton Loaders** while loading
- **Haptic Feedback** on data refresh
- **Particle System** visualizing air quality
  - High AQI = Brown smog particles (slow)
  - Low AQI = White fresh air particles (fast)

---

## 🎨 Visual Features You'll See

1. **Launch App:**
   - Skeleton placeholders appear
   - Particles start animating
   
2. **Data Loads:**
   - Haptic vibration fires
   - Real AQI/weather appears
   - Particles match air quality

3. **Pull to Refresh:**
   - Swipe down from top
   - New data fetched in parallel
   - Haptic confirms update

---

## 🐛 Troubleshooting

### "Invalid API Key" Error
→ Check keys in `APIService.swift`

### No Data Loading
→ Check internet connection
→ App falls back to mock data automatically

### Particles Not Showing
→ Run on iOS 17+ device/simulator

---

## 📚 Architecture Overview

```
NetworkManager (Generic)
    ↓
APIService (IQAir + OpenWeather)
    ↓
DashboardViewModel (Parallel Fetch + Haptic)
    ↓
DashboardView (UI + Particles)
```

---

## 🔑 Key Files

| File | Purpose |
|------|---------|
| `NetworkManager.swift` | Generic fetch<T> method |
| `APIService.swift` | API endpoints + mapping |
| `DashboardViewModel.swift` | Parallel fetching logic |
| `SmogParticleView.swift` | Particle animation |
| `DashboardView.swift` | Main UI with loaders |

---

## ✅ Features Checklist

- [x] Generic Network Layer
- [x] Swift 6 Concurrency (async/await)
- [x] Parallel API Calls
- [x] Haptic Feedback
- [x] Skeleton Loaders
- [x] Air Quality Particle System
- [x] Error Handling
- [x] Mock Data Fallback

---

**Ready to run!** 🎉

Get your API keys from:
- IQAir: https://www.iqair.com/air-pollution-data-api
- OpenWeather: https://openweathermap.org/api
