import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case httpStatus(Int, String?)
    case decoding(Error)
    case network(Error)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .unauthorized:
            return "Not signed in. Sign in again."
        case let .httpStatus(code, message):
            if let message, !message.isEmpty { return "HTTP \(code): \(message)" }
            return "HTTP \(code)"
        case let .decoding(error):
            return "Bad JSON: \(error.localizedDescription)"
        case let .network(error):
            return "Network error: \(error.localizedDescription)"
        case .emptyResponse:
            return "Empty response from server."
        }
    }
}

struct APIErrorBody: Decodable {
    let message: String?
    let error: String?
}

/// URLSession JSON client. Attaches `X-Session-Token` when a session exists.
final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL = AppConfig.productionAPIBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: (any Encodable)? = nil,
        ifMatch: Int? = nil
    ) async throws -> T {
        guard let relativeURL = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        guard var components = URLComponents(url: relativeURL, resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = KeychainTokenStore.shared.sessionToken {
            request.setValue(token, forHTTPHeaderField: "X-Session-Token")
        }
        if let ifMatch {
            request.setValue(String(ifMatch), forHTTPHeaderField: "If-Match")
        }
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.emptyResponse
        }

        if http.statusCode == 401 {
            throw APIError.unauthorized
        }

        guard (200 ... 299).contains(http.statusCode) else {
            let message = (try? decoder.decode(APIErrorBody.self, from: data)).flatMap { $0.message ?? $0.error }
            throw APIError.httpStatus(http.statusCode, message)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func requestVoid(
        _ path: String,
        method: String = "POST",
        body: (any Encodable)? = nil
    ) async throws {
        let _: MessageResponse? = try await requestOptional(path, method: method, body: body)
    }

    private func requestOptional<T: Decodable>(
        _ path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: (any Encodable)? = nil
    ) async throws -> T? {
        guard let relativeURL = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        guard var components = URLComponents(url: relativeURL, resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty { components.queryItems = query }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw APIError.httpStatus((response as? HTTPURLResponse)?.statusCode ?? -1, nil)
        }
        guard !data.isEmpty else { return nil }
        return try decoder.decode(T.self, from: data)
    }
}

/// Type-erased Encodable for generic request bodies.
private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        encodeFunc = value.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
