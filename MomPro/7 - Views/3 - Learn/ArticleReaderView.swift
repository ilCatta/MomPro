//
//  ArticleReaderView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//
import SwiftUI
import RevenueCatUI // Per il paywall se l'utente clicca su un articolo bloccato

struct ArticleReaderView: View {
    let article: Article
    var viewModel: LearnViewModel // Passiamo il VM per segnare come letto
    
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false
    @State private var isRead: Bool = false
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                // --- SFONDO ---
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        
                        // --- IMMAGINE HEADER (STRETCHY HEADER) ---
                         let headerHeight = geo.size.height * 0.37 // Altezza di base
                         GeometryReader { scrollGeo in
                            let minY = scrollGeo.frame(in: .global).minY 
                            
                            Image(article.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: geo.size.width,
                                       height: headerHeight + (minY > 0 ? minY : 0), alignment: .top)
                                .clipped()
                                // Effetto bloccato
                                // 1. Rende l'immagine in bianco e nero se bloccata
                                 .saturation(viewModel.isLocked(article) ? 0 : 1)
                                 
                                 // 2. Aggiunge una patina scura se bloccata
                                 .overlay {
                                     if viewModel.isLocked(article) {
                                         Color.black.opacity(0.5)
                                     }
                                 }
                                //
                                .overlay(alignment: .bottomLeading) {
                                    // Badge Pro o Categoria
                                    HStack {
                                        if article.isPro {
                                            Text("PRO")
                                                .font(.system(.caption ,design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal,8)
                                                .padding(.vertical,6)
                                                .background(.pink)
                                                .cornerRadius(10)
                                        }
                                        Text(article.category.rawValue.localized)
                                            .font(.system(.caption ,design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .textCase(.uppercase)
                                            .padding(.horizontal,8)
                                            .padding(.vertical,6)
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .cornerRadius(10)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 4) {
                                                Image(systemName: "clock")
                                            
                                                Text("\(article.readTimeMinutes) \("learn_view_min".localized)")
                                                .textCase(.uppercase)
                                            }
                                            .font(.system(.caption ,design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .padding(.horizontal,8)
                                            .padding(.vertical,6)
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .cornerRadius(10)
                                        
                                        
                                        HStack{
                                            Text(difficultyString)
                                            difficultyIcon
                                        }
                                        .font(.system(.caption ,design: .rounded))
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .textCase(.uppercase)
                                            .padding(.horizontal,8)
                                            .padding(.vertical,6)
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .cornerRadius(10)
                                        
                                        
                                    }
                                    .padding()
                                }
                                .offset(y: minY > 0 ? -minY : 0)
                        }
                         .frame(height: headerHeight)
                         .padding(.bottom, 2)
                        // --- FINE IMMAGINE HEADER (STRETCHY HEADER) ---
                        
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(article.title.localized)
                                .font(.system(.title ,design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.bottom)
                            
                            // Divider
                            Rectangle()
                                .fill(Color(uiColor: .separator))
                                .frame(height: 1)
                                .padding(.bottom)

                            
                            // CONTENUTO (Markdown supportato nativamente da Text in SwiftUI)
                            if viewModel.isLocked(article) {
                                lockedView
                            } else {
                                
                                // 1. Carica il testo grezzo
                                let rawContent = article.loadMarkdownContent()
                                
                                // 2. Ottieni il simbolo della valuta locale dell'utente
                                // Se non lo trova, usa "$" come fallback di sicurezza
                                let userCurrencySymbol = Locale.current.currencySymbol ?? "$"
                                
                                // 3. Sostituisci il placeholder {{CURRENCY}} con il simbolo vero
                                let localizedContent = rawContent.replacingOccurrences(of: "{{CURRENCY}}", with: userCurrencySymbol)
                                
                                // 4. Mostra il testo
                                Text(LocalizedStringKey(localizedContent))
                                    .font(.body)
                                    .lineSpacing(6)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
        }
                //
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.isLocked(article) {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        markRead()
                    }) {
                        if viewModel.isRead(article) || isRead {
                            HStack(spacing: 4){
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                                
                                Text("learn_view_read".localized)
                                    .font(.system(.subheadline ,design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)}
                        } else {
                            Text("learn_view_markasread".localized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .disabled(viewModel.isRead(article) || isRead)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(displayCloseButton: true)
        }
    }
    
    // Vista quando l'articolo è bloccato
    var lockedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                
            Text("learn_view_locked_title".localized) // Contenuto Esclusivo/riservato
                .font(.system(.title3 ,design: .rounded))
                .fontWeight(.semibold)
            
            Text("learn_view_locked_body".localized)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)

            
            Button(action: {
                showPaywall = true
            }) {
                Text("learn_view_unlock_button".localized)
                    .font(.system(.title3 ,design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .padding(.horizontal)
                    .background(Color.pink)
                    .cornerRadius(16)
            }
            .buttonStyle(PremiumGlassPressStyle())
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(18)
    }
    
    private struct PremiumGlassPressStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(
                    x: configuration.isPressed ? 1.045 : 1,
                    y: configuration.isPressed ? 1.035 : 1,
                    anchor: .center
                )
                .animation(
                    configuration.isPressed
                    ? .timingCurve(0.18, 0.9, 0.25, 1, duration: 0.16)
                    : .timingCurve(0.3, 0.1, 0.25, 1, duration: 0.34),
                    value: configuration.isPressed
                )
        }
    }

    
    var difficultyString: String {
        switch article.difficulty {
        case .beginner: return "learn_view_beginner".localized
        case .intermediate: return "learn_view_intermediate".localized
        case .advanced: return "learn_view_advanced".localized
        }
    }
    
    // Icona difficoltà (adattata per sfondo scuro)
    var difficultyIcon: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i < article.difficulty.rawValue ? Color.pink : Color(.systemGroupedBackground))
                    .frame(width: 5, height: 5)
            }
        }
    }
    
    func markRead() {
        viewModel.markAsRead(article)
        isRead = true
        // Opzionale: chiudi pagina o mostra feedback
    }
}
