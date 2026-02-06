/*
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
*/


//
//  ProgressService.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation
import SwiftUI


// MARK: - Modello Storico Giornaliero
struct DailyHistoryLog: Codable {
    let date: Date
    var tasksCompleted: Int
    var articlesRead: Int
    var minutesInvested: Int
}

@Observable
class ProgressService {
    static let shared = ProgressService()
    
    // MARK: - User State
    var totalTasksCompleted: Int = 0
    var bonusLevels: Int = 0 // Livelli guadagnati extra (es. Invita amico)
    var readArticleIDs: [String] = []
    
    // Storico: [Key "yyyy-MM-dd" : Log]
        private var history: [String: DailyHistoryLog] = [:]
    
    // Persistence Keys
    private let kTotalTasks = "totalTasks"
    private let kBonusLevels = "bonusLevels"
    private let kReadArticles = "readArticles"
    private let kHistory = "historyLog"
    private let kBestStreak = "bestStreak"
    
    // Variabile per il Record
    var bestStreak: Int = 0
    
    init() {
        loadProgress()
    }
    
    // MARK: - Calcolo Livello (Matematica Reale)
    
    // Il livello è: 1 (base) + (Task Reali / 5) + Livelli Bonus
    var currentLevel: Int {
        return 1 + (totalTasksCompleted / 5) + bonusLevels
    }
    
    // Calcoliamo quanti task mancano al prossimo "scatto" di livello (basato sui 5 task)
    var tasksInCurrentCycle: Int {
        return totalTasksCompleted % 5
    }
    
    var tasksToNextLevel: Int {
        return 5 - tasksInCurrentCycle
    }
    
    var levelProgress: Double {
        return Double(tasksInCurrentCycle) / 5.0
    }
    
    // MARK: - Gestione Traguardi (21 Step in 3 anni)
    // Target finale: Livello ~1095 (3 anni * 365 giorni * 1 livello al giorno)
    
    struct Milestone {
        let thresholdLevel: Int
        let imageName: String
        let title: String
    }
    
    // Definizione dei 21 Traguardi con curva esponenziale
    // I nomi delle immagini sono placeholder (es. "milestone_01"), assicurati di averli negli Assets o rinomina qui.
    private let milestones: [Milestone] = [
        Milestone(thresholdLevel: 1,    imageName: "milestone_01", title: "Inizio del Viaggio"),
        Milestone(thresholdLevel: 3,    imageName: "milestone_02", title: "Primi Passi"),       // Gratificazione veloce
        Milestone(thresholdLevel: 10,   imageName: "milestone_03", title: "Piccoli Risparmi"),  // Primo impegno
        Milestone(thresholdLevel: 20,   imageName: "milestone_04", title: "Mamma Attenta"),
        Milestone(thresholdLevel: 35,   imageName: "milestone_05", title: "Gestione Consapevole"),
        Milestone(thresholdLevel: 50,   imageName: "milestone_06", title: "Mamma Organizzata"),
        Milestone(thresholdLevel: 70,   imageName: "milestone_07", title: "Cacciatrice di Offerte"),
        Milestone(thresholdLevel: 95,   imageName: "milestone_08", title: "Esperta del Budget"),
        Milestone(thresholdLevel: 125,  imageName: "milestone_09", title: "Mamma Strategica"),
        Milestone(thresholdLevel: 160,  imageName: "milestone_10", title: "Risparmiatrice Pro"), // ~Mezzo anno
        Milestone(thresholdLevel: 200,  imageName: "milestone_11", title: "Guardiana del Focolare"),
        Milestone(thresholdLevel: 250,  imageName: "milestone_12", title: "Mamma Boss"),
        Milestone(thresholdLevel: 310,  imageName: "milestone_13", title: "Visionaria"),
        Milestone(thresholdLevel: 380,  imageName: "milestone_14", title: "Architetto Finanziario"),
        Milestone(thresholdLevel: 460,  imageName: "milestone_15", title: "Investitrice Saggia"),
        Milestone(thresholdLevel: 550,  imageName: "milestone_16", title: "Matriarca Digitale"), // ~1 anno e mezzo
        Milestone(thresholdLevel: 650,  imageName: "milestone_17", title: "Guru dell'Efficienza"),
        Milestone(thresholdLevel: 770,  imageName: "milestone_18", title: "Icona di Stile"),
        Milestone(thresholdLevel: 900,  imageName: "milestone_19", title: "Leggenda Domestica"),
        Milestone(thresholdLevel: 1000, imageName: "milestone_20", title: "Imperatrice"),
        Milestone(thresholdLevel: 1095, imageName: "milestone_21", title: "Regina delle Finanze") // Target 3 anni
    ]
    
    // Restituisce il traguardo corrente in base al livello raggiunto
    var currentMilestone: Milestone {
        // Cerca l'ultimo traguardo che ha una soglia inferiore o uguale al livello attuale
        return milestones.last(where: { currentLevel >= $0.thresholdLevel }) ?? milestones[0]
    }
    
