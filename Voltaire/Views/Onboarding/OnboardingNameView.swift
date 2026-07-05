//
//  OnboardingNameView.swift
//  Voltaire
//
//  Created by Kilian Balaguer on 10/4/24.
//

import SwiftUI

struct OnboardingNameView: View {
    @Binding var showOnboarding: Bool
    @EnvironmentObject var appManager: AppManager
    @State private var name = ""
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 8) {
                    Text("What's your name?")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("We'll use this to personalize your experience")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 12) {
                TextField("Enter your name", text: $name)
                    .textFieldStyle(.plain)
                    .focused($isNameFocused)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .onChange(of: name) { _, newValue in
                        appManager.userName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                
                NavigationLink(destination: OnboardingInstallModelView(showOnboarding: $showOnboarding)) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundStyle(.background)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .modifier(CustomNavTitle(title: "Welcome"))
        .toolbar(.hidden)
        .onAppear {
            isNameFocused = true
        }
    }
}

#Preview {
    OnboardingNameView(showOnboarding: .constant(true))
        .environmentObject(AppManager())
}
