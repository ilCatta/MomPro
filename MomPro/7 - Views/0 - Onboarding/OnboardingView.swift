//
//  Onboarding.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI
import RevenueCat
import RevenueCatUI
import Combine
import HugeiconsCore
import HugeiconsDuotoneRounded
import HugeiconsSolidRounded
import HugeiconsStrokeRounded


// MARK: - MAIN VIEW
struct OnboardingView: View {
    
    // Gestione stati dell'animazione
    enum OnboardingPhase {
        case landing        // Schermata iniziale con icone
        case questionIntro  // Domanda al centro
        case questionInput  // Domanda in alto e opzioni
        case statProblem      // Mascotte alla lavagna (Il problema)
        case statSolution     // Testo che cambia (La soluzione)
        case wasteAnalysis   // Schermata "Yet without realizing"
        case powerToChange   // Schermata finale
    }
    
    @State private var phase: OnboardingPhase = .landing
    @State private var selectedOption: String? = nil
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Namespace per animazioni coordinate (Hero Animations)
    @Namespace private var namespace
    
    @State private var showingPaywall = false
    
    var body: some View {
        ZStack {
            // SFONDO: Nero (come video) o System Background
            Color.black.ignoresSafeArea()
            
            // CONTENUTO
            ZStack {
                
                // 1. LANDING SCREEN
                if phase == .landing {
                    LandingScreen(
                        onStart: startTransition,
                        namespace: namespace
                    )
                    // Esce verso SINISTRA (spinta via dalla prossima)
                    .transition(.move(edge: .leading))
                }
                
                // 2. QUESTION SCREEN (Gestisce sia Intro che Input)
                if phase == .questionIntro || phase == .questionInput {
                    QuestionScreen(
                        phase: $phase,
                        selectedOption: $selectedOption,
                        onContinue: goToStats,
                        namespace: namespace
                    )
                    // Entra da DESTRA, Esce verso SINISTRA (Effetto scorrimento continuo)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        )
                    )
                }
                
                // 3. STAT PROBLEM SCREEN (Mascotte Lavagna)
                else if phase == .statProblem {
                    StatProblemView(
                        onTapAnywhere: goToSolution // Tap per proseguire
                    )
                    // Insertion: .opacity -> Il testo nasce al centro
                    // Removal: .move(edge: .top) -> Esce verso l'alto
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.smooth(duration: 0.6)),
                        removal: .move(edge: .top)
                    ))
                    .zIndex(2) // Assicura che stia sopra durante l'uscita
                }
                
                // 4. STAT SOLUTION SCREEN (Testo che cambia)
                else if phase == .statSolution {
                    StatSolutionView(
                        onFinish: goToWasteAnalysis
                    )
                    // Entra dal basso
                    //.transition(.move(edge: .bottom).animation(.spring(response: 0.7, dampingFraction: 0.8)))
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).animation(.spring(response: 0.7, dampingFraction: 0.8)),
                        // removal: .scale(0.1) rimpicciolisce il testo verso il centro
                        removal: .scale(scale: 0.1).combined(with: .opacity).animation(.smooth(duration: 0.6))
                    ))
                    .zIndex(3)
                }
                
                // 5. WASTE ANALYSIS SCREEN
                else if phase == .wasteAnalysis {
                    WasteAnalysisView(
                        onNext: goToPowerToChange
                    )
                    // Transizione: se ne va a SINISTRA per far posto alla finale
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(4)
                }
                
                // 6. POWER TO CHANGE SCREEN
                else if phase == .powerToChange {
                    PowerToChangeView(
                        onFinish: openPaywall
                    )
                    // Appare da DESTRA mentre la precedente va a sinistra
                    .transition(.move(edge: .trailing))
                    .zIndex(5)
                }
                
            }
       
        }
        // Forza la dark mode per l'effetto premium del video,
        // rimuovi se vuoi che si adatti al sistema
        .preferredColorScheme(.dark)
        .toolbarColorScheme(.dark, for: .navigationBar)
        //
        .sheet(isPresented: $showingPaywall, onDismiss: {
            // Quando il paywall viene chiuso, l'onboarding è completato
            completeOnboarding()
        }) {
            // View di RevenueCatUI
            PaywallView(displayCloseButton: true)
        }
    }
    
    // MARK: - LOGICA TRANSIZIONI
    func startTransition() {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // 1. Fase Intro: Icone spariscono, Titolo appare
            withAnimation(.smooth(duration: 0.6)) {
                phase = .questionIntro
            }
            
            // 2. Fase Input: Titolo sale, Opzioni appaiono in Fade-In
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                // Usa .smooth o .easeInOut per un effetto "Cinema"
                // dampingFraction: 1.0 rimuove il rimbalzo, rendendo il fade pulito
                withAnimation(.spring(response: 0.7, dampingFraction: 1.0)) {
                    phase = .questionInput
                }
            }
        }
    
    // Dalla Domanda alla prima Statistica (Problema)
    func goToStats() {
        guard selectedOption != nil else { return }
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Animazione fluida per lo scorrimento laterale
        withAnimation(.smooth(duration: 0.6)) {
            phase = .statProblem
        }
    }
    
    // Dalla Statistica Problema alla Soluzione (Tap anywhere)
    func goToSolution() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.smooth(duration: 0.8)) {
            phase = .statSolution
        }
    }
    
    func goToWasteAnalysis() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        withAnimation(.smooth(duration: 0.8)) {
            phase = .wasteAnalysis
        }
    }

    func goToPowerToChange() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        // Transizione laterale: questa va a sinistra, la nuova entra da destra
        //withAnimation(.spring(response: 0.8, dampingFraction: 1.0)) {
        //    phase = .powerToChange
        //}
        withAnimation(.smooth(duration: 0.6)) {
            phase = .powerToChange
        }
    }
    
    func openPaywall(){
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        showingPaywall = true
    }

    func completeOnboarding() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        //withAnimation {
            hasCompletedOnboarding = true
        //}
    }
    
    
}


