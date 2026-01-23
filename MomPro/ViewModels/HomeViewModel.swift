//
//  HomeViewModel.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation
import SwiftUI // Serve per i colori o UI logic se necessario, ma meglio tenere UI fuori

@Observable
class HomeViewModel {
    // Dipendenze (Services)
    private var dailyPlanService = DailyPlanService.shared
    private var progressService = ProgressService.shared
    
    // MARK: - Output Properties (Stato per la View)
    
    // Tasks del giorno
    var dailyTasks: [DailyPlanService.DailyTaskStatus] {
        dailyPlanService.dailyTasks
    }
    
    // Dati Mascotte e Livello
    var currentLevel: Int {
        progressService.currentLevel
    }
    
    var dailyMascotImageName: String {
            let total = dailyTasks.count
            if total == 0 { return "mascotte_home_start" } // Caso limite
            
            let completed = dailyTasks.filter { $0.isCompleted }.count
            
            if completed == 0 {
                // Nessun task fatto: Mascotte in attesa / annoiata / triste
                return "mascotte_home_start"
            } else if completed == total {
                // Tutti i task fatti: Mascotte che festeggia / rilassata
                return "mascotte_home_party"
            } else {
                // Nel mezzo: Mascotte al lavoro / concentrata
                return "mascotte_home_working"
            }
        }
    
    // Progresso giornaliero (0.0 a 1.0) per la barra
    var dailyProgress: Double {
        let total = Double(dailyTasks.count)
        if total == 0 { return 0 }
        let completed = Double(dailyTasks.filter { $0.isCompleted }.count)
        return completed / total
    }
    
    // Consiglio del giorno (Randomico o logica complessa)
    // MARK: - Daily Tip Logic
        // TODO: IMPLEMENTARE LOGICA DINAMICA (Post-MVP)
        // Obbiettivo: Mostrare un consiglio diverso ogni giorno pescato da un database locale.
        //
        // 1. Data Source:
        //    - Creare una struct `Tip` in ContentService.
        //    - Popolare `ContentService` con una lista di 20-30 consigli su: Spesa, Batch Cooking, Mindset, Investimenti Base.
        //
        // 2. Logica di Selezione:
        //    - NON deve essere puramente random (altrimenti cambia se chiudo e riapro l'app).
        //    - Deve essere basato sulla data odierna (es. `tips[dayOfYear % tips.count]`) così tutti gli utenti vedono lo stesso consiglio quel giorno, oppure rimane fisso per 24h.
        //
        // 3. Esempi di Copy:
        //    - "Non andare mai a fare la spesa quando hai fame."
        //    - "Controlla il prezzo al KG, non quello della confezione."
        //    - "Hai cucinato troppo? Congela subito una porzione."
    var dailyTip: String = "I saldi iniziano tra 30 giorni, evita di comprare vestiti ora!"
    
    // MARK: - User Intent (Actions)
    
    func refreshData() {
        dailyPlanService.checkAndRefreshDailyPlan()
    }
    
    // Quando l'utente clicca "Fatto" su un task semplice
    func completeSimpleTask(taskId: UUID) {
        // Incrementiamo di 1 (per i task semplici il target è 1)
        dailyPlanService.updateTaskProgress(id: taskId)
    }
    
    // Quando l'utente aggiunge +1 a un task contatore (es. "Ho comprato 1 alimento")
    func incrementTaskProgress(taskId: UUID) {
        dailyPlanService.updateTaskProgress(id: taskId)
    }
    
    // Helper per colore card
    func colorForTaskStatus(_ taskStatus: DailyPlanService.DailyTaskStatus) -> Color {
        if taskStatus.isCompleted {
            return .green.opacity(0.8) // Eccellente/Fatto
        } else if taskStatus.currentProgress > 0 {
            return .blue.opacity(0.8) // In corso
        } else {
            return .red.opacity(0.7) // Da iniziare
        }
    }
}
