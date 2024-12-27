//
//  UserService.swift
//  Harpie
//
//  Created by Gerardo Gallegos on 12/16/24.
//

import Foundation
import SwiftData

struct UserService {
    private let modelContext: ModelContext
    
    init(context: ModelContext) {
        self.modelContext = context
    }
    
    func fetchUserInfo() -> UserInfo? {
        do {
            let allUserInfo = try modelContext.fetch(FetchDescriptor<UserInfo>())
            print("All UserInfo objects: \(allUserInfo)")
        } catch {
            print("Error fetching UserInfo objects: \(error)")
        }
        
        return try? modelContext.fetch(
            FetchDescriptor<UserInfo>()
        ).first
    }
    
    func saveUserInfo(_ newUserInfo: UserInfo) {
        if let existingUserInfo = fetchUserInfo() {
            // Update existing instance
            existingUserInfo.country = newUserInfo.country
            existingUserInfo.displayName = newUserInfo.displayName
            existingUserInfo.email = newUserInfo.email
            existingUserInfo.href = newUserInfo.href
            existingUserInfo.product = newUserInfo.product
            existingUserInfo.type = newUserInfo.type
            existingUserInfo.uri = newUserInfo.uri
            existingUserInfo.profileImage = newUserInfo.profileImage
        } else {
            // Insert a new instance
            modelContext.insert(newUserInfo)
            print("insert to context")
        }
        
        do {
            try modelContext.save()
            print("USERINFO SAVED")
            print("Fetch after save: \(String(describing: try? modelContext.fetch(FetchDescriptor<UserInfo>())))")
        } catch {
            print("Failed to save UserInfo: \(error)")
        }
    }
    
    func convertUserResponseToUserInfo(_ userResponse: UserResponse) -> UserInfo {
        return UserInfo(
            id: userResponse.id,
            country: userResponse.country,
            displayName: userResponse.displayName,
            email: userResponse.email,
            href: userResponse.href,
            profileImage: userResponse.images.first?.url ?? "",
            product: userResponse.product,
            type: userResponse.type,
            uri: userResponse.uri
        )
    }
    
    func deleteUserInfo() {
        if let userInfo = fetchUserInfo() {
            modelContext.delete(userInfo)
            do {
                try modelContext.save()
            } catch {
                print("Failed to delete UserInfo: \(error)")
            }
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return fetchUserInfo() != nil
    }
}
