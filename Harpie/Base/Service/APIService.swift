import Foundation

struct APIService {
    private static let baseURL = Config.apiUrl // Shared base URL
    
    static func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        queryParameters: [String: String]? = nil,
        body: Encodable? = nil,
        responseType: T.Type
    ) async throws -> T {
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        let token = try await FirebaseService.shared.validateAppCheckToken()
        guard !token.isEmpty else {
            print("App Check token is empty")
            throw OpenAIError.invalidResponse // TODO: Firebase-specific error
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(T.self, from: data)
        } else {
            if let apiError = try? JSONDecoder().decode(NodeAPIError.self, from: data) {
                throw OpenAIError.apiError(apiError.error)
            } else {
                throw OpenAIError.apiError("Unknown error")
            }
        }
    }
}
