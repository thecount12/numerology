//
//  DailyReadingEngine.swift
//  Numerology
//
//  Deterministic daily readings: authentic Personal Day / Year / Life Path
//  math as the backbone; seeded picks only vary wording inside that day's pool.
//

import Foundation

struct DailyReading {
    let personalDay: Int
    let personalYear: Int
    let lifePath: Int
    let dayTitle: String
    let dayEssence: String
    let theme: String
    let challenge: String
    let action: String
    let planetaryCurrent: String
    let composedText: String
}

enum DailyReadingEngine {
    
    // MARK: - Seed (stable for a given person + calendar day)
    
    static func seed(personalDay: Int, lifePath: Int, on date: Date = Date()) -> UInt64 {
        let calendar = Calendar.current
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        // YYYYMMDD * 100 + PD*10 + LP  — unique per day/person core
        let stamp = UInt64(y) * 10_000
            + UInt64(m) * 100
            + UInt64(d)
        return stamp * 100 + UInt64(personalDay) * 10 + UInt64(lifePath)
    }
    
    /// Tiny deterministic PRNG (no GameplayKit dependency).
    private struct SeededRNG: RandomNumberGenerator {
        private var state: UInt64
        init(seed: UInt64) {
            state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
        }
        mutating func next() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
            z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
            return z ^ (z >> 31)
        }
    }
    
    private static func pick<T>(_ items: [T], rng: inout SeededRNG) -> T {
        let index = Int(rng.next() % UInt64(items.count))
        return items[index]
    }
    
    // MARK: - Public API
    
    static func generate(
        birthMonth: Int,
        birthDay: Int,
        lifePath: Int,
        on date: Date = Date()
    ) -> DailyReading {
        let day = NumerologyMath.personalDay(birthMonth: birthMonth, birthDay: birthDay, on: date)
        let year = NumerologyMath.personalYear(birthMonth: birthMonth, birthDay: birthDay, on: date)
        let bank = FragmentBank.forDay(day)
        let planet = PlanetaryDataModel.fetchData(for: day)
        
        var rng = SeededRNG(seed: seed(personalDay: day, lifePath: lifePath, on: date))
        let theme = pick(bank.themes, rng: &rng)
        let challenge = pick(bank.challenges, rng: &rng)
        let action = pick(bank.actions, rng: &rng)
        
        let yearLabel = FragmentBank.yearContext(year)
        let lifeBridge = FragmentBank.lifePathBridge(lifePath: lifePath, personalDay: day)
        
        let composed = """
        Personal Day \(day) — \(bank.title). \(bank.essence) \
        Today’s current: \(theme) \(challenge) \(action) \
        \(lifeBridge) Your Personal Year \(year) frame: \(yearLabel) \
        Planetary current: \(planet.planet) (\(planet.glyph)), spirit \(OlympicSpirit.from(root: day).displayName).
        """
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return DailyReading(
            personalDay: day,
            personalYear: year,
            lifePath: lifePath,
            dayTitle: bank.title,
            dayEssence: bank.essence,
            theme: theme,
            challenge: challenge,
            action: action,
            planetaryCurrent: "\(planet.glyph) \(planet.planet)",
            composedText: composed
        )
    }
}

// MARK: - Fragment banks keyed by Personal Day (authentic pools, not global Mad Libs)

private struct FragmentBank {
    let title: String
    let essence: String
    let themes: [String]
    let challenges: [String]
    let actions: [String]
    
