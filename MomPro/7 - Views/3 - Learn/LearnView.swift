//
//  GuidesView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

struct LearnView: View {
    @State private var viewModel = LearnViewModel()
        
    var body: some View {
        

            NavigationStack {
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // SEZIONI
                        ForEach(viewModel.categories.indices, id: \.self) { index in
                            let category = viewModel.categories[index]

                            VStack(alignment: .leading, spacing: 0) {
                                
                                // TITOLO SEZIONE (Ora Cliccabile)
                                NavigationLink(value: category) {
                                    HStack {
                                        Text(category.rawValue.localized)
                                            .font(.system(.title2 ,design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                            //.foregroundStyle(.primary) // Mantiene il colore nero/bianco
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        if isCategoryLocked(category) {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.secondary)
                                                .font(.footnote)
                                        } else {
                                            Text(viewModel.progressText(for: category))
                                                .font(.footnote)
                                                .fontWeight(.medium)
                                                .padding(.horizontal,8)
                                                .padding(.vertical,6)
                                                .background(Color(.secondarySystemGroupedBackground))
                                                .clipShape(Capsule())
                                                .foregroundColor(.secondary)

                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                // --- TAP FEEDBACK ---
                                .simultaneousGesture(TapGesture().onEnded {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                })
                                // ----------------------------------------
                                .padding(.bottom, 10)
                                
                                Text( categoryDescription(for: category))
                                        .font(.system(.callout, design: .default))
                                        .fontWeight(.regular)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal)
                                        .padding(.bottom, 28)
                                
                                // Lista Orizzontale Articoli
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(viewModel.articles(for: category)) { article in
                                            NavigationLink(value: article) {
                                                ArticleCard(article: article, viewModel: viewModel)
                                                    .frame(width: 160) // Forza larghezza fissa nella home
                                            }
                                            // --- TAP FEEDBACK ---
                                            .simultaneousGesture(TapGesture().onEnded {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                            })
                                            // ----------------------------------------
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.bottom, 28)
                            }
                            
                            // Divider SOLO se non è l’ultima
                            if index != viewModel.categories.indices.last {
                                Rectangle()
                                    .fill(Color(uiColor: .separator))
                                    .frame(height: 1)
                                    .padding(.horizontal)
                                    .padding(.bottom, 32)
                            }
                        }
                       
                    }
                    .padding(.top)
                    
                }
                .background(Color(uiColor: .systemGroupedBackground))
                //
                //
                // --- TOOLBAR ---
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 0) {
                            Text("tab_learn".localized)
                                .font(.system(.title ,design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            viewModel.pickSuggestedArticle()
                        }) {
                            HStack {
                                Text("learn_view_pickforme".localized)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            //.font(.subheadline)
                            //.fontWeight(.medium)
                        }
                    }
                }
              
                // NAVIGAZIONE 1: Dettaglio Categoria (La nuova pagina)
                .navigationDestination(for: ArticleCategory.self) { category in
                    CategoryDetailView(category: category, viewModel: viewModel)
                }
                // NAVIGAZIONE 2: Consigliami (Articolo Diretto)
                .navigationDestination(isPresented: $viewModel.showSuggestion) {
                    if let article = viewModel.suggestedArticle {
                        ArticleReaderView(article: article, viewModel: viewModel)
                    }
                }
                // NAVIGAZIONE 3: Click su Card (Articolo Diretto)
                .navigationDestination(for: Article.self) { article in
                    ArticleReaderView(article: article, viewModel: viewModel)
                }
            }
        
    }
    
    func isCategoryLocked(_ category: ArticleCategory) -> Bool {
        if category == .investing || category == .budgeting {
            return !StoreService.shared.isPro
        }
        return false
    }
    
    // Funzione per i testi descrittivi delle sezioni
    func categoryDescription(for category: ArticleCategory) -> String {
        switch category {
        case .savings:
            return "learn_savings_desc".localized
        case .eco:
            return "learn_eco_desc".localized
        case .family:
            return "learn_family_desc".localized
        case .budgeting:
            return "learn_budgeting_desc".localized
        case .investing:
            return "learn_investing_desc".localized
        }
    }
}



// MARK: - Article Card (Versione Poster Verticale Full Screen)
struct ArticleCard: View {
    let article: Article
    var viewModel: LearnViewModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) { // Tutto sovrapposto, allineato in basso a sinistra
            
            // 1. LIVELLO SFONDO (L'immagine occupa tutto)
            Image(article.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 240) // Altezza fissa verticale (Poster)
                .frame(maxWidth: 160) // Occupa tutta la larghezza disponibile
                .clipped() // Taglia l'immagine che sborda
                .saturation(viewModel.isLocked(article) ? 0 : 1) // B/N se bloccato
                .overlay {
                    // Gradiente nero per rendere leggibile il testo bianco
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.8)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                }
                // Se bloccato, scurisci tutto
                .overlay {
                    if viewModel.isLocked(article) {
                        Color.black.opacity(0.5)
                    }
                }
            
            // 2. LIVELLO TESTO (In basso, sopra l'immagine)
            VStack(alignment: .leading, spacing: 4) {
                // Nome categoria in piccolo (Opzionale, sta bene)
                Text(article.category.rawValue.localized)
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(.white.opacity(0.7))
                
                Text(article.title.localized)
                    .font(.system(.headline ,design: .rounded))
                    .fontWeight(.bold)
                    .lineLimit(3) // Fino a 3 righe per i titoli lunghi
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white) // Testo BIANCO
                    
                
                HStack {
                    Text("\(article.readTimeMinutes) \("learn_view_min".localized)")
                        .textCase(.lowercase)
                        .foregroundStyle(.white.opacity(0.9))
                    Spacer()
                    difficultyIcon
                }
                .font(.system(.caption2 ,design: .rounded))
                .padding(.top, 4)
            }
            .padding(12) // Spazio dal bordo
            .padding(.bottom, 6)
            
            // 3. LIVELLO BADGES (In alto a destra)
            VStack {
                HStack {
                    Spacer() // Spinge tutto a destra
                    
                    if viewModel.isRead(article) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .background(Color.white.clipShape(Circle()))
                            .padding(8)
                    } else if viewModel.isLocked(article) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.6).clipShape(Circle()))
                            .padding(8)
                    } else if article.isPro {
                        Text("PRO")
                            .font(.system(.caption2 ,design: .rounded))
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(.pink)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                            .padding(8)
                    }
                }
                Spacer() // Spinge tutto in alto
            }
        }
        // Configurazione finale della Card
        .frame(height: 240) // Forza l'altezza del contenitore
        .background(Color.gray.opacity(0.3)) // Colore mentre carica
        .cornerRadius(16) // Angoli arrotondati
        //.shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3) // Ombra esterna
        .opacity(viewModel.isRead(article) ? 0.8 : 1.0)
    }
    
    // Icona difficoltà (adattata per sfondo scuro)
    var difficultyIcon: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i < article.difficulty.rawValue ? Color.pink : Color.white.opacity(0.3))
                    .frame(width: 5, height: 5)
            }
        }
    }
}
