import Foundation
import SwiftUI
import Observation

@Observable
class StatsViewModel {
    
    // MARK: - Dati Utente
    var totalTasksCompleted: Int = 42
    var articlesRead: Int = 7
    var currentStreak: Int = 5
    var bestStreak: Int = 12
    var hasUsedBoost: Bool = false
    
    var dailyMascotImageName: String = "mascotte_level_2"
    
    // MARK: - Logica Livello
    var currentLevel: Int {
        return (totalTasksCompleted / 15) + 1
    }
    
    var tasksInCurrentLevel: Int {
        return totalTasksCompleted % 15
    }
    
    var tasksToNextLevel: Int {
        return 15 - tasksInCurrentLevel
    }
    
    var levelProgress: Double {
        return Double(tasksInCurrentLevel) / 15.0
    }
    
    var levelTitle: String {
        switch currentLevel {
        case 1...3: return "Mamma in Pigiama"
        case 4...8: return "Mamma Organizzata"
        case 9...15: return "Mamma Boss"
        default: return "Regina delle Finanze"
        }
    }
    
    var timeInvestedString: String {
        let minutes = totalTasksCompleted * 10
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return String(format: "%dh %02dm", hours, mins)
        }
    }
    
    // MARK: - Dati Grafico (Ultimi 7 giorni)
    struct DailyStat: Identifiable {
        let id = UUID()
        let date: Date
        let completed: Int
        let goal: Int // Obiettivo giornaliero (es. 5 task)
    }
    
    var chartData: [DailyStat] = []
    
    init() {
        generateChartData()
    }
    
    func generateChartData() {
        var data: [DailyStat] = []
        let calendar = Calendar.current
        
        // MODIFICA: Solo 7 giorni (0...6) invece di 11
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let goal = 5
                // Dati casuali per demo
                let completed = Int.random(in: 1...6)
                data.append(DailyStat(date: date, completed: completed, goal: goal))
            }
        }
        self.chartData = data
    }
    
    func applyBoost() {
        if !hasUsedBoost {
            totalTasksCompleted += 5
            hasUsedBoost = true
        }
    }
}
