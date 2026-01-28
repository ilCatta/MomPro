//
//  TaskItem.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import Foundation

enum TaskCategory: String, Codable, CaseIterable {
    case shopping = "Spesa & Cibo"
    case home = "Casa"
    case finance = "Risparmio"
    case family = "Famiglia"
    case education = "Educazione" // Per l'articolo fisso
}

enum TaskType: String, Codable {
    case simpleCheck // Basta spuntare
    case counter // Richiede un conteggio (es. 3 alimenti)
}

struct TaskItem: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let category: TaskCategory
    let type: TaskType
    let targetCount: Int
    let isPro: Bool // <--- NUOVA PROPRIETÀ
    
    // Init aggiornato con isPro
    init(id: UUID = UUID(),
         title: String,
         description: String,
         category: TaskCategory,
         type: TaskType = .simpleCheck,
         targetCount: Int = 1,
         isPro: Bool = false) { // Default false
        
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.type = type
        self.targetCount = targetCount
        self.isPro = isPro
    }
}