// -------------------------------------------------
//
// MARK: - 1) LANDING SCREEN COMPONENT
//
// -------------------------------------------------

struct LandingScreen: View {
    
    var onStart: () -> Void
    var namespace: Namespace.ID
    
    // Testi che ruotano
    let rollingWords = [
        "onboarding_view_success",
        "onboarding_view_independence",
        "onboarding_view_serenity",
        "onboarding_view_control"
    ]
    @State private var currentWordIndex = 0
    @State private var timer: Timer?
    
    var body: some View{
    
        VStack(spacing: 0) {
            
            Spacer()
            
           // --- ORBIT SYSTEM ---
            OrbitingIconsView()
                .frame(height: 300)
                .padding(.bottom, 40)
            
            Spacer()
            Spacer()
            
            // --- APP NAME SHIMMER ---
            ShimmerText(text: "MomPro")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)
                .padding(.bottom, 20)
            
            // --- TITOLO GRANDE ---
            VStack(spacing: 0) {
                Text("onboarding_view_set_yourself_up_for".localized)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 0)
                
                // Parola che cambia
                Text(rollingWords[currentWordIndex].localized)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.pink)
                    // Questo crea l'effetto "slot machine" o scorrimento numerico
                    .contentTransition(.numericText(value: Double(currentWordIndex)))
                    .animation(.snappy(duration: 0.4), value: currentWordIndex)
            }
            .padding(.bottom, 20)
            
            // --- SOTTOTITOLO ---
            Text("onboarding_view_plan_save_and_invest_10_minutes".localized)
                .font(.system(.body, design: .default))
                .fontWeight(.medium)
                .foregroundStyle(.gray.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            
            //Spacer()
            
            // --- BUTTON START ---
            Button(action: onStart) {
                HStack {
                    Text("onboarding_view_start_now".localized)
                }
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous) // 300 o 30 per pillola
                        .fill( Color.white)
                )
            }
            .padding(.horizontal)
            .buttonStyle(SquishyButtonEffect())
        }
        .onAppear {
            startRollingText()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func startRollingText() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation {
                currentWordIndex = (currentWordIndex + 1) % rollingWords.count
            }
        }
    }
}



// MARK: - 2. ORBITING ICONS SYSTEM (Timeline Based - Indistruttibile)
struct OrbitingIconsView: View {
    
    let icons = [
        "bag.fill",
        "house.fill",
        "building.columns.fill",
        "figure.2.and.child.holdinghands",
        "graduationcap.fill",
        "chart.bar.xaxis.ascending"
    ]
    
    let radius: CGFloat = 130
    
