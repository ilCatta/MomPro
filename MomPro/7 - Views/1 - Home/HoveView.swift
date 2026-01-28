//
//  HoveView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

struct HomeView: View {
    
    // Serve a controllare su quale tab ci troviamo (0 = Home, 1 = Learn, etc.)
    @Binding var currentTab: Tab
    
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
                                .foregroundColor(.primary)
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
                            Text("home_view_daily_activities".localized)
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
                                    Text("\(viewModel.remainingRefreshes) \(viewModel.remainingRefreshes == 1 ? "home_view_swap".localized : "home_view_swaps".localized )")
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
                                    Text("home_view_new_swaps_tomorrow".localized)
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
                        
                        
                        //  --- TASK EDUCATIVO (ex Wisdom Card)  ---
                        if let eduTask = viewModel.educationTaskStatus {
                            ClassicTask(
                                taskStatus: eduTask,
                                color: .purple, // Colore distintivo per l'educazione
                                onTap: {
                                    showEducationSheet = true
                                },
                                onRefresh: { }, // Nessuna azione
                                canRefresh: false // Nasconde il tasto refresh
                            )
                            .padding(.bottom, 16) // Spazio prima degli altri task
                            .padding(.horizontal)
                        }
                        
                        
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
                        .padding(.bottom, 20)
                        .padding(.horizontal)
                        // --- FINE 4 TASK"GIORNALIERI CLASSICI ---

                        
                        // Divider
                        Rectangle()
                            .fill(Color(uiColor: .separator))
                            .frame(height: 1)
                            .padding(.horizontal)
                            .padding(.bottom, 20)

                        
                        // --- ATTIVITÀ PRO ---
                        HStack(spacing:0) {
                            Text("home_view_extra_activities".localized)
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .padding(.trailing, 6)
                            
                            Text("PRO")
                                .font(.system(.caption ,design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal,8)
                                .padding(.vertical,6)
                                .background(.pink)
                                .cornerRadius(10)
                            
                           
                        }
                        .padding(.bottom, 20)
                        .padding(.horizontal)
                        // --- FINE ATTIVITÀ TITLE ---
                        
               
                        // --- I 2 TASK"GIORNALIERI PRO ---
                        VStack(alignment: .leading, spacing: 16) {
                            
                            ForEach(viewModel.vipTasks) { taskStatus in
                                // USIAMO LA NUOVA CARD
                                VipTaskCard(taskStatus: taskStatus) {
                                    // Se è bloccato apre paywall, altrimenti apre dettaglio
                                    if !StoreService.shared.isPro {
                                        showPaywall = true
                                    } else {
                                        selectedTask = taskStatus
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        
                        
                        // --- DISCLAIMER TASK PRO ---
                        // Tailored selection: 2 extra high-impact tasks, distinct from your base plan, curated daily to fast-track your goals.
                        Text("home_view_extra_activities_desc".localized)
                            .font(.system(.caption, design: .default))
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        

                        
                        
                        // --- SPACE ---
                        Spacer(minLength: 40)

   
                       
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
                // MARK: - SHEET UNIFICATO EDUCATION
                .sheet(isPresented: $showEducationSheet) {
                    if let task = viewModel.educationTaskStatus, task.isCompleted {
                        
                        // CASO 1: Successo
                        EducationSuccessSheet()
                            .presentationDetents([.fraction(0.50)])
                            
                    } else {
                        
                        // CASO 2: Istruzioni -> VAI A LEARN
                        EducationInstructionSheet(onGoToLearn: {
                            showEducationSheet = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation {
                                    // MODIFICA QUI: Usa l'enum .learn
                                    currentTab = .learn
                                }
                            }
                        })
                        .presentationDetents([.fraction(0.45)])
                    }
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
                return ("home_view_excellent".localized, .green, "arrow.up.circle.fill")
            } else if taskStatus.currentProgress > 0 {
                return ("home_view_ok".localized, .blue, "checkmark.circle.fill")
            } else {
                return ("home_view_low".localized, .red, "arrow.down.circle.fill") 
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
                
                HStack(spacing: 0) {
                    
                    // --- PARTE SINISTRA: INFO ---
                    VStack(alignment: .leading, spacing: 0) {
                        
                        
                        // 1. Header: Icona Categoria + Nome Categoria
                        HStack(spacing: 0) {
                            Image(systemName: iconName(for: taskStatus.task.category))
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.tertiary)
                                .padding(.trailing, 4)
                            
                            Text((taskStatus.task.category.rawValue).localized)
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.tertiary)
                                .textCase(.uppercase)
                               
                        }
                        .padding(.bottom, 8)
                        
                        
                        // 2. Titolo del Task
                        Text(LocalizedStringKey(taskStatus.task.title))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 8)

                                                
                        // 3. Status (Insufficiente / Ok / Eccellente)
                        HStack(spacing: 0) {
                            Image(systemName: statusConfig.icon)
                                .padding(.trailing, 4)
                            Text(statusConfig.text)
                        }
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(statusConfig.color) // Colore rosso/arancio/verde
                    }
                    
                    Spacer()
                    
                    // --- PARTE DESTRA: SLIDER & REFRESH ---
                    HStack(spacing: 0) {
                        
                        VStack(spacing: 0){
                            // Tasto Refresh (in alto a destra)
                            if !taskStatus.isCompleted && canRefresh {
                                Button(action: onRefresh) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)
                                        .padding(6)
                                        .background(Color(uiColor: .systemGray5))
                                        .clipShape(Circle())
                                }
                            } else {
                                // Spacer invisibile per mantenere l'allineamento se non c'è il bottone
                                Color.clear.frame(width: 32, height: 32)
                            }
                            
                            Spacer()
                        }
                        .padding(.trailing, 8)
                        
                        
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
                                            Circle().strokeBorder(statusConfig.color, lineWidth: 4)
                                        )
                                        // Calcolo posizione inversa (dal basso)
                                        .offset(y: -((60 - 14) * progressPercentage))
                                }
                                .frame(height: 60)
                            }
                            .frame(width: 14, height: 60)
                        }
                    
                    }
                   
                }
                .padding(.horizontal)
                .padding(.vertical)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }
            .buttonStyle(SquishyButtonEffect())
        }
        
        
    }
    
    


    
    
    
    
    
   
}

























