//
//  ContentView.swift
//  Numerology
//
//  Created by William Gunnells on 10/20/26.
//

import SwiftUI

struct ContentView: View {
    // 1. Splash State Controller - lives in memory during execution launch
    @State private var isSplashActive = true
    @State private var splashOpacity = 0.0
    @State private var logoScale = 0.7
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            if isSplashActive {
                // MARK: - THE CUSTOM SPLASH VISUAL SCREEN
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Core Geometric Vibrational Icon
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 90))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(logoScale)
                        .shadow(color: .purple.opacity(0.3), radius: 20, y: 10)
                    
                    VStack(spacing: 8) {
                        Text("Numerology Calculator")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Vibrational Digital Root Engine")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .tracking(2)
                    }
                    
                    Spacer()
                    
                    Text("Secure & Ephemeral")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .tracking(1)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGroupedBackground))
                .opacity(splashOpacity)
                .onAppear {
                    // Smoothly animate the logo scale and opacity when loaded
                    withAnimation(.easeOut(duration: 1.0)) {
                        self.splashOpacity = 1.0
                        self.logoScale = 1.0
                    }
                    
                    // Fire the automatic transition gateway to reveal the app
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            self.isSplashActive = false
                        }
                    }
                }
            } else {
                // MARK: - MASTER DASHBOARD
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
                            .padding(.top, 24)
                            
                            // The Master Dashboard Grid
                            // Life Path, Destiny, Soul Urge & Personality live inside Trinity Core
                            LazyVGrid(columns: columns, spacing: 16) {
                                NavigationLink(destination: TrinityMatrixView()) {
                                    DashboardButtonView(
                                        title: "Trinity Core",
                                        subtitle: "The Big Three Matrix",
                                        iconName: "triangle.fill",
                                        backgroundColor: .indigo
                                    )
                                }
                                
                                NavigationLink(destination: TextRootCalculatorView()) {
                                    DashboardButtonView(title: "Text Root", subtitle: "Names & Streets", iconName: "abc", backgroundColor: .purple)
                                }
                                
                                NavigationLink(destination: CompatibilityView()) {
                                    DashboardButtonView(title: "Compatibility", subtitle: "Compare Vibrations", iconName: "heart", backgroundColor: .pink)
                                }
                                
                                NavigationLink(destination: PersonalYearView()) {
                                    DashboardButtonView(title: "Personal Year", subtitle: "2026 Cycle Theme", iconName: "clock.arrow.2.circlepath", backgroundColor: .blue)
                                }
                                
                                NavigationLink(destination: PersonalDayTrackerView()) {
                                    DashboardButtonView(title: "Daily Tracker", subtitle: "Today’s Number Root", iconName: "bolt.shield", backgroundColor: .mint)
                                }
                                
                                NavigationLink(destination: DailyReadingView()) {
                                    DashboardButtonView(title: "Daily Reading", subtitle: "Seeded Day Forecast", iconName: "book.pages.fill", backgroundColor: .orange)
                                }
                                
                                NavigationLink(destination: PlanesOfExpressionView()) {
                                    DashboardButtonView(title: "Planes", subtitle: "Temperament Grids", iconName: "square.grid.3x3.topleft.filled", backgroundColor: .brown)
                                }
                                
                                NavigationLink(destination: MaturityNumberView()) {
                                    DashboardButtonView(title: "Maturity", subtitle: "Future Horizon Root", iconName: "leaf.arrow.triangle.circlepath", backgroundColor: Color(red: 0.0, green: 0.6, blue: 0.3))
                                }
                                
                                NavigationLink(destination: ProfilesVaultView()) {
                                    DashboardButtonView(
                                        title: "Saved Vault",
                                        subtitle: "Persistent Records",
                                        iconName: "person.text.rectangle.fill",
                                        backgroundColor: Color(.systemGray)
                                    )
                                }

                                NavigationLink(destination: CosmicSpheresView()) {
                                    DashboardButtonView(
                                        title: "Cosmic Spheres",
                                        subtitle: "The Vertical Planes",
                                        iconName: "globe.americas.fill",
                                        backgroundColor: .purple
                                    )
                                }
                                
                                NavigationLink(destination: PlanetaryArchetypesView()) {
                                    DashboardButtonView(
                                        title: "Planets & Spirits",
                                        subtitle: "Alchemical Roots",
                                        iconName: "moon.stars.fill",
                                        backgroundColor: .teal
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                }
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
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