    // Accessor rapidi per la UI
    var currentMilestoneImage: String { currentMilestone.imageName }
    var currentMilestoneTitle: String { currentMilestone.title }
    
    
    // MARK: - Calcolo Streak (Logica Reale)
    var currentStreak: Int {
        let sortedKeys = history.keys.sorted(by: >) // Date dalla più recente alla meno recente
        guard !sortedKeys.isEmpty else { return 0 }
        
        var streak = 0
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Formattiamo le date per confrontarle con le chiavi dello storico
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let todayKey = fmt.string(from: today)
        let yesterdayKey = fmt.string(from: yesterday)
        
        // Se non ho fatto nulla né oggi né ieri, lo streak è perso (0).
        // A meno che non sia il primo giorno assoluto.
        let hasActivityToday = history[todayKey] != nil
        let hasActivityYesterday = history[yesterdayKey] != nil
        
        if !hasActivityToday && !hasActivityYesterday {
            return 0
        }
        
        // Calcoliamo la catena
        // Partiamo da oggi (se c'è attività) o da ieri (se oggi non ho ancora fatto nulla ma la catena è attiva)
        var checkDate = hasActivityToday ? today : yesterday
        
        while true {
            let key = fmt.string(from: checkDate)
            if history[key] != nil {
                streak += 1
                // Andiamo indietro di un giorno
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break // Catena spezzata
            }
        }
        
        return streak
    }
    
    // Helper interno per aggiornare il record
    private func updateBestStreak() {
        let current = currentStreak
        if current > bestStreak {
            bestStreak = current
        }
    }
    
    
    // MARK: - Actions
    
    func completeTask() {
        totalTasksCompleted += 1
        logDailyActivity(tasks: 1, articles: 0, minutes: 2) // Standard 2 min per task
        updateBestStreak() // Controlliamo se abbiamo battuto il record
        saveProgress()
    }
    
    // Questo preserva la correttezza statistica (non ho fatto 5 task, ho solo ricevuto un premio).
    func boostLevel() {
        bonusLevels += 1
        saveProgress()
    }
    
    // Chiamata quando si legge un articolo
    func markArticleAsRead(articleId: String, readTime: Int = 3) {
        if !readArticleIDs.contains(articleId) {
            readArticleIDs.append(articleId)
            // Logghiamo l'attività storica (che è separata dal completamento task per livello)
            logDailyActivity(tasks: 0, articles: 1, minutes: readTime)
            updateBestStreak() // Anche leggere mantiene lo streak
            saveProgress()
        }
    }
    
    // MARK: - History Logic
        
    private func logDailyActivity(tasks: Int, articles: Int, minutes: Int) {
        let key = Date().formattedYYYYMMDD
        var log = history[key] ?? DailyHistoryLog(date: Date(), tasksCompleted: 0, articlesRead: 0, minutesInvested: 0)
        
        log.tasksCompleted += tasks
        log.articlesRead += articles
        log.minutesInvested += minutes
        
        history[key] = log
    }
    
    // API per StatsViewModel per recuperare i dati storici
    func getHistory(for date: Date) -> DailyHistoryLog? {
        return history[date.formattedYYYYMMDD]
    }
    
    // Recupera tutto lo storico (per aggregazioni mensili/annuali)
    func getAllHistory() -> [DailyHistoryLog] {
        return Array(history.values)
    }
    
    // MARK: - Persistence
    private func saveProgress() {
        UserDefaults.standard.set(totalTasksCompleted, forKey: kTotalTasks)
        UserDefaults.standard.set(bonusLevels, forKey: kBonusLevels)
        UserDefaults.standard.set(readArticleIDs, forKey: kReadArticles)
        UserDefaults.standard.set(bestStreak, forKey: kBestStreak)
        //
        // Salvataggio Storico (Codifica JSON)
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: kHistory)
        }
    }
    
    private func loadProgress() {
            totalTasksCompleted = UserDefaults.standard.integer(forKey: kTotalTasks)
            bonusLevels = UserDefaults.standard.integer(forKey: kBonusLevels)
            bestStreak = UserDefaults.standard.integer(forKey: kBestStreak) // Carichiamo il record
            
            if let savedIDs = UserDefaults.standard.stringArray(forKey: kReadArticles) {
                readArticleIDs = savedIDs
            }
            
            // Caricamento Storico
            if let data = UserDefaults.standard.data(forKey: kHistory),
               let decoded = try? JSONDecoder().decode([String: DailyHistoryLog].self, from: data) {
                history = decoded
            }
        }
    
    // Funzione Debug per reset
    func resetProgress() {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            totalTasksCompleted = 0
            bonusLevels = 0
            readArticleIDs = []
            history = [:]
        }
}

// Helper data
extension Date {
    var formattedYYYYMMDD: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
