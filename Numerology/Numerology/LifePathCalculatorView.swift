//
//  LifePathCalculatorView.swift
//  Numerology
//
//  Created by William Gunnells on 10/21/26.
//

import SwiftUI
import SwiftData

struct LifePathCalculatorView: View {
    @State private var name: String = ""
    @State private var birthDate = Date()
    @State private var resultMessage: String? = nil
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    @State private var selectedProfile: UserProfile?
    
    var body: some View {
        Form {
            // Drop this block inside your Form view list hierarchy right at the top:
            Section(header: Text("Quick-Fill From Vault")) {
                Picker("Select Profile", selection: $selectedProfile) {
                    Text("Manual Workspace").tag(UserProfile?.none)
                    ForEach(savedProfiles) { profile in
                        Text(profile.name).tag(profile as UserProfile?)
                    }
                }
                .onChange(of: selectedProfile) {
                    LastSelectedProfile.remember(selectedProfile)
                    if let profile = selectedProfile {
                        self.name = profile.name
                        self.birthDate = profile.birthDate
                        calculateLifePath()
                    }
                }
            }

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
        .onAppear {
            if selectedProfile == nil,
               let profile = LastSelectedProfile.resolve(from: savedProfiles) {
                selectedProfile = profile
                name = profile.name
                birthDate = profile.birthDate
                calculateLifePath()
            }
        }
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
