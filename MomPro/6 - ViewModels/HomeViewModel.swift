//
//  HomeViewModel.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//


import SwiftUI
import Observation

@Observable
class HomeViewModel {
    private var dailyService = DailyPlanService.shared
    private var storeService = StoreService.shared
    
    private var randomMascotVariant1: String = "mascotte_today_lv1_a"
    private var randomMascotVariant2: String = "mascotte_today_lv2_a"
    private var randomMascotVariant3: String = "mascotte_today_lv3_a"
    private var randomMascotVariant4: String = "mascotte_today_lv4_a"
    private var randomMascotVariant5: String = "mascotte_today_lv5_a"
    private var randomMascotVariant6: String = "mascotte_today_lv6_a"
    private var randomMascotVariant7: String = "mascotte_today_lv7_a"

    private let options1 = ["mascotte_today_lv1_a", "mascotte_today_lv1_b", "mascotte_today_lv1_c", "mascotte_today_lv1_d"]
    private let options2 = ["mascotte_today_lv2_a", "mascotte_today_lv2_b", "mascotte_today_lv2_c"]
    private let options3 = ["mascotte_today_lv3_a", "mascotte_today_lv3_b", "mascotte_today_lv3_c"]
    private let options4 = ["mascotte_today_lv4_a", "mascotte_today_lv4_b", "mascotte_today_lv4_c"]
    private let options5 = ["mascotte_today_lv5_a", "mascotte_today_lv5_b", "mascotte_today_lv5_c"]
    private let options6 = ["mascotte_today_lv6_a", "mascotte_today_lv6_b", "mascotte_today_lv6_c"]
    private let options7 = ["mascotte_today_lv7_a", "mascotte_today_lv7_b", "mascotte_today_lv7_c"]


    
    
    // Contiene TUTTI i 7 task (1 Edu + 4 Grid + 2 VIP)
    var dailyTasks: [DailyPlanService.DailyTaskStatus] = []
    
    var dailyArticle: Article?
    var showRefreshAlert = false
    
        
    // MARK: - Separazione Intelligente dei Task
    
    // Il 1° task è sempre quello Educativo
    var educationTaskStatus: DailyPlanService.DailyTaskStatus? {
        guard !dailyTasks.isEmpty else { return nil }
        return dailyTasks.first
    }
    
    // I 4 task centrali sono la Griglia (Base)
    var gridTasks: [DailyPlanService.DailyTaskStatus] {
        guard dailyTasks.count >= 5 else { return [] }
        // Prende dal secondo al quinto elemento (indici 1, 2, 3, 4)
        return Array(dailyTasks[1..<5])
    }
    
    // Gli ultimi 2 sono i Bonus VIP
    var vipTasks: [DailyPlanService.DailyTaskStatus] {
        guard dailyTasks.count >= 7 else { return [] }
        // Prende gli ultimi 2
        return Array(dailyTasks.suffix(2))
    }
    
    // Scorciatoia per la UI
    var freeTasks: [DailyPlanService.DailyTaskStatus] {
        return gridTasks
    }
    
    // Stato completamento articolo (per la Wisdom Card)
    var isEducationTaskCompleted: Bool {
        return educationTaskStatus?.isCompleted ?? false
    }
    
    // MARK: - Stati Calcolati
    
    var canRefresh: Bool {
        dailyService.canRefresh()
    }
    
    var remainingRefreshes: Int {
        dailyService.remainingRefreshes
    }
    
    // MODIFICA 1: Progresso Totale (Base 5 Task)
    var dailyProgress: Double {
        // La base è composta da: 1 Edu + 4 Grid = 5 Task Totali
        let baseTotal: Double = 5.0
        
        // Contiamo quelli fatti
        var completedCount = 0.0
        
        // 1. Articolo
        if isEducationTaskCompleted {
            completedCount += 1
        }
        
        // 2. Griglia
        completedCount += Double(gridTasks.filter { $0.isCompleted }.count)
        
        return completedCount / baseTotal
    }
    
