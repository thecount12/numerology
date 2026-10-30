//
//  TrinityMatrixView.swift
//  Numerology
//
//  Created by William Gunnells on 10/30/26.
//

import SwiftUI
import SwiftData

struct TrinityMatrixView: View {
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    @State private var selectedProfile: UserProfile?
    
    // Manual state configurations if no profile is active
    @State private var manualName: String = ""
    @State private var manualBirthDate = Date()
    
    // Output states for the Master Quadrant
    @State private var lifePathRoot: Int? = nil
    @State private var destinyRoot: Int? = nil
    @State private var soulUrgeRoot: Int? = nil
    @State private var personalityRoot: Int? = nil
    
    // Detail sheet modal controller state
    @State private var selectedDetailType: PillarType? = nil
    
    enum PillarType: Identifiable {
        case lifePath(Int)
        case destiny(Int)
        case soulUrge(Int)
        case personality(Int)
        
        var id: String {
            switch self {
            case .lifePath: return "lifePath"
            case .destiny: return "destiny"
            case .soulUrge: return "soulUrge"
            case .personality: return "personality"
            }
        }
    }
    
    // Flexible adaptive layout grid for a clean 2x2 presentation
    let quadrantColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        Form {
            Section(header: Text("Identity Blueprint Source")) {
                Picker("Select Profile", selection: $selectedProfile) {
                    Text("Quick Manual Entry").tag(UserProfile?.none)
                    ForEach(savedProfiles) { profile in
                        Text(profile.name).tag(profile as UserProfile?)
                    }
                }
                .onChange(of: selectedProfile) {
                    calculateMatrix()
                }
            }
            
            if selectedProfile == nil {
                Section(header: Text("Manual Matrix Parameters")) {
                    TextField("Full Legal Name", text: $manualName)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .onChange(of: manualName) {
                            calculateMatrix()
                        }
                    
                    DatePicker("Birthdate", selection: $manualBirthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .onChange(of: manualBirthDate) {
                            calculateMatrix()
                        }
                }
            }
            
            if let lp = lifePathRoot, let ds = destinyRoot, let su = soulUrgeRoot, let pr = personalityRoot {
                Section(header: Text("The Core Quadrant (Tap for details)")) {
                    VStack(spacing: 16) {
                        Text("Master Alignment Matrix")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                            .tracking(2)
                            .padding(.top, 4)
                        
                        // Using a 2x2 grid wrapped in buttons for clean sheet popovers
                        LazyVGrid(columns: quadrantColumns, spacing: 12) {
                            Button(action: { selectedDetailType = .lifePath(lp) }) {
                                TrinityBadgeView(title: "Life Path", number: lp, description: "Nature & Path")
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { selectedDetailType = .destiny(ds) }) {
                                TrinityBadgeView(title: "Destiny", number: ds, description: "Blueprint & Target")
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { selectedDetailType = .soulUrge(su) }) {
                                TrinityBadgeView(title: "Soul Urge", number: su, description: "Internal Desire")
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { selectedDetailType = .personality(pr) }) {
                                TrinityBadgeView(title: "Personality", number: pr, description: "External Aura")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Trinity & Core")
        .onAppear {
            calculateMatrix()
        }
        .sheet(item: $selectedDetailType) { detailType in
            QuadrantDetailModalView(type: detailType)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    func calculateMatrix() {
        var targetName = ""
        var targetDate = Date()
        
        if let profile = selectedProfile {
            targetName = profile.name
            targetDate = profile.birthDate
        } else {
            targetName = manualName
            targetDate = manualBirthDate
        }
        
        let cleanedName = targetName.lowercased().filter { $0.isLetter }
        
        guard !cleanedName.isEmpty else {
            lifePathRoot = nil
            destinyRoot = nil
            soulUrgeRoot = nil
            personalityRoot = nil
            return
        }
        
        // 1. Life Path Calculation
        let calendar = Calendar.current
        let day = calendar.component(.day, from: targetDate)
        let month = calendar.component(.month, from: targetDate)
        let year = calendar.component(.year, from: targetDate)
        let lpTotal = day + month + year
        lifePathRoot = (lpTotal % 9 == 0) ? 9 : lpTotal % 9
        
        // 2. Name Split Calculations (Destiny, Soul Urge, Personality)
        let vowelsSet: Set<Character> = ["a", "e", "i", "o", "u"]
        var totalDestinySum = 0
        var totalSoulSum = 0
        var totalPersonalitySum = 0
        
        for character in cleanedName {
            if let asciiValue = character.asciiValue {
                let weight = Int(asciiValue) - 96
                let reducedWeight = ((weight - 1) % 9) + 1
                
                totalDestinySum += reducedWeight
                
                if vowelsSet.contains(character) {
                    totalSoulSum += reducedWeight
                } else {
                    totalPersonalitySum += reducedWeight
                }
            }
        }
        
        destinyRoot = (totalDestinySum % 9 == 0 && totalDestinySum > 0) ? 9 : totalDestinySum % 9
        soulUrgeRoot = (totalSoulSum % 9 == 0 && totalSoulSum > 0) ? 9 : totalSoulSum % 9
        personalityRoot = (totalPersonalitySum % 9 == 0 && totalPersonalitySum > 0) ? 9 : totalPersonalitySum % 9
    }
}

// MARK: - Reusable Mini Badge Component for Trinity Layout
struct TrinityBadgeView: View {
    let title: String
    let number: Int
    let description: String
    
    var body: some View {
        let theme = NumerologyTheme.from(number: number)
        
        VStack(spacing: 8) {
            Text(title)
                .font(.caption2.bold())
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text("\(number)")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(theme.pulseColor)
                .frame(width: 76, height: 76)
                .background(theme.color.gradient)
                .clipShape(Circle())
                .shadow(color: theme.color.opacity(0.3), radius: 6, y: 3)
            
            Text(description)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 4, y: 2)
    }
}

// MARK: - Slide-Up Core Profile Modal Sheet
struct QuadrantDetailModalView: View {
    let type: TrinityMatrixView.PillarType
    
    var title: String {
        switch type {
        case .lifePath: return "Life Path Meaning"
        case .destiny: return "Destiny Definition"
        case .soulUrge: return "Soul Urge Reading"
        case .personality: return "Personality Blueprint"
        }
    }
    
    var number: Int {
        switch type {
        case .lifePath(let num), .destiny(let num), .soulUrge(let num), .personality(let num):
            return num
        }
    }
    
    var explanationText: String {
        switch type {
        case .lifePath: return "Your life journey focuses on leadership, independence, and carving out untrodden paths. You are wired to innovate and step into individual authority."
        case .destiny: return "Your complete destiny targets original creation and self-reliance. Your names hold the architectural spark required to run organizations autonomously."
        case .soulUrge: return "Deep down, your heart desires total autonomy and dominance. Your soul secretively aches to be number one, resisting submissive roles."
        case .personality: return "The world perceives you as an intimidating, fiercely confident alpha presence. Your external aura projects power, style, and individual dominance."
        }
    }
    
    var body: some View {
        let theme = NumerologyTheme.from(number: number)
        
        VStack(spacing: 24) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.top, 30)
            
            // Fixed the missing backslash escaping here!
            Text("\(number)")
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(theme.pulseColor)
                .frame(width: 140, height: 140)
                .background(theme.color.gradient)
                .clipShape(Circle())
                .shadow(color: theme.color.opacity(0.4), radius: 12, y: 6)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(theme.name)
                    .font(.title3.bold())
                    .foregroundColor(theme.color)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Divider()
                    .padding(.vertical, 4)
                
                ScrollView {
                    Text(explanationText)
                        .font(.body)
                        .lineSpacing(6)
                        .foregroundColor(.primary)
                }
            }
            .padding(24)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
} // Closes the QuadrantDetailModalView struct container cleanly
