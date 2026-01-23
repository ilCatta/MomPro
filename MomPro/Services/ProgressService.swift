//
//  ProgressService.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation
import SwiftUI

@Observable // Usiamo la nuova macro di iOS 17+
class ProgressService {
    static let shared = ProgressService()
    
    // MARK: - User State
    var currentLevel: Int = 1
    var totalTasksCompleted: Int = 0
    var readArticleIDs: [String] = []
    
    // Persistence Keys
    private let kLevel = "userLevel"
    private let kTotalTasks = "totalTasks"
    private let kReadArticles = "readArticles"
    
    init() {
        loadProgress()
    }
    
    // MARK: - Actions
    
    func completeTask() {
        totalTasksCompleted += 1
        checkLevelUp()
        saveProgress()
    }
    
    func boostLevel() {
            // Aggiungiamo 5 task fittizi, che equivalgono esattamente a +1 Livello
            totalTasksCompleted += 5
            checkLevelUp()
            saveProgress()
        }
    
    func markArticleAsRead(articleId: String) {
        if !readArticleIDs.contains(articleId) {
            readArticleIDs.append(articleId)
            saveProgress()
            // Completare un articolo conta come completare un task?
            // Se sì, chiamiamo completeTask() dal ViewModel
           // print("Articolo salvato come letto: \(articleId)")
        }
    }

    
    private func checkLevelUp() {
        // Logica: Ogni 5 task = 1 livello
        // Livello = 1 + (Totale / 5)
        let newLevel = 1 + (totalTasksCompleted / 5)
        if newLevel > currentLevel {
            currentLevel = newLevel
            // Qui potremmo lanciare un evento per mostrare un popup di festa
            print("LEVEL UP! Ora sei livello \(currentLevel)")
        }
    }
    
    // MARK: - Mascotte Logic
    // Ritorna il nome dell'immagine della mascotte in base al livello
    var currentMascotImageName: String {
        switch currentLevel {
        case 1...3: return "mascotte_lvl1" // Pigiama
        case 4...8: return "mascotte_lvl2" // Casual
        case 9...15: return "mascotte_lvl3" // Business
        default: return "mascotte_lvl4" // Super Mamma
        }
    }
    
    // MARK: - Persistence
    private func saveProgress() {
        UserDefaults.standard.set(currentLevel, forKey: kLevel)
        UserDefaults.standard.set(totalTasksCompleted, forKey: kTotalTasks)
        // Salviamo direttamente l'array di stringhe, molto più semplice
        UserDefaults.standard.set(readArticleIDs, forKey: kReadArticles)
    }
    
    private func loadProgress() {
        currentLevel = UserDefaults.standard.integer(forKey: kLevel)
        if currentLevel == 0 { currentLevel = 1 }
        
        totalTasksCompleted = UserDefaults.standard.integer(forKey: kTotalTasks)
        
        // Carichiamo direttamente l'array di stringhe
        if let savedIDs = UserDefaults.standard.stringArray(forKey: kReadArticles) {
            readArticleIDs = savedIDs
        }
    }
    
    // Funzione Debug per reset
    func resetProgress() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        currentLevel = 1
        totalTasksCompleted = 0
        readArticleIDs = []
    }
}