    // --- NUOVA FUNZIONE ---
        // Chiamata quando la vista appare
        func randomizeMascotVariant() {
            self.randomMascotVariant1 = options1.randomElement() ?? "mascotte_today_lv1_a"
            self.randomMascotVariant2 = options2.randomElement() ?? "mascotte_today_lv2_a"
            self.randomMascotVariant3 = options3.randomElement() ?? "mascotte_today_lv3_a"
            self.randomMascotVariant4 = options4.randomElement() ?? "mascotte_today_lv4_a"
            self.randomMascotVariant5 = options5.randomElement() ?? "mascotte_today_lv5_a"
            self.randomMascotVariant6 = options6.randomElement() ?? "mascotte_today_lv6_a"
            self.randomMascotVariant7 = options7.randomElement() ?? "mascotte_today_lv7_a"
        }
    
    
    // MODIFICA 2: Mascotte Dinamica con livelli PRO
    var dailyMascotImageName: String {
        let p = dailyProgress
        
        // FASE 1: Completamento Base (0% - 99%)
        // Se non hai finito la base, la mascotte segue la logica standard
        if p < 1.0 {
            if p < 0.2 { return randomMascotVariant1 }
            if p < 0.4 { return randomMascotVariant2 }
            if p < 0.6 { return randomMascotVariant3 }
            if p < 0.8 { return randomMascotVariant4 }
            return randomMascotVariant5
        }
        
        // FASE 2: Base Completata (100%)
        // Se arriviamo qui, la base è finita.
        
        // Se l'utente NON è Pro, rimane semplicemente "Felice"
        if !storeService.isPro {
            return randomMascotVariant5
        }
        
        // Se l'utente È PRO, guardiamo i Bonus (VIP Tasks)
        let completedVipCount = vipTasks.filter { $0.isCompleted }.count
        
        if completedVipCount == 1 {
            return randomMascotVariant6 // Ha fatto 1 bonus su 2
        } else if completedVipCount >= 2 {
            return randomMascotVariant7 // Ha fatto tutto (Super Mamma Livello Massimo)
        } else {
            // Ha finito la base ma nessun bonus ancora
            return randomMascotVariant5
        }
    }
    
    // MARK: - Init & Load
    
    init() {
        refreshData()
    }
    
    func refreshData() {
        self.dailyTasks = dailyService.getOrGenerateDailyPlan()
        self.dailyArticle = dailyService.getDailyArticle()
    }
    
    // MARK: - Actions
    
    func completeSimpleTask(taskId: UUID) {
        if let index = dailyTasks.firstIndex(where: { $0.id == taskId }) {
            dailyTasks[index].isCompleted = true
            dailyService.completeTask(taskId: dailyTasks[index].task.id)
        }
    }
    
    func incrementTaskProgress(taskId: UUID) {
            guard let index = dailyTasks.firstIndex(where: { $0.id == taskId }) else { return }
        
            let target = dailyTasks[index].task.targetCount

            // --- AGGIUNTA DI SICUREZZA ---
            // Se il task è già completato o ha raggiunto il target, non fare nulla.
            if dailyTasks[index].currentProgress >= target { return }
            // -----------------------------
            
            // 1. Incrementiamo in memoria (per aggiornare la UI subito)
            dailyTasks[index].currentProgress += 1
            
            // 2. [NUOVO] Diciamo al Service di salvare questo numero nel disco
            // Usiamo task.id (che è stabile) non dailyTasks[index].id (che cambia ogni avvio)
            dailyService.updateProgress(taskId: dailyTasks[index].task.id, newProgress: dailyTasks[index].currentProgress)
            
            // 3. Controllo completamento
            //let target = dailyTasks[index].task.targetCount
            if dailyTasks[index].currentProgress >= target {
                dailyTasks[index].isCompleted = true
                dailyService.completeTask(taskId: dailyTasks[index].task.id)
            }
        }
    
    func requestRefresh(for task: DailyPlanService.DailyTaskStatus) {
        if dailyService.refreshTask(taskToReplace: task) != nil {
            refreshData()
        }
    }
    
    func colorForTaskStatus(_ status: DailyPlanService.DailyTaskStatus) -> Color {
        // Se è VIP e l'utente NON è Pro, è grigio
        // Nota: vipTasks sono identificati dalla posizione, ma possiamo usare ancora isLocked come controllo extra
        if status.isLocked && !storeService.isPro { return .gray.opacity(0.5) }
        
        switch status.task.category {
        case .shopping: return .orange
        case .home: return .blue
        case .finance: return .green
        case .family: return .pink
        case .education: return .purple
        }
    }
}
