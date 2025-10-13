//
//  JishoAPIService.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import Foundation

class JishoAPIService: ObservableObject {
    static let shared = JishoAPIService()

    private let baseURL = "https://jisho.org/api/v1/search/words"
    private let session = URLSession.shared

    private init() {}

    func searchWords(keyword: String) async throws -> JishoResponse {
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw JishoError.emptyKeyword
        }

        guard
            let encodedKeyword = keyword.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed)
        else {
            throw JishoError.invalidKeyword
        }

        guard let url = URL(string: "\(baseURL)?keyword=\(encodedKeyword)") else {
            throw JishoError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("JishoApp/1.0", forHTTPHeaderField: "User-Agent")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw JishoError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                throw JishoError.serverError(httpResponse.statusCode)
            }

            // Debug: Print raw JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response:")
                print(jsonString)
            }

            let decoder = JSONDecoder()
            do {
                let jishoResponse = try decoder.decode(JishoResponse.self, from: data)
                return jishoResponse
            } catch let decodingError as DecodingError {
                print("Decoding Error Details:")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type \(type)")
                    print("Context: \(context)")
                    print("Coding path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value not found for type \(type)")
                    print("Context: \(context)")
                    print("Coding path: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key)")
                    print("Context: \(context)")
                    print("Coding path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data corrupted")
                    print("Context: \(context)")
                    print("Coding path: \(context.codingPath)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
                throw JishoError.decodingError(decodingError)
            }
        } catch let error as JishoError {
            throw error
        } catch {
            throw JishoError.networkError(error)
        }
    }
}

enum JishoError: LocalizedError {
    case emptyKeyword
    case invalidKeyword
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case networkError(Error)
    case decodingError(DecodingError)

    var errorDescription: String? {
        switch self {
        case .emptyKeyword:
            return "Please enter a search term"
        case .invalidKeyword:
            return "Invalid search term"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to parse server response"
        }
    }
}
