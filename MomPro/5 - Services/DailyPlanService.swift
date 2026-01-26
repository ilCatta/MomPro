//
//  DailyPlanService.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation

@Observable
class DailyPlanService {
    static let shared = DailyPlanService()
    
    var dailyTasks: [DailyTaskStatus] = []
    var lastGeneratedDate: Date?
    
    // Wrapper per tracciare lo stato locale del task nel giorno corrente
    struct DailyTaskStatus: Identifiable, Codable {
        let id = UUID()
        let task: TaskItem
        var currentProgress: Int = 0 // Es. 1/3
        var isCompleted: Bool = false
    }
    
    private let kLastPlanDate = "lastPlanDate"
    private let kDailyTasksData = "dailyTasksData" // Chiave per il salvataggio JSON
    
    init() {
        // 1. Appena parte il servizio, proviamo a caricare i dati salvati
        loadPlan()
                    // 2. Poi controlliamo se serve rigenerarli (es. è cambiato giorno)
        checkAndRefreshDailyPlan()
    }
    
    func checkAndRefreshDailyPlan() {
            let today = Calendar.current.startOfDay(for: Date())
            let lastDate = UserDefaults.standard.object(forKey: kLastPlanDate) as? Date ?? Date.distantPast
            
            // Se non è lo stesso giorno, OPPURE se per qualche motivo la lista è vuota (es. primo avvio assoluto)
            if !Calendar.current.isDate(today, inSameDayAs: lastDate) || dailyTasks.isEmpty {
                
                // Se la lista è vuota ma è lo stesso giorno (bug fix), non rigenerare se abbiamo appena caricato dati validi
                // Ma se loadPlan ha fallito, allora rigeneriamo.
                if Calendar.current.isDate(today, inSameDayAs: lastDate) && !dailyTasks.isEmpty {
                    return
                }
                
                generateNewDailyPlan()
                
                // Aggiorna la data ultima generazione a Oggi
                UserDefaults.standard.set(today, forKey: kLastPlanDate)
            }
        }
        
        private func generateNewDailyPlan() {
            var newPlan: [DailyTaskStatus] = []
            
            // 1. Task Fisso: Leggere articolo
            let readingTask = ContentService.shared.getDailyReadingTask()
            newPlan.append(DailyTaskStatus(task: readingTask))
            
            // 2. Task Random: Prendi 4 random dal database (escludendo l'educazione se presente)
            // Filtriamo per non prendere task education nei random
            let availableTasks = ContentService.shared.allTasks.filter { $0.category != .education }.shuffled()
            let randomPicks = availableTasks.prefix(4)
            
            for task in randomPicks {
                newPlan.append(DailyTaskStatus(task: task))
            }
            
            self.dailyTasks = newPlan
            
            // SALVA APPENA GENERATI
            savePlan()
        }
        
        // Aggiorna progresso
        func updateTaskProgress(id: UUID, increment: Int = 1) {
            if let index = dailyTasks.firstIndex(where: { $0.id == id }) {
                var item = dailyTasks[index]
                
                // Evitiamo di andare oltre il target
                if item.currentProgress < item.task.targetCount {
                    item.currentProgress += increment
                }
                
                if item.currentProgress >= item.task.targetCount {
                    item.currentProgress = item.task.targetCount
                    if !item.isCompleted {
                        item.isCompleted = true
                        // Notifica il ProgressService globale
                        ProgressService.shared.completeTask()
                    }
                }
                dailyTasks[index] = item
                
                // SALVA AD OGNI MODIFICA
                savePlan()
            }
        }
    
    // Chiama questa funzione quando un articolo viene segnato come letto
        func completeEducationTask() {
            if let educationTaskIndex = dailyTasks.firstIndex(where: { $0.task.category == .education }) {
                if !dailyTasks[educationTaskIndex].isCompleted {
                    // Forziamo il completamento
                    // Nota: usiamo updateTaskProgress così salva e notifica il livello
                    let needed = dailyTasks[educationTaskIndex].task.targetCount - dailyTasks[educationTaskIndex].currentProgress
                    if needed > 0 {
                        updateTaskProgress(id: dailyTasks[educationTaskIndex].id, increment: needed)
                    }
                }
            }
        }
        
        // MARK: - Persistence (Salvataggio su Disco)
        
        private func savePlan() {
            do {
                let data = try JSONEncoder().encode(dailyTasks)
                UserDefaults.standard.set(data, forKey: kDailyTasksData)
            } catch {
                print("Errore nel salvataggio del piano giornaliero: \(error)")
            }
        }
        
        private func loadPlan() {
            guard let data = UserDefaults.standard.data(forKey: kDailyTasksData) else { return }
            
            do {
                dailyTasks = try JSONDecoder().decode([DailyTaskStatus].self, from: data)
            } catch {
                print("Errore nel caricamento del piano giornaliero: \(error)")
                // Se fallisce (es. cambio struttura dati), rigenererà un nuovo piano
                dailyTasks = []
            }
        }
}
