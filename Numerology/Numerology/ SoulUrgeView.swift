//
//  SoulUrge.swift
//  Numerology
//
//  Created by William Gunnells on 10/24/26.
//

import SwiftUI

struct SoulUrgeView: View {
    @State private var fullName: String = ""
    @State private var calculatedUrge: Int? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Enter Full Name")) {
                TextField("First, Middle, or Last Name", text: $fullName)
                    .autocorrectionDisabled()
                    .onChange(of: fullName) {
                        calculateSoulUrge()
                    }
            }
            
            if let urge = calculatedUrge {
                Section(header: Text("Soul Urge Vibration (Vowels Only)")) {
                    HStack {
                        Text("Internal Heart's Desire:")
                        Spacer()
                        Text("\(urge)")
                            .font(.title2.bold())
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .navigationTitle("Soul Urge Analyzer")
    }
    
    func calculateSoulUrge() {
        let cleanedName = fullName.lowercased()
        let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
        
        var totalSum = 0
        
        // Loop strictly pulling your alphabet weights only if they are vowels
        for character in cleanedName {
            if vowels.contains(character) {
                if let asciiValue = character.asciiValue {
                    let positionInAlphabet = Int(asciiValue) - 96
                    let vowelWeight = ((positionInAlphabet - 1) % 9) + 1
                    totalSum += vowelWeight
                }
            }
        }
        
        let finalRemainder = totalSum % 9
        calculatedUrge = (finalRemainder == 0 && totalSum > 0) ? 9 : finalRemainder
    }
}

#Preview {
    SoulUrgeView()
}
