//
//  MomProApp.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI
import SwiftData

@main
struct MomProApp: App {
    
    private let storeService = StoreService.shared
    
    @State private var languageService = LanguageService.shared
        
    // Leggiamo la preferenza utente direttamente qui
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    init() {
        storeService.configure()  // Configura RevenueCat all'avvio
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MomProAppRootView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                // 1. Questo ID cambia quando cambi lingua, costringendo SwiftUI a ricaricare tutto
                .id(languageService.currentLanguage)
                
                // 2. Passiamo il servizio a tutte le viste figlie (SettingsView, ecc.)
                .environment(languageService)
        }
        .modelContainer(sharedModelContainer)
    }
}
