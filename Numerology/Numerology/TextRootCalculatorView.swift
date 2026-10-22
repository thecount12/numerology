//
//  TextRootCalculatorView.swift
//  Numerology
//
//  Created by William Gunnells on 10/21/26.
//

import SwiftUI

struct TextRootCalculatorView: View {
    @State private var textInput: String = ""
    @State private var calculatedRoot: Int? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Input Text")) {
                TextField("Enter Name, Street, or Phrase", text: $textInput)
                    .autocorrectionDisabled()
                    .onChange(of: textInput) {
                        calculateTextRoot()
                    }
            }
            
            if let root = calculatedRoot {
                Section(header: Text("Vibrational Digital Root")) {
                    HStack {
                        Text("Total Energy Value:")
                        Spacer()
                        Text("\(root)")
                            .font(.title2.bold())
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .navigationTitle("Text Root Analyzer")
    }
    
    // Core String Mapping Loop using your Modulo-9 Shortcut
    func calculateTextRoot() {
        let cleanedString = textInput.lowercased().filter { $0.isLetter || $0.isNumber }
        
        guard !cleanedString.isEmpty else {
            calculatedRoot = nil
            return
        }
        
        var totalSum = 0
        
        for character in cleanedString {
            if let numberValue = character.wholeNumberValue {
                // If it's a structural digit (like a house street number), add it directly
                totalSum += numberValue
            } else {
                // Standard Western Numerology Alphabet Map (A=1, B=2 ... I=9, J=1 ... Z=8)
                if let asciiValue = character.asciiValue {
                    let positionInAlphabet = Int(asciiValue) - 96 // 'a' is ASCII 97
                    let letterValue = ((positionInAlphabet - 1) % 9) + 1
                    totalSum += letterValue
                }
            }
        }
        
        // Final reduction to a single digital root
        let finalRemainder = totalSum % 9
        calculatedRoot = (finalRemainder == 0 && totalSum > 0) ? 9 : finalRemainder
    }
}
