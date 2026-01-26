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
        // Cerca nei task di oggi quello di categoria .education e completalo
        if let readingTask = DailyPlanService.shared.dailyTasks.first(where: { $0.task.category == .education }) {
            DailyPlanService.shared.updateTaskProgress(id: readingTask.id)
        }
    }
}
