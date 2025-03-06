import Foundation

struct APIService {
    static func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        queryParameters: [String: String]? = nil,
        body: Encodable? = nil,
        responseType: T.Type,
        includeResponseString: Bool = false
    ) async throws -> (response: T, responseString: String?) {
        let baseURL = Config.apiUrl
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")
        urlComponents?.queryItems = queryParameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents?.url else { throw APIError.invalidResponse }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let token = try await FirebaseService.shared.validateAppCheckToken()

        guard !token.isEmpty else {
            print("App Check token is empty")
            throw OpenAIError.invalidResponse // TODO: Firebase error
        }

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            let responseString = includeResponseString ? String(data: data, encoding: .utf8) : nil
            
            if (200...299).contains(httpResponse.statusCode) {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return (decodedResponse, responseString)
            } else {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                switch errorResponse.error.source {
                case "spotify":
                    let code: SpotifyErrorCode
                    switch errorResponse.error.code {
                    case "invalid_grant": code = .invalidGrant
                    case "invalid_client": code = .invalidClient
                    case "rate_limit_exceeded": code = .rateLimitExceeded
                    case "invalid_token": code = .invalidToken
                    case "user_error": code = .userError
                    case "failed_create_playlist": code = .failedCreatePlaylist
                    default: code = .custom(errorResponse.error.message)
                    }
                    throw APIError.spotify(code)
                case "openai":
                    let code: OpenAIErrorCode
                    switch errorResponse.error.code {
                    case "invalid_response": code = .invalidResponse
                    case "rate_limit": code = .rateLimit
                    case "invalid_json": code = .invalidJson
                    default: code = .custom(errorResponse.error.message)
                    }
                    throw APIError.openAI(code)
                default:
                    throw APIError.node(errorResponse.error.message)
                }
            }
        } catch let error as APIError {
            print("GONNA LOG IN FIREBASE")
            await ErrorLogger.logAPIError(
                error,
                userId: "n/a",
                context: ["endpoint": endpoint],
                file: "APISERVICE.SWIFT",
                line: 81
            )
            throw error
        } catch let error as DecodingError {
            print(error)
            let error = APIError.decodingError(error)
            await ErrorLogger.logAPIError(
                error,
                userId: "n/a",
                context: ["endpoint": endpoint]
            )
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// Error response structure from Node API
struct ErrorResponse: Decodable {
    let error: ErrorDetails
}

struct ErrorDetails: Decodable {
    let source: String
    let code: String
    let message: String
}
