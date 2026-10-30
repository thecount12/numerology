//
//  CosmicSpheresView.swift
//  Numerology
//
//  Created by William Gunnells on 10/30/26.
//

import SwiftUI
import SwiftData

struct CosmicSpheresView: View {
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    @State private var selectedProfile: UserProfile?
    
    @State private var manualNumber: String = ""
    @State private var calculatedRoot: Int? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Target Identity Source")) {
                Picker("Select Profile", selection: $selectedProfile) {
                    Text("Manual Quick Input").tag(UserProfile?.none)
                    ForEach(savedProfiles) { profile in
                        Text(profile.name).tag(profile as UserProfile?)
                    }
                }
                .onChange(of: selectedProfile) {
                    updateCalculation()
                }
            }
            
            if selectedProfile == nil {
                Section(header: Text("Enter Single Digital Root")) {
                    TextField("Enter a Number (1-9)", text: $manualNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: manualNumber) {
                            if let num = Int(manualNumber), num >= 1 && num <= 9 {
                                calculatedRoot = num
                            } else {
                                calculatedRoot = nil
                            }
                        }
                }
            }
            
            if let number = calculatedRoot {
                let theme = NumerologyTheme.from(number: number)
                let model = SpheresDataModel.fetchData(for: number)
                
                Section(header: Text("Vertical Sphere Cosmology")) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Top Header Badge
                        HStack {
                            Spacer()
                            Text("\(number)")
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundColor(theme.pulseColor)
                                .frame(width: 80, height: 80)
                                .background(theme.color.gradient)
                                .clipShape(Circle())
                                .shadow(color: theme.color.opacity(0.3), radius: 8, y: 4)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        // Vertical Stack Array mapping your son's spheres
                        SphereTierRowView(tierName: "Highest Sphere", detail: model.highest, baseColor: theme.color)
                        SphereTierRowView(tierName: "Sphere of Intellect", detail: model.intellect, baseColor: theme.color)
                        SphereTierRowView(tierName: "Heavenly Sphere", detail: model.heavenly, baseColor: theme.color)
                        SphereTierRowView(tierName: "Elemental Sphere", detail: model.elemental, baseColor: theme.color)
                        SphereTierRowView(tierName: "Lower Sphere", detail: model.lower, baseColor: theme.color)
                        SphereTierRowView(tierName: "Infernal Sphere", detail: model.infernal, baseColor: .red)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Cosmic Spheres")
        .onAppear {
            updateCalculation()
        }
    }
    
    func updateCalculation() {
        if let profile = selectedProfile {
            calculatedRoot = profile.lifePathNumber
        } else {
            if let num = Int(manualNumber) {
                calculatedRoot = num
            } else {
                calculatedRoot = nil
            }
        }
    }
}

// MARK: - Reusable Row Component for Vertical Tiers
struct SphereTierRowView: View {
    let tierName: String
    let detail: String
    let baseColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(tierName)
                .font(.caption.bold())
                .foregroundColor(baseColor)
                .textCase(.uppercase)
                .tracking(1)
            
            Text(detail)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider().padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Cosmology Interpretation Static Framework Data
struct SpheresDataModel {
    let highest: String
    let intellect: String
    let heavenly: String
    let elemental: String
    let lower: String
    let infernal: String
    
