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
                    LastSelectedProfile.remember(selectedProfile)
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
            if selectedProfile == nil {
                selectedProfile = LastSelectedProfile.resolve(from: savedProfiles)
            }
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
        case .lifePath(let num):
            return TrinityPillarCopy.lifePath(num)
        case .destiny(let num):
            return TrinityPillarCopy.destiny(num)
        case .soulUrge(let num):
            return TrinityPillarCopy.soulUrge(num)
        case .personality(let num):
            return TrinityPillarCopy.personality(num)
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
}

// MARK: - Pillar meanings for digital roots 1–9
enum TrinityPillarCopy {
    static func lifePath(_ n: Int) -> String {
        switch n {
        case 1:
            return "Your life journey focuses on leadership, independence, and carving out untrodden paths. You are wired to innovate and step into individual authority."
        case 2:
            return "Your life journey focuses on partnership, patience, and diplomatic balance. You are wired to cooperate, sense subtle dynamics, and strengthen others behind the scenes."
        case 3:
            return "Your life journey focuses on creative expression, communication, and joyful expansion. You are wired to share your voice, uplift through art or speech, and socialize with purpose."
        case 4:
            return "Your life journey focuses on building durable foundations through discipline and integrity. You are wired for structure, hard work, and systems that last."
        case 5:
            return "Your life journey focuses on freedom, change, and adaptable experience. You are wired as a catalyst—travel, variety, and turning points keep your path alive."
        case 6:
            return "Your life journey focuses on responsibility, care, and harmonious service. You are wired for home, family, beauty, and the healing of close communities."
        case 7:
            return "Your life journey focuses on inner wisdom, analysis, and spiritual investigation. You are wired for solitude, study, and uncovering what lies beneath the surface."
        case 8:
            return "Your life journey focuses on mastery of material power, ambition, and fair authority. You are wired for business, results, and karmic balance in the outer world."
        case 9:
            return "Your life journey focuses on completion, compassion, and wide humanitarian vision. You are wired to release, forgive, and serve a story larger than the personal self."
        default:
            return "Life Path vibration unresolved for this root."
        }
    }
    
    static func destiny(_ n: Int) -> String {
        switch n {
        case 1:
            return "Your Destiny / Expression targets original creation and self-reliance. Your full name carries the architectural spark to initiate, lead, and stand alone when needed."
        case 2:
            return "Your Destiny / Expression targets peacemaking, support, and refined collaboration. Your full name equips you to mediate, partner, and bring delicate order to shared work."
        case 3:
            return "Your Destiny / Expression targets creative output and inspired communication. Your full name pushes you toward performance, writing, teaching, or any stage where ideas become joy."
        case 4:
            return "Your Destiny / Expression targets reliable construction and practical excellence. Your full name asks you to organize, fortify, and leave tangible structures behind."
        case 5:
            return "Your Destiny / Expression targets liberation, versatility, and progressive change. Your full name moves you through many roles, places, and experiments in freedom."
        case 6:
            return "Your Destiny / Expression targets nurturing leadership and aesthetic harmony. Your full name calls you to counsel, beautify, protect, and elevate domestic or community life."
        case 7:
            return "Your Destiny / Expression targets specialized knowledge and contemplative mastery. Your full name steers you toward research, spiritual craft, analysis, or quiet expertise."
        case 8:
            return "Your Destiny / Expression targets executive achievement and ethical power. Your full name is built for enterprise, recognition, and managing large material currents."
        case 9:
            return "Your Destiny / Expression targets universal service and culminating wisdom. Your full name asks you to teach, heal, create for the many, and complete cycles with grace."
        default:
            return "Destiny vibration unresolved for this root."
        }
    }
    
    static func soulUrge(_ n: Int) -> String {
        switch n {
        case 1:
            return "Deep down, your heart desires autonomy and first place. Your Soul Urge aches to lead, decide, and never be buried in someone else’s shadow."
        case 2:
            return "Deep down, your heart desires closeness, peace, and mutual understanding. Your Soul Urge softens toward partnership, tenderness, and being gently needed."
        case 3:
            return "Deep down, your heart desires delight, applause, and creative play. Your Soul Urge lights up when you entertain, express, and feel emotionally colorful."
        case 4:
            return "Deep down, your heart desires security, order, and earned respect. Your Soul Urge rests when life is stable, honest, and built on solid ground."
        case 5:
            return "Deep down, your heart desires freedom, novelty, and unconfined motion. Your Soul Urge resists cages—routine without oxygen feels like exile."
        case 6:
            return "Deep down, your heart desires to love and be responsible for what you love. Your Soul Urge finds meaning in caretaking, beauty, and emotional belonging."
        case 7:
            return "Deep down, your heart desires truth, privacy, and spiritual or intellectual depth. Your Soul Urge retreats from noise to understand the real pattern."
        case 8:
            return "Deep down, your heart desires accomplishment, influence, and material confirmation. Your Soul Urge measures fulfillment partly through status, skill, and tangible win."
        case 9:
            return "Deep down, your heart desires to give, forgive, and belong to the whole. Your Soul Urge expands toward compassion, art with purpose, and letting go."
        default:
            return "Soul Urge vibration unresolved for this root."
        }
    }
    
    static func personality(_ n: Int) -> String {
        switch n {
        case 1:
            return "The world perceives you as a confident, self-directed presence. Your Personality aura projects initiative, style, and an alpha clarity that others notice first."
        case 2:
            return "The world perceives you as gentle, approachable, and finely tuned. Your Personality aura projects diplomacy, softness, and a listening quality that invites trust."
        case 3:
            return "The world perceives you as lively, charming, and expressive. Your Personality aura projects wit, warmth, and creative sparkle in first impressions."
        case 4:
            return "The world perceives you as steady, serious, and dependable. Your Personality aura projects competence, restraint, and someone who keeps their word."
        case 5:
            return "The world perceives you as magnetic, restless, and progressive. Your Personality aura projects adventure, modernity, and a refusal to look boxed-in."
        case 6:
            return "The world perceives you as warm, responsible, and aesthetically aware. Your Personality aura projects caretaker energy, grace, and reliable heart."
        case 7:
            return "The world perceives you as reserved, intelligent, and slightly mysterious. Your Personality aura projects depth, selectivity, and a mind that does not chatter lightly."
        case 8:
            return "The world perceives you as powerful, composed, and executive. Your Personality aura projects authority, polish, and someone who can handle large stakes."
        case 9:
            return "The world perceives you as wise, open-hearted, and worldly. Your Personality aura projects compassion, artistic breadth, and a finishing-elder quality."
        default:
            return "Personality vibration unresolved for this root."
        }
    }
}
