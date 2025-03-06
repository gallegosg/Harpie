import Firebase
import FirebaseAppCheck

class YourSimpleAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
      return DeviceCheckProvider(app: app)
  }
}


struct FirebaseService {
    
    // MARK: - Singleton
    static let shared = FirebaseService()
    
    private init() {}
    
    // MARK: - Configure Firebase and App Check
    func configureFirebase() {
        
        #if DEBUG
            // Use Debug Provider for App Check during development
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            print("Using App Check Debug Provider")
        #else
            let providerFactory = YourSimpleAppCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            print("Using default App Check Provider")
        #endif

        // Initialize Firebase
        FirebaseApp.configure()

    }
    
    // MARK: - Validate App Check Token
    func validateAppCheckToken() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            AppCheck.appCheck().token(forcingRefresh: false) { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let token = token else {
                    let error = NSError(domain: "FirebaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token is nil"])
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: token.token)
            }
        }
    }
}
