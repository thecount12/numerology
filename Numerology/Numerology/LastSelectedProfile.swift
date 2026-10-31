//
//  LastSelectedProfile.swift
//  Numerology
//
//  Remembers the last profile chosen in any tool picker.
//

import Foundation

enum LastSelectedProfile {
    private static let key = "lastSelectedProfileID"
    
    static var id: UUID? {
        get {
            guard let raw = UserDefaults.standard.string(forKey: key) else { return nil }
            return UUID(uuidString: raw)
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue.uuidString, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    static func resolve(from profiles: [UserProfile]) -> UserProfile? {
        guard let id else { return nil }
        return profiles.first { $0.id == id }
    }
    
    static func remember(_ profile: UserProfile?) {
        // Only persist an actual selection — switching to Manual Entry should not erase memory
        if let profile {
            id = profile.id
        }
    }
}
