//
//  CompatibilityView.swift
//  Numerology
//
//  Created by William Gunnells on 10/24/26.
//


import SwiftUI

struct CompatibilityView: View {
    @State private var yourNumber: String = ""
    @State private var theirNumber: String = ""
    @State private var compatibilityResult: String? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Enter Life Path or Destiny Numbers")) {
                TextField("Your Number (1-9)", text: $yourNumber)
                    .keyboardType(.numberPad)
                TextField("Their Number (1-9)", text: $theirNumber)
                    .keyboardType(.numberPad)
            }
            
            Button(action: checkCompatibility) {
                Text("Check Vibrational Alignment")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(yourNumber.isEmpty || theirNumber.isEmpty)
            
            if let result = compatibilityResult {
                Section(header: Text("Vibrational Report")) {
                    Text(result)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Compatibility Matcher")
    }
    
    func checkCompatibility() {
        guard let num1 = Int(yourNumber), let num2 = Int(theirNumber) else {
            compatibilityResult = "Please enter valid integers between 1 and 9."
            return
        }
        
        // Simple elegant math rule: if they share a digital root layout or match parity
        let total = (num1 + num2) % 9
        
        if num1 == num2 {
            compatibilityResult = "Perfect Resonance (\(num1) & \(num2))! You share the exact same vibrational frequency. Deep mutual understanding."
        } else if total % 2 == 0 {
            compatibilityResult = "Harmonious Flow (\(num1) & \(num2)). Your numbers build a balanced, stable rhythm together. Highly compatible."
        } else {
            compatibilityResult = "Dynamic Growth (\(num1) & \(num2)). This combination creates spark and friction, pushing both individuals to evolve."
        }
    }
}

#Preview {
    CompatibilityView()
}
