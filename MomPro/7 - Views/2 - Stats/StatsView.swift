//
//  StatsView.swift
//  MomPro
//
//  Created by Andrea Cataldo on 18/01/26.
//

import SwiftUI
import Charts

struct StatsView: View {
    @State private var viewModel = StatsViewModel()
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // 1. STRETCHY HEADER
                    let headerHeight = geo.size.height * 0.38
                    GeometryReader { scrollGeo in
                        let minY = scrollGeo.frame(in: .global).minY
                        
                        Image(viewModel.dailyMascotImageName)
                            .resizable()
                            .scaledToFill()
                            .overlay(
                                LinearGradient(colors: [.clear, .black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: geo.size.width, height: headerHeight + (minY > 0 ? minY : 0), alignment: .top)
                            .clipped()
                            .offset(y: minY > 0 ? -minY : 0)
                    }
                    .frame(height: headerHeight)
                    
                    
                    // 2. LIVELLO
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Livello \(viewModel.currentLevel)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.pink)
                                    .textCase(.uppercase)
                                
                                Text(viewModel.levelTitle)
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.yellow)
                                .shadow(color: .orange.opacity(0.5), radius: 5)
                        }
                        
                        GeometryReader { barGeo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                
                                Capsule()
                                    .fill(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: barGeo.size.width * viewModel.levelProgress, height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        Text("Ancora \(viewModel.tasksToNextLevel) task al prossimo livello!")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    
                    // 3. BENTO GRID
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        BentoCard(icon: "checkmark.circle.fill", iconColor: .green, value: "\(viewModel.totalTasksCompleted)", label: "Task Completati")
                        BentoCard(icon: "hourglass", iconColor: .orange, value: viewModel.timeInvestedString, label: "Tempo Investito")
                        BentoCard(icon: "book.fill", iconColor: .blue, value: "\(viewModel.articlesRead)", label: "Guide Lette")
                        BentoCard(icon: "flame.fill", iconColor: .pink, value: "\(viewModel.currentStreak)", label: "Giorni di Fila", subLabel: "Record: \(viewModel.bestStreak)")
                    }
                    .padding(.horizontal)
                    
                    
                    // 4. GRAFICO COSTANZA (Nuova Grafica 7 Giorni)
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("La tua Costanza")
                                .font(.headline)
                            Spacer()
                            HStack(spacing: 12) {
                                Circle().fill(Color.indigo).frame(width: 6, height: 6)
                                Text("Fatti").font(.caption2).foregroundStyle(.secondary)
                                Circle().fill(Color.pink.opacity(0.5)).frame(width: 6, height: 6)
                                Text("Mancati").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        
                        // GRAFICO AGGIORNATO
                        ChartRedBlueView(data: viewModel.chartData)
                            .frame(height: 180) // Un po' più alto per dare respiro
                    }
                    .padding(20) // Più padding interno
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    
                    // 5. INVITA AMICO
                    if !viewModel.hasUsedBoost {
                        InviteFriendCard(viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    } else {
                        Spacer(minLength: 40)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

// MARK: - COMPONENTI UI

struct BentoCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    var subLabel: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .padding(8)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if let subLabel = subLabel {
                    Text(subLabel)
                        .font(.caption2)
                        .foregroundStyle(Color.gray.opacity(0.8))
                        .padding(.top, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

// MARK: - GRAFICO AGGIORNATO (Stile Reference Image)
// MARK: - GRAFICO AGGIORNATO (Linea Estesa ai Bordi)
struct ChartRedBlueView: View {
    let data: [StatsViewModel.DailyStat]
    
    // Configurazione visiva
    let barWidth: CGFloat = 26     // Larghezza barra
    let chartHeight: CGFloat = 130 // Altezza ESATTA area disegno
    let maxGoal: CGFloat = 8       // Scala Y
    
    var body: some View {
        VStack(spacing: 12) {
            
            // 1. AREA GRAFICA (Barre + Linea)
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    
                    // A. LE BARRE
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(data) { day in
                            
                            // Colori Dinamici (Oggi vs Passato)
                            let isToday = Calendar.current.isDateInToday(day.date)
                            
                            VStack(spacing: 0) {
                                Spacer()
                                // La "Pillola"
                                VStack(spacing: 0) {
                                    
                                    // ROSSO (Mancati)
                                    let missing = max(0, day.goal - day.completed)
                                    if missing > 0 {
                                        Rectangle()
                                            .fill(isToday ? Color.pink.opacity(0.8) : Color.pink.opacity(0.25))
                                            .frame(height: heightFor(value: missing, maxHeight: geo.size.height))
                                    }
                                    
                                    // BLU (Fatti)
                                    Rectangle()
                                        .fill(isToday ? Color.indigo : Color.indigo.opacity(0.4))
                                        .frame(height: heightFor(value: day.completed, maxHeight: geo.size.height))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(width: barWidth)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // B. LA LINEA (Estesa ai bordi)
                    Path { path in
                        let totalWidth = geo.size.width
                        let step = totalWidth / CGFloat(data.count)
                        
                        // Variabili per tracciare l'ultimo punto
                        var lastX: CGFloat = 0
                        var lastY: CGFloat = 0
                        
                        for (index, day) in data.enumerated() {
                            // Coordinate del CENTRO della barra corrente
                            let x = (step * CGFloat(index)) + (step / 2)
                            let blueH = heightFor(value: day.completed, maxHeight: geo.size.height)
                            let y = geo.size.height - blueH
                            
                            // Salviamo per l'estensione finale
                            lastX = x
                            lastY = y
                            
                            if index == 0 {
                                // PRIMO PUNTO: Inizia dal BORDO SINISTRO della barra
                                path.move(to: CGPoint(x: x - (barWidth / 2), y: y))
                                // Collega al centro (per iniziare la curva fluidamente)
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                // CURVE INTERMEDIE
                                let prevIndex = index - 1
                                let prevX = (step * CGFloat(prevIndex)) + (step / 2)
                                let prevDay = data[prevIndex]
                                let prevBlueH = heightFor(value: prevDay.completed, maxHeight: geo.size.height)
                                let prevY = geo.size.height - prevBlueH
                                
                                let control1 = CGPoint(x: prevX + (step / 2), y: prevY)
                                let control2 = CGPoint(x: x - (step / 2), y: y)
                                
                                path.addCurve(to: CGPoint(x: x, y: y), control1: control1, control2: control2)
                            }
                        }
                        
                        // ULTIMO PUNTO: Estendi fino al BORDO DESTRO dell'ultima barra
                        path.addLine(to: CGPoint(x: lastX + (barWidth / 2), y: lastY))
                    }
                    .stroke(Color.indigo, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .shadow(color: .indigo.opacity(0.3), radius: 4, x: 0, y: 4)
                }
            }
            .frame(height: chartHeight)
            
            // 2. ETICHETTE DATE
            HStack(spacing: 0) {
                ForEach(data) { day in
                    let isToday = Calendar.current.isDateInToday(day.date)
                    
                    Text(day.date.formatted(.dateTime.weekday(.abbreviated)))
                        .font(.system(size: 11, weight: isToday ? .bold : .medium))
                        .foregroundStyle(isToday ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // Helper altezza
    func heightFor(value: Int, maxHeight: CGFloat) -> CGFloat {
        let ratio = CGFloat(value) / maxGoal
        return min(maxHeight * ratio, maxHeight)
    }
}

struct InviteFriendCard: View {
    var viewModel: StatsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                    .font(.largeTitle)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Boost Amica")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Ottieni +5 Task completati subito!")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
            }
            
            Button(action: {
                withAnimation {
                    viewModel.applyBoost()
                }
            }) {
                HStack {
                    Text("Invita e Sali di Livello")
                    Image(systemName: "arrow.up.forward.circle.fill")
                }
                .fontWeight(.bold)
                .foregroundStyle(.indigo)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
    }
}
