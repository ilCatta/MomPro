import SwiftUI
import Observation
import Foundation

// Enum per il selettore
enum TimeFrame: String, CaseIterable {
    case day = "Giorno"
    case month = "Mese"
    case year = "Anno"
    
    // Chiavi di localizzazione (opzionale)
    var localizedKey: String {
        switch self {
        case .day: return "stats_view_day"
        case .month: return "stats_view_month"
        case .year: return "stats_view_year"
        }
    }
}

@Observable
class StatsViewModel {
    
    // MARK: - Dati Utente
    var totalTasksCompleted: Int = 142
    var articlesRead: Int = 15
    var currentStreak: Int = 5
    var bestStreak: Int = 12
    var hasUsedBoost: Bool = false
    
    var dailyMascotImageName: String = "mascotte_level_2"
    
    // MARK: - Gestione TimeFrame
    var selectedTimeFrame: TimeFrame = .day {
        didSet {
            // Quando cambia il filtro, rigeneriamo i dati
            generateChartData()
        }
    }
    
    // Il "Goal" massimo cambia in base al periodo
    // Giorno: 7 task
    // Mese: ~210 task (7 * 30)
    // Anno: ~2500 task
    var currentMaxGoal: Double {
        switch selectedTimeFrame {
        case .day: return 7.0
        case .month: return 210.0 // Target mensile ideale
        case .year: return 2500.0 // Target annuale ideale
        }
    }
    
    // MARK: - Logica Livello
    var currentLevel: Int { (totalTasksCompleted / 15) + 1 }
    var tasksInCurrentLevel: Int { totalTasksCompleted % 15 }
    var tasksToNextLevel: Int { 15 - tasksInCurrentLevel }
    var levelProgress: Double { Double(tasksInCurrentLevel) / 15.0 }
    
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
        if minutes < 60 { return "\(minutes) min" }
        else {
            let hours = minutes / 60
            let mins = minutes % 60
            return String(format: "%dh %02dm", hours, mins)
        }
    }
    
    // MARK: - Dati Grafico
    // Usiamo una struct generica che va bene per Giorno, Mese o Anno
    struct ChartDataPoint: Identifiable, Equatable {
        let id = UUID()
        let date: Date     // Rappresenta il giorno specifico, o il 1° del mese, o il 1° dell'anno
        let completed: Int
        let goal: Int
    }
    
    var chartData: [ChartDataPoint] = []
    
    init() {
        generateChartData()
    }
    
    func generateChartData() {
        var data: [ChartDataPoint] = []
        let calendar = Calendar.current
        
        switch selectedTimeFrame {
        case .day:
            // ULTIMI 30 GIORNI
            for i in (0..<30).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                    let goal = 7
                    let completed = Int.random(in: 0...7)
                    data.append(ChartDataPoint(date: date, completed: completed, goal: goal))
                }
            }
            
        case .month:
            // ULTIMI 12 MESI
            for i in (0..<12).reversed() {
                if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
                    let goal = 210 // 30 * 7
                    // Generiamo un numero realistico (es. tra 100 e 200)
                    let completed = Int.random(in: 100...210)
                    data.append(ChartDataPoint(date: date, completed: completed, goal: goal))
                }
            }
            
        case .year:
            // ULTIMI 5 ANNI
            for i in (0..<5).reversed() {
                if let date = calendar.date(byAdding: .year, value: -i, to: Date()) {
                    let goal = 2500
                    let completed = Int.random(in: 1500...2500)
                    data.append(ChartDataPoint(date: date, completed: completed, goal: goal))
                }
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
    
    
    // MARK: - Frase del giorno coi dati
    // Usiamo una struct generica che va bene per Giorno, Mese o Anno

    struct SummaryData {
        let contextName: String    // Es. "Oggi", "Gennaio", "Il 2026"
        let score: Int
        let tasksCount: Int
        let readsCount: Int
        let totalCompleted: Int
        let timeFormatted: String  // NUOVO: Es. "45 min" o "12 ore"
        let conclusion: String
    }

    var currentSummary: SummaryData {
        let appLocale = Locale(identifier: LanguageService.shared.currentLanguage)
        
        // Helper per formattare il tempo
        func formatTime(_ minutes: Int) -> String {
            if minutes < 60 {
                return "\(minutes) minuti"
            } else {
                let hours = minutes / 60
                // Se vuoi anche i minuti residui: return String(format: "%d h %02d min", hours, minutes % 60)
                return "\(hours) ore" // Più pulito per i riassunti lunghi
            }
        }
        
        // Helper per la frase conclusiva
        func getConclusion(for score: Int) -> String {
            switch score {
            case 90...100: return "Prestazione leggendaria!"
            case 75..<90:  return "Stai andando alla grande!"
            case 50..<75:  return "Buon ritmo, continua così."
            case 25..<50:  return "Puoi fare di più, forza!"
            default:       return "Ogni inizio è difficile, non mollare."
            }
        }
        
        switch selectedTimeFrame {
        case .day:
            let context = "Oggi"
            let tasks = Int.random(in: 1...5)
            let reads = Int.random(in: 0...2)
            let total = tasks + reads
            
            // Calcolo Tempo: 10 min per task, 5 min per lettura
            let minutes = (tasks * 10) + (reads * 5)
            
            let score = min(Int((Double(total) / 10.0) * 100), 100)
            
            return SummaryData(
                contextName: context,
                score: score,
                tasksCount: tasks,
                readsCount: reads,
                totalCompleted: total,
                timeFormatted: formatTime(minutes),
                conclusion: getConclusion(for: score)
            )
            
        case .month:
            let context = Date().formatted(.dateTime.month(.wide).locale(appLocale)).capitalized
            let tasks = Int.random(in: 40...100)
            let reads = Int.random(in: 5...20)
            let total = tasks + reads
            
            let minutes = (tasks * 10) + (reads * 5)
            
            let score = min(Int((Double(total) / 150.0) * 100), 100)
            
            return SummaryData(
                contextName: context,
                score: score,
                tasksCount: tasks,
                readsCount: reads,
                totalCompleted: total,
                timeFormatted: formatTime(minutes),
                conclusion: getConclusion(for: score)
            )
            
        case .year:
            let yearNum = Date().formatted(.dateTime.year().locale(appLocale))
            let context = "Il \(yearNum)"
            let tasks = Int.random(in: 500...1200)
            let reads = Int.random(in: 50...150)
            let total = tasks + reads
            
            let minutes = (tasks * 10) + (reads * 5)
            
            let score = min(Int((Double(total) / 2000.0) * 100), 100)
            
            return SummaryData(
                contextName: context,
                score: score,
                tasksCount: tasks,
                readsCount: reads,
                totalCompleted: total,
                timeFormatted: formatTime(minutes),
                conclusion: getConclusion(for: score)
            )
        }
    }
}
