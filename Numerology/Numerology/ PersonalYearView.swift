//
//   PersonalYearView.swift
//  Numerology
//
//  Created by William Gunnells on 10/24/26.
//

import SwiftUI

struct PersonalYearView: View {
    @State private var birthMonth: String = ""
    @State private var birthDay: String = ""
    @State private var calculatedYearTheme: String? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Enter Birth Information")) {
                TextField("Birth Month (1-12)", text: $birthMonth)
                    .keyboardType(.numberPad)
                TextField("Birth Day (1-31)", text: $birthDay)
                    .keyboardType(.numberPad)
            }
            
            Section(header: Text("Current Target Horizon")) {
                HStack {
                    Text("Calculating Energy For Year:")
                    Spacer()
                    Text("2026")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: calculatePersonalYear) {
                Text("Reveal Year Vibration")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(birthMonth.isEmpty || birthDay.isEmpty)
            
            if let theme = calculatedYearTheme {
                Section(header: Text("Your 2026 Forecast")) {
                    Text(theme)
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Personal Year Cycles")
    }
    
    func calculatePersonalYear() {
        guard let month = Int(birthMonth), let day = Int(birthDay) else {
            calculatedYearTheme = "Please enter valid numeric values."
            return
        }
        
        let currentYear = 2026
        let totalSum = month + day + currentYear
        
        // Applying your verified modulo-9 shortcut!
        let remainder = totalSum % 9
        let personalYearNumber = (remainder == 0) ? 9 : remainder
        
        // Mapping themes based on standard numerology digital roots
        switch personalYearNumber {
        case 1:
            calculatedYearTheme = "Year 1: New Beginnings! A time for fresh starts, high energy, sowing seeds, and taking decisive independent action."
        case 2:
            calculatedYearTheme = "Year 2: Patience & Cooperation. A slow-paced year focused on partnerships, diplomacy, waiting, and balancing details."
        case 3:
            calculatedYearTheme = "Year 3: Expression & Social Expansion. A highly creative cycle for self-expression, communication, travel, and joy."
        case 4:
            calculatedYearTheme = "Year 4: Build Foundations. A serious discipline cycle centered on hard work, organization, structure, and physical health."
        case 5:
            calculatedYearTheme = "Year 5: Freedom & Turning Points. Expect sudden changes, unpredictability, travel, adventure, and breaking old routines."
        case 6:
            calculatedYearTheme = "Year 6: Responsibility & Home. A domestic cycle emphasizing family, relationships, community service, and emotional healing."
        case 7:
            calculatedYearTheme = "Year 7: Inner Wisdom & Solitude. A highly spiritual year for introspection, studying, resting, and analyzing your life direction."
        case 8:
            calculatedYearTheme = "Year 8: Manifestation & Power. The harvest cycle. Focuses heavily on career advancement, money, business, and material balance."
        case 9:
            calculatedYearTheme = "Year 9: Completion & Cleansing. The end of a 9-year loop. A crucial time for letting go, finishing projects, and decluttering."
        default:
            calculatedYearTheme = "Vibrational anomaly detected."
        }
    }
}

#Preview {
    PersonalYearView()
}
