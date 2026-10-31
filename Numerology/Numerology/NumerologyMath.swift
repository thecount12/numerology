//
//  NumerologyMath.swift
//  Numerology
//
//  Shared digital-root helpers used across calculators.
//

import Foundation

enum NumerologyMath {
    /// Classic modulo-9 digital root (9 stays 9; 0 only if sum is 0).
    static func digitalRoot(_ sum: Int) -> Int {
        guard sum > 0 else { return 0 }
        let remainder = sum % 9
        return remainder == 0 ? 9 : remainder
    }
    
    /// Personal Day: birth month + birth day + today's full date, reduced.
    static func personalDay(birthMonth: Int, birthDay: Int, on date: Date = Date()) -> Int {
        let calendar = Calendar.current
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        return digitalRoot(birthMonth + birthDay + y + m + d)
    }
    
    /// Personal Year: birth month + birth day + target calendar year, reduced.
    static func personalYear(birthMonth: Int, birthDay: Int, year: Int) -> Int {
        digitalRoot(birthMonth + birthDay + year)
    }
    
    static func personalYear(birthMonth: Int, birthDay: Int, on date: Date = Date()) -> Int {
        let year = Calendar.current.component(.year, from: date)
        return personalYear(birthMonth: birthMonth, birthDay: birthDay, year: year)
    }
    
    static func birthMonthDay(from birthDate: Date) -> (month: Int, day: Int) {
        let calendar = Calendar.current
        return (
            calendar.component(.month, from: birthDate),
            calendar.component(.day, from: birthDate)
        )
    }
    
    /// Compatibility / birthday root: birth month + birth day, reduced to 1–9.
    static func birthMonthDayRoot(month: Int, day: Int) -> Int {
        digitalRoot(month + day)
    }
    
    static func birthMonthDayRoot(from birthDate: Date) -> Int {
        let parts = birthMonthDay(from: birthDate)
        return birthMonthDayRoot(month: parts.month, day: parts.day)
    }
    
    /// Western numerology text root: letters A=1…I=9…Z=8 plus digits, reduced to 1–9.
    static func textRoot(_ text: String) -> Int? {
        let cleaned = text.lowercased().filter { $0.isLetter || $0.isNumber }
        guard !cleaned.isEmpty else { return nil }
        
        var totalSum = 0
        for character in cleaned {
            if let numberValue = character.wholeNumberValue {
                totalSum += numberValue
            } else if let asciiValue = character.asciiValue {
                let positionInAlphabet = Int(asciiValue) - 96 // 'a' == 97
                let letterValue = ((positionInAlphabet - 1) % 9) + 1
                totalSum += letterValue
            }
        }
        
        return digitalRoot(totalSum)
    }
}
