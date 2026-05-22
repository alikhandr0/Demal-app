// ViewModels/ProfileViewModel.swift
// TazaAua – Profile view model

import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var username: String = "Almaty Explorer"
    var favoriteRoutes: [MountainRoute] = []
    var totalEscapes: Int = 0

    private let storage: StorageManager

    private enum Keys {
        static let username = "profile.username"
        static let favorites = "profile.favorites"
        static let escapes = "profile.escapes"
    }

    init(storage: StorageManager = StorageManager()) {
        self.storage = storage
    }

    func loadProfile() async {
        do {
            username = try await storage.load(key: Keys.username, as: String.self)
        } catch StorageManager.StorageError.fileNotFound {
            username = "Almaty Explorer"
        } catch {
            print("❌ Failed to load username: \(error)")
        }

        do {
            favoriteRoutes = try await storage.load(key: Keys.favorites, as: [MountainRoute].self)
        } catch StorageManager.StorageError.fileNotFound {
            favoriteRoutes = []
        } catch {
            print("❌ Failed to load favorites: \(error)")
        }

        do {
            totalEscapes = try await storage.load(key: Keys.escapes, as: Int.self)
        } catch StorageManager.StorageError.fileNotFound {
            totalEscapes = 0
        } catch {
            print("❌ Failed to load escapes: \(error)")
        }
    }

    func saveFavorite(route: MountainRoute) async {
        guard !favoriteRoutes.contains(where: { $0.id == route.id }) else { return }

        favoriteRoutes.append(route)
        totalEscapes += 1

        do {
            try await storage.save(favoriteRoutes, with: Keys.favorites)
            try await storage.save(totalEscapes, with: Keys.escapes)
        } catch {
            print("❌ Failed to save favorite: \(error)")
        }
    }

    func removeFavorite(route: MountainRoute) async {
        guard let index = favoriteRoutes.firstIndex(where: { $0.id == route.id }) else { return }

        favoriteRoutes.remove(at: index)
        totalEscapes = max(totalEscapes - 1, 0)

        do {
            try await storage.save(favoriteRoutes, with: Keys.favorites)
            try await storage.save(totalEscapes, with: Keys.escapes)
        } catch {
            print("❌ Failed to remove favorite: \(error)")
        }
    }
}
