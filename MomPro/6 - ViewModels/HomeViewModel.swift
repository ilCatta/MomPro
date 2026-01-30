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
    
    // MARK: - Mascotte Assets (Varianti)
    private let mascotOptionsLv1 = ["mascotte_today_lv1_a", "mascotte_today_lv1_b", "mascotte_today_lv1_c", "mascotte_today_lv1_d"]
    private let mascotOptionsLv2 = ["mascotte_today_lv2_a", "mascotte_today_lv2_b", "mascotte_today_lv2_c"]
    private let mascotOptionsLv3 = ["mascotte_today_lv3_a", "mascotte_today_lv3_b", "mascotte_today_lv3_c"]
    private let mascotOptionsLv4 = ["mascotte_today_lv4_a", "mascotte_today_lv4_b", "mascotte_today_lv4_c"]
    private let mascotOptionsLv5 = ["mascotte_today_lv5_a", "mascotte_today_lv5_b", "mascotte_today_lv5_c"]
    // Varianti PRO
    private let mascotOptionsLv6 = ["mascotte_today_lv6_a", "mascotte_today_lv6_b", "mascotte_today_lv6_c"]
    private let mascotOptionsLv7 = ["mascotte_today_lv7_a", "mascotte_today_lv7_b", "mascotte_today_lv7_c"]

    // MARK: - Testi Motivazionali (Chiavi Localizzate)
    // 3 varianti per ogni livello, basate sul brief (Risparmio, No Stress, Investimenti)
    private let textOptionsLv1 = ["quote_today_lv1_a", "quote_today_lv1_b", "quote_today_lv1_c"] // Inizio
    private let textOptionsLv2 = ["quote_today_lv2_a", "quote_today_lv2_b", "quote_today_lv2_c"] // Riscaldamento
    private let textOptionsLv3 = ["quote_today_lv3_a", "quote_today_lv3_b", "quote_today_lv3_c"] // Metà strada
    private let textOptionsLv4 = ["quote_today_lv4_a", "quote_today_lv4_b", "quote_today_lv4_c"] // Quasi fatto
    private let textOptionsLv5 = ["quote_today_lv5_a", "quote_today_lv5_b", "quote_today_lv5_c"] // Base completata
    private let textOptionsLv6 = ["quote_today_lv6_a", "quote_today_lv6_b", "quote_today_lv6_c"] // Bonus 1
    private let textOptionsLv7 = ["quote_today_lv7_a", "quote_today_lv7_b", "quote_today_lv7_c"] // Tutto completato


    
    // Contiene TUTTI i 7 task (1 Edu + 4 Grid + 2 VIP)
    var dailyTasks: [DailyPlanService.DailyTaskStatus] = []
    
    var dailyArticle: Article?
    var showRefreshAlert = false
    
        
    // MARK: - Computed Properties (Task Separation)
    
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
    
    // MARK: - Helper Logica Giornaliera (STABILE)
        
    // Restituisce un elemento dall'array in base al giorno dell'anno.
    // Questo garantisce che per TUTTO il giorno l'utente veda la stessa variante,
    // ma il giorno dopo cambi automaticamente.
    private func getDailyVariant(for options: [String], salt: Int) -> String {
        guard !options.isEmpty else { return "" }
        
        let calendar = Calendar.current
        // Otteniamo il numero del giorno nell'anno (1...365)
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = calendar.component(.year, from: Date())
        
        // Creiamo un indice univoco combinando anno, giorno e un "sale" (per variare tra livelli)
        let uniqueIndex = dayOfYear + year + salt
        
        // Usiamo il modulo (%) per ruotare le opzioni
        return options[uniqueIndex % options.count]
    }
    
    
    // MODIFICA 2: Mascotte Dinamica con livelli PRO
    var dailyMascotImageName: String {
        let p = dailyProgress
        
        // FASE 1: Base incompleta -  Completamento Base (0% - 99%)
        // Se non hai finito la base, la mascotte segue la logica standard
        if p < 0.2 { return getDailyVariant(for: mascotOptionsLv1, salt: 1) }
        if p < 0.4 { return getDailyVariant(for: mascotOptionsLv2, salt: 2) }
        if p < 0.6 { return getDailyVariant(for: mascotOptionsLv3, salt: 3) }
        if p < 0.8 { return getDailyVariant(for: mascotOptionsLv4, salt: 4) }
        if p < 1.0 { return getDailyVariant(for: mascotOptionsLv5, salt: 5) } // Quasi finito
        
        // FASE 2: Base Completata (100%)
        // Se arriviamo qui, la base è finita.
        
        // Se l'utente NON è Pro, rimane semplicemente "Felice"
        if !storeService.isPro {
            return getDailyVariant(for: mascotOptionsLv5, salt: 5)
        }
        
        // Se l'utente È PRO, guardiamo i Bonus (VIP Tasks)
        let completedVipCount = vipTasks.filter { $0.isCompleted }.count
        
        if completedVipCount == 1 {
            return getDailyVariant(for: mascotOptionsLv6, salt: 6)
        } else if completedVipCount >= 2 {
            return getDailyVariant(for: mascotOptionsLv7, salt: 7)
        } else {
            // Base finita, nessun bonus ancora
            return getDailyVariant(for: mascotOptionsLv5, salt: 5)
        }
    }
    
    // MARK: - Testo Motivazionale (Data-Driven)
        
    var dailyMotivationalText: String {
        let p = dailyProgress
        
        // FASE 1: Incoraggiamento Iniziale
        if p < 0.2 { return getDailyVariant(for: textOptionsLv1, salt: 10) }
        
        // FASE 2: Momentum
        if p < 0.4 { return getDailyVariant(for: textOptionsLv2, salt: 20) }
        if p < 0.6 { return getDailyVariant(for: textOptionsLv3, salt: 30) }
        if p < 0.8 { return getDailyVariant(for: textOptionsLv4, salt: 40) }
        
        // FASE 3: Soddisfazione (Base 100%)
        if p < 1.0 { return getDailyVariant(for: textOptionsLv5, salt: 50) } // Quasi finito
        
        // FASE 4: Base Completata
        if !storeService.isPro {
            return getDailyVariant(for: textOptionsLv5, salt: 50)
        }
        
        // FASE 5: Bonus PRO
        let completedVipCount = vipTasks.filter { $0.isCompleted }.count
        
        if completedVipCount == 1 {
            return getDailyVariant(for: textOptionsLv6, salt: 60)
        } else if completedVipCount >= 2 {
            return getDailyVariant(for: textOptionsLv7, salt: 70)
        } else {
            return getDailyVariant(for: textOptionsLv5, salt: 50)
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
