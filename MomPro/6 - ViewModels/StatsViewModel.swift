import Foundation
import SwiftUI

@Observable
class StatsViewModel {
    private var progressService = ProgressService.shared
    
    // MARK: - Output
    
    var currentLevel: Int {
        progressService.currentLevel
    }
    
    // Qui usiamo la logica del LIVELLO (Pigiama -> SuperMamma)
    // Assicurati di avere le immagini in Assets: mascotte_lvl1, mascotte_lvl2, etc.
    var levelMascotImageName: String {
        progressService.currentMascotImageName
    }
    
    // Dati per il grafico
    var historyData: [DailyHistoryItem] = []
    
    // Stato per il bottone Boost (lo nascondiamo se già usato)
    var hasUsedBoost: Bool {
        get { UserDefaults.standard.bool(forKey: "hasUsedBoost") }
        set { UserDefaults.standard.set(newValue, forKey: "hasUsedBoost") }
    }
    
    // MARK: - Init
    
    init() {
        generateMockHistory()
    }
    
    // MARK: - Logic
    
    // Genera dati finti per visualizzare il grafico
    private func generateMockHistory() {
        var mockItems: [DailyHistoryItem] = []
        let calendar = Calendar.current
        
        // Generiamo gli ultimi 30 giorni
        for i in 0..<30 {
            // Data a ritroso (oggi, ieri, l'altro ieri...)
            if let date = calendar.date(byAdding: .day, value: -((29 - i)), to: Date()) {
                
                // Randomizziamo i task completati (0 a 5)
                // Trucco: Facciamo pesare di più i valori alti per far sembrare l'utente bravo
                let randomCount = [0, 1, 2, 3, 3, 4, 4, 5, 5, 5].randomElement() ?? 0
                
                mockItems.append(DailyHistoryItem(date: date, tasksCompleted: randomCount))
            }
        }
        self.historyData = mockItems
    }
    
    // Logica Colori Brief:
    // Verde (5), Rosa (3-4), Giallo (1-2), Grigio (0)
    func colorForCount(_ count: Int) -> Color {
        switch count {
        case 5: return .green      // Eccellente
        case 3...4: return .pink   // Buono
        case 1...2: return .yellow // Ok
        default: return .gray.opacity(0.3) // Insufficiente
        }
    }
    
    func heightRatioForCount(_ count: Int) -> CGFloat {
        // Altezza barra in base al numero (0.1 minimo per vederla)
        let maxTasks = 5.0
        let val = Double(count)
        return max(0.1, val / maxTasks)
    }
    
    // MARK: - Actions
    
    func applyBoost() {
            // Controllo di sicurezza: se l'ha già usato, esce subito
            guard !hasUsedBoost else { return }
            
            // 1. Deleghiamo al service la logica di business
            progressService.boostLevel()
            
            // 2. Aggiorniamo lo stato locale per nascondere il bottone per sempre
            hasUsedBoost = true
            
            // Nota: Poiché ProgressService è @Observable, la UI si aggiornerà
            // automaticamente mostrando il nuovo livello e la nuova mascotte.
        }
}

// Struttura dati semplice per il grafico
struct DailyHistoryItem: Identifiable {
    let id = UUID()
    let date: Date
    let tasksCompleted: Int
}
