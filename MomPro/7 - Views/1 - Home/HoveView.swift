//
//  HoveView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var selectedTask: DailyPlanService.DailyTaskStatus?
    @State private var showPaywall = false // Per i task VIP
    @State private var showEducationSheet = false
    
    // NUOVO: Stato per la data che si aggiorna
    @State private var todayDate = Date()
    
    var body: some View {
        
        NavigationStack {
        
        GeometryReader { geo in
            
            ZStack {
                
                // --- SFONDO ---
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        
                        // --- IMMAGINE HEADER (STRETCHY HEADER) ---
                        let headerHeight = geo.size.height * 0.38 // Altezza di base
                        GeometryReader { scrollGeo in
                            let minY = scrollGeo.frame(in: .global).minY
                            
                            Image(viewModel.dailyMascotImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: geo.size.width,
                                    height: headerHeight + (minY > 0 ? minY : 0), alignment: .top)
                                .clipped()
                                .offset(y: minY > 0 ? -minY : 0)
                        }
                        .frame(height: headerHeight)
                        .padding(.bottom, 8)
                        // --- FINE IMMAGINE HEADER (STRETCHY HEADER) ---
                        
                        
                        
                        // --- PROGRESSO E BARRA PROGRESSO ---
                        VStack(alignment: .leading, spacing: 2) {
                            
                            Text(LocalizedStringKey("Progresso"))
                                .font(.system(.callout, design: .default))
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text(LocalizedStringKey("Inizia la giornata!"))
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.pink)
                                .padding(.bottom, 10)
                            
                            // Barra Progresso
                            ProgressView(value: viewModel.dailyProgress)
                                .tint(.green)
                                .background(Color.white.opacity(0.3))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .clipShape(Capsule())
                            
                        }
                        .padding(.bottom, 20)
                        .padding(.horizontal)
                        // --- FINE PROGRESSO E BARRA PROGRESSO ---
                        
                        
                        // Divider
                        Rectangle()
                            .fill(Color(uiColor: .separator))
                            .frame(height: 1)
                            .padding(.horizontal)
                            .padding(.bottom, 20)

                        
                        // --- ATTIVITÀ TITLE ---
                        HStack {
                            Text("Attività")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            // Indicatore Refresh Disponibile
                            if viewModel.remainingRefreshes > 0 {
                                // CASO: Ci sono cambi disponibili
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    // Mostra "1 Cambio" o "2 Cambi"
                                    Text("\(viewModel.remainingRefreshes) \(viewModel.remainingRefreshes == 1 ? "Cambio" : "Cambi")")
                                }
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.pink)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.pink.opacity(0.1))
                                .clipShape(Capsule())
                                
                            } else {
                                // CASO: Cambi esauriti -> Messaggio conciso
                                HStack(spacing: 4) {
                                    Image(systemName: "moon.zzz.fill")
                                    Text("Nuovi cambi domani!")
                                }
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.bottom, 20)
                        .padding(.horizontal)
                        // --- FINE ATTIVITÀ TITLE ---
                        
                        
                        // --- I 4 TASK"GIORNALIERI CLASSICI ---
                        VStack(alignment: .leading, spacing: 16) { // Spaziatura tra le card
                           
                            ForEach(viewModel.freeTasks) { taskStatus in
                                ClassicTask(
                                    taskStatus: taskStatus,
                                    color: viewModel.colorForTaskStatus(taskStatus),
                                    onTap: { selectedTask = taskStatus },
                                    onRefresh: {
                                        if viewModel.canRefresh {
                                            viewModel.requestRefresh(for: taskStatus)
                                        }
                                    },
                                    canRefresh: viewModel.canRefresh
                                )
                            }
                        }
                        .padding(.bottom)
                        .padding(.horizontal)
                        // --- FINE 4 TASK"GIORNALIERI CLASSICI ---

                        
                        
                        
                        
                        // MARK: - BODY
                        VStack(spacing: 24) {
                            
                            /*
                             // MARK: - B. DAILY WISDOM (Task Fisso)
                             if let article = viewModel.dailyArticle {
                             wisdomCard(article: article)
                             } else {
                             Text("Caricamento articolo...")
                             .font(.caption)
                             .foregroundStyle(.secondary)
                             } */
                            
                            // MARK: - C. GRIGLIA QUOTIDIANA (4 Free)
                            /*
                            VStack(alignment: .leading, spacing: 12) {
                               
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(viewModel.freeTasks) { taskStatus in
                                        TaskGridCard(
                                            taskStatus: taskStatus,
                                            color: viewModel.colorForTaskStatus(taskStatus),
                                            onTap: { selectedTask = taskStatus },
                                            onRefresh: {
                                                // Chiamata al refresh se disponibile
                                                if viewModel.canRefresh {
                                                    viewModel.requestRefresh(for: taskStatus)
                                                }
                                            },
                                            canRefresh: viewModel.canRefresh
                                        )
                                    }
                                }
                            }*/
                            
                            
                            
                            // MARK: - D. VIP ZONE (2 Pro)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Zona VIP")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(.yellow)
                                    
                                    Spacer()
                                }
                                
                                ForEach(viewModel.vipTasks) { taskStatus in
                                    VipTaskRow(taskStatus: taskStatus) {
                                        // Se è bloccato apre paywall, altrimenti apre dettaglio
                                        if !StoreService.shared.isPro {
                                            showPaywall = true
                                        } else {
                                            selectedTask = taskStatus
                                        }
                                    }
                                }
                            }
                            
                            Spacer(minLength: 50)
                        }
                        .padding()
                        .background(Color(uiColor: .systemGroupedBackground))
                        // Corner radius negativo per effetto "foglio che copre l'header"
                        //.clipShape(RoundedRectangle(cornerRadius: 24))
                        //.offset(y: -20)
                    }
                }
                .ignoresSafeArea(.all, edges: .top)
                .onAppear {
                    // 1. Ricarica i dati dei task
                    viewModel.refreshData()
                    // 2. NUOVO: Cambia "vestito" alla mascotte ogni volta che entri qui!
                    viewModel.randomizeMascotVariant()
                    //
                }
                .onAppear { viewModel.refreshData() }
                //
                //
                // -------------------------------------------------
                // MARK: --- TOOLBAR
                //
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(formattedDate.capitalized)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                }
                // NUOVO: Aggiorna la data automaticamente a mezzanotte
                .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                    self.todayDate = Date()
                }
                //
                // -------------------------------------------------
                // MARK: --- SHEET
                //
                .sheet(item: $selectedTask) { task in
                    // Logic to pass updated task...
                    TaskDetailSheet(taskStatus: task, viewModel: viewModel)
                }
                .sheet(isPresented: $showPaywall) {
                    // PaywallView() // Scommenta quando hai importato RevenueCatUI
                    Text("Paywall Placeholder")
                }
                // SHEET 3: Istruzioni Education (NUOVO)
                .sheet(isPresented: $showEducationSheet) {
                    EducationInstructionSheet()
                        .presentationDetents([.fraction(0.40)]) // Occupa solo il 40% dello schermo
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}
 
    // -------------------------------------------------
    //
    // MARK: - Helper
    //
    // -------------------------------------------------
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE d MMMM")
        let languageCode = LanguageService.shared.currentLanguage // "it" o "en"
        formatter.locale = Locale(identifier: languageCode)
        return formatter.string(from: todayDate)
    }
   
    // -------------------------------------------------
    //
    // MARK: - Classic Task Component
    //
    // -------------------------------------------------
    
    struct ClassicTask: View {
        let taskStatus: DailyPlanService.DailyTaskStatus
        let color: Color
        let onTap: () -> Void
        let onRefresh: () -> Void
        let canRefresh: Bool
        
        // Configurazione Stato (Testo, Colore, Icona)
        private var statusConfig: (text: String, color: Color, icon: String) {
            if taskStatus.isCompleted {
                return ("Eccellente", .green, "checkmark.circle.fill")
            } else if taskStatus.currentProgress > 0 {
                return ("Ok", .orange, "minus.circle.fill")
            } else {
                return ("Insufficiente", .red, "arrow.down.circle.fill")
            }
        }
        
        // Calcolo Percentuale per lo Slider (0.0 -> 1.0)
        private var progressPercentage: CGFloat {
            if taskStatus.isCompleted { return 1.0 }
            let target = CGFloat(max(taskStatus.task.targetCount, 1))
            let current = CGFloat(taskStatus.currentProgress)
            return min(current / target, 1.0)
        }
        
        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 16) {
                    
                    // --- PARTE SINISTRA: INFO ---
                    VStack(alignment: .leading, spacing: 8) {
                        
                        // 1. Header: Icona Categoria + Nome Categoria
                        HStack(spacing: 6) {
                            Image(systemName: iconName(for: taskStatus.task.category))
                                .font(.subheadline)
                                .foregroundStyle(color) // Colore della categoria
                                .padding(6)
                                .background(color.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text(LocalizedStringKey(taskStatus.task.category.rawValue))
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                        }
                        
                        // 2. Titolo del Task
                        Text(LocalizedStringKey(taskStatus.task.title))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold) // Più marcato per leggibilità
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 2)
                        
                        Spacer(minLength: 0)
                        
                        // 3. Status (Insufficiente / Ok / Eccellente)
                        HStack(spacing: 6) {
                            Image(systemName: statusConfig.icon)
                            Text(statusConfig.text)
                        }
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(statusConfig.color) // Colore rosso/arancio/verde
                    }
                    .padding(.vertical, 16)
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    // --- PARTE DESTRA: SLIDER & REFRESH ---
                    VStack(alignment: .trailing) {
                        
                        // Tasto Refresh (in alto a destra)
                        if !taskStatus.isCompleted && canRefresh {
                            Button(action: onRefresh) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.secondary)
                                    .padding(8)
                                    .background(Color(uiColor: .systemGray6))
                                    .clipShape(Circle())
                            }
                        } else {
                            // Spacer invisibile per mantenere l'allineamento se non c'è il bottone
                            Color.clear.frame(width: 32, height: 32)
                        }
                        
                        Spacer()
                        
                        // Slider Verticale
                        ZStack(alignment: .bottom) {
                            // Sfondo barra
                            Capsule()
                                .fill(Color(uiColor: .systemGray5))
                                .frame(width: 6, height: 60) // Altezza fissa per coerenza
                            
                            // Indicatore che sale
                            GeometryReader { geo in
                                VStack {
                                    Spacer()
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 14, height: 14)
                                        .shadow(color: statusConfig.color.opacity(0.4), radius: 2, x: 0, y: 1)
                                        .overlay(
                                            Circle().strokeBorder(statusConfig.color, lineWidth: 3)
                                        )
                                        // Calcolo posizione inversa (dal basso)
                                        .offset(y: -((60 - 14) * progressPercentage))
                                }
                                .frame(height: 60)
                            }
                            .frame(width: 14, height: 60)
                        }
                        .padding(.bottom, 16)
                        .padding(.trailing, 4)
                    }
                    .padding(.trailing, 12)
                    .padding(.top, 12)
                }
                .frame(height: 140) // Card più alta per ospitare tutto in verticale
                .background(Color.white)
                .cornerRadius(22)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
        
        func iconName(for cat: TaskCategory) -> String {
            switch cat {
            case .shopping: return "cart.fill"
            case .home: return "house.fill"
            case .finance: return "banknote.fill"
            case .family: return "figure.2.and.child.holdinghands"
            default: return "star.fill"
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // Componente Wisdom Card
        func wisdomCard(article: Article) -> some View {
            // MODIFICA CRUCIALE:
            // Controlliamo se il TASK "Leggi un articolo" è completato,
            // NON se questo specifico articolo è stato letto.
            let isCompleted = viewModel.isEducationTaskCompleted
            
            return Button(action: {
                if !isCompleted {
                    showEducationSheet = true
                } else {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.green.opacity(0.15) : Color.purple.opacity(0.15))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: isCompleted ? "checkmark" : "book.fill")
                            .foregroundStyle(isCompleted ? .green : .purple)
                            .font(.title3)
                            .fontWeight(isCompleted ? .bold : .regular)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("IL TUO MOMENTO CRESCITA")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        // Titolo: "Obiettivo completato" se fatto, altrimenti titolo articolo suggerito
                        Text(isCompleted ? "Obiettivo lettura completato!" : "Investi 5 minuti su te stessa: leggi una guida.")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(isCompleted ? .secondary : .primary)
                            .strikethrough(isCompleted)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    if !isCompleted {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
}

























// MARK: - NUOVO COMPONENTE: Foglio Istruzioni Education
struct EducationInstructionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Icona Grande
            Image(systemName: "signpost.right.and.left.fill")
                .font(.system(size: 60))
                .foregroundStyle(.purple)
                .padding()
                .background(Color.purple.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 10) {
                Text("Tempo di imparare!")
                    .font(.title2)
                    .fontWeight(.bold)
            
                Text("Per completare questo obiettivo, vai nella sezione **Guide**, scegli un articolo che ti ispira e leggilo fino in fondo.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                dismiss()
                // Nota: L'utente dovrà cambiare tab manualmente.
                // Questo è voluto per fargli esplorare l'app.
            }) {
                Text("Ho capito, vado a leggere")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(14)
            }
        }
        .padding(24)
    }
}




struct VipTaskRow: View {
    let taskStatus: DailyPlanService.DailyTaskStatus
    let onTap: () -> Void
    
    var isLocked: Bool {
        return !StoreService.shared.isPro
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icona Lucchetto o Categoria
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isLocked ? Color.gray.opacity(0.2) : Color.pink.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isLocked ? "lock.fill" : "crown.fill")
                        .foregroundStyle(isLocked ? .gray : .pink)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isLocked ? "Strategia Avanzata" : taskStatus.task.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(isLocked ? .secondary : .primary)
                    
                    if isLocked {
                        Text("Sblocca per risparmiare di più")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(taskStatus.task.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.pink)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
