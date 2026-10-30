//
//  DestinyExpressionView.swift
//  Numerology
//
//  Created by William Gunnells on 10/29/26.
//

import SwiftUI

struct DestinyExpressionView: View {
    @State private var fullName: String = ""
    @State private var calculatedDestiny: Int? = nil
    @State private var breakdownMessage: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Enter Full Name")) {
                TextField("First, Middle, and Last Name", text: $fullName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .onChange(of: fullName) {
                        calculateDestinyNumber()
                    }
            }
            
            if !breakdownMessage.isEmpty {
                Section(header: Text("Vibrational Synthesis Breakdown")) {
                    Text(breakdownMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if let number = calculatedDestiny {
                let theme = NumerologyTheme.from(number: number)
                
                VStack(spacing: 16) {
                    Text("Destiny / Expression Root")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(number)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(theme.pulseColor) // Your custom polarity shift!
                        .frame(width: 140, height: 140)
                        .background(theme.color.gradient)
                        .clipShape(Circle())
                        .shadow(color: theme.color.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    VStack(spacing: 4) {
                        Text(theme.name)
                            .font(.headline)
                        Text("Full Expression Blueprint")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Destiny Number")
    }
    
    func calculateDestinyNumber() {
        let cleanedName = fullName.lowercased().filter { $0.isLetter }
        guard !cleanedName.isEmpty else {
            calculatedDestiny = nil
            breakdownMessage = ""
            return
        }
        
        let vowelsSet: Set<Character> = ["a", "e", "i", "o", "u"]
        var vowelSum = 0
        var consonantSum = 0
        
        for character in cleanedName {
            if let asciiValue = character.asciiValue {
                let weight = Int(asciiValue) - 96
                let reducedWeight = ((weight - 1) % 9) + 1
                
                if vowelsSet.contains(character) {
                    vowelSum += reducedWeight
                } else {
                    consonantSum += reducedWeight
                }
            }
        }
        
        let reducedVowels = vowelSum == 0 ? 0 : ((vowelSum - 1) % 9) + 1
        let reducedConsonants = consonantSum == 0 ? 0 : ((consonantSum - 1) % 9) + 1
        
        let totalSum = reducedVowels + reducedConsonants
        let finalDestiny = totalSum == 0 ? 0 : ((totalSum - 1) % 9) + 1
        
        breakdownMessage = "Vowels Layer: \(reducedVowels) | Consonants Layer: \(reducedConsonants)"
        calculatedDestiny = finalDestiny > 0 ? finalDestiny : nil
    }
}

#Preview {
    DestinyExpressionView()
}
