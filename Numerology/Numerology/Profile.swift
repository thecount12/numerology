//
//  Profile.swift
//  Numerology
//
//  Created by William Gunnells on 10/30/26.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var birthDate: Date
    var isFavorite: Bool
    
    init(name: String, birthDate: Date, isFavorite: Bool = false) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.isFavorite = isFavorite
    }
    
    // Computed property to instantly get the Life Path Number using your modulo-9 math
    var lifePathNumber: Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: birthDate)
        let month = calendar.component(.month, from: birthDate)
        let year = calendar.component(.year, from: birthDate)
        let total = day + month + year
        return (total % 9 == 0) ? 9 : total % 9
    }
    
    /// Birth month + birth day reduced to 1–9 (compatibility core).
    var birthMonthDayRoot: Int {
        NumerologyMath.birthMonthDayRoot(from: birthDate)
    }
    
    // Centralized custom interpretation dictionary mapping numbers 1-9
    var interpretation: String {
        switch lifePathNumber {
        case 1: return "The Leader: Independent, pioneering, and ambitious. You thrive on initiating fresh paths and stepping into individual authority."
        case 2: return "The Diplomat: Sensitive, intuitive, and cooperative. You find power in harmony, relationships, and balancing details behind the scenes."
        case 3: return "The Creative: Expressive, joyful, and communicative. A cycle of artistic vision, social expansion, and sharing your inner voice."
        case 4: return "The Builder: Structured, disciplined, and reliable. Your path focuses on building lasting foundations, hard work, and deep integrity."
        case 5: return "The Adventurer: Versatile, freedom-loving, and dynamic. You are a catalyst for change, thriving on travel, adaptability, and turning points."
        case 6: return "The Nurturer: Responsible, loving, and community-minded. Your vibration centers on domestic harmony, service, and emotional balance."
        case 7: return "The Seeker: Introspective, spiritual, and analytical. You are wired to seek deep inner truths, wisdom, solitude, and universal knowledge."
        case 8: return "The Executive: Manifestation, power, and abundance. A harvest vibration heavily focused on business, material balance, and leadership."
        case 9: return "The Humanitarian: Compassionate, idealistic, and completing a journey. You carry a global vision, focused on healing and letting go."
        default: return "Vibrational anomaly detected."
        }
    }
}
