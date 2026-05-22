// Views/MapView.swift
// TazaAua – Interactive AQI Map (iOS 17 MapKit)

import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel = MapViewModel(cache: MapDataCache())
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.1577, longitude: 77.0593),
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        )
    )
    @State private var route: MKRoute? = nil

    var body: some View {
        Map(position: $cameraPosition) {
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            ForEach(viewModel.routes) { route in
                Annotation(route.name, coordinate: route.coordinate) {
                    routeAnnotation(route)
                        .onTapGesture {
                            Task { await buildRoute(to: route.coordinate) }
                        }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .ignoresSafeArea(edges: .top)
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.large)
    }

    private func buildRoute(to destination: CLLocationCoordinate2D) async {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        let response = try? await directions.calculate()
        route = response?.routes.first
    }

    private func routeAnnotation(_ route: MountainRoute) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(aqiColor(route.aqi))
                .frame(width: 8, height: 8)
            Text(route.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    private func aqiColor(_ aqi: Int) -> Color {
        switch aqi {
        case 0...50:
            return Color(red: 0.2, green: 0.8, blue: 0.4)
        case 51...100:
            return Color(red: 1.0, green: 0.75, blue: 0.1)
        case 101...150:
            return Color(red: 1.0, green: 0.45, blue: 0.2)
        default:
            return Color(red: 0.7, green: 0.1, blue: 0.1)
        }
    }
}

#Preview {
    NavigationStack {
        MapView()
    }
    .environment(ProfileViewModel())
}
