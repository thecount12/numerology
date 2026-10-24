//
//  LifePathCalculatorView.swift
//  Numerology
//
//  Created by William Gunnells on 10/21/26.
//

import SwiftUI

struct LifePathCalculatorView: View {
    @State private var name: String = ""
    @State private var birthDate = Date()
    @State private var resultMessage: String? = nil
    
    var body: some View {
        Form {
            Section(header: Text("User Details")) {
                TextField("Full Name", text: $name)
                    .autocorrectionDisabled()
            }
            
            Section(header: Text("Select Birthdate")) {
                DatePicker("Birthdate", selection: $birthDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            
            Button(action: calculateLifePath) {
                Text("Calculate Life Path")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(name.isEmpty)
            
            if let result = resultMessage {
                Section(header: Text("Result Profile")) {
                    Text(result)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Life Path Calculator")
    }
    
    func calculateLifePath() {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: birthDate)
        let month = calendar.component(.month, from: birthDate)
        let year = calendar.component(.year, from: birthDate)
        
        let total = day + month + year
        let remainder = total % 9
        let lifePath = (remainder == 0) ? 9 : remainder
        
        resultMessage = "\(name), your Life Path Number is \(lifePath)"
    }
}
