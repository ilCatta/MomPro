//
//  SettingsViewModel.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation
import SwiftUI
import RevenueCat

@Observable
class SettingsViewModel {
    private var storeService = StoreService.shared
    
    // MARK: - Output
    
    var isPro: Bool {
        storeService.isPro
    }
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }
    
    // Stato per mostrare il Paywall
    var showPaywall: Bool = false
    
    // Stato per mostrare alert di conferma ripristino
    var showRestoreAlert: Bool = false
    var restoreMessage: String = ""
    
    // Gestione Tema (salviamo la preferenza utente)
    // Nota: Per applicarlo serve un modifier nella root dell'app (vedi sotto)
    var isDarkMode: Bool {
        get { UserDefaults.standard.bool(forKey: "isDarkMode") }
        set { UserDefaults.standard.set(newValue, forKey: "isDarkMode") }
    }
    
    // MARK: - Actions
    
    func openPaywall() {
        showPaywall = true
    }
    
    func restorePurchases() {
        Task {
            await storeService.restorePurchases()
            
            // Feedback all'utente
            await MainActor.run {
                if storeService.isPro {
                    restoreMessage = "Acquisti ripristinati con successo! Sei PRO."
                } else {
                    restoreMessage = "Nessun abbonamento attivo trovato."
                }
                showRestoreAlert = true
            }
        }
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
    
    
}