    static func fetchData(for num: Int) -> SpheresDataModel {
        switch num {
        case 1:
            return SpheresDataModel(
                highest: "The Supreme Source, the unified origin of all cosmic design.",
                intellect: "The Soul of the World, reflecting pure archetypal blueprint ideas.",
                heavenly: "The Solar Force (The Sun), guiding systemic life and star vectors.",
                elemental: "The Core Catalyst, the initial spark that transforms heavy matter.",
                lower: "The Human Heart, the electrical engine driving vital organic pulses.",
                infernal: "Lucifer, the rebel force representing pride and fractured individual will."
            )
        case 2:
            return SpheresDataModel(
                highest: "The Dual Mirror, reflecting absolute cosmic wisdom and opposition.",
                intellect: "The Gate of the Sacred Threshold, the balance of polar forces.",
                heavenly: "The Harmony of the Sun and Moon, the great geometric lights.",
                elemental: "Earth and Water, the liquid and solid foundations of nature.",
                lower: "The Brain and Heart, the dual processors of thought and feeling.",
                infernal: "The Two Infernal Chiefs, symbolizing division, doubt, and conflict."
            )
        case 3:
            return SpheresDataModel(
                highest: "The Triple Majesty, representing divine justice, mercy, and law.",
                intellect: "The Intelligences of Order, governing cosmic hierarchies and balance.",
                heavenly: "The Jupiterian Sphere, generating expansion and sovereign harmony.",
                elemental: "The Mineral Kingdom, where physical elements crystalize securely.",
                lower: "The Three Power Centers: Intuition, Reason, and Vital Will.",
                infernal: "The Three Furies, generating discord, excess, and unbridled ambition."
            )
        case 4:
            return SpheresDataModel(
                highest: "The Eternal Tetrad, the perfect structural foundation of the cosmos.",
                intellect: "The Architect Spheres, projecting geometry, form, and spacing rules.",
                heavenly: "The Four Turning Corners of Heaven, stabilizing seasonal solstices.",
                elemental: "The Four Great Pillars: Fire, Earth, Air, and Water elements.",
                lower: "The Four Physical Senses and Framework of the organic blueprint.",
                infernal: "The Four Kings of Distortion, freezing growth into rigid stagnation."
            )
        case 5:
            return SpheresDataModel(
                highest: "The Quintessence, the hidden spiritual force woven through nature.",
                intellect: "The Elohim of Motion, animating thoughts, words, and communication.",
                heavenly: "The Mercurial Axis, coordinating cosmic paths and swift orbits.",
                elemental: "The Astral Ether, the invisible fluid bounding base matter.",
                lower: "The Five Extended Senses and the nervous network of the body.",
                infernal: "The Demonic Temests, generating chaos, instability, and deceit."
            )
        case 6:
            return SpheresDataModel(
                highest: "The Six-Lettered Divine Name, expressing perfect cosmic harmony.",
                intellect: "The Six Angelic Choirs: Seraphim, Cherubim, Shadows, Dominions, Powers, and Virtues.",
                heavenly: "The Moon and five core planets, balancing localized gravitational cycles.",
                elemental: "The Six Elemental Qualities, structural patterns through which matter refines.",
                lower: "The Six Graduated Degrees of the Mind, indicating refined human consciousness.",
                infernal: "The Six Demons of Disaster: Acteus, Megalesius, Ormenus, Lycus, Nicon, and Mimon."
            )
        case 7:
            return SpheresDataModel(
                highest: "The Septenary Seal, the master vault of hidden natural mysteries.",
                intellect: "The Watcher Archangels, managing the cycles of planetary time.",
                heavenly: "The Martian Horizon, fueling drive, vitality, and focused will.",
                elemental: "The Seven Metamorphic Metals, forging dense mineral realities.",
                lower: "The Seven Energy Rhythms, connecting vital physical internal nodes.",
                infernal: "The Seven Capitals of Imbalance, causing fury, conflict, and destruction."
            )
        case 8:
            return SpheresDataModel(
                highest: "The Cosmic Octave, structural bridge between physical and spiritual law.",
                intellect: "The Lords of Karma, enforcing exact structural consequence across time.",
                heavenly: "The Saturnian Sphere, anchoring time boundaries, structures, and deep space.",
                elemental: "The Great Under-Realms, heavy bedrock anchoring deep roots.",
                lower: "The Skeleton and Joints, the physical architecture bearing the human body.",
                infernal: "The Wardens of Limitation, trapping minds in fear and heavy scarcity."
            )
        case 9:
            return SpheresDataModel(
                highest: "The Horizon of Horizons, the absolute edge of finite manifestation.",
                intellect: "The Unified Field Matrix, synthesizing all previous numbers into a whole.",
                heavenly: "The Primum Mobile, the swift wheel driving outer space movements.",
                elemental: "The Complete Seasonal Loop, the closure cycle of physical decay and rebirth.",
                lower: "The Completed Incarnation Blueprint, the cellular threshold of transition.",
                infernal: "The Void Abysses, generating absolute isolation and dark illusions."
            )
        default:
            return SpheresDataModel(
                highest: "The High Structural Law governing this numerical digital root.",
                intellect: "The Angelic Framework and intellectual matrices matching this vector.",
                heavenly: "The Planetary Alignment and stellar coordinates shifting this number.",
                elemental: "The Natural Qualities and seasons shaped by this energetic frequency.",
                lower: "The Human Virtues and psychological traits that anchor this blessing.",
                infernal: "The Imbalance Tier, showing what happens when this energy drops into discord."
            )
        }
    }

}
