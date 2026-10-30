//
//  ContentView.swift
//  Numerology
//
//  Created by William Gunnells on 10/20/26.
//

import SwiftUI

struct ContentView: View {
    // A clean grid layout layout that handles 2 columns beautifully
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Space
                    VStack(spacing: 8) {
                        Text("Numerology Calculator")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                        Text("Select a tool to explore numerical vibrations.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 30)
                    
                    // The Master Dashboard Grid (Scales easily up to 10 icons!)
                    LazyVGrid(columns: columns, spacing: 16) {
                        
                        // ICON 1: Life Path Calendar
                        NavigationLink(destination: LifePathCalculatorView()) {
                            DashboardButtonView(
                                title: "Life Path",
                                subtitle: "Birthdate Math",
                                iconName: "calendar.badge.clock",
                                backgroundColor: .blue
                            )
                        }
                        
                        // ICON 2: Alphabet / Text Root Analyzer
                        NavigationLink(destination: TextRootCalculatorView()) {
                            DashboardButtonView(
                                title: "Text Analyzer",
                                subtitle: "Input Anything",
                                iconName: "abc",
                                backgroundColor: .purple
                            )
                        }
                        
                        // FUTURE ICONS (3 through 10) GO HERE!
                        // ICON 3: Compatibility Matcher
                        NavigationLink(destination: CompatibilityView()) {
                            DashboardButtonView(
                                title: "Compatibility",
                                subtitle: "Compare Vibrations",
                                iconName: "heart",
                                backgroundColor: .pink
                            )
                        }
                        
                        // ICON 4: Personal Year Cycles
                        NavigationLink(destination: PersonalYearView()) {
                            DashboardButtonView(
                                title: "Personal Year",
                                subtitle: "2026 Cycle Theme",
                                iconName: "clock.arrow.2.circlepath",
                                backgroundColor: .blue
                            )
                        }
                        
                        // ICON 5: Soul Urge Analyzer
                        NavigationLink(destination: SoulUrgeView()) {
                            DashboardButtonView(
                                title: "Soul Urge",
                                subtitle: "Vowel Desires",
                                iconName: "waveform.path.ecg",
                                backgroundColor: .orange
                            )
                        }
                        
                        // ICON 6: Personality Analyzer
                        NavigationLink(destination: PersonalityView()) {
                            DashboardButtonView(
                                title: "Personality",
                                subtitle: "Consonant Aura",
                                iconName: "person.text.rectangle",
                                backgroundColor: .teal
                            )
                        }
                        
                        // ICON 7: Full Destiny Expression Calculator
                        NavigationLink(destination: DestinyExpressionView()) {
                            DashboardButtonView(
                                title: "Destiny",
                                subtitle: "Full Name Blueprint",
                                iconName: "signature",
                                backgroundColor: .indigo
                            )
                        }
                        
                        // ICON 8: Personal Day Tracker
                        NavigationLink(destination: PersonalDayTrackerView()) {
                            DashboardButtonView(
                                title: "Daily Tracker",
                                subtitle: "Hourly Flow Root",
                                iconName: "bolt.shield",
                                backgroundColor: .mint
                            )
                        }
                        
                        // ICON 9: Planes of Expression Matrix
                        NavigationLink(destination: PlanesOfExpressionView()) {
                            DashboardButtonView(
                                title: "Planes",
                                subtitle: "Temperament Grids",
                                iconName: "square.grid.3x3.topleft.filled",
                                backgroundColor: .brown
                            )
                        }
                        
                        // ICON 10: Maturity Destination Number
                        NavigationLink(destination: MaturityNumberView()) {
                            DashboardButtonView(
                                title: "Maturity",
                                subtitle: "Future Horizon Root",
                                iconName: "leaf.arrow.triangle.circlepath",
                                backgroundColor: Color(red: 0.0, green: 0.6, blue: 0.3)
                            )
                        }
                        
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
    }
}

// MARK: - Reusable Dashboard Component
struct DashboardButtonView: View {
    let title: String
    let subtitle: String
    let iconName: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 80, height: 80)
                .background(backgroundColor.gradient) // Beautiful modern Apple gradient
                .cornerRadius(20)
                .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
}
