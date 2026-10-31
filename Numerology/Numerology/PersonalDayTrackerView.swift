//
//  PersonalDayTrackerView.swift
//  Numerology
//
//  Created by William Gunnells on 10/29/26.
//

import SwiftUI
import SwiftData

struct PersonalDayTrackerView: View {
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    @State private var selectedProfile: UserProfile?
    
    @State private var manualMonth: String = ""
    @State private var manualDay: String = ""
    @State private var dailyVibrationResult: Int? = nil
    
    private var formattedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Target Identity Source")) {
                Picker("Track Energy For", selection: $selectedProfile) {
                    Text("Quick Manual Entry").tag(UserProfile?.none)
                    ForEach(savedProfiles) { profile in
                        Text(profile.name).tag(profile as UserProfile?)
                    }
                }
                .onChange(of: selectedProfile) {
                    LastSelectedProfile.remember(selectedProfile)
                    executeAutoCalculations()
                }
            }
            
            if selectedProfile == nil {
                Section(header: Text("Manual Birth Data Matrix")) {
                    TextField("Birth Month (1-12)", text: $manualMonth)
                        .keyboardType(.numberPad)
                    TextField("Birth Day (1-31)", text: $manualDay)
                        .keyboardType(.numberPad)
                }
                
                Button(action: calculateManualDay) {
                    Text("Compute Matrix Engine")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(manualMonth.isEmpty || manualDay.isEmpty)
            }
            
            if let number = dailyVibrationResult {
                let theme = NumerologyTheme.from(number: number)
                
                VStack(spacing: 16) {
                    Text("Dynamic Horizon Wave Value")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(number)")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundColor(theme.pulseColor)
                        .frame(width: 140, height: 140)
                        .background(theme.color.gradient)
                        .clipShape(Circle())
                        .shadow(color: theme.color.opacity(0.4), radius: 12, x: 0, y: 6)
                    
                    Text(theme.name)
                        .font(.headline)
                    
                    Text("Calculated for today: \(formattedCurrentDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Daily Tracker")
        .onAppear {
            if selectedProfile == nil {
                selectedProfile = LastSelectedProfile.resolve(from: savedProfiles)
            }
            executeAutoCalculations()
        }
    }
    
    func executeAutoCalculations() {
        if let profile = selectedProfile {
            let calendar = Calendar.current
            let bMonth = calendar.component(.month, from: profile.birthDate)
            let bDay = calendar.component(.day, from: profile.birthDate)
            computeRootValue(month: bMonth, day: bDay)
        } else {
            dailyVibrationResult = nil
        }
    }
    
    func calculateManualDay() {
        guard let m = Int(manualMonth), let d = Int(manualDay) else { return }
        computeRootValue(month: m, day: d)
    }
    
    func computeRootValue(month: Int, day: Int) {
        dailyVibrationResult = NumerologyMath.personalDay(birthMonth: month, birthDay: day)
    }
}


#Preview {
    PersonalDayTrackerView()
}