    var body: some View {
        // KeyframeAnimator ricostruisce la vista frame-per-frame basandosi su un valore
        // Non dipende da onAppear, quindi non si blocca mai.
        KeyframeAnimator(
            initialValue: 0.0,
            repeating: true
        ) { angle in
            ZStack {
                
                // --- AURA CENTRALE ---
                ZStack {
                    
                    // 1. L'ALONE (GLOW)
                    ZStack {
                        // A. Strato di fondo per l'atmosfera (ampio e morbido)
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.pink.opacity(0.4))
                            .frame(width: 135, height: 135)
                            .blur(radius: 50)
                        
                        // B. Strato centrale "Acceso" (Nucleo)
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.9, blue: 0.95), // Centro quasi bianco (Luce forte)
                                        Color.pink,                             // Rosa Intenso
                                        Color.pink.opacity(0.0)                 // Svanisce nel nulla
                                    ]),
                                    center: .center,
                                    startRadius: 5,  // Il punto di luce massima è piccolo
                                    endRadius: 60    // La sfumatura arriva fino al bordo
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 15) // Blur minore per mantenere il centro "caldo"
                    }
                    
                    // 2. L'ICONA VERA E PROPRIA
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                       
                }
                
                // --- ICONE ORBITANTI ---
                ForEach(0..<icons.count, id: \.self) { index in
                    // 1. Calcoliamo l'angolo fisso di questa icona sulla torta (0°, 60°, 120°...)
                    let baseAngle = (Double(index) / Double(icons.count)) * 360.0
                    
                    // 2. Sommiamo l'angolo dell'animazione corrente
                    let currentAngle = baseAngle + angle
                    
                    // 3. Convertiamo in radianti per seno/coseno
                    let radians = currentAngle * .pi / 180.0
                    
                    // 4. Calcoliamo X e Y (Matematica pura, niente rotazioni visive che confondono SwiftUI)
                    let x = radius * cos(radians)
                    let y = radius * sin(radians)
                    
                    Image(systemName: icons[index])
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 50, height: 50)
                        .position(x: 150 + x, y: 150 + y) // 150 è metà frame (300/2) per centrarlo
                }
            }
            // Definiamo la grandezza del contenitore esplicitamente per i calcoli .position
            .frame(width: 300, height: 300)
            
        } keyframes: { _ in
            // Definiamo il ciclo: da 0 a 360 gradi in 20 secondi, lineare
            LinearKeyframe(360.0, duration: 40.0)
        }
    }
}



// MARK: - 4.  SHIMMER TEXT

struct ShimmerText: View {
    var text: String
    // Stato per muovere la luce da sinistra a destra
    @State private var spotlightOffset: CGFloat = -150
    
    var body: some View {
        ZStack {
            // 1. Testo Base (Spento/Grigio Rosato)
            Text(text)
                // Un colore base che richiami il brand ma spento
                .foregroundStyle(Color.gray.opacity(0.7))
            
            // 2. Testo Acceso (Bianco Brillante) mascherato dalla luce
            Text(text)
                .foregroundStyle(.white)
                // La maschera decide dove mostrare il bianco
                .mask(
                    // Creiamo un "faro" di luce
                    GeometryReader { geo in
                        RadialGradient(
                            gradient: Gradient(colors: [.white, .white.opacity(0.5), .clear]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 50 // Dimensione del bagliore
                        )
                        .frame(width: 100, height: geo.size.height + 40) // Alto quanto basta, stretto
                        .blur(radius: 5) // Ammorbidisce i bordi del bagliore
                        .offset(x: spotlightOffset) // Muove la luce
                        .onAppear {
                            // Calcola quanto deve viaggiare la luce in base alla larghezza del testo
                            let travelDistance = geo.size.width + 200
                            spotlightOffset = -travelDistance / 2
                            
                            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false).delay(0.5)) {
                                spotlightOffset = travelDistance / 2
                            }
                        }
                    }
                )
            // Aggiungiamo un leggero bagliore esterno al testo bianco per enfatizzare l'effetto luce
            .shadow(color: .white.opacity(0.6), radius: 8, x: 0, y: 0)
        }
    }
}


// -------------------------------------------------
//
// MARK: - 2) QUESTION SCREEN
//
// -------------------------------------------------

struct QuestionScreen: View {
    
    @Binding var phase: OnboardingView.OnboardingPhase
    @Binding var selectedOption: String?
    var onContinue: () -> Void
    var namespace: Namespace.ID
    
    let options = [
        "onboarding_view_option_groceries",
        "onboarding_view_option_investing",
        "onboarding_view_option_home",
        "onboarding_view_option_stress",
        "onboarding_view_option_meals",
        "onboarding_view_option_renovation"
    ]
    
