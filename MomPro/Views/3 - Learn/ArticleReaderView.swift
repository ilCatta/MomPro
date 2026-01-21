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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Immagine Header
                Image(article.imageName) // Assicurati di avere un placeholder se manca
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipped()
                    .overlay(alignment: .bottomLeading) {
                        // Badge Pro o Categoria
                        HStack {
                            if article.isPro {
                                Text("PRO")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(6)
                                    .background(Color.black)
                                    .foregroundStyle(.yellow)
                                    .cornerRadius(4)
                            }
                            
                            Text(article.category.rawValue)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(6)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        }
                        .padding()
                    }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(article.title.localized)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label("\(article.readTimeMinutes) min lettura", systemImage: "clock")
                        Spacer()
                        Label(difficultyString, systemImage: "chart.bar")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    // CONTENUTO (Markdown supportato nativamente da Text in SwiftUI)
                    if viewModel.isLocked(article) {
                        lockedView
                    } else {
                        // Carica il contenuto dal file .md
                        Text(LocalizedStringKey(article.loadMarkdownContent()))
                            .font(.body)
                            .lineSpacing(6)
                    }
                }
                .padding()
                
                Spacer(minLength: 50)
            }
        }
        .ignoresSafeArea(edges: .top)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.isLocked(article) {
                    Button(action: {
                        markRead()
                    }) {
                        if viewModel.isRead(article) || isRead {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        } else {
                            Text("Segna Letto")
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
            
            Text("Contenuto riservato a MumPro")
                .font(.headline)
            
            Text("Sblocca tutti gli articoli e impara a gestire i tuoi soldi come una pro.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            
            Button(action: {
                showPaywall = true
            }) {
                Text("Sblocca Ora")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(16)
    }
    
    var difficultyString: String {
        switch article.difficulty {
        case .beginner: return "Facile"
        case .intermediate: return "Medio"
        case .advanced: return "Avanzato"
        }
    }
    
    func markRead() {
        viewModel.markAsRead(article)
        isRead = true
        // Opzionale: chiudi pagina o mostra feedback
    }
}
