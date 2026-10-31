//
//   PersonalYearView.swift
//  Numerology
//
//  Created by William Gunnells on 10/24/26.
//

import SwiftUI
import SwiftData

struct PersonalYearView: View {
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    @State private var selectedProfile: UserProfile?
    
    @State private var birthMonth: String = ""
    @State private var birthDay: String = ""
    @State private var calculatedYearNumber: Int? = nil
    @State private var calculatedYearTheme: String? = nil
    
    private let targetYear = 2026
    
    var body: some View {
        Form {
            Section(header: Text("Identity Profile Target")) {
                Picker("Select Profile", selection: $selectedProfile) {
                    Text("Quick Manual Entry").tag(UserProfile?.none)
                    ForEach(savedProfiles) { profile in
                        Text(profile.name).tag(profile as UserProfile?)
                    }
                }
                .onChange(of: selectedProfile) {
                    LastSelectedProfile.remember(selectedProfile)
                    applyProfileSelection()
                }
                
                if savedProfiles.isEmpty {
                    Text("No profiles saved yet. Use Quick Manual Entry, or add records in Saved Vault.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if selectedProfile == nil {
                Section(header: Text("Enter Birth Information")) {
                    TextField("Birth Month (1-12)", text: $birthMonth)
                        .keyboardType(.numberPad)
                    TextField("Birth Day (1-31)", text: $birthDay)
                        .keyboardType(.numberPad)
                }
            } else if let profile = selectedProfile {
                Section(header: Text("Profile Birth Date")) {
                    HStack {
                        Text(profile.name)
                        Spacer()
                        Text(formattedBirthDate(profile.birthDate))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text("Current Target Horizon")) {
                HStack {
                    Text("Calculating Energy For Year:")
                    Spacer()
                    Text("\(targetYear)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            if selectedProfile == nil {
                Button(action: calculatePersonalYear) {
                    Text("Reveal Year Vibration")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(birthMonth.isEmpty || birthDay.isEmpty)
            }
            
            if let number = calculatedYearNumber, let theme = calculatedYearTheme {
                Section(header: Text("Your \(targetYear) Forecast")) {
                    HStack {
                        Spacer()
                        Text("\(number)")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(NumerologyTheme.from(number: number).readableColor)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    Text(theme)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Personal Year Cycles")
        .onAppear {
            if selectedProfile == nil {
                selectedProfile = LastSelectedProfile.resolve(from: savedProfiles)
            }
            applyProfileSelection()
        }
    }
    
    func applyProfileSelection() {
        guard let profile = selectedProfile else {
            calculatedYearNumber = nil
            calculatedYearTheme = nil
            return
        }
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: profile.birthDate)
        let day = calendar.component(.day, from: profile.birthDate)
        birthMonth = "\(month)"
        birthDay = "\(day)"
        calculatePersonalYear()
    }
    
    func formattedBirthDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func calculatePersonalYear() {
        guard let month = Int(birthMonth), let day = Int(birthDay),
              month >= 1, month <= 12, day >= 1, day <= 31 else {
            calculatedYearNumber = nil
            calculatedYearTheme = "Please enter a valid birth month and day."
            return
        }
        
        let totalSum = month + day + targetYear
        
        // Applying your verified modulo-9 shortcut!
        let remainder = totalSum % 9
        let personalYearNumber = (remainder == 0) ? 9 : remainder
        calculatedYearNumber = personalYearNumber
        
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
