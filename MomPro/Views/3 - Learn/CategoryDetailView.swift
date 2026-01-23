//
//  CategoryDetailView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 21/01/26.
//

import SwiftUI

struct CategoryDetailView: View {
    let category: ArticleCategory
    var viewModel: LearnViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Recuperiamo gli articoli filtrati e ordinati dal VM
                let articles = viewModel.filterArticlesForDetail(category: category, searchText: searchText)
                
                if articles.isEmpty {
                    ContentUnavailableView {
                        Label("\("search_no_results".localized) \"\(searchText)\"", systemImage: "magnifyingglass")
                    } description: {
                        Text("search_check_spelling".localized)
                            .font(.body)
                            .padding(.top, 8)
                    }
                } else {
                    ForEach(articles) { article in
                        NavigationLink(value: article) {
                            CategoryListCard(article: article, viewModel: viewModel)
                        }
                        // Aggiungiamo il feedback tattile anche qui
                        .simultaneousGesture(TapGesture().onEnded {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        })
                    }
                }
            }
            .padding()
            .padding(.bottom, 20) // Aggiungiamo un po' di spazio extra in fondo per evitare che l'ultima card tocchi il bordo

        }
        .navigationTitle(category.rawValue.localized)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "\("learn_view_search_in".localized) \(category.rawValue.localized)"
        )
        .background(Color(uiColor: .systemGroupedBackground))
    }
}


// MARK: - CategoryListCard (Nuovo Stile Full Background)
struct CategoryListCard: View {
    let article: Article
    var viewModel: LearnViewModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 1. SFONDO (Immagine a tutta grandezza)
            Image(article.imageName)
                .resizable()
                .scaledToFill()
                // Altezza fissa per la lista: 200 è un buon compromesso tra impatto visivo e densità
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
                .saturation(viewModel.isLocked(article) ? 0 : 1) // B/N se bloccato
                .overlay {
                    // Gradiente per leggibilità testo
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                // Overlay scuro aggiuntivo se bloccato
                .overlay {
                    if viewModel.isLocked(article) {
                        Color.black.opacity(0.5)
                    }
                }
            
            // 2. TESTO E METADATI (In basso a sinistra)
            VStack(alignment: .leading, spacing: 6) {
                
                Text(article.title.localized)
                    .font(.system(.title3, design: .rounded)) // Un po' più grande di headline
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1) // Leggera ombra per stacco
                
                HStack {
                    
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
                    
                    Spacer()
                    
                    // Difficoltà
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
                //.font(.system(.caption, design: .rounded))
                //.fontWeight(.medium)
                //.foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal)
            .padding(.vertical)
            // Spazio interno dal bordo
            
            // 3. BADGES (In alto a destra)
            VStack {
                HStack {
                    Spacer()
                    
                    if viewModel.isRead(article) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .background(Color.white.clipShape(Circle()))
                            .padding(10)
                    } else if viewModel.isLocked(article) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(Color.black.opacity(0.6).clipShape(Circle()))
                            .padding(10)
                    } else if article.isPro {
                        Text("PRO")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(.pink)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(10)
                    }
                }
                Spacer()
            }
        }
        // Configurazione Card
        .frame(height: 200) // Deve corrispondere all'immagine
        .background(Color.gray.opacity(0.3))
        .cornerRadius(16)
        // Ombra esterna morbida per staccarla dallo sfondo grigio della lista
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .opacity(viewModel.isRead(article) ? 0.8 : 1.0)
    }
    
    var difficultyString: String {
        switch article.difficulty {
        case .beginner: return "learn_view_beginner".localized
        case .intermediate: return "learn_view_intermediate".localized
        case .advanced: return "learn_view_advanced".localized
        }
    }
    
    // Icona difficoltà (Adattata per sfondo scuro - Pallini Bianchi/Rosa)
    var difficultyIcon: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i < article.difficulty.rawValue ? Color.pink : Color.white.opacity(0.3))
                    .frame(width: 6, height: 6) // Leggermente più grandi
            }
        }
    }
}
