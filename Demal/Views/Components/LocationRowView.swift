// Views/Components/LocationRowView.swift
// Single row in the Locations list

import SwiftUI

struct LocationRowView: View {
    let location: Location
    var onPin: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    var showActions: Bool = false

    private var aqiColor: Color {
        switch location.airQuality.category {
        case .good:      return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .moderate:  return Color(red: 1.0, green: 0.75, blue: 0.1)
        case .unhealthy: return Color(red: 1.0, green: 0.35, blue: 0.2)
        case .hazardous: return Color(red: 0.7, green: 0.1, blue: 0.1)
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // AQI dot indicator
            Circle()
                .fill(aqiColor)
                .frame(width: 10, height: 10)
                .shadow(color: aqiColor.opacity(0.8), radius: 4)

            // Name & subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text(location.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if showActions {
                // Pin button
                Button(action: { onPin?() }) {
                    Text("Pin")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(red: 1.0, green: 0.55, blue: 0.1))
                        )
                }
                .buttonStyle(.plain)

                // Share button
                Button(action: { onShare?() }) {
                    Text("Share")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(red: 0.2, green: 0.5, blue: 0.95))
                        )
                }
                .buttonStyle(.plain)
            } else {
                // AQI value
                HStack(spacing: 4) {
                    Text("\(location.airQuality.aqi)")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(aqiColor)
                    Text("AQI")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }
}

#Preview {
    ZStack {
        Color(red: 0.1, green: 0.1, blue: 0.12).ignoresSafeArea()
        VStack {
            LocationRowView(location: MockData.orbita)
            LocationRowView(location: MockData.shymbulak, showActions: true)
        }
        .padding()
    }
    .environment(ProfileViewModel())
}
