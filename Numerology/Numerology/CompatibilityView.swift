//
//  CompatibilityView.swift
//  Numerology
//
//  Created by William Gunnells on 10/24/26.
//

import SwiftUI
import SwiftData

struct CompatibilityView: View {
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    
    @State private var sourceMode: SourceMode = .vault
    
    @State private var selectedProfile1: UserProfile?
    @State private var selectedProfile2: UserProfile?
    
    // Manual: birth month + day for each person
    @State private var manualMonth1: String = ""
    @State private var manualDay1: String = ""
    @State private var manualMonth2: String = ""
    @State private var manualDay2: String = ""
    
    @State private var compatibilityResult: String? = nil
    @State private var root1: Int? = nil
    @State private var root2: Int? = nil
    
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
            
            Section {
                Text("Compatibility uses each person’s birth month + birth day root (not full Life Path).")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                                Text("\(profile.name) · root \(profile.birthMonthDayRoot)")
                                    .tag(profile as UserProfile?)
                            }
                        }
                        .onChange(of: selectedProfile1) {
                            LastSelectedProfile.remember(selectedProfile1)
                        }
                        
                        Picker("Person 2", selection: $selectedProfile2) {
                            Text("Select Profile").tag(UserProfile?.none)
                            ForEach(savedProfiles) { profile in
                                Text("\(profile.name) · root \(profile.birthMonthDayRoot)")
                                    .tag(profile as UserProfile?)
                            }
                        }
                    }
                }
            case .manual:
                Section(header: Text("Person 1 — Birth Month & Day")) {
                    TextField("Month (1-12)", text: $manualMonth1)
                        .keyboardType(.numberPad)
                    TextField("Day (1-31)", text: $manualDay1)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Person 2 — Birth Month & Day")) {
                    TextField("Month (1-12)", text: $manualMonth2)
                        .keyboardType(.numberPad)
                    TextField("Day (1-31)", text: $manualDay2)
                        .keyboardType(.numberPad)
                }
            }
            
            Button(action: checkVibrationalAlignment) {
                Text("Analyze Alignment Matrix")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .disabled(isCalculationDisabled)
            
            if let r1 = root1, let r2 = root2, let result = compatibilityResult {
                Section(header: Text("Birthday Roots")) {
                    HStack {
                        rootChip(r1, label: "Person 1")
                        Spacer()
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundColor(.secondary)
                        Spacer()
                        rootChip(r2, label: "Person 2")
                    }
                    .padding(.vertical, 4)
                }
                
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
    
    @ViewBuilder
    private func rootChip(_ number: Int, label: String) -> some View {
        let theme = NumerologyTheme.from(number: number)
        VStack(spacing: 6) {
            Text("\(number)")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(theme.pulseColor)
                .frame(width: 56, height: 56)
                .background(theme.color.gradient)
                .clipShape(Circle())
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var isCalculationDisabled: Bool {
        switch sourceMode {
        case .vault:
            return selectedProfile1 == nil || selectedProfile2 == nil
        case .manual:
            return manualMonth1.isEmpty || manualDay1.isEmpty
                || manualMonth2.isEmpty || manualDay2.isEmpty
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
            num1 = p1.birthMonthDayRoot
            num2 = p2.birthMonthDayRoot
            name1 = p1.name
            name2 = p2.name
        case .manual:
            guard let m1 = Int(manualMonth1), let d1 = Int(manualDay1),
                  let m2 = Int(manualMonth2), let d2 = Int(manualDay2),
                  (1...12).contains(m1), (1...31).contains(d1),
                  (1...12).contains(m2), (1...31).contains(d2) else {
                compatibilityResult = "Please enter valid birth months (1–12) and days (1–31)."
                root1 = nil
                root2 = nil
                return
            }
            num1 = NumerologyMath.birthMonthDayRoot(month: m1, day: d1)
            num2 = NumerologyMath.birthMonthDayRoot(month: m2, day: d2)
        }
        
        root1 = num1
        root2 = num2
        
        let resonanceScore = NumerologyMath.digitalRoot(num1 + num2)
        
        if num1 == num2 {
            compatibilityResult = "Absolute Resonance (\(num1) & \(num2))! \(name1) and \(name2) share the same birth month+day root. Deep calendar affinity and unspoken rhythm."
        } else if resonanceScore % 2 == 0 {
            compatibilityResult = "Harmonious Currents (\(num1) & \(num2)). \(name1)’s and \(name2)’s birthday roots weave a balanced circuit (combined root \(resonanceScore)). High constructive affinity."
        } else {
            compatibilityResult = "Polarized Friction (\(num1) & \(num2)). \(name1) and \(name2) spark growth through contrast (combined root \(resonanceScore)). Challenge that expands both perspectives."
        }
    }
}

#Preview {
    CompatibilityView()
}
