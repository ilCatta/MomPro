//
//  ContentService.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation

class ContentService {
    static let shared = ContentService()
    
    // MARK: - Database Obiettivi
    // Aggiungi qui i tuoi nuovi obiettivi
    let allTasks: [TaskItem] = [
        TaskItem(title: "Pianifica 3 cene", description: "Controlla cosa hai in frigo e pianifica 3 cene basandoti su quello.", category: .shopping, type: .counter, targetCount: 3),
        TaskItem(title: "Batch Cooking", description: "Cucina una doppia porzione stasera e congela la metà per una sera in cui sarai stanca.", category: .shopping),
        TaskItem(title: "No-Spend Day", description: "Impegnati a non tirare fuori il portafoglio oggi (escluse emergenze).", category: .finance),
        TaskItem(title: "Controllo Abbonamenti", description: "Controlla l'estratto conto. C'è un abbonamento che non usi da 30 giorni? Cancellalo.", category: .finance),
        TaskItem(title: "Lavatrice Eco", description: "Fai partire la lavatrice solo se è piena e in fascia oraria economica.", category: .home),
        TaskItem(title: "Luci Spente", description: "Fai un giro della casa e spegni tutto ciò che non serve.", category: .home),
        TaskItem(title: "Lezione di Risparmio", description: "Spiega ai tuoi figli o partner perché è importante risparmiare per il prossimo obiettivo familiare.", category: .family),
        // --- TASKS A CONTATORE (.counter) ---
            TaskItem(title: "Bevi Acqua", description: "Bevi 3 bicchieri d'acqua extra oggi.", category: .home, type: .counter, targetCount: 3),
            TaskItem(title: "Verdure ai pasti", description: "Inserisci una porzione di verdura in 2 pasti oggi.", category: .shopping, type: .counter, targetCount: 2),
            TaskItem(title: "No Social", description: "Fai 3 pause di 10 minuti senza telefono.", category: .home, type: .counter, targetCount: 3),
        TaskItem(title: "Salvadanaio", description: "Metti via 1€ per 3 volte oggi (o 3€ subito).", category: .finance, type: .counter, targetCount: 3),
        // --- TASKS SEMPLICI (.simpleCheck) ---
            TaskItem(title: "Batch Cooking", description: "Cucina una doppia porzione stasera e congela la metà.", category: .shopping),
            TaskItem(title: "No-Spend Day", description: "Impegnati a non tirare fuori il portafoglio oggi.", category: .finance),
            TaskItem(title: "Controllo Abbonamenti", description: "Controlla se hai abbonamenti attivi che non usi.", category: .finance),
            TaskItem(title: "Luci Spente", description: "Spegni le luci nelle stanze vuote.", category: .home),
            TaskItem(title: "Attività Gratis", description: "Cerca un'attività gratuita per il weekend.", category: .family),
    ]
    
    // MARK: - Database Articoli
    // Aggiungi qui i tuoi nuovi articoli
    /*
    let allArticles: [Article] = [
        Article(title: "Perché dovresti iniziare oggi", content: "Il momento migliore per piantare un albero era 20 anni fa. Il secondo migliore è oggi...", imageName: "start_today", category: .budgeting, difficulty: .beginner),
        Article(title: "Regola del 50/30/20", content: "Un metodo semplice per dividere le tue entrate...", imageName: "budget_rule", category: .budgeting, difficulty: .beginner),
        Article(title: "ETF spiegati a mia nonna", content: "Gli ETF sono come un cesto di frutta...", imageName: "etf_fruit", category: .investing, difficulty: .intermediate, isPro: true),
        Article(title: "Ristrutturare Low Cost", content: "Non serve cambiare tutto...", imageName: "reno_house", category: .family, difficulty: .beginner)
    ]*/
    
    // MARK: - Database Articoli
    
