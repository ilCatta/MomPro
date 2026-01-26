//
//  GuidesViewModel.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//
import Foundation
import SwiftUI

@Observable
class LearnViewModel {
    private var contentService = ContentService.shared
    private var progressService = ProgressService.shared
    private var storeService = StoreService.shared
    private var dailyPlanService = DailyPlanService.shared
    
    // MARK: - Output
    
    // Lista delle categorie per ordinare la UI
    let categories: [ArticleCategory] = ArticleCategory.allCases
    
    // Articolo suggerito per la navigazione
    var suggestedArticle: Article?
    var showSuggestion: Bool = false
    
    // MARK: - Data Processing
    
    // Ritorna gli articoli di una categoria, ORDINATI:
    // 1. Prima i NON letti
    // 2. Poi i Letti
    func articles(for category: ArticleCategory) -> [Article] {
        let all = contentService.allArticles.filter { $0.category == category }
        
        return all.sorted { (a1, a2) -> Bool in
            let read1 = isRead(a1)
            let read2 = isRead(a2)
            
            // Se uno è letto e l'altro no, vince quello NON letto (true < false)
            if read1 != read2 {
                return !read1
            }
            // Altrimenti ordine alfabetico o di difficoltà
            return a1.difficulty.rawValue < a2.difficulty.rawValue
        }
    }
    
    func isRead(_ article: Article) -> Bool {
        return progressService.readArticleIDs.contains(article.id)
    }
    
    // LOGICA DI BLOCCO (STRATEGIA PREMIUM)
    func isLocked(_ article: Article) -> Bool {
            // 1. Utente Pro -> Tutto aperto
            if storeService.isPro {
                return false
            }
            
            // 2. Comanda il database.
            // Se nel ContentService hai messo "isPro: true", è bloccato.
            // Se hai messo "isPro: false" (come per inv_001), è aperto.
            // Questo sovrascrive qualsiasi logica di categoria, permettendoti eccezioni.
            return article.isPro
        }
    
    // Stringa progresso es. "2/5"
    func progressText(for category: ArticleCategory) -> String {
        let all = contentService.allArticles.filter { $0.category == category }
        if all.isEmpty { return "" }
        let readCount = all.filter { isRead($0) }.count
        return "\(readCount)/\(all.count)"
    }
    
    // MARK: - Actions
    
    func markAsRead(_ article: Article) {
        progressService.markArticleAsRead(articleId: article.id)
        // Fondamentale: completa il task nella Home!
        dailyPlanService.completeEducationTask()
    }
    
    // LOGICA "CONSIGLIAMI" INTELLIGENTE
    func pickSuggestedArticle() {
            let isPro = storeService.isPro
            let allArticles = contentService.allArticles
            
            // --- STRATEGIA HOOK (NOVITÀ) ---
            // Se l'utente è FREE e NON ha ancora letto l'articolo "Esca" (inv_001),
            // glielo proponiamo subito per invogliarlo.
            if !isPro {
                // Cerchiamo l'articolo specifico per nome file
                if let hookArticle = allArticles.first(where: { $0.fileName == "inv_001" }),
                   !isRead(hookArticle) { // Se non lo ha ancora letto
                    suggestedArticle = hookArticle
                    showSuggestion = true
                    return // Esce dalla funzione, ignorando il resto
                }
            }
            // -------------------------------
            
            // 1. Filtro Candidati Standard
            var candidates = allArticles.filter { !isRead($0) }
            
            // 2. Se l'utente è FREE, togliamo quelli PRO dalla pesca casuale
            if !isPro {
                candidates = candidates.filter { !$0.isPro }
            }
            
            // 3. Ordinamento per Difficoltà (Beginner -> Intermediate -> Advanced)
            let beginners = candidates.filter { $0.difficulty == .beginner }
            if let pick = beginners.randomElement() {
                suggestedArticle = pick
                showSuggestion = true
                return
            }
            
            let intermediates = candidates.filter { $0.difficulty == .intermediate }
            if let pick = intermediates.randomElement() {
                suggestedArticle = pick
                showSuggestion = true
                return
            }
            
            let advanced = candidates.filter { $0.difficulty == .advanced }
            if let pick = advanced.randomElement() {
                suggestedArticle = pick
                showSuggestion = true
                return
            }
            
            // 4. Caso speciale: Ha finito tutto il materiale gratuito!
            // Mandiamolo su un articolo PRO a caso per tentare l'upsell
            if !isPro && candidates.isEmpty {
                suggestedArticle = allArticles.filter { !isRead($0) && $0.isPro }.randomElement()
                if suggestedArticle != nil {
                    showSuggestion = true
                }
            }
        }
    
    // MARK: - Detail Page Logic

        func filterArticlesForDetail(category: ArticleCategory, searchText: String) -> [Article] {
            let categoryArticles = contentService.allArticles.filter { $0.category == category }
            
            if searchText.isEmpty {
                return categoryArticles.sorted { $0.difficulty.rawValue < $1.difficulty.rawValue }
            } else {
                return categoryArticles
                    .filter { article in
                        // MODIFICA FONDAMENTALE:
                        // Cerchiamo dentro il titolo TRADOTTO (.localized), non nella chiave (es. savings_001)
                        article.title.localized.localizedCaseInsensitiveContains(searchText)
                    }
                    .sorted { $0.difficulty.rawValue < $1.difficulty.rawValue }
            }
        }
}
