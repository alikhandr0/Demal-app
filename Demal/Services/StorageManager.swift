// Services/StorageManager.swift
// TazaAua – Thread-safe local storage actor

import Foundation

actor StorageManager {
    enum StorageError: Error {
        case fileNotFound
    }

    private let fileManager: FileManager
    private let documentsDirectory: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
    }

    func save<T: Codable>(_ object: T, with key: String) throws {
        let url = fileURL(for: key)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    func load<T: Codable>(key: String, as type: T.Type) throws -> T {
        let url = fileURL(for: key)
        guard fileManager.fileExists(atPath: url.path) else {
            throw StorageError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func fileURL(for key: String) -> URL {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let sanitized = String(key.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" })
        return documentsDirectory.appendingPathComponent(sanitized).appendingPathExtension("json")
    }
}
