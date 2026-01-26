//
//  Article.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation

enum ArticleDifficulty: Int, Codable {
    case beginner = 1
    case intermediate = 2
    case advanced = 3
}

enum ArticleCategory: String, Codable, CaseIterable {
    case savings = "article_category_savings"
    case investing = "article_category_investing"
    case budgeting = "article_category_budgeting"
    case family = "article_category_family"
    case eco = "article_category_eco"
}

struct Article: Identifiable, Codable, Hashable {
    var id: String { fileName }
    //
    let title: String
    let fileName: String // Questo è il vero identificativo univoco
    let imageName: String
    let category: ArticleCategory
    let difficulty: ArticleDifficulty
    let readTimeMinutes: Int
    let isPro: Bool
        
    init(title: String, fileName: String, imageName: String = "article_placeholder", category: ArticleCategory, difficulty: ArticleDifficulty = .beginner, readTimeMinutes: Int = 3, isPro: Bool = false) {
            self.title = title
            self.fileName = fileName
            self.imageName = imageName
            self.category = category
            self.difficulty = difficulty
            self.readTimeMinutes = readTimeMinutes
            self.isPro = isPro
        }
    
    
    func loadMarkdownContent() -> String {
            // 1. Recuperiamo la lingua scelta dall'utente
            let lang = LanguageService.shared.currentLanguage
            
            // 2. Cerchiamo il percorso del bundle specifico (es. cartella it.lproj)
            // Se non trova la cartella specifica (es. non esiste it.lproj), usa il Bundle.main come fallback
            let bundle: Bundle
            if let path = Bundle.main.path(forResource: lang, ofType: "lproj") {
                bundle = Bundle(path: path) ?? Bundle.main
            } else {
                bundle = Bundle.main
            }
            
            // 3. Cerchiamo il file in QUEL bundle specifico
            guard let url = bundle.url(forResource: fileName, withExtension: "md") else {
                // Fallback estremo: prova a cercarlo nella root se non c'è nella cartella lingua
                if let fallbackUrl = Bundle.main.url(forResource: fileName, withExtension: "md") {
                    do { return try String(contentsOf: fallbackUrl, encoding: .utf8) } catch { }
                }
                return "Errore: Articolo non trovato (\(fileName).md)"
            }
            
            do {
                return try String(contentsOf: url, encoding: .utf8)
            } catch {
                return "Errore nel caricamento del contenuto."
            }
        }
}
