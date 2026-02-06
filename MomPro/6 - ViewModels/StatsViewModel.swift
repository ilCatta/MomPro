//
//  StatsViewModel.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI
import Observation
import Foundation

// MARK: - ENUM TIMEFRAME
// Definito fuori dalla classe per essere visibile ovunque
enum TimeFrame: String, CaseIterable {
    case day = "Giorno"
    case month = "Mese"
    case year = "Anno"
    
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
    
    // MARK: - STRUCT DATI RIASSUNTO (Era mancante)
    struct SummaryData {
        let contextName: String    // Es. "Oggi", "Gennaio", "Il 2026"
        let score: Int             // 0-100
        let tasksCount: Int
        let readsCount: Int
        let totalCompleted: Int
        let timeFormatted: String  // Es. "45 min" o "12 ore"
        let conclusion: String
    }
    
    // MARK: - Dipendenze
    private var progressService = ProgressService.shared
    private var storeService = StoreService.shared
    
    // Modalità Demo: Se true, mostra i grafici (con dati finti) anche se Free
    var isDemoMode: Bool = true
    
    // MARK: - Dati Base
    var totalTasksCompleted: Int { progressService.totalTasksCompleted }
    var articlesRead: Int { progressService.readArticleIDs.count }
    var currentLevel: Int { progressService.currentLevel }
    var tasksToNextLevel: Int { progressService.tasksToNextLevel }
    var levelProgress: Double { progressService.levelProgress }
    var milestoneImage: String { progressService.currentMilestoneImage }
    var milestoneTitle: String { progressService.currentMilestoneTitle }
    var currentStreak: Int { progressService.currentStreak }
    var bestStreak: Int { progressService.bestStreak }
    
    // Ora controlla direttamente il dato salvato nel Service.
    // Se bonusLevels > 0 significa che l'abbiamo già usato.
    var hasUsedBoost: Bool {
        return progressService.bonusLevels > 0
    }
    
    // MARK: - TimeFrame & Charts
    var selectedTimeFrame: TimeFrame = .day {
        didSet { generateChartData() }
    }
    
    // Goal Grafico (per la scala Y)
    var currentMaxGoal: Double {
        switch selectedTimeFrame {
        case .day: return 7.0
        case .month: return 210.0 // ~30 * 7
        case .year: return 2500.0 // ~365 * 7
        }
    }
    
    struct ChartDataPoint: Identifiable, Equatable {
        let id = UUID()
        let date: Date
        let completed: Int // Task
        let goal: Int
    }
    
    var chartData: [ChartDataPoint] = []
    
    // Dati per la Card Riassunto
    var currentSummary: SummaryData = SummaryData(
        contextName: "", score: 0, tasksCount: 0, readsCount: 0,
        totalCompleted: 0, timeFormatted: "", conclusion: ""
    )
    
    // MARK: - Init
    init() {
        generateChartData()
    }
    
    // MARK: - Generazione Dati
    func generateChartData() {
        // Logica: Mostra dati reali se PRO.
        // Se FREE, mostra dati finti (che poi la View sfocherà se non siamo in Demo Mode)
        let showRealData = storeService.isPro
        
        if showRealData {
            fetchRealHistoryData()
        } else {
            generateMockData()
        }
        
        generateSummary(isReal: showRealData)
    }
    
