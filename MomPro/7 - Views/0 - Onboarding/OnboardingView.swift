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
    }
    
    @State private var phase: OnboardingPhase = .landing
    @State private var selectedOption: String? = nil
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Namespace per animazioni coordinate (Hero Animations)
    @Namespace private var namespace
    
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
                    .transition(.move(edge: .leading))
                }
                
                // 2. QUESTION SCREEN (Gestisce sia Intro che Input)
                if phase == .questionIntro || phase == .questionInput {
                    QuestionScreen(
                        phase: $phase,
                        selectedOption: $selectedOption,
                        onContinue: completeOnboarding,
                        namespace: namespace
                    )
                    .transition(.move(edge: .trailing))
                }
            }
        }
        // Forza la dark mode per l'effetto premium del video,
        // rimuovi se vuoi che si adatti al sistema
        .preferredColorScheme(.dark)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    // MARK: - LOGICA TRANSIZIONI
    /*
    func startTransition() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.smooth(duration: 0.6)) {
            phase = .questionIntro
        }
        
        // Dopo 1.2 secondi, sposta la domanda in alto
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                phase = .questionInput
            }
        }
    }*/
    
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
    
    func completeOnboarding() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        withAnimation {
            hasCompletedOnboarding = true
        }
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
        "cart.fill",
        "house.fill",
        "banknote.fill",
        "figure.2.and.child.holdinghands",
        "graduationcap.fill",
        "chart.line.uptrend.xyaxis"
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
                    Image("mascotte_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        // .continuous è il segreto per la forma "squircle" di Apple
                        // 18 è circa il 22% di 80, la proporzione standard iOS
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        // Aggiungiamo un bordo sottilissimo per definirla sul nero
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
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
                .matchedGeometryEffect(id: "QuestionTitle", in: namespace)
                .padding(.horizontal)
            
            if phase == .questionIntro {
                Spacer()
            }
            
            // --- GRIGLIA OPZIONI ---
            if phase == .questionInput {
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



/*
// Preview
#Preview {
   OnboardingView()
}
*/
