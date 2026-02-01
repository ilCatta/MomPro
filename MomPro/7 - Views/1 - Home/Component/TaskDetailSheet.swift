//
//  TaskDetailSheet.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//
//
//  TaskDetailSheet.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

struct TaskDetailSheet: View {
    let taskStatus: DailyPlanService.DailyTaskStatus
    var viewModel: HomeViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Maniglia
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            // Icona Grande
            Image(systemName: iconForCategory(taskStatus.task.category))
                .font(.system(size: 60))
                .foregroundStyle(.pink)
                .padding()
                .background(Color.pink.opacity(0.1))
                .clipShape(Circle())
            
            // Info Testuali
            VStack(spacing: 8) {
                Text(taskStatus.task.title.localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(taskStatus.task.description.localized)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Divider()
            
            // --- SEZIONE AZIONI ---
            
            // CASO 1: Già completato
            if taskStatus.isCompleted {
                VStack {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                    Text("Obiettivo Completato!")
                        .font(.headline)
                        .foregroundStyle(.green)
                }
                .padding()
            }
            // CASO 2: È l'Articolo del giorno (Education)
            // NON mostriamo bottoni, ma solo un avviso.
            else if taskStatus.task.category == .education {
                VStack(spacing: 15) {
                    Image(systemName: "book.closed.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    
                    Text("Questo obiettivo si completa leggendo l'articolo nella sezione Guide.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Chiudi") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(.pink)
                }
                .padding()
            }
            // CASO 3: Task Normale (Da completare)
            else {
                if taskStatus.task.type == .counter {
                    // UI Contatore (es. 1/3)
                    counterControlView
                } else {
                    // UI Check Semplice
                    Button(action: {
                        completeSimple()
                    }) {
                        Text("Segna come Fatto")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(14)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .presentationDetents([.medium, .fraction(0.7)])
    }
    
    // Componente Contatore
    var counterControlView: some View {
        VStack(spacing: 20) {
            Text("\(taskStatus.currentProgress) / \(taskStatus.task.targetCount)")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Button(action: {
                increment()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Aggiungi 1")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.pink)
                .cornerRadius(14)
            }
        }
    }
    
    // MARK: - Actions
    
    func completeSimple() {
        withAnimation {
            viewModel.completeSimpleTask(taskId: taskStatus.id)
            dismiss()
        }
    }
    
    func increment() {
        withAnimation {
            viewModel.incrementTaskProgress(taskId: taskStatus.id)
            // Chiude lo sheet automaticamente solo se abbiamo FINITO il conteggio
            if taskStatus.currentProgress + 1 >= taskStatus.task.targetCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
    
    func iconForCategory(_ category: TaskCategory) -> String {
        switch category {
        case .shopping: return "cart.fill"
        case .home: return "house.fill"
        case .finance: return "banknote.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .education: return "graduationcap.fill"
        }
    }
}