    // MARK: - 1. Dati Finti (Mock)
    private func generateMockData() {
        var data: [ChartDataPoint] = []
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedTimeFrame {
        case .day:
            for i in (0..<30).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    data.append(ChartDataPoint(date: date, completed: Int.random(in: 2...7), goal: 7))
                }
            }
        case .month:
            for i in (0..<12).reversed() {
                if let date = calendar.date(byAdding: .month, value: -i, to: today) {
                    data.append(ChartDataPoint(date: date, completed: Int.random(in: 120...200), goal: 210))
                }
            }
        case .year:
            for i in (0..<5).reversed() {
                if let date = calendar.date(byAdding: .year, value: -i, to: today) {
                    data.append(ChartDataPoint(date: date, completed: Int.random(in: 1500...2400), goal: 2500))
                }
            }
        }
        self.chartData = data
    }
    
    // MARK: - 2. Dati Reali (Real History)
    private func fetchRealHistoryData() {
        var data: [ChartDataPoint] = []
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedTimeFrame {
        case .day:
            for i in (0..<30).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                    let log = progressService.getHistory(for: date)
                    let val = log?.tasksCompleted ?? 0
                    data.append(ChartDataPoint(date: date, completed: val, goal: 7))
                }
            }
            
        case .month:
            let allHistory = progressService.getAllHistory()
            for i in (0..<12).reversed() {
                if let monthDate = calendar.date(byAdding: .month, value: -i, to: today) {
                    let monthLogs = allHistory.filter { calendar.isDate($0.date, equalTo: monthDate, toGranularity: .month) }
                    let totalMonth = monthLogs.reduce(0) { $0 + $1.tasksCompleted }
                    data.append(ChartDataPoint(date: monthDate, completed: totalMonth, goal: 210))
                }
            }
            
        case .year:
            let allHistory = progressService.getAllHistory()
            for i in (0..<5).reversed() {
                if let yearDate = calendar.date(byAdding: .year, value: -i, to: today) {
                    let yearLogs = allHistory.filter { calendar.isDate($0.date, equalTo: yearDate, toGranularity: .year) }
                    let totalYear = yearLogs.reduce(0) { $0 + $1.tasksCompleted }
                    data.append(ChartDataPoint(date: yearDate, completed: totalYear, goal: 2500))
                }
            }
        }
        self.chartData = data
    }
    
    // MARK: - 3. Logica Sommario
    private func generateSummary(isReal: Bool) {
            let appLocale = Locale(identifier: LanguageService.shared.currentLanguage)
            let calendar = Calendar.current
            let now = Date()
            
            var contextName = ""
            var actualTasks = 0
            var actualReads = 0
            var actualMinutes = 0
            var targetTasks = 0
            
            if isReal {
                let allHistory = progressService.getAllHistory()
                
                switch selectedTimeFrame {
                case .day:
                    // CHIAVE AGGIORNATA
                    contextName = "stats_view_summary_today".localized
                    targetTasks = 7
                    if let log = progressService.getHistory(for: now) {
                        actualTasks = log.tasksCompleted
                        actualReads = log.articlesRead
                        actualMinutes = log.minutesInvested
                    }
                    
                case .month:
                    contextName = now.formatted(.dateTime.month(.wide).locale(appLocale)).capitalized
                    let range = calendar.range(of: .day, in: .month, for: now)!
                    targetTasks = range.count * 7
                    
                    let monthLogs = allHistory.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
                    actualTasks = monthLogs.reduce(0) { $0 + $1.tasksCompleted }
                    actualReads = monthLogs.reduce(0) { $0 + $1.articlesRead }
                    actualMinutes = monthLogs.reduce(0) { $0 + $1.minutesInvested }
                    
                case .year:
                    let yearStr = now.formatted(.dateTime.year().locale(appLocale))
                    // CHIAVE AGGIORNATA
                    contextName = String(format: "stats_view_summary_year_format".localized, yearStr)
                    
                    let range = calendar.range(of: .day, in: .year, for: now)!
                    targetTasks = range.count * 7
                    
                    let yearLogs = allHistory.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .year) }
                    actualTasks = yearLogs.reduce(0) { $0 + $1.tasksCompleted }
                    actualReads = yearLogs.reduce(0) { $0 + $1.articlesRead }
                    actualMinutes = yearLogs.reduce(0) { $0 + $1.minutesInvested }
                }
                
            } else {
                // DATI MOCK (Demo)
                switch selectedTimeFrame {
                case .day:
                    contextName = "stats_view_summary_today".localized
                    targetTasks = 7
                    actualTasks = Int.random(in: 3...7)
                    actualReads = Int.random(in: 0...2)
                    actualMinutes = (actualTasks * 2) + (actualReads * 5)
                case .month:
                    contextName = now.formatted(.dateTime.month(.wide).locale(appLocale)).capitalized
                    targetTasks = 196
                    actualTasks = Int.random(in: 100...150)
                    actualReads = Int.random(in: 15...25)
                    actualMinutes = (actualTasks * 2) + (actualReads * 5)
                case .year:
                    let yearStr = now.formatted(.dateTime.year().locale(appLocale))
                    contextName = String(format: "stats_view_summary_year_format".localized, yearStr)
                    targetTasks = 2555
                    actualTasks = Int.random(in: 1500...2000)
                    actualReads = Int.random(in: 100...200)
                    actualMinutes = (actualTasks * 2) + (actualReads * 5)
                }
            }
            
            let safeTarget = max(Double(targetTasks), 1.0)
            let score = min(Int((Double(actualTasks) / safeTarget) * 100), 100)
            let totalActivity = actualTasks + actualReads
            
            self.currentSummary = SummaryData(
                contextName: contextName,
                score: score,
                tasksCount: actualTasks,
                readsCount: actualReads,
                totalCompleted: totalActivity,
                timeFormatted: formatTime(actualMinutes),
                conclusion: getConclusion(for: score) // Restituisce la chiave
            )
        }
        
        // Helpers Aggiornati con prefisso "stats_view_"
        private func formatTime(_ minutes: Int) -> String {
            if minutes < 60 {
                return "\(minutes) \("stats_view_summary_time_min".localized)"
            } else {
                return "\(minutes / 60) \("stats_view_summary_time_hours".localized)"
            }
        }
        
        private func getConclusion(for score: Int) -> String {
            switch score {
            case 90...100: return "stats_view_summary_conclusion_legendary".localized
            case 75..<90:  return "stats_view_summary_conclusion_great".localized
            case 50..<75:  return "stats_view_summary_conclusion_good".localized
            case 25..<50:  return "stats_view_summary_conclusion_push".localized
            default:       return "stats_view_summary_conclusion_start".localized
            }
        }
    
    func applyBoost() {
        if !hasUsedBoost {
            progressService.boostLevel()
        }
    }
}
