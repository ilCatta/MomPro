//
//  ContentView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI
import SwiftData

struct MomProAppRootView: View {
    // Usiamo AppStorage per ricordare se l'utente ha già visto l'intro
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}
