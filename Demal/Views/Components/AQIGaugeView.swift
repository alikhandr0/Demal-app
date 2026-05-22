// Views/Components/AQIGaugeView.swift
// Circular AQI gauge – pure SwiftUI

import SwiftUI

struct AQIGaugeView: View {
    let aqi: Int
    let category: AQICategory

    private var progress: Double {
        min(Double(aqi) / 300.0, 1.0)
    }

    private var gaugeColor: Color {
        aqiColor(for: aqi)
    }

    private func aqiColor(for value: Int) -> Color {
        switch value {
        case 0...50:
            return Color(red: 0.2, green: 0.8, blue: 0.4)
        case 51...100:
            return Color(red: 1.0, green: 0.75, blue: 0.1)
        case 101...150:
            return Color(red: 1.0, green: 0.55, blue: 0.2)
        default:
            return Color(red: 0.9, green: 0.2, blue: 0.2)
        }
    }

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 14)

            // Value ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [gaugeColor.opacity(0.6), gaugeColor],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.2), value: progress)

            // Center content
            VStack(spacing: 2) {
                Text("AQI")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                Text("\(aqi)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(gaugeColor)
                Text(category.label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(gaugeColor)
                Text("Updated just now")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(width: 200, height: 200)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AQIGaugeView(aqi: 158, category: .unhealthy)
    }
    .environment(ProfileViewModel())
}