// MARK: - SHEET 1: Istruzioni (Prima di completare)
struct EducationInstructionSheet: View {
    @Environment(\.dismiss) private var dismiss
    // Questa closure serve per dire alla Home: "Spostati sul tab Learn"
    var onGoToLearn: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Icona Grande
            Image(systemName: "signpost.right.and.left.fill")
                .font(.system(size: 60))
                .foregroundStyle(.purple)
                .padding()
                .background(Color.purple.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 12) {
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
                // Ritardiamo leggermente la navigazione per far chiudere il foglio in modo fluido
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onGoToLearn()
                }
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
        .presentationDetents([.fraction(0.45)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - SHEET 2: Successo (Dopo aver completato)
struct EducationSuccessSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Icona Successo
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 65))
                .foregroundStyle(.green)
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(Circle())
                .shadow(color: .green.opacity(0.2), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                Text("Obiettivo Completato!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Ottimo lavoro! Hai investito del tempo prezioso per la tua crescita personale.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            
            // Box Riepilogo (Simile a ClassicTask ma statico)
            HStack {
                Image(systemName: "book.fill")
                    .foregroundStyle(.purple)
                    .padding(10)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("Lettura Giornaliera")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text("Completata")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Chiudi")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(uiColor: .tertiarySystemFill))
                    .clipShape(Capsule())
            }
        }
        .padding(24)
        .presentationDetents([.fraction(0.50)]) // Mezzo schermo
        .presentationDragIndicator(.visible)
    }
}













struct VipTaskCard: View {
    let taskStatus: DailyPlanService.DailyTaskStatus
    let onTap: () -> Void
    
    var isLocked: Bool {
        return !StoreService.shared.isPro
    }
    
    // MARK: - Generazione Testi Misteriosi
        // Questi testi cambiano in base alla VERA categoria del task nascosto.
        // Così non rischi mai di avere un titolo sbagliato.
    var lockedTitle: String {
        switch taskStatus.task.category {
        case .finance:
            return "home_view_mystery_finance".localized   // "Finance Strategy" - "Strategia Finanziaria"
        case .shopping:
            return "home_view_mystery_shopping".localized  // "Shopping Protocol" - "Protocollo Spesa"
        case .home:
            return "home_view_mystery_home".localized     // "Home Efficiency" - "Efficienza Domestica"
        case .family:
            return "home_view_mystery_family".localized    // "Family Balance" - "Equilibrio Familiare"
        case .education:
            return ""
        }
    }
        
        var lockedSubtitle: String {
            // Un sottotitolo unico, elegante e motivante per tutti
            return "home_view_locked_subtitle".localized // "Reveal the advanced method." - "Rivela il metodo avanzato."
        }
    
    var body: some View {
        Button(action: onTap) {
            
            HStack(spacing: 0) {
                
                // --- PARTE SINISTRA: INFO ---
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. Header: Icona Categoria + Nome Categoria (o PRO)
                    HStack(spacing: 0) {
                        
                        Text(isLocked ? "home_view_exclusive_access".localized : (taskStatus.task.category.rawValue.localized))
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(  isLocked ? .pink : Color(uiColor: .tertiaryLabel))
                            .textCase(.uppercase)
                    }
                    .padding(.bottom, 8)
                    
                    
                    // 2. Titolo del Task (o Teaser se bloccato)
                    Text(isLocked ? lockedTitle.localized : taskStatus.task.title.localized)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 8)

                    
                    // 3. Status / Call to Action
                    HStack(spacing: 4) {
                        if isLocked {
                            // Testo persuasivo basato sul brief
                            Text(lockedSubtitle)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            // Se sbloccato, mostra lo stato classico
                            Image(systemName: taskStatus.isCompleted ? "checkmark.circle.fill" : "circle")
                            Text(taskStatus.isCompleted ? "Completato" : "Pronto per iniziare")
                        }
                    }
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(isLocked ? .secondary : .primary)
                }
                
                Spacer(minLength: 16)
                
                // --- PARTE DESTRA: LUCCHETTO O FRECCIA ---
                ZStack {
                    // Sfondo cerchio leggero per dare importanza
                    Circle()
                        .fill(isLocked ? Color(uiColor: .systemGray5) : Color(uiColor: .systemGray6))
                        .frame(width: 44, height: 44)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20) // Un po' più di padding verticale per i VIP
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(SquishyButtonEffect()) // Stesso effetto tocco della ClassicTask
    }
    
}


private func iconName(for cat: TaskCategory) -> String {
    switch cat {
    case .shopping: return "cart.fill"
    case .home: return "house.fill"
    case .finance: return "banknote.fill"
    case .family: return "figure.2.and.child.holdinghands"
    case .education: return "graduationcap.fill"
    }
}

private struct SquishyButtonEffect: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
        .brightness(configuration.isPressed ? -0.0 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0), value: configuration.isPressed)
    }
}
