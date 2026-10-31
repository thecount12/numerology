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
                    LastSelectedProfile.remember(selectedProfile)
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
                let accent = theme.readableColor
                
                Section(header: Text("The Septenary Planetary Matrix")) {
                    let spirit = OlympicSpirit.from(root: number)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        // Planetary glyph + Olympic seal side by side
                        HStack(spacing: 20) {
                            Spacer(minLength: 0)
                            
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(theme.color.gradient)
                                        .frame(width: 88, height: 88)
                                        .shadow(color: theme.color.opacity(0.3), radius: 8, y: 4)
                                    
                                    VStack(spacing: 2) {
                                        Text(data.glyph)
                                            .font(.system(size: 32, weight: .medium))
                                            .foregroundColor(theme.pulseColor)
                                        Text("\(number)")
                                            .font(.system(size: 13, weight: .black, design: .rounded))
                                            .foregroundColor(theme.pulseColor.opacity(0.85))
                                    }
                                }
                                Text(data.glyphName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 100)
                            }
                            
                            VStack(spacing: 8) {
                                OlympicSealView(spirit: spirit)
                                    .frame(width: 110, height: 72)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                                            .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
                                    )
                                Text("Seal of \(spirit.displayName)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 120)
                            }
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 8)
                        
                        Text(data.vibrationType)
                            .font(.headline.bold())
                            .foregroundColor(accent)
                            .frame(maxWidth: .infinity)
                        
                        // Detailed attribute rows
                        ArchetypeRowView(
                            label: "Planetary Sphere",
                            value: data.planet,
                            color: accent,
                            glyph: data.glyph
                        )
                        ArchetypeRowView(
                            label: "Olympic Spirit",
                            value: data.olympicSpirit,
                            color: accent,
                            seal: spirit
                        )
                        ArchetypeRowView(label: "Archangel", value: data.archangel, color: accent, icon: "sparkles")
                        ArchetypeRowView(label: "Sacred Incense", value: data.incense, color: accent, icon: "smoke.fill")
                        ArchetypeRowView(label: "Alchemical Stone", value: data.stone, color: accent, icon: "diamond.fill")
                        ArchetypeRowView(label: "Instrument Frequency", value: data.instrument, color: accent, icon: "guitars")
                        ArchetypeRowView(label: "Animal Archetype", value: data.animal, color: accent, icon: "pawprint.fill")
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Planetary Matrix")
        .onAppear {
            if selectedProfile == nil {
                selectedProfile = LastSelectedProfile.resolve(from: savedProfiles)
            }
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
    let color: Color
    var icon: String? = nil
    var glyph: String? = nil
    var seal: OlympicSpirit? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Group {
                if let seal {
                    OlympicSealView(spirit: seal)
                        .frame(width: 40, height: 28)
                } else if let glyph {
                    Text(glyph)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 28, height: 28)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(color)
                        .frame(width: 28, height: 28)
                }
            }
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
    /// Traditional planetary / alchemy glyph (Unicode)
    let glyph: String
    let glyphName: String
    
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
                animal: "The Lion & The Golden Eagle",
                glyph: "☉",
                glyphName: "Sol — Alchemy of Gold"
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
                animal: "The Owl & The Silver Fox",
                glyph: "☽",
                glyphName: "Luna — Alchemy of Silver"
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
                animal: "The Eagle, The Stag, & The Dolphin",
                glyph: "♃",
                glyphName: "Jupiter — Alchemy of Tin"
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
                animal: "The Hawk & The Sacred Bull",
                glyph: "♅",
                glyphName: "Uranus / Solar Shadow"
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
                animal: "The Swift Swallow, The Fox, & The Monkey",
                glyph: "☿",
                glyphName: "Mercury — Alchemy of Quicksilver"
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
                animal: "The Dove & The White Swan",
                glyph: "♀",
                glyphName: "Venus — Alchemy of Copper"
            )
        case 7:
            // 7 shares the Moon with 2 — seeker / mystical lunar ray
            return PlanetaryDataModel(
                vibrationType: "Lunar Vibration (Seeker Ray)",
                planet: "The Moon (Luna — Inner Tide & Mysteries)",
                olympicSpirit: "Phul (Lord of Waters & Silver Under-Realms)",
                archangel: "Gabriel (The Cosmic Messenger)",
                incense: "Jasmine, Camphor, & White Myrrh",
                stone: "Moonstone, Clear Quartz, or White Topaz",
                instrument: "Flute, Silver Harp, & Contemplative Choir",
                animal: "The Owl, The Phoenix, & The White Elephant",
                glyph: "☾",
                glyphName: "Luna — Alchemy of Silver (Higher Tide)"
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
                animal: "The Black Raven, The Goat, & The Crocodile",
                glyph: "♄",
                glyphName: "Saturn — Alchemy of Lead"
            )
        case 9:
            return PlanetaryDataModel(
                vibrationType: "Martian Vibration",
                planet: "Mars (Ares)",
                olympicSpirit: "Phaleg (Lord of War, Fortitude, & Vital Energy)",
                archangel: "Camael / Khamael (Angel of Strength, Justice, & Courage)",
                incense: "Dragon's Blood Resin, Tobacco, & Ginger",
                stone: "Ruby, Red Jasper, or Bloodstone",
                instrument: "Drums, Cymbals, & Charging Brass (Martial Tones)",
                animal: "The Ram, The Wolf, & The Stallion",
                glyph: "♂",
                glyphName: "Mars — Alchemy of Iron"
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
                animal: "Sacred Spirit Guide Animal",
                glyph: "✦",
                glyphName: "Celestial Coordinate"
            )
        }
    }
}