    var body: some View {
        VStack(spacing: 0 ) {
            
            // SPAZIATORE SUPERIORE (Dinamico)
            // Se siamo in fase 'input', serve spazio per la Safe Area.
            // Se siamo in fase 'intro', usiamo Spacer per centrare.
            if phase == .questionInput {
                //Color.clear.frame(height: 60)
            } else {
                Spacer()
            }
            
            // --- DOMANDA ---
            Text("onboarding_view_what_s_your_goal".localized)
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if phase == .questionIntro {
                Spacer()
            }
            
            // --- GRIGLIA OPZIONI ---
            if phase != .questionIntro {
                //Spacer(minLength: 20)
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 16) {
                        
                        // --- DESCRIZIONE (Appare solo dopo) ---
                        Text("onboarding_view_question_subtitle".localized)
                            .font(.system(.body, design: .default))
                            .fontWeight(.medium)
                            .foregroundStyle(.gray.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.vertical)
                            .padding(.bottom, 8)
                            //.transition(.opacity.combined(with: .move(edge: .bottom)))
                        
                        
                        ForEach(options, id: \.self) { option in
                            OptionButton(
                                text: option.localized,
                                isSelected: selectedOption == option,
                                action: {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        selectedOption = option
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                // Animazione di entrata delle opzioni (dal basso)
                .transition(
                    .asymmetric(
                        insertion: .opacity
                            .combined(with: .move(edge: .bottom).animation(.smooth(duration: 0.8))), // Entra dal basso ma dolce
                        removal: .opacity
                    )
                )
                
                // --- BOTTONE CONTINUA ---
                Button(action: onContinue) {
                    Text("actions_continue".localized)
                        .font(.headline)
                        .foregroundStyle(selectedOption != nil ? .black : .gray.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(selectedOption != nil ? Color.white : Color(white: 0.15))
                        )
                }
                .disabled(selectedOption == nil)
                .padding(.horizontal)
                .buttonStyle(SquishyButtonEffect())
            }
        }
    }
}

// Componente Bottone Opzione
struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        
        Button(action: action) {
            HStack {
                
                Text(text)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : .white)
                
                Spacer()
                
                if isSelected {
                    HugeiconsText(
                        "checkmark-circle-02",
                        font: HugeiconsSolidRounded.hugeiconsFont(size: 27),
                        color: .white
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous) // 300 o 30 per pillola
                    .fill(isSelected ? Color.pink : Color(uiColor: .secondarySystemGroupedBackground))
                    .environment(\.colorScheme, .dark)
            )
        }
        .buttonStyle(SquishyButtonEffect())
        .scaleEffect(isSelected ? 1.01 : 1.0)
    }
}


// -------------------------------------------------
//
// MARK: - 3) STAT PROBLEM
//
// -------------------------------------------------

struct StatProblemView: View {
    var onTapAnywhere: () -> Void
    
    // Stati interni
    @State private var textIsGrainyAndSmall = true
    @State private var showTapToContinue = false
    @State private var showText = false
    @State private var moveTextUp = false
    @State private var showBridgeText = false
    
    @State private var showImage1 = false
    @State private var showImage2 = false
    @State private var showImage3 = false
    @State private var showImage4 = false
    
    @State private var isAnimationComplete = false
    
