//
//  HoveView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

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
                        
                        
                      
                        // --- CARD PROGRESSO ---
                        VStack(alignment: .leading, spacing: 0) {
                            
                            Text(formattedDate.capitalized)
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(.pink)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 8)
                            
                            Text(viewModel.dailyMotivationalText.localized)
                                .font(.system(.body, design: .rounded)) 
                                .fontWeight(.regular)
                                .foregroundColor(.primary)
                                .lineLimit(8)
                                .fixedSize(horizontal: false, vertical: true) // Evita troncamenti
                                .animation(.easeInOut, value: viewModel.dailyMotivationalText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        .padding(.vertical)
                        .padding(.bottom, 4)
                        // --- FINE CARD PROGRESSO ---
                        
                        
                        // --- PROGRESSO E BARRA PROGRESSO ---
                        VStack(alignment: .leading, spacing: 0) {
                            // Barra Progresso
                            CustomProgressBar(progress: viewModel.dailyProgress)
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
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
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
                                
                                if StoreService.shared.isPro {
                                    
                                    // CASO 1: UTENTE PRO -> Grafica Classica
                                    ClassicTask(
                                        taskStatus: taskStatus,
                                        color: viewModel.colorForTaskStatus(taskStatus),
                                        onTap: {
                                            selectedTask = taskStatus
                                        },
                                        onRefresh: {},
                                        canRefresh: false
                                    )
                                    
                                } else {
                                    
                                    // CASO 2: UTENTE FREE -> Grafica "Misteriosa" con Lucchetto
                                    VipTaskCard(taskStatus: taskStatus) {
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                        showPaywall = true
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
                    // Ricarica solo i dati, la mascotte e i testi si aggiornano da soli con la data
                    viewModel.refreshData()
                }
                //
                //
                // -------------------------------------------------
                // MARK: --- TOOLBAR
                //
                /*
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(formattedDate.capitalized)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                }
                 */
                // Aggiorna la data automaticamente a mezzanotte
                .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                    // 1. Aggiorna la data visualizzata nella UI
                        self.todayDate = Date()
                    // 2. Forza il ViewModel a rigenerare i task e ricalcolare mascotte/testi
                    // Questo è fondamentale per "azzerare" la giornata
                    viewModel.refreshData()
                }
                //
                // -------------------------------------------------
                // MARK: --- SHEET
                //
                // SINGLE TASK
                .sheet(item: $selectedTask) { task in
                    // Logic to pass updated task...
                    TaskDetailSheet(taskStatus: task, viewModel: viewModel)
                }
                //
                //
                // EDUCATION
                
                .sheet(isPresented: $showEducationSheet) {
                    if let task = viewModel.educationTaskStatus, task.isCompleted {
                        // CASO 1: Successo
                        EducationInstructionSheet(
                            isCompleted: true,
                            onGoToLearn: {},
                        )
                            //.presentationDetents([.fraction(0.45)])
                    } else {
                        // CASO 2: Istruzioni -> VAI A LEARN
                        EducationInstructionSheet(
                            isCompleted: false,
                            onGoToLearn: {
                            showEducationSheet = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation {
                                    currentTab = .learn
                                }
                            }
                        })
                        //.presentationDetents([.fraction(0.45)])
                    }
                }
                 
                //
                //
                // PAYWALL
                .sheet(isPresented: $showPaywall) {
                    PaywallView(displayCloseButton: true)
                        .onRestoreCompleted { info in
                             // Gestione opzionale se l'utente ripristina gli acquisti
                             if info.entitlements.active.isEmpty == false {
                                 showPaywall = false
                             }
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
    // MARK: - Custom Progress Bar
    //
    // -------------------------------------------------
    
    struct CustomProgressBar: View {
        // Riceviamo il progresso come percentuale (0.0 - 1.0) dal ViewModel
        var progress: Double
        
        // Costanti di configurazione
        private let totalSteps: Int = 5
        private let spacing: CGFloat = 6
        
        var body: some View {
            GeometryReader { geo in
                let totalWidth = geo.size.width
                let height = geo.size.height
                
                // --- 1. CALCOLO DIMENSIONI ---
                // Proporzioni: 15% - 70% - 15%
                let availableWidth = totalWidth - (spacing * 2)
                let smallWidth = availableWidth * 0.15
                let largeWidth = availableWidth * 0.70
                
                // --- 2. CALCOLO STEP CORRENTE (0...5) ---
                let currentStep = Int(round(progress * Double(totalSteps)))
                
                ZStack(alignment: .leading) {
                    
                    // --- STRATO A: I 3 RETTANGOLI ---
                    HStack(spacing: spacing) {
                        
                        // RETTANGOLO 1 (Iniziale) - Step 0
                        renderGlowBar(
                            width: smallWidth,
                            isActive: currentStep == 0,
                            knobRelativePos: 0.5 // Cursore al centro
                        )
                        
                        // RETTANGOLO 2 (Centrale) - Step 1...4
                        renderGlowBar(
                            width: largeWidth,
                            isActive: (currentStep >= 1 && currentStep <= 4),
                            knobRelativePos: calculateCenterKnobRelativePos(step: currentStep)
                        )
                        
                        // RETTANGOLO 3 (Finale) - Step 5
                        renderGlowBar(
                            width: smallWidth,
                            isActive: currentStep == 5,
                            knobRelativePos: 0.5 // Cursore al centro
                        )
                    }
                    
                    // --- STRATO B: IL PALLINO (Knob) ---
                    let knobX = calculateGlobalKnobPosition(
                        step: currentStep,
                        smallW: smallWidth,
                        largeW: largeWidth,
                        gap: spacing
                    )
                    
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .shadow(color: Color.pink.opacity(0.3), radius: 4, x: 0, y: 2)
                        .position(x: knobX, y: height / 2)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: knobX)
                }
            }
            .frame(height: 24)
        }
        
        // --- COMPONENTE: BARRA CON EFFETTO GLOW ---
        @ViewBuilder
        private func renderGlowBar(width: CGFloat, isActive: Bool, knobRelativePos: CGFloat) -> some View {
            ZStack(alignment: .leading) {
                
                // 1. Sfondo Grigio (Base)
                Capsule()
                    .fill(Color(uiColor: .systemGray5))
                    .frame(width: width, height: 16)
                
                // 2. Luce Rosa (Glow)
                // Mostriamo il bagliore solo se la barra è attiva
                if isActive {
                    GeometryReader { internalGeo in
                        // Creiamo un gradiente largo il doppio della barra per avere una sfumatura morbida
                        let glowWidth = width * 1.75
                        
                        // Gradiente: Trasparente -> Rosa Forte -> Trasparente
                        LinearGradient(
                            stops: [
                                .init(color: .pink.opacity(0.01), location: 0.0),
                                .init(color: .pink, location: 0.5), // Centro del bagliore
                                .init(color: .pink.opacity(0.01), location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: glowWidth, height: 16)
                        // Posizioniamo il CENTRO del gradiente esattamente sotto il cursore
                        // knobRelativePos è 0.0-1.0. Moltiplichiamo per la larghezza per avere i pixel.
                        // Sottraiamo metà della larghezza del gradiente (glowWidth/2) per centrarlo.
                        .offset(x: (width * knobRelativePos) - (glowWidth / 2))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: knobRelativePos)
                    }
                    // Mascheriamo tutto dentro la forma della capsula così il gradiente non esce
                    .mask(Capsule())
                }
            }
            .frame(width: width, height: 16) // Forza la dimensione del contenitore
        }
        
        // --- CALCOLI MATEMATICI ---
        
        // Calcola la posizione relativa (0.0 - 1.0) del cursore DENTRO il blocco centrale
        private func calculateCenterKnobRelativePos(step: Int) -> CGFloat {
            guard step >= 1 && step <= 4 else { return 0.5 }
            
            let stepsInRange = CGFloat(step - 1) // 0, 1, 2, 3
            let maxSteps = CGFloat(3) // 4-1
            let rawPercent = stepsInRange / maxSteps
            
            // Margini visivi: non vogliamo il cursore attaccato ai bordi (15% - 85%)
            let minPos = 0.15
            let maxPos = 0.85
            
            return minPos + (rawPercent * (maxPos - minPos))
        }
        
        // Calcola la posizione assoluta X per il pallino bianco (sopra tutto)
        private func calculateGlobalKnobPosition(step: Int, smallW: CGFloat, largeW: CGFloat, gap: CGFloat) -> CGFloat {
            
            let block1_Start: CGFloat = 0
            let block2_Start: CGFloat = smallW + gap
            let block3_Start: CGFloat = smallW + gap + largeW + gap
            
            switch step {
            case 0:
                return block1_Start + (smallW / 2)
            case 5:
                return block3_Start + (smallW / 2)
            default:
                // Usiamo la stessa logica relativa per trovare i pixel assoluti
                let relativePos = calculateCenterKnobRelativePos(step: step)
                // Mappiamo la posizione relativa nella larghezza del blocco centrale
                return block2_Start + (largeW * relativePos)
            }
        }
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
                        Text(taskStatus.task.title.localized)
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
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(SquishyButtonEffect())
        }
        
        
    }
    
    
   
}




// -------------------------------------------------
//
// MARK: - Education Sheet
//
// -------------------------------------------------


// MARK: - SHEET 1: Istruzioni (Prima di completare)
struct EducationInstructionSheet: View {
    @Environment(\.dismiss) private var dismiss
    // Questa closure serve per dire alla Home: "Spostati sul tab Learn"
    let isCompleted: Bool
    var onGoToLearn: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Icona Grande
            Image(systemName: iconName(for: TaskCategory.education))
                .font(.system(size: 30))
                .foregroundStyle(.pink)
                .frame(width: 73, height: 73)
                .background(Color.pink.opacity(0.1))
                .clipShape(Circle())
                .padding(.vertical, 24)
            
       
            Text("education_01_title".localized)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 24)
        
            Text("education_01_desc".localized)
                .font(.system(.body, design: .default))
                .fontWeight(.regular)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                                
            Spacer()
            
            // --- SEZIONE AZIONI ---
            
            // CASO 1: Già completato
            if isCompleted {
                VStack (spacing: 0){
                    
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
                Button(action: {
                    dismiss()
                    // Ritardiamo leggermente la navigazione per far chiudere il foglio in modo fluido
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onGoToLearn()
                    }
                }) {
                    Text("education_01_cta".localized)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous) // 300 o 30 per pillola
                                .fill( Color.pink)
                        )
                }
                .buttonStyle(SquishyButtonEffect())
            }
           
        }
        .padding()
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






// -------------------------------------------------
//
// MARK: - VIP TASK CARD
//
// -------------------------------------------------


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
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(SquishyButtonEffect()) // Stesso effetto tocco della ClassicTask
    }
    
}


private func iconName(for cat: TaskCategory) -> String {
    switch cat {
    case .shopping: return "bag.fill"
    case .home: return "house.fill"
    case .finance: return "building.columns.fill"
    case .family: return "figure.2.and.child.holdinghands"
    case .education: return "graduationcap.fill"
    }
}


