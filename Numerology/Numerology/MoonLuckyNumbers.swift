//
//  MoonLuckyNumbers.swift
//  Numerology
//
//  Moon-phase lucky numbers blended with Personal Day + Life Path.
//  Fully offline and deterministic for a given date + profile.
//

import Foundation

struct MoonPhaseInfo {
    /// 0...1 through the synodic cycle (0 ≈ new moon)
    let cyclePosition: Double
    /// Approximate illuminated fraction 0...1
    let illumination: Double
    let name: String
    let symbol: String
    /// Phase band index 0...7 (new → waxing crescent → ... → waning crescent)
    let bandIndex: Int
    /// Numerology root associated with this phase band (1...9)
    let phaseRoot: Int
}

struct MoonLuckyResult {
    let phase: MoonPhaseInfo
    /// Primary set shown to the user (usually 3 numbers)
    let numbers: [Int]
    let phaseNumber: Int
    let personalDay: Int
    let lifePath: Int
    let wildCard: Int
    let guidance: String
}

enum MoonLuckyNumbers {
    
    /// Mean synodic month in days
    private static let synodicMonth = 29.530588853
    /// Reference new moon: 2000-01-06 18:14 UTC (astronomical approx.)
    private static let referenceNewMoon = Date(timeIntervalSince1970: 947_182_440)
    
    // MARK: - Phase
    
    static func phase(on date: Date = Date()) -> MoonPhaseInfo {
        let days = date.timeIntervalSince(referenceNewMoon) / 86_400
        var position = days / synodicMonth
        position -= floor(position) // 0...1
        if position < 0 { position += 1 }
        
        let illumination = (1 - cos(position * 2 * .pi)) / 2
        
        let band = min(7, Int(position * 8))
        let (name, symbol, root) = bandMetadata(band)
        
        return MoonPhaseInfo(
            cyclePosition: position,
            illumination: illumination,
            name: name,
            symbol: symbol,
            bandIndex: band,
            phaseRoot: root
        )
    }
    
    /// Phase → numerology root (aligned with your lunar/martial map where useful)
    private static func bandMetadata(_ band: Int) -> (String, String, Int) {
        switch band {
        case 0: return ("New Moon", "🌑", 1)           // beginnings
        case 1: return ("Waxing Crescent", "🌒", 3)  // expression rising
        case 2: return ("First Quarter", "🌓", 5)    // action / turning
        case 3: return ("Waxing Gibbous", "🌔", 6)   // refinement / care
        case 4: return ("Full Moon", "🌕", 9)        // culmination → Mars/9 in your map
        case 5: return ("Waning Gibbous", "🌖", 8)   // harvest / distribute
        case 6: return ("Last Quarter", "🌗", 4)     // structure / release work
        default: return ("Waning Crescent", "🌘", 7) // seeker moon / inner tide
        }
    }
    
    // MARK: - Lucky set
    
    static func generate(
        personalDay: Int,
        lifePath: Int,
        on date: Date = Date()
    ) -> MoonLuckyResult {
        let phase = phase(on: date)
        let phaseNumber = phase.phaseRoot
        
        // Deterministic wild card from date + cores (1...9), prefer unused values
        let wildCard = wildCardNumber(
            phaseRoot: phaseNumber,
            personalDay: personalDay,
            lifePath: lifePath,
            on: date
        )
        
        // Stable ordered unique set: Moon phase → Personal Day → Life Path → wild if needed
        var ordered: [Int] = []
        for n in [phaseNumber, personalDay, lifePath, wildCard] {
            if !ordered.contains(n) {
                ordered.append(n)
            }
        }
        // Ensure at least 3 slots when possible by walking the wheel
        var cursor = NumerologyMath.digitalRoot(phaseNumber + personalDay + lifePath)
        while ordered.count < 3 {
            if cursor == 0 { cursor = 1 }
            if !ordered.contains(cursor) {
                ordered.append(cursor)
            }
            cursor = NumerologyMath.digitalRoot(cursor + 1)
            if cursor == 0 { break }
        }
        
        let numbers = Array(ordered.prefix(3))
        let guidance = guidanceText(phase: phase, personalDay: personalDay, lifePath: lifePath)
        
        return MoonLuckyResult(
            phase: phase,
            numbers: numbers,
            phaseNumber: phaseNumber,
            personalDay: personalDay,
            lifePath: lifePath,
            wildCard: wildCard,
            guidance: guidance
        )
    }
    
    private static func wildCardNumber(
        phaseRoot: Int,
        personalDay: Int,
        lifePath: Int,
        on date: Date
    ) -> Int {
        let calendar = Calendar.current
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        let stamp = y * 10_000 + m * 100 + d
        let raw = stamp + phaseRoot * 17 + personalDay * 13 + lifePath * 11
        return NumerologyMath.digitalRoot(raw)
    }
    
    private static func guidanceText(phase: MoonPhaseInfo, personalDay: Int, lifePath: Int) -> String {
        let moonNote: String
        switch phase.bandIndex {
        case 0:
            moonNote = "New Moon favors planting intentions and quiet first moves."
        case 1, 2, 3:
            moonNote = "Waxing light favors building, visibility, and forward momentum."
        case 4:
            moonNote = "Full Moon favors culmination, courage, and clear outcomes (Mars/9 current in this system)."
        default:
            moonNote = "Waning light favors release, review, and inner lunar work (2/7 Moon current)."
        }
        
        if personalDay == 2 || personalDay == 7 {
            return "\(moonNote) Your Personal Day \(personalDay) is already a Moon number—lunar luck is amplified today."
        }
        if lifePath == 2 || lifePath == 7 {
            return "\(moonNote) Life Path \(lifePath) is lunar-native, so these numbers lean toward intuition and timing."
        }
        return "\(moonNote) Blend the Moon root with your Personal Day \(personalDay) and Life Path \(lifePath) for today’s set."
    }
}
