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
}
