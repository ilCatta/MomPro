//
//  StatsView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI

struct StatsView: View {
    @State private var viewModel = StatsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // MARK: - 1. HEADER LIVELLO
                VStack(spacing: 10) {
                    Text("Il tuo Livello")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    // Mascotte (Stile Avatar Rotondo o Figura intera)
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.1))
                            .frame(width: 180, height: 180)
                        
                        Circle()
                            .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                            .frame(width: 160, height: 160)
                        
                        // Immagine Mascotte Livello
                        Image(viewModel.levelMascotImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                    }
                    
                    Text("Livello \(viewModel.currentLevel)")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.pink)
                    
                    Text(titleForLevel(viewModel.currentLevel))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                Divider()
                    .padding(.horizontal)
                
                // MARK: - 2. GRAFICO COSTANZA
                VStack(alignment: .leading, spacing: 15) {
                    Text("La tua costanza")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Legenda
                    HStack(spacing: 12) {
                        LegendItem(color: .green, text: "5/5")
                        LegendItem(color: .pink, text: "3-4")
                        LegendItem(color: .yellow, text: "1-2")
                        LegendItem(color: .gray.opacity(0.5), text: "0")
                    }
                    .padding(.horizontal)
                    .font(.caption)
                    
                    // Grafico Scrollabile
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(viewModel.historyData) { item in
                                VStack {
                                    // La Barra
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(viewModel.colorForCount(item.tasksCompleted))
                                        .frame(width: 12, height: 150 * viewModel.heightRatioForCount(item.tasksCompleted))
                                        // Animazione carina all'apparizione
                                        .animation(.spring, value: item.tasksCompleted)
                                    
                                    // Giorno (es. 18)
                                    Text(item.date.formatted(.dateTime.day()))
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        // Facciamo scrollare automaticamente alla fine (oggi)
                        .onAppear {
                            // In un'app reale useremmo ScrollViewReader per saltare alla fine
                        }
                    }
                    .frame(height: 180)
                }
                
                // MARK: - 3. BOOST SECTION
                // Mostra solo se non l'ha ancora usato
                if !viewModel.hasUsedBoost {
                    VStack(spacing: 15) {
                        Text("Vuoi salire subito di livello?")
                            .font(.headline)
                        
                        // ShareLink è nativo di iOS 16+
                        ShareLink(item: URL(string: "https://mumpro.app")!, message: Text("Sto imparando a gestire le finanze con MumPro! 10 minuti al giorno.")) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Condividi con un'amica (+1 Livello)")
                            }
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.indigo)
                            .cornerRadius(16)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            // Trucco: Aspettiamo un secondo (simulando che abbia condiviso) e diamo il premio
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation {
                                    viewModel.applyBoost()
                                }
                            }
                        })
                        
                        Text("Offerta valida una sola volta!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(20)
                    .padding()
                }
                
                Spacer(minLength: 50)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    // Helper Titolo Livello
    func titleForLevel(_ level: Int) -> String {
        switch level {
        case 1...3: return "Mamma in Pigiama"
        case 4...8: return "Mamma Organizzata"
        case 9...15: return "Mamma Boss"
        default: return "Super Mamma"
        }
    }
}

// Componente Legenda
struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    StatsView()
}
