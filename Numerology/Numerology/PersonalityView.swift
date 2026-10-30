//
//  PersonalityView.swift
//  Numerology
//
//  Created by William Gunnells on 10/24/26.
//


import SwiftUI

struct PersonalityView: View {
    @State private var fullName: String = ""
    @State private var calculatedPersonality: Int? = nil
    @State private var extractedConsonants: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Enter Full Name")) {
                TextField("First, Middle, or Last Name", text: $fullName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .onChange(of: fullName) {
                        calculatePersonality()
                    }
            }
            
            // Sub-analysis layout: Shows what consonants your engine found
            if !extractedConsonants.isEmpty {
                Section(header: Text("Extracted Core Consonants")) {
                    Text(extractedConsonants)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .tracking(4) // Spaces letters out beautifully
                }
            }
            
            // The Big Hero Number Result Card
            if let number = calculatedPersonality {
                let theme = NumerologyTheme.from(number: number)
                
                VStack(spacing: 16) {
                    Text("Personality Vibration")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    // The Number is the HERO
                    Text("\(number)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(theme.pulseColor) // flashing colors
                        .frame(width: 140, height: 140)
                        .background(theme.color.gradient) // Colored by your Lux rules!
                        .clipShape(Circle())
                        .shadow(color: theme.color.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    VStack(spacing: 4) {
                        Text(theme.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("External Persona Root")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Personality")
    }
    
    // Core Consonant Isolation Loop
    func calculatePersonality() {
        let cleanedName = fullName.lowercased()
        let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
        
        var totalSum = 0
        var isolatedChars: [String] = []
        
        for character in cleanedName {
            // Ensure it's a standard alphabet letter, but NOT a vowel
            if character.isLetter && !vowels.contains(character) {
                isolatedChars.append(String(character).uppercased())
                
                if let asciiValue = character.asciiValue {
                    let positionInAlphabet = Int(asciiValue) - 96
                    let consonantWeight = ((positionInAlphabet - 1) % 9) + 1
                    totalSum += consonantWeight
                }
            }
        }
        
        extractedConsonants = isolatedChars.joined(separator: " ")
        
        guard totalSum > 0 else {
            calculatedPersonality = nil
            return
        }
        
        // Final reduction to your verified modulo-9 shortcut
        let finalRemainder = totalSum % 9
        calculatedPersonality = (finalRemainder == 0) ? 9 : finalRemainder
    }
}

#Preview {
    PersonalityView()
}
