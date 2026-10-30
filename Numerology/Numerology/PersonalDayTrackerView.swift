//
//  PersonalDayTrackerView.swift
//  Numerology
//
//  Created by William Gunnells on 10/29/26.
//

import SwiftUI

struct PersonalDayTrackerView: View {
    @State private var birthMonth: String = ""
    @State private var birthDay: String = ""
    @State private var dailyVibrationResult: Int? = nil
    
    // Grabs the true current date dynamically from the device environment
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Enter Birth Information")) {
                TextField("Birth Month (1-12)", text: $birthMonth)
                    .keyboardType(.numberPad)
                TextField("Birth Day (1-31)", text: $birthDay)
                    .keyboardType(.numberPad)
            }
            
            Section(header: Text("Current Horizon Metric")) {
                HStack {
                    Text("Today's Target Date:")
                    Spacer()
                    Text(formattedCurrentDate)
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: calculatePersonalDay) {
                Text("Compute Current Day Energy")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(birthMonth.isEmpty || birthDay.isEmpty)
            
            if let number = dailyVibrationResult {
                let theme = NumerologyTheme.from(number: number)
                
                VStack(spacing: 16) {
                    Text("Today's Daily Root Vibration")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(number)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(theme.pulseColor) // Polarity matching target configuration
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
        .navigationTitle("Personal Day Tracker")
    }
    
    func calculatePersonalDay() {
        guard let bMonth = Int(birthMonth), let bDay = Int(birthDay) else { return }
        
        let today = Date()
        let calendar = Calendar.current
        let tYear = calendar.component(.year, from: today)
        let tMonth = calendar.component(.month, from: today)
        let tDay = calendar.component(.day, from: today)
        
        let runningSum = bMonth + bDay + tYear + tMonth + tDay
        let remainder = runningSum % 9
        dailyVibrationResult = (remainder == 0) ? 9 : remainder
    }
}

#Preview {
    PersonalDayTrackerView()
}
