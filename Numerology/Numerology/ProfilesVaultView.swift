//
//  ProfilesVaultView.swift
//  Numerology
//
//  Created by William Gunnells on 10/30/26.
//

import SwiftUI
import SwiftData

struct ProfilesVaultView: View {
    // This macro automatically fetches and streams your saved data model live from disk
    @Query(sort: \UserProfile.name) private var savedProfiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddModal = false
    @State private var newName = ""
    @State private var newBirthDate = Date()
    
    var body: some View {
        List {
            if savedProfiles.isEmpty {
                ContentUnavailableView(
                    "No Profiles Saved",
                    systemImage: "person.stack.fill",
                    description: Text("Tap the '+' button to save a friend or family member's blueprint permanently.")
                )
            } else {
                ForEach(savedProfiles) { profile in
                    NavigationLink(destination: ProfileDetailView(profile: profile)) {
                        HStack(spacing: 16) {
                            let theme = NumerologyTheme.from(number: profile.lifePathNumber)
                            
                            // Visual Polarity Badge
                            Text("\(profile.lifePathNumber)")
                                .font(.headline.bold())
                                .foregroundColor(theme.pulseColor)
                                .frame(width: 40, height: 40)
                                .background(theme.color.gradient)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.name)
                                    .font(.headline)
                                Text(profile.birthDate, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteProfiles)
            }
        }
        .navigationTitle("Profiles Vault")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddModal = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        // Modal slide sheet to input new users fresh from the vault
        .sheet(isPresented: $showingAddModal) {
            NavigationStack {
                Form {
                    TextField("Full Name", text: $newName)
                        .autocorrectionDisabled()
                    DatePicker("Birthdate", selection: $newBirthDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                }
                .navigationTitle("New Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddModal = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveProfile()
                            showingAddModal = false
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    func saveProfile() {
        let profile = UserProfile(name: newName, birthDate: newBirthDate)
        modelContext.insert(profile)
        newName = ""
        newBirthDate = Date()
    }
    
    func deleteProfiles(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(savedProfiles[index])
        }
    }
}

// MARK: - Dedicated Deep Interpretation Subview
struct ProfileDetailView: View {
    let profile: UserProfile
    
    var body: some View {
        ScrollView {
            let theme = NumerologyTheme.from(number: profile.lifePathNumber)
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(profile.name)
                        .font(.largeTitle.bold())
                    Text(profile.birthDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Hero badge pulling our custom text coloring engine rules
                Text("\(profile.lifePathNumber)")
                    .font(.system(size: 90, weight: .black, design: .rounded))
                    .foregroundColor(theme.pulseColor)
                    .frame(width: 150, height: 150)
                    .background(theme.color.gradient)
                    .clipShape(Circle())
                    .shadow(color: theme.color.opacity(0.3), radius: 15, y: 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Core Interpretation")
                        .font(.headline)
                        .foregroundColor(theme.color)
                    
                    Text(profile.interpretation)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                }
                .padding(24)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.03), radius: 8, y: 4)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}
