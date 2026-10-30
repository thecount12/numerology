//
//  MaturityNumberView.swift
//  Numerology
//
//  Created by William Gunnells on 10/29/26.
//

import SwiftUI

struct MaturityNumberView: View {
    @State private var birthDate = Date()
    @State private var fullName: String = ""
    @State private var calculatedMaturity: Int? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Core Blueprint Inputs")) {
                DatePicker("Birthdate", selection: $birthDate, displayedComponents: .date)
                TextField("Full Legal Name", text: $fullName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
            }
            
            Button(action: calculateMaturityNumber) {
                Text("Synthesize Maturity Number")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(fullName.isEmpty)
            
            if let number = calculatedMaturity {
                let theme = NumerologyTheme.from(number: number)
                
                VStack(spacing: 16) {
                    Text("Maturity Number Horizon")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(number)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(theme.pulseColor) // Polarity matching
                        .frame(width: 140, height: 140)
                        .background(theme.color.gradient)
                        .clipShape(Circle())
                        .shadow(color: theme.color.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    Text(theme.name)
                        .font(.headline)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Maturity Number")
    }
    
    func calculateMaturityNumber() {
        // 1. Calculate Life Path Root
        let calendar = Calendar.current
        let day = calendar.component(.day, from: birthDate)
        let month = calendar.component(.month, from: birthDate)
        let year = calendar.component(.year, from: birthDate)
        let lpTotal = day + month + year
        let lifePath = lpTotal % 9 == 0 ? 9 : lpTotal % 9
        
        // 2. Calculate Destiny Root
        let cleanedName = fullName.lowercased().filter { $0.isLetter }
        var destinyTotal = 0
        for character in cleanedName {
            if let asciiValue = character.asciiValue {
                let weight = Int(asciiValue) - 96
                let reducedWeight = ((weight - 1) % 9) + 1
                destinyTotal += reducedWeight
            }
        }
        let destiny = destinyTotal % 9 == 0 ? 9 : destinyTotal % 9
        
        // 3. Combine into Maturity Root
        let finalSum = lifePath + destiny
        calculatedMaturity = finalSum % 9 == 0 ? 9 : finalSum % 9
    }
}

#Preview {
    MaturityNumberView()
}