    static func forDay(_ day: Int) -> FragmentBank {
        switch day {
        case 1:
            return FragmentBank(
                title: "Initiation Day",
                essence: "A 1 day favors independence, first moves, and clean starts.",
                themes: [
                    "a clear opening to claim a new direction.",
                    "fresh momentum around leadership and self-trust.",
                    "a pioneering spark that wants decisive motion.",
                    "an invitation to begin without waiting for consensus."
                ],
                challenges: [
                    "Guard against forcing outcomes just to feel in control.",
                    "Impatience with slower people can create friction before noon.",
                    "Avoid reinventing what only needs a first honest step.",
                    "Do not confuse solitude with isolation today."
                ],
                actions: [
                    "Name one initiative and take its first concrete action before midday.",
                    "Make a clean decision you’ve been postponing.",
                    "Lead a short conversation with clarity rather than persuasion.",
                    "Start a small ritual that signals a new cycle."
                ]
            )
        case 2:
            return FragmentBank(
                title: "Alliance Day",
                essence: "A 2 day favors patience, partnership, and quiet calibration.",
                themes: [
                    "subtle emotional undercurrents asking for cooperation.",
                    "a softer rhythm that rewards listening over pushing.",
                    "relational detail-work that strengthens long-term trust.",
                    "an attunement between your timing and someone else’s."
                ],
                challenges: [
                    "Over-reading micro-signals can drain your clarity.",
                    "People-pleasing may masquerade as harmony—check your boundaries.",
                    "Waiting is useful; stalling is not. Know the difference today.",
                    "Avoid absorbing other people’s anxiety as your own forecast."
                ],
                actions: [
                    "Offer one sincere collaboration rather than a solo sprint.",
                    "Pause before reacting; respond after one full breath cycle.",
                    "Tend a relationship detail you’ve neglected.",
                    "Write down what you need from partnership without editing it."
                ]
            )
        case 3:
            return FragmentBank(
                title: "Expression Day",
                essence: "A 3 day favors voice, creativity, social warmth, and play.",
                themes: [
                    "a lift in creative voltage and conversational range.",
                    "social openings that want lightness and honest wit.",
                    "an urge to shape feelings into language or art.",
                    "joyful expansion through sharing what you’ve been holding."
                ],
                challenges: [
                    "Scattered enthusiasm can thin your follow-through.",
                    "Performance energy may outrun sincerity—stay grounded in truth.",
                    "Gossip or oversharing can leak focus this afternoon.",
                    "Don’t use humor to dodge a real feeling."
                ],
                actions: [
                    "Create or send something expressive before the day ends.",
                    "Have the enlivening conversation you’ve delayed.",
                    "Capture spontaneous ideas; they carry structural weight today.",
                    "Choose one joyful outing or creative block and protect it."
                ]
            )
        case 4:
            return FragmentBank(
                title: "Foundation Day",
                essence: "A 4 day favors structure, discipline, body care, and durable work.",
                themes: [
                    "a call to fortify systems, schedules, and physical supports.",
                    "steady labor that compounds into real security.",
                    "an alignment between workspace order and mental clarity.",
                    "practical progress through patient bricklaying."
                ],
                challenges: [
                    "Rigidity can masquerade as responsibility—leave a little flex.",
                    "Frustration rises if you demand overnight results from long builds.",
                    "Neglecting rest will tax tomorrow’s foundation.",
                    "Avoid perfectionism that blocks a good-enough next step."
                ],
                actions: [
                    "Complete one structural task you’ve been circling.",
                    "Organize a physical space for twenty focused minutes.",
                    "Set a realistic boundary around work hours today.",
                    "Tend the body: sleep, food, or movement as infrastructure."
                ]
            )
        case 5:
            return FragmentBank(
                title: "Turning Point Day",
                essence: "A 5 day favors change, freedom, curiosity, and adaptive movement.",
                themes: [
                    "unexpected shifts that loosen stuck routines.",
                    "a hunger for variety, travel of mind or body, and fresh input.",
                    "magnetic change-currents around freedom and timing.",
                    "a pivot opportunity if you stay agile rather than reactive."
                ],
                challenges: [
                    "Restlessness can scatter commitments that still matter.",
                    "Impulse decisions may outrun wisdom after mid-afternoon.",
                    "Escaping discomfort is not the same as liberating yourself.",
                    "Too many open tabs—literal or mental—dilute the gift of 5."
                ],
                actions: [
                    "Change one routine deliberately and notice what opens.",
                    "Take a short exploratory walk or route you’ve never used.",
                    "Say yes to a stimulating offer; say no to chaos dressed as freedom.",
                    "Update a plan that no longer fits who you are becoming."
                ]
            )
        case 6:
            return FragmentBank(
                title: "Care & Duty Day",
                essence: "A 6 day favors home, responsibility, beauty, and heart-centered service.",
                themes: [
                    "domestic and relational currents asking for presence.",
                    "a pull toward harmony, aesthetics, and mutual care.",
                    "emotional repair opportunities inside close circles.",
                    "service that restores balance rather than depletes you."
                ],
                challenges: [
                    "Over-responsibility can crowd out your own needs.",
                    "Resentment builds if care is given without consent or limits.",
                    "Idealizing family or partnership may hide a needed truth.",
                    "Avoid fixing others as a way to avoid your own center."
                ],
                actions: [
                    "Offer practical help in one place that truly needs it.",
                    "Beautify or reset a corner of your home with intention.",
                    "Speak appreciation clearly to someone close.",
                    "Schedule care for yourself with the same seriousness you give others."
                ]
            )
        case 7:
            return FragmentBank(
                title: "Inner Study Day",
                essence: "A 7 day favors analysis, solitude, spiritual signal, and deep focus.",
                themes: [
                    "an internal audit of meaning, motives, and long-range aims.",
                    "quiet intelligence rising when noise falls away.",
                    "a contemplative current that rewards research and stillness.",
                    "subtle intuitive hits that want verification, not dismissal."
                ],
                challenges: [
                    "Over-analysis can freeze action that is already clear.",
                    "Withdrawal may be wise; disappearance from needed bonds is not.",
                    "Cynicism can pose as insight—test it against lived evidence.",
                    "Avoid filtering intuition through other people’s fear."
                ],
                actions: [
                    "Protect a block of uninterrupted study or meditation.",
                    "Journal the question beneath today’s surface worry.",
                    "Seek one primary source or quiet fact before deciding.",
                    "Walk alone long enough for your own signal to return."
                ]
            )
        case 8:
            return FragmentBank(
                title: "Harvest & Power Day",
                essence: "A 8 day favors authority, material results, business clarity, and karma-in-motion.",
                themes: [
                    "a harvest current around work, money, and visible impact.",
                    "structural power asking to be used with integrity.",
                    "executive focus that can lock in tangible gains.",
                    "a test of balance between ambition and ethical weight."
                ],
                challenges: [
                    "Control habits may tighten under pressure—delegate where wise.",
                    "Status anxiety can distort otherwise good strategy.",
                    "Forcing a win can create tomorrow’s debt.",
                    "Don’t measure the whole self by today’s ledger."
                ],
                actions: [
                    "Close one financial or career loop with clean paperwork.",
                    "Make the high-leverage call or ask you’ve been delaying.",
                    "Review power dynamics in a key relationship or deal.",
                    "Act from authority without domination—firm and fair."
                ]
            )
        case 9:
            return FragmentBank(
                title: "Completion Day",
                essence: "A 9 day favors release, compassion, endings, and wide-lens perspective.",
                themes: [
                    "a closing current that clears space for the next cycle.",
                    "humanitarian feeling and forgiveness rising to the surface.",
                    "completion energy around projects, stories, and old roles.",
                    "a wider vision that softens personal urgency."
                ],
                challenges: [
                    "Clinging to what is finished will feel heavier than usual.",
                    "Emotional flooding can arrive if you skip the goodbye.",
                    "Saving everyone else may be avoidance of your own ending.",
                    "Nostalgia is information, not a veto on growth."
                ],
                actions: [
                    "Finish, gift, or release one thing that has completed its term.",
                    "Offer compassion without taking on another’s entire load.",
                    "Declutter a physical or digital archive as ritual closure.",
                    "Write the ending paragraph on a chapter you’ve outgrown."
                ]
            )
        default:
            return FragmentBank(
                title: "Open Current",
                essence: "Observe the day’s pattern and move with integrity.",
                themes: ["a subtle shift in your vibrational field."],
                challenges: ["Stay present; avoid borrowed urgency."],
                actions: ["Return to breath and one clear priority."]
            )
        }
    }
    
    static func yearContext(_ year: Int) -> String {
        switch year {
        case 1: return "a year of beginnings—today’s moves plant longer seeds."
        case 2: return "a year of patience and alliance—today’s tone favors soft power."
        case 3: return "a year of expression—today amplifies voice and creative reach."
        case 4: return "a year of building—today rewards durable, honest labor."
        case 5: return "a year of change—today’s flexibility is strategic, not random."
        case 6: return "a year of care and duty—today’s heart-work echoes the annual theme."
        case 7: return "a year of inner wisdom—today’s quiet insight compounds."
        case 8: return "a year of manifestation—today’s material choices carry weight."
        case 9: return "a year of completion—today supports release and wide compassion."
        default: return "an unfolding annual cycle."
        }
    }
    
    static func lifePathBridge(lifePath: Int, personalDay: Int) -> String {
        if lifePath == personalDay {
            return "Your Life Path \(lifePath) matches today’s root—this is a high-fidelity day for your core nature."
        }
        return "Life Path \(lifePath) meets Personal Day \(personalDay)—filter today’s weather through your native strengths."
    }
}
