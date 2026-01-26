//
//  LanguageService.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation
import SwiftUI

@Observable
class LanguageService {
    static let shared = LanguageService()
    
    // Salviamo la scelta: "en" o "it"
    var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
        }
    }
    
    init() {
        // Al primo avvio, controlla se c'è una preferenza salvata.
        // Se non c'è, controlla la lingua del telefono. Se è italiano mette "it", altrimenti default "en".
        if let saved = UserDefaults.standard.string(forKey: "selectedLanguage") {
            self.currentLanguage = saved
        } else {
            let sysLang = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = sysLang == "it" ? "it" : "en"
        }
    }
    
    // Funzione per cambiare lingua
    func setLanguage(_ lang: String) {
        currentLanguage = lang
    }
}

// Estensione per tradurre le stringhe "al volo"
extension String {
    var localized: String {
        let lang = LanguageService.shared.currentLanguage
        
        // Cerca il file delle traduzioni dentro la cartella specifica (es. it.lproj)
        if let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        
        // Fallback: usa la lingua standard se non trova il bundle
        return NSLocalizedString(self, comment: "")
    }
}
