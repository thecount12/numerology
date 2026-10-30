//
//  Untitled.swift
//  Numerology
//
//  Created by William Gunnells on 10/24/26.
//

import SwiftUI

// 1. Define the custom theme tokens matching your Lux blueprint
enum NumerologyTheme {
    case gold
    case purple
    case blue
    case orange
    case green
    case black
    case red
    case unknown
    
    // 2. Map the calculated digital roots directly to the theme buckets
    static func from(number: Int) -> NumerologyTheme {
        switch number {
        case 1, 4: return .gold
        case 2, 7: return .purple
        case 3:    return .blue
        case 5:    return .orange
        case 6:    return .green
        case 8:    return .black
        case 9:    return .red
        default:   return .unknown
        }
    }
    
    // 3. Hand back native SwiftUI colors instantly for backgrounds or text
    var color: Color {
        switch self {
        case .gold:   return Color(.systemYellow) // High contrast premium gold
        case .purple: return Color(.systemPurple)
        case .blue:   return Color(.systemBlue)
        case .orange: return Color(.systemOrange)
        case .green:  return Color(.systemGreen)
        case .black:  return Color(.black)
        case .red:    return Color(.systemRed)
        case .unknown: return Color(.systemGray)
        }
    }
    
    // Your exact requested polarity shift mapping for the numbers!
    var pulseColor: Color {
        switch self {
        case .gold:   return Color(.systemPurple) // Gold -> Purple
        case .purple: return Color(.systemYellow) // Purple -> Yellow
        case .blue:   return Color(.systemOrange) // Blue -> Orange
        case .orange: return Color(.systemBlue)   // Orange -> Blue
        case .green:  return Color(.systemRed)    // Green -> Red
        case .black:  return Color(.white)        // Black -> White
        case .red:    return Color(.systemGreen)  // Red -> Green
        case .unknown: return Color(.white)
        }
    }
    
    // 4. Hand back matching semantic names for descriptions
    var name: String {
        switch self {
        case .gold:   return "Gold (Vibration of Leadership & Structure)"
        case .purple: return "Purple (Vibration of Intuition & Wisdom)"
        case .blue:   return "Blue (Vibration of Creative Expression)"
        case .orange: return "Orange (Vibration of Freedom & Change)"
        case .green:  return "Green (Vibration of Harmony & Nurturing)"
        case .black:  return "Black (Vibration of Power & Authority)"
        case .red:    return "Red (Vibration of Transformation & Completion)"
        case .unknown: return "Unknown"
        }
    }
}
