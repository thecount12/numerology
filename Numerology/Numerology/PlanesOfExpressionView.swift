//
//  PlanesOfExpressionView.swift
//  Numerology
//
//  Created by William Gunnells on 10/29/26.
//

import SwiftUI

struct PlanesOfExpressionView: View {
    @State private var fullName: String = ""
    @State private var mentalScore = 0
    @State private var physicalScore = 0
    @State private var emotionalScore = 0
    @State private var intuitiveScore = 0
    
    var body: some View {
        Form {
            Section(header: Text("Enter Full Name")) {
                TextField("First, Middle, and Last Name", text: $fullName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .onChange(of: fullName) {
                        calculatePlanes()
                    }
            }
            
            Section(header: Text("Temperament Breakdown Matrices")) {
                PlaneRowView(title: "Mental (Logic)", score: mentalScore, baseColor: .blue, pulseColor: .orange)
                PlaneRowView(title: "Physical (Action)", score: physicalScore, baseColor: .yellow, pulseColor: .purple)
                PlaneRowView(title: "Emotional (Feeling)", score: emotionalScore, baseColor: .red, pulseColor: .green)
                PlaneRowView(title: "Intuitive (Spirit)", score: intuitiveScore, baseColor: .purple, pulseColor: .yellow)
            }
        }
        .navigationTitle("Planes of Expression")
    }
    
    func calculatePlanes() {
        let cleanedName = fullName.lowercased()
        mentalScore = 0; physicalScore = 0; emotionalScore = 0; intuitiveScore = 0
        
        let mentalSet: Set<Character> = ["a", "g", "h", "j", "l", "n", "p", "r", "s", "t", "w"]
        let physicalSet: Set<Character> = ["b", "e", "k", "m", "q", "u", "x", "z"]
        let emotionalSet: Set<Character> = ["c", "f", "i", "k", "o", "r", "v", "x"]
        let intuitiveSet: Set<Character> = ["d", "i", "m", "t", "y"]
        
        for character in cleanedName where character.isLetter {
            if let asciiValue = character.asciiValue {
                let weight = Int(asciiValue) - 96
                let reducedWeight = ((weight - 1) % 9) + 1
                
                if mentalSet.contains(character) { mentalScore += reducedWeight }
                if physicalSet.contains(character) { physicalScore += reducedWeight }
                if emotionalSet.contains(character) { emotionalScore += reducedWeight }
                if intuitiveSet.contains(character) { intuitiveScore += reducedWeight }
            }
        }
        
        mentalScore = mentalScore == 0 ? 0 : ((mentalScore - 1) % 9) + 1
        physicalScore = physicalScore == 0 ? 0 : ((physicalScore - 1) % 9) + 1
        emotionalScore = emotionalScore == 0 ? 0 : ((emotionalScore - 1) % 9) + 1
        intuitiveScore = intuitiveScore == 0 ? 0 : ((intuitiveScore - 1) % 9) + 1
    }
}

struct PlaneRowView: View {
    let title: String
    let score: Int
    let baseColor: Color
    let pulseColor: Color
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text("\(score)")
                .font(.title3.bold())
                .foregroundColor(pulseColor)
                .frame(width: 44, height: 44)
                .background(baseColor.gradient)
                .clipShape(Circle())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PlanesOfExpressionView()
}
