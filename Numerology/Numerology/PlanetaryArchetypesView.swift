//
//  PlanetaryArchetypesView.swift
//  Numerology
//
//  Created by William Gunnells on 10/30/26.
//

import SwiftUI
import SwiftData

struct PlanetaryArchetypesView: View {
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    @State private var selectedProfile: UserProfile?
    
    @State private var manualNumber: String = ""
    @State private var calculatedRoot: Int? = nil
    
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
                    updateCalculation()
                }
            }
            
            if selectedProfile == nil {
                Section(header: Text("Enter Single Alchemical Root")) {
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
                let data = PlanetaryDataModel.fetchData(for: number)
                
                Section(header: Text("The Septenary Planetary Matrix")) {
                    VStack(alignment: .leading, spacing: 18) {
                        // High Contrast Polarity Circle Badge
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text("\(number)")
                                    .font(.system(size: 44, weight: .black, design: .rounded))
                                    .foregroundColor(theme.pulseColor)
                                    .frame(width: 80, height: 80)
                                    .background(theme.color.gradient)
                                    .clipShape(Circle())
                                    .shadow(color: theme.color.opacity(0.3), radius: 8, y: 4)
                                
                                Text(data.vibrationType)
                                    .font(.headline.bold())
                                    .foregroundColor(theme.color)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        
                        // Detailed attribute rows with matching theme highlights
                        ArchetypeRowView(label: "Planetary Sphere", value: data.planet, icon: "globe", color: theme.color)
                        ArchetypeRowView(label: "Olympic Spirit", value: data.olympicSpirit, icon: "crown", color: theme.color)
                        ArchetypeRowView(label: "Archangel", value: data.archangel, icon: "wings", color: theme.color)
                        ArchetypeRowView(label: "Sacred Incense", value: data.incense, icon: "smoke", color: theme.color)
                        ArchetypeRowView(label: "Alchemical Stone", value: data.stone, icon: "diamond", color: theme.color)
                        ArchetypeRowView(label: "Instrument Frequency", value: data.instrument, icon: "guitars", color: theme.color)
                        ArchetypeRowView(label: "Animal Archetype", value: data.animal, icon: "pawprint", color: theme.color)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Planetary Matrix")
        .onAppear {
            updateCalculation()
        }
    }
    
    func updateCalculation() {
        if let profile = selectedProfile {
            calculatedRoot = profile.lifePathNumber
        } else if let num = Int(manualNumber) {
            calculatedRoot = num
        } else {
            calculatedRoot = nil
        }
    }
}

// MARK: - Reusable Row Component for Alchemical Correspondences
struct ArchetypeRowView: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Divider()
    }
}

// MARK: - Static Repository For Ancient Planetary Mappings
struct PlanetaryDataModel {
    let vibrationType: String
    let planet: String
    let olympicSpirit: String
    let archangel: String
    let incense: String
    let stone: String
    let instrument: String
    let animal: String
    
