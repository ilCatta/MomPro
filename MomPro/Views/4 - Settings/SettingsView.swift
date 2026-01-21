//
//  SettingsView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI
import RevenueCatUI // Necessario per PaywallView

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    
    var body: some View {
        List {
            Section("Account") {
                if viewModel.isPro {
                    Label("Sei un utente PRO 🌟", systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                } else {
                    Button {
                        viewModel.openPaywall()
                    } label: {
                        Label("Passa a MumPro", systemImage: "arrow.up.circle.fill")
                    }
                }
            }
            
            Section("Assistenza") {
                Button("Ripristina Acquisti") {
                    viewModel.restore()
                }
            }
        }
        // MAGIA REVENUECAT:
        // Questo sheet presenta il Paywall disegnato online.
        // displayCloseButton: true mette la "X" automaticamente.
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallView(displayCloseButton: true)
                // Se l'utente acquista con successo, chiudi il paywall
                .onPurchaseCompleted { info in
                    viewModel.showPaywall = false
                }
        }
    }
}
