// Services/NetworkManager.swift
// TazaAua – Generic Network Manager (Swift 6 Concurrency)

import Foundation

/// A generic, strictly-typed network manager using Swift 6 async/await patterns.
actor NetworkManager {
    
    // MARK: - Properties
    
    private let session: URLSession
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Generic Fetch Method
    
    /// Fetches and decodes data from the given URL.
    /// - Parameter url: The URL to fetch from.
    /// - Parameter headers: Optional HTTP headers to attach to the request.
    /// - Returns: A decoded object of type T.
    /// - Throws: NetworkError if the request fails.
    func fetch<T: Decodable>(url: URL, headers: [String: String] = [:]) async throws -> T {
        var request = URLRequest(url: url)
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Perform the network request
        let (data, response) = try await session.data(for: request)
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Check status code (200...299 is success)
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Ensure data is present
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        // Decode the JSON
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("⚠️ RAW JSON RESPONSE: \(rawJSON)")
            }
            print("⚠️ DECODING ERROR: \(error)")
            throw error
        }
    }
}
