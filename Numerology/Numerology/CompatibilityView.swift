//
//  CompatibilityView.swift
//  Numerology
//
//  Created by William Gunnells on 10/24/26.
//


import SwiftUI
import SwiftData

struct CompatibilityView: View {
    // Stream saved profiles from SwiftData to feed our selector pickers
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    
    // Toggle for selection method
    @State private var sourceMode: SourceMode = .vault
    
    // Vault Mode States
    @State private var selectedProfile1: UserProfile?
    @State private var selectedProfile2: UserProfile?
    
    // Manual Mode States
    @State private var manualNumber1: String = ""
    @State private var manualNumber2: String = ""
    
    @State private var compatibilityResult: String? = nil
    
    enum SourceMode {
        case vault, manual
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Input Method", selection: $sourceMode.animation()) {
                    Text("Saved Profiles").tag(SourceMode.vault)
                    Text("Quick Manual Entry").tag(SourceMode.manual)
                }
                .pickerStyle(.segmented)
            }
            
            switch sourceMode {
            case .vault:
                Section(header: Text("Select Profiles from Vault")) {
                    if savedProfiles.isEmpty {
                        Text("No profiles saved yet. Go to the Saved Vault to add records, or use Quick Manual Entry.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Person 1", selection: $selectedProfile1) {
                            Text("Select Profile").tag(UserProfile?.none)
                            ForEach(savedProfiles) { profile in
                                Text(profile.name).tag(profile as UserProfile?)
                            }
                        }
                        .onChange(of: selectedProfile1) {
                            LastSelectedProfile.remember(selectedProfile1)
                        }
                        
                        Picker("Person 2", selection: $selectedProfile2) {
                            Text("Select Profile").tag(UserProfile?.none)
                            ForEach(savedProfiles) { profile in
                                Text(profile.name).tag(profile as UserProfile?)
                            }
                        }
                    }
                }
            case .manual:
                Section(header: Text("Enter Quick Digits")) {
                    TextField("First Number (1-9)", text: $manualNumber1)
                        .keyboardType(.numberPad)
                    TextField("Second Number (1-9)", text: $manualNumber2)
                        .keyboardType(.numberPad)
                }
            }
            
            Button(action: checkVibrationalAlignment) {
                Text("Analyze Alignment Matrix")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(isCalculationDisabled)
            
            if let result = compatibilityResult {
                Section(header: Text("Vibrational Report")) {
                    Text(result)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Compatibility")
        .onAppear {
            if selectedProfile1 == nil {
                selectedProfile1 = LastSelectedProfile.resolve(from: savedProfiles)
            }
        }
    }
    
    private var isCalculationDisabled: Bool {
        switch sourceMode {
        case .vault:
            return selectedProfile1 == nil || selectedProfile2 == nil
        case .manual:
            return manualNumber1.isEmpty || manualNumber2.isEmpty
        }
    }
    
    func checkVibrationalAlignment() {
        var num1 = 0
        var num2 = 0
        var name1 = "Person 1"
        var name2 = "Person 2"
        
        switch sourceMode {
        case .vault:
            guard let p1 = selectedProfile1, let p2 = selectedProfile2 else { return }
            num1 = p1.lifePathNumber
            num2 = p2.lifePathNumber
            name1 = p1.name
            name2 = p2.name
        case .manual:
            guard let n1 = Int(manualNumber1), let n2 = Int(manualNumber2) else {
                compatibilityResult = "Please enter valid numbers between 1 and 9."
                return
            }
            num1 = n1
            num2 = n2
        }
        
        let dynamicSum = (num1 + num2) % 9
        let resonanceScore = (dynamicSum == 0) ? 9 : dynamicSum
        
        if num1 == num2 {
            compatibilityResult = "Absolute Resonance (\(num1) & \(num2))! \(name1) and \(name2) share the identical structural core frequency. Deep, unspoken soul-level affinity."
        } else if resonanceScore % 2 == 0 {
            compatibilityResult = "Harmonious Currents (\(num1) & \(num2)). The architecture of these numbers weaves a balanced, constructive circuit. High geometric affinity."
        } else {
            compatibilityResult = "Polarized Friction (\(num1) & \(num2)). This specific matrix triggers spark and growth. It challenges both minds to scale and expand perspective."
        }
    }
}


#Preview {
    CompatibilityView()
}
