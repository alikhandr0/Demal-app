// Services/NetworkError.swift
// TazaAua – Network Error Handling (Swift 6)

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkFailure(Error)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkFailure(let error):
            return "Network failure: \(error.localizedDescription)"
        case .noData:
            return "No data received from the server."
        }
    }
}