    static func fetchData(for num: Int) -> PlanetaryDataModel {
        switch num {
        case 1:
            return PlanetaryDataModel(
                vibrationType: "Solar Vibration",
                planet: "The Sun (Sol)",
                olympicSpirit: "Och (Lord of Solar Vitality & Light)",
                archangel: "Michael (Captain of the Heavenly Host)",
                incense: "Frankincense & Pure Amber",
                stone: "Diamond, Ruby, or Gold Topaz",
                instrument: "Pipe Organ & Trumpet (Resonant Brass)",
                animal: "The Lion & The Golden Eagle"
            )
        case 2:
            return PlanetaryDataModel(
                vibrationType: "Lunar Vibration",
                planet: "The Moon (Luna)",
                olympicSpirit: "Phul (Lord of Waters & Silver Under-Realms)",
                archangel: "Gabriel (The Cosmic Messenger)",
                incense: "Myrrh & White Sandalwood",
                stone: "Moonstone, Pearl, or Selenite",
                instrument: "Flute & Silver Harp (Flowing Winds)",
                animal: "The Owl & The Silver Fox"
            )
        case 3:
            return PlanetaryDataModel(
                vibrationType: "Jupiterian Vibration",
                planet: "Jupiter (Jove)",
                olympicSpirit: "Bethor (Governor of Magnanimity, Abundance, & Wisdom)",
                archangel: "Sachiel / Zadkiel (Angel of Mercy & Prosperity)",
                incense: "Cedarwood, Nutmeg, & Saffron",
                stone: "Amethyst, Lapis Lazuli, or Turquoise",
                instrument: "Cello & Orchestral French Horn (Noble Tones)",
                animal: "The Eagle, The Stag, & The Dolphin"
            )
        case 4:
            // 4 links structurally back to the Solar alignment matrix in traditional Septenary codes
            return PlanetaryDataModel(
                vibrationType: "Uranean / Solar Shadow Vibration",
                planet: "The Sun (Lower Ray Matrix / Shadow Aspect)",
                olympicSpirit: "Och (Aspect of Earthly Structure & Forms)",
                archangel: "Michael (Shielding Ray Configuration)",
                incense: "Copal & Frankincense",
                stone: "Tiger's Eye or Hessonite Garnet",
                instrument: "Bass Drum & Timpani (Deep Structural Percussion)",
                animal: "The Hawk & The Sacred Bull"
            )
        case 5:
            return PlanetaryDataModel(
                vibrationType: "Mercurial Vibration",
                planet: "Mercury (Hermes)",
                olympicSpirit: "Ophiel (Governor of Arts, Intellect, & Communication)",
                archangel: "Raphael (The Great Physician & Guide)",
                incense: "Mastic, Lavender, & Star Anise",
                stone: "Emerald, Agate, or Green Tourmaline",
                instrument: "Woodwinds, Clarinet, & Fast Piano Arpeggios",
                animal: "The Swift Swallow, The Fox, & The Monkey"
            )
        case 6:
            return PlanetaryDataModel(
                vibrationType: "Venusian Vibration",
                planet: "Venus (Morning Star)",
                olympicSpirit: "Hagith (Lord of Beauty, Art, and Charm)",
                archangel: "Anael / Haniel (Angel of Grace & Love)",
                incense: "Rose, Benzoin, & Musk",
                stone: "Emerald, Malachite, or Green Jade",
                instrument: "Violin, Lute, & Classical Cello (Rich Strings)",
                animal: "The Dove & The White Swan"
            )
        case 7:
            return PlanetaryDataModel(
                vibrationType: "Martian Vibration",
                planet: "Mars (Ares)",
                olympicSpirit: "Phaleg (Lord of War, Fortitude, & Vital Energy)",
                archangel: "Camael / Khamael (Angel of Strength, Justice, & Courage)",
                incense: "Dragon's Blood Resin, Tobacco, & Ginger",
                stone: "Ruby, Red Jasper, or Bloodstone",
                instrument: "Drums, Cymbals, & Charging Brass (Martial Tones)",
                animal: "The Ram, The Wolf, & The Stallion"
            )
        case 8:
            return PlanetaryDataModel(
                vibrationType: "Saturnian Vibration",
                planet: "Saturn (Chronos)",
                olympicSpirit: "Aratron (Governor of Time, Architecture, & Natural Laws)",
                archangel: "Cassiel / Tzaphkiel (Angel of Solitude, Karma, & Depths)",
                incense: "Myrrh, Onycha, & Storax Resin",
                stone: "Onyx, Jet, Obsidian, or Blue Sapphire",
                instrument: "Pipe Organ, Double Bass, & Heavy Cello (Deep Resonances)",
                animal: "The Black Raven, The Goat, & The Crocodile"
            )
        case 9:
            // 9 forms the complete envelope wrapping back around to the Astral Light of Luna
            return PlanetaryDataModel(
                vibrationType: "Cosmic Envelope / Higher Lunar Ray",
                planet: "The Moon (Higher Ray Synthesis Plane)",
                olympicSpirit: "Phul (Aspect of Completion & Astral Tides)",
                archangel: "Gabriel (Universal Integration Signature)",
                incense: "Jasmine, Camphor, & White Myrrh",
                stone: "Clear Quartz Crystal or White Topaz",
                instrument: "The Symphony Orchestra Choir (Unified Resonance)",
                animal: "The Phoenix & The White Elephant"
            )
        default:
            return PlanetaryDataModel(
                vibrationType: "Planetary Vibration",
                planet: "Higher Celestial Coordinate",
                olympicSpirit: "Aligned Olympic Governor Spirit",
                archangel: "Assigned Sphere Archangel",
                incense: "Sacred Herbal Resin Blend",
                stone: "High-Frequency Crystalline Structure",
                instrument: "Acoustic Resonant Instrument",
                animal: "Sacred Spirit Guide Animal"
            )
        }
    }

}
