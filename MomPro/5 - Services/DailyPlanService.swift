//
//  DailyPlanService.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//


import Foundation
import SwiftUI


class DailyPlanService {
    static let shared = DailyPlanService()
    
    // Chiavi per salvare i dati
    private let kLastGenerationDate = "lastGenerationDate"
    private let kDailyTaskIDs = "dailyTaskIDs"
    private let kDailyArticleID = "dailyArticleID"
    private let kCompletedTaskIDs = "completedTaskIDs_today"
        
    // MODIFICA: Usiamo un contatore invece di un booleano
    private let kRefreshCount = "refreshCount_today"
    // NUOVO: Chiave per salvare i progressi parziali (es. 1/3, 2/5) di TUTTI i task
    private let kTaskProgress = "taskProgress_today"
    
    struct DailyTaskStatus: Identifiable {
        let id: UUID
        let task: TaskItem
        var isCompleted: Bool
        var currentProgress: Int
        var isLocked: Bool
    }
    
    // MARK: - API Pubbliche
    
    func getDailyArticle() -> Article? {
        let allArticles = ContentService.shared.allArticles
        // Logica semplice: primo non letto o random
        return allArticles.first
    }
    
    func getOrGenerateDailyPlan() -> [DailyTaskStatus] {
            let today = Calendar.current.startOfDay(for: Date())
            let lastDate = UserDefaults.standard.object(forKey: kLastGenerationDate) as? Date ?? Date.distantPast
            
            // 1. Se è un nuovo giorno, rigenera
            if !Calendar.current.isDate(today, inSameDayAs: lastDate) {
                generateNewDailyPlan(date: today)
            }
            
            // 2. Carica da disco
            var plan = loadDailyPlanFromDisk()
            
            // --- SAFETY CHECK MIGLIORATO ---
            // Controlliamo se abbiamo "perso" dei task per strada.
            // Il minimo sindacale è 7 (1 Articolo + 4 Task Griglia + 2 task pro).
            // Se ne abbiamo meno, significa che gli ID vecchi non combaciano più -> Rigeneriamo.
            if plan.count < 7 {
                print("⚠️ Piano incompleto (Trovati solo \(plan.count) task). Rigenerazione forzata con nuovi ID stabili.")
                generateNewDailyPlan(date: today)
                plan = loadDailyPlanFromDisk()
            }
            // -------------------------------
            
            return plan
        }
    
    func completeTask(taskId: UUID) {
            var completed = getCompletedIDs()
            // Se il task non era già stato completato oggi...
            if !completed.contains(taskId.uuidString) {
                // 1. Salva lo stato locale (Spunta verde nella Home)
                completed.insert(taskId.uuidString)
                saveCompletedIDs(completed)
                // 2. Avvisa il ProgressService globale (Incrementa Livello)
                ProgressService.shared.completeTask()
                // Debug Log
                //print("Task Completato! Totale aggiornato: \(ProgressService.shared.totalTasksCompleted)")
            }
        }
    
    // MARK: - Helper Education
    func completeEducationTask() {
        let currentPlan = getOrGenerateDailyPlan()
        if let eduTaskStatus = currentPlan.first(where: { $0.task.category == .education }) {
            if !eduTaskStatus.isCompleted {
                completeTask(taskId: eduTaskStatus.task.id)
            }
        }
    }
    
    // MARK: - MAGIC REFRESH LOGIC (AGGIORNATA)
    
    // Calcola quanti cambi rimangono
    var remainingRefreshes: Int {
        let used = UserDefaults.standard.integer(forKey: kRefreshCount)
        // Se PRO: 2 cambi, Se FREE: 1 cambio
        let limit = StoreService.shared.isPro ? 2 : 1
        return max(0, limit - used)
    }
    
    func canRefresh() -> Bool {
        return remainingRefreshes > 0
    }
    
    func refreshTask(taskToReplace: DailyTaskStatus) -> DailyTaskStatus? {
        guard canRefresh() else { return nil }
        
        let allTasks = ContentService.shared.allTasks
        let category = taskToReplace.task.category
        
        // Cerca sostituti: Stessa categoria, FREE, NON il task attuale
        let candidates = allTasks.filter {
            $0.category == category &&
            !$0.isPro &&
            $0.id != taskToReplace.task.id
        }
        
        guard let newTemplate = candidates.randomElement() else { return nil }
        
        // INCREMENTA IL CONTATORE
        let currentCount = UserDefaults.standard.integer(forKey: kRefreshCount)
        UserDefaults.standard.set(currentCount + 1, forKey: kRefreshCount)
        
        updatePersistedPlan(oldTaskID: taskToReplace.task.id, newTaskID: newTemplate.id)
        
        return DailyTaskStatus(id: UUID(), task: newTemplate, isCompleted: false, currentProgress: 0, isLocked: false)
    }
    
