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
    @State private var extractedVowels: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Enter Full Name")) {
                TextField("First, Middle, or Last Name", text: $fullName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .onChange(of: fullName) {
                        calculateSoulUrge()
                    }
            }
            
            // Sub-analysis layout: Shows what characters your engine is chewing on
            if !extractedVowels.isEmpty {
                Section(header: Text("Extracted Core Vowels")) {
                    Text(extractedVowels)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .tracking(4) // Spaces letters out beautifully
                }
            }
            
            // The Big Hero Number Result Card
            if let number = calculatedUrge {
                let theme = NumerologyTheme.from(number: number)
                
                VStack(spacing: 16) {
                    Text("Soul Urge Vibration")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    // The Number is the HERO
                    Text("\(number)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 140, height: 140)
                        .background(theme.color.gradient) // Colored by your Lux rules!
                        .clipShape(Circle())
                        .shadow(color: theme.color.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    VStack(spacing: 4) {
                        Text(theme.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Internal Heart's Desire Root")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear) // Blends seamlessly into the Form layout
            }
        }
        .navigationTitle("Soul Urge")
    }
    
    // Core Vowel Isolation Loop
    func calculateSoulUrge() {
        let cleanedName = fullName.lowercased()
        let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
        
        var totalSum = 0
        var isolatedChars: [String] = []
        
        for character in cleanedName {
            if vowels.contains(character) {
                isolatedChars.append(String(character).uppercased())
                
                if let asciiValue = character.asciiValue {
                    let positionInAlphabet = Int(asciiValue) - 96
                    let vowelWeight = ((positionInAlphabet - 1) % 9) + 1
                    totalSum += vowelWeight
                }
            }
        }
        
        // Update the display string of extracted vowels
        extractedVowels = isolatedChars.joined(separator: " ")
        
        guard totalSum > 0 else {
            calculatedUrge = nil
            return
        }
        
        // Final reduction to your verified modulo-9 shortcut
        let finalRemainder = totalSum % 9
        calculatedUrge = (finalRemainder == 0) ? 9 : finalRemainder
    }
}

#Preview {
    SoulUrgeView()
}

