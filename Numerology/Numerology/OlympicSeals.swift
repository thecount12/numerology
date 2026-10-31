//
//  OlympicSeals.swift
//  Numerology
//
//  Traditional Arbatel Olympic spirit seals from Wikimedia Commons
//  (as shown on https://en.wikipedia.org/wiki/Olympian_spirits — public domain).
//

import SwiftUI

enum OlympicSpirit: String {
    case och, phul, bethor, ophiel, hagith, phaleg, aratron
    
    static func from(root: Int) -> OlympicSpirit {
        switch root {
        case 1, 4: return .och      // Sun
        case 2, 7: return .phul     // Moon
        case 3:    return .bethor   // Jupiter
        case 5:    return .ophiel   // Mercury
        case 6:    return .hagith   // Venus
        case 9:    return .phaleg   // Mars
        case 8:    return .aratron  // Saturn
        default:   return .och
        }
    }
    
    var displayName: String {
        switch self {
        case .aratron: return "Aratron"
        default: return rawValue.capitalized
        }
    }
    
    /// Asset catalog name for the Wikipedia / Commons seal artwork
    var imageName: String {
        switch self {
        case .aratron: return "SealAratron"
        case .bethor:  return "SealBethor"
        case .phaleg:  return "SealPhaleg"
        case .och:     return "SealOch"
        case .hagith:  return "SealHagith"
        case .ophiel:  return "SealOphiel"
        case .phul:    return "SealPhul"
        }
    }
}

/// Renders the traditional Arbatel seal for an Olympic spirit.
struct OlympicSealView: View {
    let spirit: OlympicSpirit
    /// Kept for call-site compatibility; Wikipedia seals use original colors.
    var color: Color = .primary
    var lineWidth: CGFloat = 1.5
    
    var body: some View {
        Image(spirit.imageName)
            .resizable()
            .scaledToFit()
            .accessibilityLabel("Seal of \(spirit.displayName)")
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach([OlympicSpirit.och, .phul, .bethor, .ophiel, .hagith, .phaleg, .aratron], id: \.self) { spirit in
            OlympicSealView(spirit: spirit)
                .frame(width: 64, height: 48)
        }
    }
    .padding()
}