    private var _sizeImage: CGFloat {
        switch DeviceType.current {
        case .small: return 95
        case .standard: return 105
        case .large: return 130
        case .ipadMini: return 140
        case .ipadStandard: return 150
        case .ipadHuge: return 150
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) { // Spacing manuale per controllo preciso
                
                // 1. SPACER SUPERIORE
                // Logica:
                // - Se la mascotte NON c'è: Spacer() spinge il testo al centro verticale.
                // - Se la mascotte C'È: Spacer().frame(height: 80) blocca il testo in alto.
                if !moveTextUp {
                    Spacer()
                } else {
                    // Questo spazio fisso determina quanto in alto va il testo
                    Spacer().frame(height: 32)
                }
                
                // 2. TESTO STATISTICA (Stili originali mantenuti)
                Text("onboarding_view_on_average_mom_manages".localized)
                    .font(.system(.title, design: .default))
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .blur(radius: textIsGrainyAndSmall ? 3 : 0)
                    .scaleEffect(textIsGrainyAndSmall ? 0.7 : 1.0)
                    .opacity(showText ? (textIsGrainyAndSmall ? 0.6 : 1.0) : 0)
                
                Text("onboarding_view_85_family_expenses".localized)
                    .font(.system(.title, design: .default))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .blur(radius: textIsGrainyAndSmall ? 3 : 0)
                    .scaleEffect(textIsGrainyAndSmall ? 0.7 : 1.0)
                    .opacity(showText ? (textIsGrainyAndSmall ? 0.6 : 1.0) : 0)
                
                // 3. AREA CONTENUTO DINAMICO (Le 3 Immagini)
                if moveTextUp {
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        if showImage1 {
                            statImageCard(imageName: "mascotte_onboarding_1", size: _sizeImage)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        
                        if showImage2 {
                            statImageCard(imageName: "mascotte_onboarding_2",size: _sizeImage)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        
                        if showImage3 {
                            statImageCard(imageName: "mascotte_onboarding_3",size: _sizeImage)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                        
                        if showImage4 {
                            statImageCard(imageName: "mascotte_onboarding_4",size: _sizeImage)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    // TESTO PONTE
                    if showBridgeText {
                        Text("onboarding_view_but_managing_doesn".localized)
                            .font(.system(.title2, design: .default))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    Spacer()
                    Spacer()
                    
                    } else {
                        Spacer()
                    }
            }
            
            // TAP TO CONTINUE (In basso)
            VStack {
                Spacer()
                if showTapToContinue {
                    ShimmerText(text: "onboarding_view_tap_anywhere_to_continue".localized)
                        .font(.system(.title3, design: .default))
                        .fontWeight(.medium)
                        .padding(.bottom, 20)
                        .transition(.opacity)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isAnimationComplete {
                onTapAnywhere()
            }
        }
        .onAppear {
            animateSequence()
        }
    }
    
    // Helper per creare le card immagini tutte uguali
    @ViewBuilder
    func statImageCard(imageName: String, size: CGFloat) -> some View {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: size) // Altezza rettangolare fissa
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
        }
    
    func animateSequence() {
            // 1. Appare il testo
            withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
                showText = true
            }
            
            // 2. Nitidezza
            withAnimation(.smooth(duration: 1.4).delay(0.6)) {
                textIsGrainyAndSmall = false
            }
            
            // 3. Salita testo
            withAnimation(.smooth(duration: 1.0).delay(2.4)) {
                moveTextUp = true
            }
            
            // 4. Ingresso ritmato immagini (Cascata)
            let baseDelay = 2.6
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(baseDelay)) {
                showImage1 = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(baseDelay + 0.3)) {
                showImage2 = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(baseDelay + 0.6)) {
                showImage3 = true
            }
        
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(baseDelay + 0.9)) {
                showImage4 = true
            }
            
            // 5. Appare il testo ponte
            withAnimation(.easeOut(duration: 0.8).delay(baseDelay + 1.5)) {
                showBridgeText = true
            }
            
            // 6. Tap to continue
            withAnimation(.easeOut(duration: 0.8).delay(baseDelay + 2.3)) {
                showTapToContinue = true
            } completion: {
                // Questo viene eseguito SOLO quando l'animazione sopra è finita
                isAnimationComplete = true
            }
        }
}
// -------------------------------------------------
//
// MARK: - 4) STAT SOLUTION
//
// -------------------------------------------------


struct StatSolutionView: View {
    var onFinish: () -> Void
    
    // STATI PER IL CONTROLLO FINE DELLE ANIMAZIONI
    @State private var percentage: Int = 70         // Parte da 70
    @State private var showAsterisk = false         // Appare solo alla fine
    @State private var showFinalLabel = false       // Appare con l'alzarsi del testo
    @State private var showDisclaimer = false       // Slide da destra
    @State private var finalScale: CGFloat = 1.0    // Pulse finale
    @State private var isAnimationComplete = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // --- GRUPPO CENTRALE (Unico blocco di testo iOS 26 Style) ---
            VStack(spacing: 0) {
                
                // 1. "Punta a un"
                Text("onboarding_view_stat_aim_for".localized)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 0)
                
                // 2. IL NUMERO E IL SIMBOLO (Concatenati in un unico Text)
                // Usiamo l'interpolazione nidificata come richiesto da iOS 26
                
                Text("\(Text(String(percentage)).font(.system(.largeTitle, design: .rounded)).monospacedDigit())\(Text("\("onboarding_view_stat_yield".localized)\(showAsterisk ? "*" : "")").font(.system(.largeTitle, design: .rounded)))")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    // Effetto rullo numerico che si attiva ad ogni cambio di 'percentage'
                    .contentTransition(.numericText(value: Double(percentage)))
                
                    Text(showFinalLabel ? "onboarding_view_average_per_year".localized : "")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 0)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
          
            }
            .offset(y: -20)
            .scaleEffect(finalScale)
            
