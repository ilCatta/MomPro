//
//  HoveView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    // 1. NUOVO STATO: Tiene traccia di quale task abbiamo cliccato
        @State private var selectedTask: DailyPlanService.DailyTaskStatus?
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - HEADER ELASTICO
                    ZStack(alignment: .bottom) {
                        
                        // 1. Immagine di Sfondo Elastica
                        GeometryReader { scrollGeo in
                            let minY = scrollGeo.frame(in: .global).minY
                            let headerHeight = geo.size.height * 0.47 // 47% dello schermo
                            
                            Image(viewModel.dailyMascotImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width,
                                       height: headerHeight + (minY > 0 ? minY : 0))
                                .clipped()
                                // Gradiente per rendere leggibile il testo sopra
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .clear,
                                            .black.opacity(0.1),
                                            .black.opacity(0.7)
                                        ]),
                                        startPoint: .center,
                                        endPoint: .bottom
                                    )
                                )
                                .offset(y: minY > 0 ? -minY : 0) // Blocca l'immagine in alto
                        }
                        .frame(height: geo.size.height * 0.47) // Altezza statica per il layout
                        
                        // 2. Contenuto Header (Testo e Barra Progresso)
                        VStack(alignment: .leading, spacing: 8) {
                            
                            // Data
                            Text(Date().formatted(date: .complete, time: .omitted))
                                .font(.caption)
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                                .foregroundStyle(.white.opacity(0.8))
                            
                            HStack {
                                Text("Livello \(viewModel.currentLevel)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            
                            // BARRA DEL PROGRESSO GIORNALIERO
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Progresso Giornata")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.9))
                                
                                ProgressView(value: viewModel.dailyProgress)
                                    .tint(viewModel.dailyProgress >= 1.0 ? .green : .pink) // Diventa verde se finita
                                    .background(Color.white.opacity(0.3))
                                    .scaleEffect(x: 1, y: 2, anchor: .leading) // La rendiamo più spessa
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .padding(.top, 5)
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 25)
                    }
                    
                    // MARK: - BODY
                    VStack(spacing: 20) {
                        
                        // Daily Tip Box
                        HStack(spacing: 15) {
                            Image(systemName: "lightbulb.fill")
                                .font(.title)
                                .foregroundStyle(.yellow)
                            
                            Text(viewModel.dailyTip)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Titolo Sezione
                        HStack {
                            Text("Obiettivi di Oggi")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        // Lista Tasks
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.dailyTasks) { taskStatus in
                                TaskCardView(
                                    taskStatus: taskStatus,
                                    cardColor: viewModel.colorForTaskStatus(taskStatus)
                                ) {
                                    // 2. MODIFICA AZIONE: Apriamo lo sheet
                                    selectedTask = taskStatus
                                }
                            }
                        }
                        
                        Spacer(minLength: 100) // Spazio extra in fondo per lo scroll
                    }
                    .padding()
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
            .ignoresSafeArea(.all, edges: .top) // Fondamentale per l'header
            .onAppear {
                viewModel.refreshData()
            }
            // 3. NUOVO SHEET: Questo gestisce l'apertura del dettaglio
            .sheet(item: $selectedTask) { task in
                // Dobbiamo passare il task AGGIORNATO dal ViewModel,
                // altrimenti lo sheet avrà una copia vecchia dei dati (es. progresso vecchio).
                if let upToDateTask = viewModel.dailyTasks.first(where: { $0.id == task.id }) {
                    TaskDetailSheet(taskStatus: upToDateTask, viewModel: viewModel)
                } else {
                    // Fallback se qualcosa va storto
                    TaskDetailSheet(taskStatus: task, viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Components

struct TaskCardView: View {
    let taskStatus: DailyPlanService.DailyTaskStatus
    let cardColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Icona
                Image(systemName: iconForCategory(taskStatus.task.category))
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.25))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(taskStatus.task.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .strikethrough(taskStatus.isCompleted)
                    
                    Text(taskStatus.task.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Spacer()
                
                // Check o Counter
                if taskStatus.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                } else {
                    if taskStatus.task.type == .counter {
                        Text("\(taskStatus.currentProgress)/\(taskStatus.task.targetCount)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "circle")
                            .font(.title2)
                            .opacity(0.6)
                    }
                }
            }
            .padding()
            .foregroundStyle(.white)
            .background(cardColor)
            .cornerRadius(16)
            // Ombra leggera colorata
            .shadow(color: cardColor.opacity(0.4), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    func iconForCategory(_ category: TaskCategory) -> String {
        switch category {
        case .shopping: return "cart.fill"
        case .home: return "house.fill"
        case .finance: return "eurosign.circle.fill" // o banknote.fill
        case .family: return "figure.2.and.child.holdinghands"
        case .education: return "book.fill"
        }
    }
}

// Button Style corretto
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
