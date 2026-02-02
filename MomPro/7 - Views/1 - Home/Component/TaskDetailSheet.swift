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
    
    var liveTaskStatus: DailyPlanService.DailyTaskStatus {
        // 1. Cerca nei task gratuiti
        if let found = viewModel.freeTasks.first(where: { $0.id == taskStatus.id }) {
            return found
        }
        // 2. Cerca nei task VIP
        if let found = viewModel.vipTasks.first(where: { $0.id == taskStatus.id }) {
            return found
        }
        // 3. Cerca nel task education
        if let edu = viewModel.educationTaskStatus, edu.id == taskStatus.id {
            return edu
        }
        // Fallback (ritorna la copia vecchia se non trova nulla, ma non dovrebbe succedere)
        return taskStatus
    }
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        VStack(spacing: 0) {
                        
            // Icona Grande
            Image(systemName: iconForCategory(taskStatus.task.category))
                .font(.system(size: 30))
                .foregroundStyle(.pink)
                .frame(width: 73, height: 73)
                .background(Color.pink.opacity(0.1))
                .clipShape(Circle())
                .padding(.vertical, 24)
            
            
            Text(taskStatus.task.title.localized)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 24)
        
            Text(taskStatus.task.description.localized)
                .font(.system(.body, design: .default))
                .fontWeight(.regular)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 24)
            
            /*
            Rectangle()
                .fill(Color(uiColor: .separator))
                .frame(height: 1)
                .padding(.horizontal)
                .padding(.bottom, 24)
             */
            
           
            
            // --- SEZIONE AZIONI ---
            
            // CASO 1: Già completato
            if liveTaskStatus.isCompleted {
                VStack (spacing: 0){
                    Spacer()
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                        .padding(.bottom, 8)
                    
                    Text("home_view_goal_completed".localized)
                        .font(.headline)
                        .foregroundStyle(.green)
                }
                
            }
            // CASO 2: Task Normale (Da completare)
            else {
                if taskStatus.task.type == .counter {
                    // UI Contatore (es. 1/3)
                    counterControlView
                } else {
                    
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            completeSimple()
                        }) {
                            Text("home_view_mark_as_done".localized)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .padding(.horizontal)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous) // 300 o 30 per pillola
                                        .fill( Color.pink)
                                )
                        }.buttonStyle(SquishyButtonEffect())
                    }
                }
            }
            
        }
        .padding()
        .presentationDetents([.fraction(0.45)])
        .presentationDragIndicator(.visible)
    }
    
    // Componente Contatore
    var counterControlView: some View {
        VStack(spacing: 0) {
        
            Text("\(liveTaskStatus.currentProgress) / \(taskStatus.task.targetCount)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
            
            Spacer()
            
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                increment()
            }) {
                
                HStack {
                    Image(systemName: "plus")
                    Text("home_view_add_1".localized)
                }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous) // 300 o 30 per pillola
                            .fill( Color.pink)
                    )
            }.buttonStyle(SquishyButtonEffect())
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
            if liveTaskStatus.currentProgress >= taskStatus.task.targetCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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