            // --- FOOTER SECTION ---
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 6) {
                    if showDisclaimer {
                        Text("onboarding_view_stat_disclaimer".localized)
                            .font(.system(.footnote, design: .default))
                            .fontWeight(.medium)
                            .foregroundStyle(.gray)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Text("onboarding_view_stat_source".localized)
                        .font(.system(.caption2, design: .default))
                        .fontWeight(.medium)
                        .foregroundStyle(.gray.opacity(0.4))
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isAnimationComplete {
                onFinish()
            }
        }
        .onAppear {
            startCountingSequence()
        }
    }
    
    // MARK: - COREOGRAFIA ANIMAZIONI
    private func startCountingSequence() {
        let startValue = 70
        let endValue = 8
        let totalSteps = startValue - endValue // 62 passi
        let totalTime: Double = 2.5            // Durata richiesta
        let interval = totalTime / Double(totalSteps) // Tempo tra un numero e l'altro (~0.04s)
        
        for i in 0...totalSteps {
            let currentDelay = Double(i) * interval
            
            DispatchQueue.main.asyncAfter(deadline: .now() + currentDelay) {
                // Ogni decremento attiva l'effetto .numericText()
                withAnimation(.snappy(duration: interval)) {
                    self.percentage = startValue - i
                    
                    // TRIGGER: Esattamente a quota x, alziamo il testo (come nel video)
                    if self.percentage == 17 {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                            self.showFinalLabel = true
                        }
                    }
                    
                    // FINE: Quando arriviamo a 8, aggiungiamo l'asterisco e mostriamo il disclaimer
                    if self.percentage == 8 {
                        withAnimation(.spring()) {
                            self.showAsterisk = true
                            self.showDisclaimer = true
                        }
                        triggerFinalPulse()
                    }
                }
            }
        }
    }
    
    private func triggerFinalPulse() {
        // Effetto ingrandimento di enfasi finale
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                finalScale = 1.25
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    finalScale = 1.2
                } completion: {
                isAnimationComplete = true
            }
            }
        }
    }
}


// -------------------------------------------------
//
// MARK: - 5) Waste Analysis (Corretta)
//
// -------------------------------------------------

struct WasteAnalysisView: View {
    var onNext: () -> Void
    
    @State private var revealHeight: CGFloat = 0 // Altezza del pannello bianco
    @State private var showIcons = false
    @State private var secondPhase = false // Inversione colori per la fase 2
    @State private var isAnimationComplete = false
    
    let wasteEmojis = ["💸", "📉", "🛒", "🛍️", "☕","🧾","⛓️"]
    let wasteRadii: [CGFloat] = [175, 180, 170, 165, 165, 150, 180]
    let valueEmojis = ["🏠", "🎓", "🌴", "🎨", "🧘‍♀️", "📈","💎","🍱", "💰", "🧸","🍳"]
    