    let allArticles: [Article] = [
            
            // MARK: - RISPARMIO (Savings) - Hook (Tutti aperti)
            Article(title: "sav_001_title", fileName: "sav_001", imageName: "mascotte_home_start", category: .savings, difficulty: .beginner, readTimeMinutes: 3),
            Article(title: "sav_002_title", fileName: "sav_002", imageName: "mascotte_home_start", category: .savings, difficulty: .beginner, readTimeMinutes: 4),
            Article(title: "sav_003_title", fileName: "sav_003", imageName: "mascotte_home_start", category: .savings, difficulty: .intermediate, readTimeMinutes: 5),
            Article(title: "sav_004_title", fileName: "sav_004", imageName: "mascotte_home_start", category: .savings, difficulty: .intermediate, readTimeMinutes: 6),
            Article(title: "sav_005_title", fileName: "sav_005", imageName: "mascotte_home_start", category: .savings, difficulty: .advanced, readTimeMinutes: 8),

            // MARK: - ECO-RISPARMIO (Eco) - Hook (Tutti aperti)
            Article(title: "eco_001_title", fileName: "eco_001", imageName: "mascotte_home_start", category: .eco, difficulty: .beginner, readTimeMinutes: 3),
            Article(title: "eco_002_title", fileName: "eco_002", imageName: "mascotte_home_start", category: .eco, difficulty: .beginner, readTimeMinutes: 4),
            Article(title: "eco_003_title", fileName: "eco_003", imageName: "mascotte_home_start", category: .eco, difficulty: .intermediate, readTimeMinutes: 5),
            Article(title: "eco_004_title", fileName: "eco_004", imageName: "mascotte_home_start", category: .eco, difficulty: .intermediate, readTimeMinutes: 5),
            Article(title: "eco_005_title", fileName: "eco_005", imageName: "mascotte_home_start", category: .eco, difficulty: .advanced, readTimeMinutes: 7),

            // MARK: - FAMILY & CASA (Family) - Misto (Avanzati PRO)
            Article(title: "fam_001_title", fileName: "fam_001", imageName: "mascotte_home_start", category: .family, difficulty: .beginner, readTimeMinutes: 4),
            Article(title: "fam_002_title", fileName: "fam_002", imageName: "mascotte_home_start", category: .family, difficulty: .beginner, readTimeMinutes: 5),
            Article(title: "fam_003_title", fileName: "fam_003", imageName: "mascotte_home_start", category: .family, difficulty: .intermediate, readTimeMinutes: 6),
            Article(title: "fam_004_title", fileName: "fam_004", imageName: "mascotte_home_start", category: .family, difficulty: .intermediate, readTimeMinutes: 8, isPro: true), // PRO
            Article(title: "fam_005_title", fileName: "fam_005", imageName: "mascotte_home_start", category: .family, difficulty: .advanced, readTimeMinutes: 10, isPro: true), // PRO

            // MARK: - BUDGETING (Budgeting) - Locked (Value)
            Article(title: "bud_001_title", fileName: "bud_001", imageName: "mascotte_home_start", category: .budgeting, difficulty: .beginner, readTimeMinutes: 5, isPro: true),
            Article(title: "bud_002_title", fileName: "bud_002", imageName: "mascotte_home_start", category: .budgeting, difficulty: .beginner, readTimeMinutes: 6, isPro: true),
            Article(title: "bud_003_title", fileName: "bud_003", imageName: "mascotte_home_start", category: .budgeting, difficulty: .intermediate, readTimeMinutes: 7, isPro: true),
            Article(title: "bud_004_title", fileName: "bud_004", imageName: "mascotte_home_start", category: .budgeting, difficulty: .intermediate, readTimeMinutes: 8, isPro: true),
            Article(title: "bud_005_title", fileName: "bud_005", imageName: "mascotte_home_start", category: .budgeting, difficulty: .advanced, readTimeMinutes: 10, isPro: true),

            // MARK: - INVESTIMENTI (Investing) - Locked (Value)
            Article(title: "inv_001_title", fileName: "inv_001", imageName: "mascotte_home_start", category: .investing, difficulty: .beginner, readTimeMinutes: 5, isPro: false),
            Article(title: "inv_002_title", fileName: "inv_002", imageName: "mascotte_home_start", category: .investing, difficulty: .beginner, readTimeMinutes: 7, isPro: true),
            Article(title: "inv_003_title", fileName: "inv_003", imageName: "mascotte_home_start", category: .investing, difficulty: .intermediate, readTimeMinutes: 8, isPro: true),
            Article(title: "inv_004_title", fileName: "inv_004", imageName: "mascotte_home_start", category: .investing, difficulty: .intermediate, readTimeMinutes: 10, isPro: true),
            Article(title: "inv_005_title", fileName: "inv_005", imageName: "mascotte_home_start", category: .investing, difficulty: .advanced, readTimeMinutes: 12, isPro: true)
        ]
    
    
 
    
    // Funzione per ottenere l'articolo 'Task' del giorno
    // (Per ora prende un articolo non letto random, logica più complessa sarà nel ProgressService)
    func getDailyReadingTask() -> TaskItem {
        return TaskItem(title: "Leggi l'articolo del giorno", description: "L'educazione è il primo passo per la libertà.", category: .education)
    }
}
