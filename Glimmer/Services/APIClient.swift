import Foundation

// MARK: - API Mode

enum APIMode: String, CaseIterable {
    case mock = "Mock"
    case live = "Live"
}

// MARK: - API Error

enum APIClientError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int, String)
    case notFound
    case conflict(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .notFound:
            return "Resource not found"
        case .conflict(let message):
            return "Conflict: \(message)"
        }
    }
}

// MARK: - API Client Protocol

protocol APIClientProtocol {
    func get<T: Decodable>(_ endpoint: String, queryParams: [String: String]?) async throws -> T
    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B?) async throws -> T
    func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T
    func patch<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T
    func delete(_ endpoint: String) async throws
}

// MARK: - Live API Client

class APIClient: APIClientProtocol {
    static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: String = "https://lumenary-api.onrender.com/api/v1") {
        self.baseURL = baseURL
        self.session = URLSession.shared

        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 formatters first
            let iso8601Formatters: [ISO8601DateFormatter] = {
                let withFractional = ISO8601DateFormatter()
                withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                let standard = ISO8601DateFormatter()
                standard.formatOptions = [.withInternetDateTime]

                return [withFractional, standard]
            }()

            for formatter in iso8601Formatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            // Try DateFormatter for dates without timezone (e.g. "2026-02-09T03:00:29.109670")
            let dateFormatters: [DateFormatter] = {
                let withFractional = DateFormatter()
                withFractional.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                withFractional.timeZone = TimeZone(identifier: "UTC")

                let withMillis = DateFormatter()
                withMillis.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                withMillis.timeZone = TimeZone(identifier: "UTC")

                let standard = DateFormatter()
                standard.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                standard.timeZone = TimeZone(identifier: "UTC")

                return [withFractional, withMillis, standard]
            }()

            for formatter in dateFormatters {
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
        }

        self.encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Public Methods

    func get<T: Decodable>(_ endpoint: String, queryParams: [String: String]? = nil) async throws -> T {
        let url = try buildURL(endpoint: endpoint, queryParams: queryParams)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addHeaders(to: &request)

        return try await perform(request)
    }

    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B?) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addHeaders(to: &request)

        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        return try await perform(request)
    }

    func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        addHeaders(to: &request)
        request.httpBody = try encoder.encode(body)

        return try await perform(request)
    }

    func patch<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        addHeaders(to: &request)
        request.httpBody = try encoder.encode(body)

        return try await perform(request)
    }

    func delete(_ endpoint: String) async throws {
        let url = try buildURL(endpoint: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        addHeaders(to: &request)

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIClientError.serverError(httpResponse.statusCode, "Delete failed")
        }
    }

    // MARK: - Private Methods

    private func buildURL(endpoint: String, queryParams: [String: String]? = nil) throws -> URL {
        var urlString = "\(baseURL)\(endpoint)"

        if let params = queryParams, !params.isEmpty {
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += "?\(queryString)"
        }

        guard let url = URL(string: urlString) else {
            throw APIClientError.invalidURL
        }

        return url
    }

    private func addHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add timezone header
        let timezone = TimeZone.current.identifier
        request.setValue(timezone, forHTTPHeaderField: "X-User-Timezone")
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIClientError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.noData
        }

        // Handle error status codes
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 404:
            throw APIClientError.notFound
        case 409:
            let message = String(data: data, encoding: .utf8) ?? "Conflict"
            throw APIClientError.conflict(message)
        default:
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIClientError.serverError(httpResponse.statusCode, message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIClientError.decodingError(error)
        }
    }
}

// MARK: - Empty Body Helper

struct EmptyBody: Encodable {}