    var body: some View {
        GeometryReader { geo in
            // Calcoliamo la metà esatta per le proporzioni 50/50
            let halfHeight = geo.size.height / 2
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // --- PARTE SUPERIORE (50%) ---
                    ZStack {
                        // 1. Pannello che scende (Rivelatore)
                        Rectangle()
                            .fill(secondPhase ? Color.black : Color.white)
                            .ignoresSafeArea(edges: .top)
                            .frame(height: revealHeight)
                            .frame(maxHeight: .infinity, alignment: .top) // Ancorato in alto
                            .opacity(revealHeight > 0 ? 1 : 0) // Nasconde il bianco nella Safe Area finché revealHeight è 0
                            .overlay {
                                if secondPhase {
                                    Color.black.opacity(0.6).blur(radius: 20)
                                }
                            }
                        
                        // 2. Testi Neri - FISSI (Si vedono solo quando il bianco ci passa sotto)
                        VStack(spacing: 8) {
                            Text("onboarding_view_yet_unrealizing".localized)
                            Text("onboarding_view_waste_potential".localized)
                            Text("onboarding_view_daily_costs".localized)
                        }
                        .font(.system(.title3, design: .default))
                        .fontWeight(.semibold)
                        // Cambia in bianco solo nella seconda fase quando lo sfondo diventa nero
                        .foregroundStyle(secondPhase ? .white : .black)
                        .multilineTextAlignment(.center)
                        
                        // Emoji Orbitanti (Sprechi)
                        if showIcons {
                            EmojiOrbitView(emojis: wasteEmojis, radius: 170, radii: wasteRadii, isBlurred: secondPhase)
                                .transition(.opacity)
                            
                        }
                    }
                    .frame(height: halfHeight)
                        
                        // --- PARTE INFERIORE (50%) ---
                        ZStack {
                            Rectangle()
                                .fill(secondPhase ? Color.white : Color.black)
                                .ignoresSafeArea(edges: .bottom)
                            
                            if secondPhase {
                                VStack(spacing: 8) {
                                    Text("onboarding_view_instead_building".localized)
                                    Text("onboarding_view_your_future".localized)
                                }
                                .font(.system(.title2, design: .default))
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                                
                                // Emoji Orbitanti (Valore/Futuro)
                                EmojiOrbitView(emojis: valueEmojis, radius: 155, isRotating: true)
                            }
                        }
                        .frame(height: halfHeight)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if isAnimationComplete { onNext() }
                }
                .onAppear {
                    runSequence(targetHeight: halfHeight)
                }
            }
            .ignoresSafeArea()
        }
        
        func runSequence(targetHeight: CGFloat) {
            // 1. Il pannello bianco scende per rivelare i testi "nascosti"
            withAnimation(.smooth(duration: 1.5).delay(0.5)) {
                revealHeight = targetHeight
            }
            
            // Apparizione icone dopo che il reveal è a buon punto
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.6)) {
                    showIcons = true
                }
            }
            
            // 2. Transizione alla seconda fase (Inversione colori e reveal sotto)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                    secondPhase = true
                }
            }
            
            // 3. Sblocco del tocco finale
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                isAnimationComplete = true
            }
        }
    }
    
    
    struct EmojiOrbitView: View {
        let emojis: [String]
        let radius: CGFloat
        var radii: [CGFloat]? = nil // Per gestire distanze diverse
        var isRotating: Bool = false
        var isBlurred: Bool = false
        
        var body: some View {
            KeyframeAnimator(initialValue: 0.0, repeating: true) { angle in
                ZStack {
                    ForEach(0..<emojis.count, id: \.self) { i in
                        let baseAngle = (Double(i) / Double(emojis.count)) * 360.0
                        let radians = (baseAngle + (isRotating ? angle : 0)) * .pi / 180.0
                        
                        // Se abbiamo radii specifici, usiamo quelli, altrimenti il radius standard
                        let currentRadius = (radii != nil && i < radii!.count) ? radii![i] : radius
                        
                        Text(emojis[i])
                            .font(.system(size: 30))
                            .offset(x: currentRadius * cos(radians), y: currentRadius * sin(radians))
                            .blur(radius: isBlurred ? 4 : 0)
                            .opacity(isBlurred ? 0.5 : 1)
                    }
                }
            } keyframes: { _ in
                LinearKeyframe(360.0, duration: 25.0)
            }
        }
    }
    
    
    // -------------------------------------------------
    //
    // MARK: - 6) Power to change
    //
    // -------------------------------------------------
    
    struct PowerToChangeView: View {
        var onFinish: () -> Void
        @State private var showText = false
            @State private var showTapToContinue = false
        
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Text("onboarding_view_power_to_change".localized)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .opacity(showText ? 1 : 0)
                    .scaleEffect(showText ? 1 : 0.9)
                
                    VStack {
                        Spacer()
                        if showTapToContinue {
                            ShimmerText(text: "onboarding_view_tap_cta_final".localized)
                                .font(.system(.title3, design: .default))
                                .fontWeight(.medium)
                                .padding(.bottom, 20)
                                .transition(.opacity)
                        }
                    }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if showTapToContinue {
                    onFinish()
                }
            }
            .onAppear {
                withAnimation(.smooth(duration: 1.5).delay(0.5)) {
                    showText = true
                }
                // Apparizione Shimmer dopo un breve delay
                withAnimation(.easeOut(duration: 0.8).delay(1.8)) {
                    showTapToContinue = true
                }
            }
        }
    }


/*
// Preview
#Preview {
   OnboardingView()
}
*/
