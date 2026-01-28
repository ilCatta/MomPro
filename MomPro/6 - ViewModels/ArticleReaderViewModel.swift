//
//  ArticleReaderViewModel.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation

@Observable
class ArticleReaderViewModel {
    private var progressService = ProgressService.shared
    
    let article: Article
    var markdownContent: String = ""
    var isRead: Bool = false
    
    init(article: Article) {
        self.article = article
        self.isRead = progressService.readArticleIDs.contains(article.id)
        loadContent()
    }
    
    private func loadContent() {
        // Chiama il metodo del modello che legge dal Bundle
        self.markdownContent = article.loadMarkdownContent()
    }
    
    func markAsRead() {
        if !isRead {
            progressService.markArticleAsRead(articleId: article.id)
            isRead = true
            
            // OPZIONALE: Se marcare come letto deve completare il task giornaliero "Leggi articolo"
            // Dobbiamo trovare il task "education" nel daily plan e completarlo.
            // Possiamo farlo tramite il DailyPlanService o notificare un evento.
            // Per semplicità qui:
             completeDailyReadingTask()
        }
    }
    
    private func completeDailyReadingTask() {
            // 1. Recuperiamo il piano di oggi chiamando la funzione del servizio
            let todaysPlan = DailyPlanService.shared.getOrGenerateDailyPlan()
            
            // 2. Cerchiamo il task che ha categoria .education
            // (Ora Swift sa che todaysPlan è un array di DailyTaskStatus, quindi riconosce .education)
            if let readingStatus = todaysPlan.first(where: { $0.task.category == .education }) {
                
                // 3. Usiamo il metodo corretto 'completeTask' passando l'ID del Task originale
                DailyPlanService.shared.completeTask(taskId: readingStatus.task.id)
            }
        }
}