    // MARK: - Private
    
    private func generateNewDailyPlan(date: Date) {
        let contentService = ContentService.shared
        var selectedTaskIDs: [String] = []
        let isUserPro = StoreService.shared.isPro
        
        // 1. [FIX] AGGIUNGI SEMPRE IL TASK EDUCATION PER PRIMO
        selectedTaskIDs.append(contentService.educationTask.id.uuidString)
        
        let categories: [TaskCategory] = [.shopping, .finance, .home, .family]
        
        for cat in categories {
            let candidates = contentService.allTasks.filter { task in
                if task.category != cat { return false }
                if isUserPro { return true } else { return !task.isPro }
            }
            
            if let pick = candidates.randomElement() {
                selectedTaskIDs.append(pick.id.uuidString)
            }
        }
        
        let proCandidates = contentService.allTasks.filter { $0.isPro }
        let availablePro = proCandidates.filter { !selectedTaskIDs.contains($0.id.uuidString) }
        let proPicks = availablePro.shuffled().prefix(2)
        selectedTaskIDs.append(contentsOf: proPicks.map { $0.id.uuidString })
        
        UserDefaults.standard.set(date, forKey: kLastGenerationDate)
        UserDefaults.standard.set(selectedTaskIDs, forKey: kDailyTaskIDs)
        UserDefaults.standard.set(0, forKey: kRefreshCount) // RESETTA IL CONTATORE A 0
        saveCompletedIDs([])
        
        // Quando inizia un nuovo giorno, cancelliamo tutti i progressi parziali di ieri
        UserDefaults.standard.removeObject(forKey: kTaskProgress)
    }
    
    private func loadDailyPlanFromDisk() -> [DailyTaskStatus] {
            guard let ids = UserDefaults.standard.stringArray(forKey: kDailyTaskIDs) else { return [] }
            let completed = getCompletedIDs()
            let allTasks = ContentService.shared.allTasks
            
            return ids.compactMap { idString in
                // [FIX] Cerca prima nei task normali (Shopping, Home, ecc.)
                var originalTask = allTasks.first(where: { $0.id.uuidString == idString })
                
                // [FIX] Se non lo trova, controlla se è il task Education speciale
                // (Il task Education non è nella lista 'allTasks' standard, quindi dobbiamo cercarlo esplicitamente)
                if originalTask == nil && idString == ContentService.shared.educationTask.id.uuidString {
                    originalTask = ContentService.shared.educationTask
                }
                
                guard let task = originalTask else { return nil }
                
                // AGGIUNGI: Recuperiamo il progresso specifico per QUESTO task
                let savedProgress = getSavedProgress(for: task.id.uuidString)
                
                return DailyTaskStatus(
                    id: UUID(),
                    task: task,
                    isCompleted: completed.contains(task.id.uuidString),
                    currentProgress: savedProgress,
                    isLocked: task.isPro
                )
            }
        }
    
    private func getCompletedIDs() -> Set<String> {
        let array = UserDefaults.standard.stringArray(forKey: kCompletedTaskIDs) ?? []
        return Set(array)
    }
    
    private func saveCompletedIDs(_ ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: kCompletedTaskIDs)
    }
    
    private func updatePersistedPlan(oldTaskID: UUID, newTaskID: UUID) {
        guard var ids = UserDefaults.standard.stringArray(forKey: kDailyTaskIDs) else { return }
        if let index = ids.firstIndex(of: oldTaskID.uuidString) {
            ids[index] = newTaskID.uuidString
            UserDefaults.standard.set(ids, forKey: kDailyTaskIDs)
        }
    }
    
    // MARK: - Gestione Progresso Multiplo
        
        // Salva il progresso di un task specifico senza toccare gli altri
        func updateProgress(taskId: UUID, newProgress: Int) {
            // 1. Carichiamo il dizionario attuale (es. {"TaskA": 1})
            var progressDict = UserDefaults.standard.dictionary(forKey: kTaskProgress) as? [String: Int] ?? [:]
            
            // 2. Aggiorniamo solo il task corrente (es. aggiungiamo "TaskB": 2)
            progressDict[taskId.uuidString] = newProgress
            
            // 3. Salviamo tutto il dizionario aggiornato
            UserDefaults.standard.set(progressDict, forKey: kTaskProgress)
        }

        // Legge il progresso di un singolo task
        private func getSavedProgress(for taskIdString: String) -> Int {
            let progressDict = UserDefaults.standard.dictionary(forKey: kTaskProgress) as? [String: Int] ?? [:]
            // Se troviamo un valore per questo ID lo restituiamo, altrimenti 0
            return progressDict[taskIdString] ?? 0
        }
}
