//
//  Onboarding.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Placeholder per immagine intro
            Image(systemName: "heart.text.square.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.pink)
            
            Text("Benvenuta in MumPro")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("10 minuti al giorno per la tua\nindipendenza finanziaria.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    hasCompletedOnboarding = true
                }
            }) {
                Text("Inizia il viaggio")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}
