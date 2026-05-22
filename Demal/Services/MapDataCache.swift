// Services/MapDataCache.swift
// TazaAua – Actor cache for map routes

import Foundation

actor MapDataCache {
    private var cache: [UUID: MountainRoute] = [:]

    func getRoute(id: UUID) -> MountainRoute? {
        cache[id]
    }

    func saveRoute(_ route: MountainRoute) {
        cache[route.id] = route
    }
}
