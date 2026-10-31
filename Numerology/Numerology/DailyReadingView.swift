//
//  DailyReadingView.swift
//  Numerology
//
//  Profile-aware daily reading: authentic Personal Day backbone +
//  deterministic fragment variation (same seed → same reading all day).
//

import SwiftUI
import SwiftData

struct DailyReadingView: View {
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    @State private var selectedProfile: UserProfile?
    
    @State private var manualMonth: String = ""
    @State private var manualDay: String = ""
    @State private var manualLifePath: String = ""
    @State private var reading: DailyReading?
    
    private var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
    
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
                    refreshReading()
                }
                
                if savedProfiles.isEmpty {
                    Text("No profiles saved yet. Use Quick Manual Entry, or add records in Saved Vault.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if selectedProfile == nil {
                Section(header: Text("Manual Birth Data")) {
                    TextField("Birth Month (1-12)", text: $manualMonth)
                        .keyboardType(.numberPad)
                    TextField("Birth Day (1-31)", text: $manualDay)
                        .keyboardType(.numberPad)
                    TextField("Life Path (1-9, optional)", text: $manualLifePath)
                        .keyboardType(.numberPad)
                }
                
                Button(action: refreshReading) {
                    Text("Reveal Daily Reading")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(manualMonth.isEmpty || manualDay.isEmpty)
            }
            
            Section(header: Text("Today")) {
                Text(formattedToday)
                    .foregroundColor(.secondary)
            }
            
            if let reading {
                let theme = NumerologyTheme.from(number: reading.personalDay)
                
                Section(header: Text("Personal Day Root")) {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("\(reading.personalDay)")
                                .font(.system(size: 52, weight: .black, design: .rounded))
                                .foregroundColor(theme.pulseColor)
                                .frame(width: 96, height: 96)
                                .background(theme.color.gradient)
                                .clipShape(Circle())
                                .shadow(color: theme.color.opacity(0.35), radius: 8, y: 4)
                            
                            Text(reading.dayTitle)
                                .font(.headline.bold())
                                .foregroundColor(theme.readableColor)
                            
                            Text(reading.planetaryCurrent)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text("Day Essence")) {
                    Text(reading.dayEssence)
                }
                
                Section(header: Text("Today’s Current")) {
                    labeledBlock("Theme", reading.theme)
                    labeledBlock("Challenge", reading.challenge)
                    labeledBlock("Action", reading.action)
                }
                
                Section(header: Text("Full Reading")) {
                    Text(reading.composedText)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Section(header: Text("Cycle Context")) {
                    HStack {
                        Text("Personal Year")
                        Spacer()
                        Text("\(reading.personalYear)")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Life Path")
                        Spacer()
                        Text("\(reading.lifePath)")
                            .fontWeight(.semibold)
                    }
                    Text("This reading is locked to today’s date and your numbers—open it again anytime today and it stays the same.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Daily Reading")
        .onAppear {
            if selectedProfile == nil {
                selectedProfile = LastSelectedProfile.resolve(from: savedProfiles)
            }
            refreshReading()
        }
    }
    
    @ViewBuilder
    private func labeledBlock(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption.bold())
                .foregroundColor(.secondary)
            Text(body)
        }
        .padding(.vertical, 2)
    }
    
    private func refreshReading() {
        if let profile = selectedProfile {
            let parts = NumerologyMath.birthMonthDay(from: profile.birthDate)
            reading = DailyReadingEngine.generate(
                birthMonth: parts.month,
                birthDay: parts.day,
                lifePath: profile.lifePathNumber
            )
            return
        }
        
        guard let month = Int(manualMonth), let day = Int(manualDay),
              month >= 1, month <= 12, day >= 1, day <= 31 else {
            reading = nil
            return
        }
        
        let lp: Int
        if let parsed = Int(manualLifePath), (1...9).contains(parsed) {
            lp = parsed
        } else {
            // Fallback: use personal day as temporary core if LP not provided
            lp = NumerologyMath.personalDay(birthMonth: month, birthDay: day)
        }
        
        reading = DailyReadingEngine.generate(
            birthMonth: month,
            birthDay: day,
            lifePath: lp
        )
    }
}

#Preview {
    NavigationStack {
        DailyReadingView()
    }
}
