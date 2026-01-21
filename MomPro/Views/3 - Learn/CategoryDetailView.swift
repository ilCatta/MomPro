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
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(articles) { article in
                        NavigationLink(value: article) {
                            // RIUTILIZZIAMO LA CARD ESISTENTE
                            // Ma magari in una versione "Row" più larga?
                            // Per coerenza usiamo la stessa ArticleCard ma la adattiamo alla larghezza
                            CategoryListCard(article: article, viewModel: viewModel)
                                        // Qui NON mettiamo width fissa, così si espande in orizzontale
                                        // Non serve neanche .frame(maxWidth: .infinity) perché VStack lo fa di default,
                                        // ma se vuoi essere sicuro:
                                        //.frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(category.rawValue.localized)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Cerca in \(category.rawValue.localized)"
        )
        .background(Color(uiColor: .systemGroupedBackground))
    }
}


// MARK: - CategoryListCard (La "Vecchia" ArticleCard Originale)
// Questa viene usata SOLO nella lista verticale di dettaglio
struct CategoryListCard: View {
    let article: Article
    var viewModel: LearnViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. IMMAGINE (Parte superiore)
            ZStack(alignment: .topTrailing) {
                Image(article.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140) // Altezza bilanciata per la lista
                    .frame(maxWidth: .infinity) // Occupa tutta la larghezza
                    .clipped()
                    .saturation(viewModel.isLocked(article) ? 0 : 1)
                
                // Overlay scuro se bloccato
                if viewModel.isLocked(article) {
                    Color.black.opacity(0.4)
                }
                
                // --- BADGES (Check, Lock, PRO) ---
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
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.yellow)
                        .foregroundStyle(.black)
                        .cornerRadius(4)
                        .padding(8)
                }
            }
            
            // 2. TESTO (Parte inferiore su sfondo chiaro)
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title.localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(viewModel.isLocked(article) ? .secondary : .primary)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("\(article.readTimeMinutes) min")
                    
                    Spacer()
                    
                    difficultyIcon
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemGroupedBackground)) // Sfondo della parte testuale
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .opacity(viewModel.isRead(article) ? 0.6 : 1.0)
    }
    
    // Icona difficoltà (versione classica colorata)
    var difficultyIcon: some View {
        HStack(spacing: 3) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i < article.difficulty.rawValue ? Color.pink : Color.gray.opacity(0.3))
                    .frame(width: 5, height: 5)
            }
        }
    }
}
